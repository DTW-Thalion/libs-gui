"""Dump the public Foundation API of the installed macOS SDK.

Scope is Foundation's headers plus the Objective-C runtime's, because the root
class and the NSObject protocol -- alloc, init, dealloc, copy, isEqual:, hash,
description -- are declared in <objc/NSObject.h>, not inside the framework.
Leaving them out under-measures every class in the audit.

Temporary: added to run on the macOS runner and removed again afterwards.
"""
import glob
import os
import subprocess
import sys

from sdk_extract import extract_headers
from schema import save_reference

sdk, framework_headers, out_path = sys.argv[1], sys.argv[2], sys.argv[3]
runtime_headers = os.path.join(sdk, "usr", "include", "objc")

version = subprocess.run(["xcrun", "--show-sdk-version"],
                         capture_output=True, text=True).stdout.strip()

headers = sorted(glob.glob(framework_headers + "/*.h"))
runtime = [p for p in (os.path.join(runtime_headers, "NSObject.h"),
                       os.path.join(runtime_headers, "NSObjCRuntime.h"))
           if os.path.exists(p)]
print(f"runtime headers found: {runtime}", file=sys.stderr)

classes = extract_headers(headers + runtime, sdk_path=sdk,
                          only_dir=[framework_headers, runtime_headers],
                          protocol_as_class={"NSObject": "NSObject"})
save_reference(out_path, "apple", f"MacOSX{version}.sdk", classes)

methods = sum(len(c["methods"]) for c in classes.values())
nsobject = len(classes.get("NSObject", {"methods": []})["methods"])
print(f"{len(classes)} classes, {methods} methods, NSObject has {nsobject}",
      file=sys.stderr)
