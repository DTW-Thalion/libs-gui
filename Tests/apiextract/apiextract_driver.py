"""Extract the public AppKit API from the macOS SDK headers.

Scope decision, and it is deliberate.

`only_dir` is AppKit.framework/Headers ALONE. It does not include the
Objective-C runtime's <objc/NSObject.h>, and there is no protocol_as_class
mapping, both of which the Foundation run needed.

The reason is that this audit measures libs-gui. NSObject's root API (alloc,
init, hash, isEqual:) is not AppKit API; it belongs to the runtime and to
libs-base, and pulling it in would credit or blame libs-gui for another
library's work. The probe still resolves inherited methods correctly without
it, because libgnustep-gui loads libgnustep-base and the runtime walks the
superclass chain on its own.

AppKit's own CATEGORIES on Foundation classes are a different matter and are
kept: -[NSString drawAtPoint:withAttributes:], -[NSObject awakeFromNib] and
-[NSBundle pathForImageResource:] are declared in AppKit headers, are AppKit
API, and libs-gui is the library that has to implement them. extract_headers
already files a category under the class it extends.
"""
import json
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import clang.cindex as ci

from sdk_extract import extract_headers


def sdk_path():
    return subprocess.run(["xcrun", "--show-sdk-path"], capture_output=True,
                          text=True, check=True).stdout.strip()


def main():
    out_path = sys.argv[1]
    sdk = sdk_path()
    appkit = os.path.join(sdk, "System/Library/Frameworks/AppKit.framework/Headers")
    print("SDK:      ", sdk)
    print("AppKit:   ", appkit)

    headers = sorted(h for h in os.listdir(appkit) if h.endswith(".h"))
    print("headers on disk:", len(headers))

    # One umbrella translation unit, so the SDK is parsed once rather than once
    # per header. AppKit.h reaches almost everything; whatever it misses is
    # picked up by the second pass below.
    umbrella = "/tmp/appkit_umbrella.m"
    with open(umbrella, "w") as f:
        f.write("#import <AppKit/AppKit.h>\n")
    classes = extract_headers([umbrella], sdk, [appkit])
    origins = {m["origin"] for e in classes.values() for m in e["methods"]}
    print(f"pass 1: {len(classes)} classes, "
          f"{sum(len(e['methods']) for e in classes.values())} methods, "
          f"{len(origins)} headers contributed")

    missed = [h for h in headers if h not in origins]
    print("headers contributing nothing to pass 1:", len(missed))
    for h in missed:
        print("   ", h)

    # Second pass: parse each unreached header on its own, so a header AppKit.h
    # does not import is still measured rather than silently dropped.
    if missed:
        extra = "/tmp/appkit_missed.m"
        with open(extra, "w") as f:
            for h in missed:
                f.write(f'#import <AppKit/{h}>\n')
        try:
            more = extract_headers([extra], sdk, [appkit])
        except Exception as exc:                       # a header may not stand alone
            print("pass 2 umbrella failed:", exc)
            more = {}
        added = 0
        for name, entry in more.items():
            tgt = classes.setdefault(name, {"superclass": None, "methods": []})
            if entry.get("superclass") and not tgt.get("superclass"):
                tgt["superclass"] = entry["superclass"]
            seen = {(m["selector"], m["kind"]) for m in tgt["methods"]}
            for m in entry["methods"]:
                if (m["selector"], m["kind"]) not in seen:
                    tgt["methods"].append(m)
                    seen.add((m["selector"], m["kind"]))
                    added += 1
        print(f"pass 2 added {added} methods")

    doc = {
        "tier": "apple",
        "source": f"macOS SDK AppKit.framework headers ({os.path.basename(sdk)})",
        "classes": classes,
    }
    with open(out_path, "w") as f:
        json.dump(doc, f, indent=1, sort_keys=True)

    total = sum(len(e["methods"]) for e in classes.values())
    print(f"\nTOTAL: {len(classes)} classes, {total} methods")
    print("clang:", ci.Config().lib is not None)
    for name in ("NSView", "NSWindow", "NSString", "NSObject", "NSBundle",
                 "NSCoder", "NSApplication", "NSCell"):
        if name in classes:
            print(f"  {name}: {len(classes[name]['methods'])}")
        else:
            print(f"  {name}: ABSENT from the extraction")


if __name__ == "__main__":
    main()
