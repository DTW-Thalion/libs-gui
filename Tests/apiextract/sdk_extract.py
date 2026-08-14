"""Read public Objective-C API out of headers using clang's own parser."""
import os
import clang.cindex as ci

CURSOR_CLASS = ci.CursorKind.OBJC_INTERFACE_DECL
CURSOR_CATEGORY = ci.CursorKind.OBJC_CATEGORY_DECL
CURSOR_CLASS_METHOD = ci.CursorKind.OBJC_CLASS_METHOD_DECL
CURSOR_INSTANCE_METHOD = ci.CursorKind.OBJC_INSTANCE_METHOD_DECL
CURSOR_PROPERTY = ci.CursorKind.OBJC_PROPERTY_DECL
CURSOR_PROTOCOL = ci.CursorKind.OBJC_PROTOCOL_DECL
CURSOR_SUPERCLASS = ci.CursorKind.OBJC_SUPER_CLASS_REF
CURSOR_CLASS_REF = ci.CursorKind.OBJC_CLASS_REF

# The pip `libclang` bindings expose no get_platform_availability(), so
# availability is read from the cursor's availability enum plus its tokens,
# which is where Apple's API_AVAILABLE / NS_AVAILABLE_MAC macros live.
_AVAILABLE_MACROS = ("API_AVAILABLE", "NS_AVAILABLE_MAC", "NS_AVAILABLE",
                     "NS_CLASS_AVAILABLE_MAC", "NS_CLASS_AVAILABLE")
_DEPRECATED_MACROS = ("API_DEPRECATED", "NS_DEPRECATED_MAC", "NS_DEPRECATED",
                      "NS_CLASS_DEPRECATED_MAC", "DEPRECATED_ATTRIBUTE",
                      "deprecated")


def _macos_version(tokens, start):
    """Read a macos version out of the tokens following an availability macro.

    Handles both `macos(10.15)` and the older `10_15` spelling.
    """
    window = tokens[start:start + 14]
    for i, tok in enumerate(window):
        if tok.lower() in ("macos", "macosx") and i + 2 < len(window):
            digits = [t for t in window[i + 1:i + 6] if t.replace(".", "").isdigit()]
            if digits:
                return digits[0]
        if "_" in tok and tok.replace("_", "").isdigit():
            return tok.replace("_", ".", 1).split(".", 2)[0] + "." + \
                   tok.replace("_", ".", 1).split(".", 2)[1]
    return None


def _availability(cursor):
    """Return (introduced, deprecated) as strings, or None where absent."""
    introduced = deprecated = None
    try:
        tokens = [t.spelling for t in cursor.get_tokens()]
    except Exception:
        tokens = []

    for i, tok in enumerate(tokens):
        if tok in _AVAILABLE_MACROS and introduced is None:
            introduced = _macos_version(tokens, i) or introduced
        if tok in _DEPRECATED_MACROS and deprecated is None:
            deprecated = _macos_version(tokens, i) or "unspecified"

    if deprecated is None:
        kind = str(getattr(cursor, "availability", "")).upper()
        if "DEPRECATED" in kind:
            deprecated = "unspecified"
    return introduced, deprecated


def _method(cursor):
    introduced, deprecated = _availability(cursor)
    kind = "class" if cursor.kind == CURSOR_CLASS_METHOD else "instance"
    return {
        "selector": cursor.spelling,
        "kind": kind,
        "introduced": introduced,
        "deprecated": deprecated,
        "origin": os.path.basename(str(cursor.location.file)),
    }


def _is_class_property(cursor):
    """True for `@property (class, ...) ...`.

    A class property's accessor is a CLASS method. Recording it as an instance
    method invents a method no Foundation can have, and libs-base then looks
    like it is missing NSBundle.mainBundle and every NSUnit constant.
    """
    toks = [t.spelling for t in cursor.get_tokens()]
    if "(" not in toks:
        return False
    start = toks.index("(")
    try:
        end = toks.index(")", start)
    except ValueError:
        return False
    return "class" in toks[start:end]


def _attribute_value(toks, keyword):
    """The NAME in `@property (getter=NAME)`, or None."""
    for i, t in enumerate(toks):
        if t == keyword and i + 2 < len(toks) and toks[i + 1] == "=":
            return toks[i + 2]
    return None


def _property_methods(cursor):
    """A property is API as its accessors, which is what the runtime sees.

    `getter=` and `setter=` rename those accessors, and the renamed form is the
    real selector: `@property (getter=isRemote) BOOL remote` is answered by
    -isRemote, and nothing responds to -remote. Taking the property's own name
    invents a method and reports the class as missing it.
    """
    introduced, deprecated = _availability(cursor)
    name = cursor.spelling
    origin = os.path.basename(str(cursor.location.file))
    kind = "class" if _is_class_property(cursor) else "instance"
    toks = [t.spelling for t in cursor.get_tokens()]

    getter = _attribute_value(toks, "getter") or name
    out = [{"selector": getter, "kind": kind, "introduced": introduced,
            "deprecated": deprecated, "origin": origin}]
    if "readonly" not in set(toks):
        setter = _attribute_value(toks, "setter")
        if setter is None:
            setter = "set" + name[0].upper() + name[1:] + ":"
        elif not setter.endswith(":"):
            setter += ":"
        out.append({"selector": setter, "kind": kind, "introduced": introduced,
                    "deprecated": deprecated, "origin": origin})
    return out


def _kind(cursor):
    """Cursor kind, or None when these bindings do not recognise it.

    A newer libclang than the bindings emits kind ids their table lacks, and
    `cursor.kind` then raises instead of returning something inert. Xcode 26.6
    does exactly this, so every kind read goes through here.
    """
    try:
        return cursor.kind
    except ValueError:
        return None


def _in_scope(cursor, only_dirs):
    loc = cursor.location.file
    if loc is None:
        return False
    path = os.path.abspath(str(loc))
    return any(path.startswith(d) for d in only_dirs)


def extract_headers(header_paths, sdk_path, only_dir, protocol_as_class=None,
                    extra_args=None):
    """Parse the given headers, returning the schema's `classes` mapping.

    `only_dir` is a directory or a list of them; only declarations located
    under one of them are kept, so other frameworks' categories on Foundation
    classes stay out. It takes a list because the root class is declared in the
    Objective-C runtime headers, outside Foundation.framework.

    `protocol_as_class` maps a protocol name to the class whose API it forms.
    Apple declares isEqual:, hash and description on `@protocol NSObject`
    rather than on the class, and every object answers them, so they belong to
    NSObject for the purpose of this audit.
    """
    # No -fobjc-arc: it demands a runtime with weak-reference support and makes
    # the parse fail outright on Linux. Declarations parse the same without it.
    args = ["-x", "objective-c"]
    if sdk_path:
        args += ["-isysroot", sdk_path]
    # The pip `libclang` wheel ships no builtin headers, so stdarg.h and
    # friends are not found, the header that includes them fails, and every
    # declaration after it is silently dropped. Passing the real toolchain's
    # resource directory is what makes the parse complete; without it
    # NSSpellServer disappeared from an AppKit run that otherwise looked fine.
    args += list(extra_args or [])
    if isinstance(only_dir, str):
        only_dir = [only_dir]
    only_dirs = [os.path.abspath(d) for d in only_dir]
    protocol_as_class = protocol_as_class or {}
    index = ci.Index.create()
    classes = {}

    for path in header_paths:
        tu = index.parse(path, args=args,
                         options=ci.TranslationUnit.PARSE_SKIP_FUNCTION_BODIES)
        for cursor in tu.cursor.walk_preorder():
            kind = _kind(cursor)
            if kind not in (CURSOR_CLASS, CURSOR_CATEGORY, CURSOR_PROTOCOL):
                continue
            if not _in_scope(cursor, only_dirs):
                continue
            if kind == CURSOR_PROTOCOL:
                mapped = protocol_as_class.get(cursor.spelling)
                if mapped is None:
                    continue
                name, superclass = mapped, None
            elif kind == CURSOR_CLASS:
                name = cursor.spelling
                superclass = next(
                    (c.spelling for c in cursor.get_children()
                     if _kind(c) == CURSOR_SUPERCLASS), None)
            else:
                # A category names its class with an OBJC_CLASS_REF child; the
                # category's own spelling is the category name, not the class.
                ref = next((c.spelling for c in cursor.get_children()
                            if _kind(c) == CURSOR_CLASS_REF), None)
                if ref is None:
                    continue
                name, superclass = ref, None
            entry = classes.setdefault(name, {"superclass": None, "methods": []})
            if superclass:
                entry["superclass"] = superclass
            seen = {(m["selector"], m["kind"]) for m in entry["methods"]}
            for child in cursor.get_children():
                child_kind = _kind(child)
                if child_kind in (CURSOR_CLASS_METHOD, CURSOR_INSTANCE_METHOD):
                    found = [_method(child)]
                elif child_kind == CURSOR_PROPERTY:
                    found = _property_methods(child)
                else:
                    continue
                for m in found:
                    if (m["selector"], m["kind"]) not in seen:
                        entry["methods"].append(m)
                        seen.add((m["selector"], m["kind"]))
    return classes
