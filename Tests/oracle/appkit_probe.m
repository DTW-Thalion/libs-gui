/* Apple oracle for NSPDFInfo.  Probes the NSPaperOrientation enum, the init
   defaults (URL, fileExtensionHidden, tagNames, paperSize, orientation,
   attributes), the setters, and whether -copy returns a non-nil object.
   Portable so the same file runs under GNUstep for an A/B. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    printf("ENUM portrait=%ld landscape=%ld\n",
           (long)NSPaperOrientationPortrait, (long)NSPaperOrientationLandscape);

    NSPDFInfo *info = [[NSPDFInfo alloc] init];

    NSSize p = [info paperSize];
    printf("INIT url=%s hidden=%d tagNames=%s paperW=%g paperH=%g orientation=%ld attributes=%s\n",
           [info URL] == nil ? "nil" : "set",
           [info isFileExtensionHidden],
           [info tagNames] == nil ? "nil"
             : [[NSString stringWithFormat: @"count-%lu",
                          (unsigned long)[[info tagNames] count]] UTF8String],
           p.width, p.height,
           (long)[info orientation],
           [info attributes] == nil ? "nil" : "set");

    [info setFileExtensionHidden: YES];
    [info setOrientation: NSPaperOrientationLandscape];
    [info setPaperSize: NSMakeSize(612, 792)];
    NSSize p2 = [info paperSize];
    printf("SET hidden=%d orientation=%ld paperW=%g paperH=%g\n",
           [info isFileExtensionHidden], (long)[info orientation],
           p2.width, p2.height);

    printf("COPY nonNil=%d\n", [info copy] != nil);
  }
  return 0;
}
