"""Dump the public Foundation API of the installed macOS SDK.

Temporary: added to run on the macOS runner and removed again afterwards.
"""
import glob
import subprocess
import sys

from sdk_extract import extract_headers
from schema import save_reference

sdk, framework_headers, out_path = sys.argv[1], sys.argv[2], sys.argv[3]
version = subprocess.run(["xcrun", "--show-sdk-version"],
                         capture_output=True, text=True).stdout.strip()
headers = sorted(glob.glob(framework_headers + "/*.h"))
classes = extract_headers(headers, sdk_path=sdk, only_dir=framework_headers)
save_reference(out_path, "apple", f"MacOSX{version}.sdk", classes)
methods = sum(len(c["methods"]) for c in classes.values())
print(f"{len(classes)} classes, {methods} methods, from {len(headers)} headers",
      file=sys.stderr)
