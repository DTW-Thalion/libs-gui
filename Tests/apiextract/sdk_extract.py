"""Read public Objective-C API out of headers using clang's own parser."""
import os
import clang.cindex as ci

CURSOR_CLASS = ci.CursorKind.OBJC_INTERFACE_DECL
CURSOR_CATEGORY = ci.CursorKind.OBJC_CATEGORY_DECL
CURSOR_CLASS_METHOD = ci.CursorKind.OBJC_CLASS_METHOD_DECL
CURSOR_INSTANCE_METHOD = ci.CursorKind.OBJC_INSTANCE_METHOD_DECL
CURSOR_PROPERTY = ci.CursorKind.OBJC_PROPERTY_DECL
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


def _property_methods(cursor):
    """A property is API as its accessors, which is what the runtime sees."""
    introduced, deprecated = _availability(cursor)
    name = cursor.spelling
    origin = os.path.basename(str(cursor.location.file))
    out = [{"selector": name, "kind": "instance", "introduced": introduced,
            "deprecated": deprecated, "origin": origin}]
    tokens = {t.spelling for t in cursor.get_tokens()}
    if "readonly" not in tokens:
        setter = "set" + name[0].upper() + name[1:] + ":"
        out.append({"selector": setter, "kind": "instance", "introduced": introduced,
                    "deprecated": deprecated, "origin": origin})
    return out


def _in_scope(cursor, only_dir):
    loc = cursor.location.file
    if loc is None:
        return False
    return os.path.abspath(str(loc)).startswith(os.path.abspath(only_dir))


def extract_headers(header_paths, sdk_path, only_dir):
    """Parse the given headers, returning the schema's `classes` mapping.

    Only declarations whose location is under `only_dir` are kept, so that
    other frameworks' categories on Foundation classes are excluded.
    """
    # No -fobjc-arc: it demands a runtime with weak-reference support and makes
    # the parse fail outright on Linux. Declarations parse the same without it.
    args = ["-x", "objective-c"]
    if sdk_path:
        args += ["-isysroot", sdk_path]
    index = ci.Index.create()
    classes = {}

    for path in header_paths:
        tu = index.parse(path, args=args,
                         options=ci.TranslationUnit.PARSE_SKIP_FUNCTION_BODIES)
        for cursor in tu.cursor.walk_preorder():
            if cursor.kind not in (CURSOR_CLASS, CURSOR_CATEGORY):
                continue
            if not _in_scope(cursor, only_dir):
                continue
            if cursor.kind == CURSOR_CLASS:
                name = cursor.spelling
                superclass = next(
                    (c.spelling for c in cursor.get_children()
                     if c.kind == CURSOR_SUPERCLASS), None)
            else:
                # A category names its class with an OBJC_CLASS_REF child; the
                # category's own spelling is the category name, not the class.
                ref = next((c.spelling for c in cursor.get_children()
                            if c.kind == CURSOR_CLASS_REF), None)
                if ref is None:
                    continue
                name, superclass = ref, None
            entry = classes.setdefault(name, {"superclass": None, "methods": []})
            if superclass:
                entry["superclass"] = superclass
            seen = {(m["selector"], m["kind"]) for m in entry["methods"]}
            for child in cursor.get_children():
                if child.kind in (CURSOR_CLASS_METHOD, CURSOR_INSTANCE_METHOD):
                    found = [_method(child)]
                elif child.kind == CURSOR_PROPERTY:
                    found = _property_methods(child)
                else:
                    continue
                for m in found:
                    if (m["selector"], m["kind"]) not in seen:
                        entry["methods"].append(m)
                        seen.add((m["selector"], m["kind"]))
    return classes
