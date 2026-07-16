/* Apple oracle for NSImageCell.  Probes the NSImageAlignment / NSImageFrameStyle
   / NSImageScaling enum values, the init defaults (imageAlignment, imageScaling,
   imageFrameStyle, refusesFirstResponder) and the three setters.  Portable so
   the same file runs under GNUstep for an A/B. */
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

    printf("ENUM alignCenter=%d alignTop=%d alignRight=%d frameNone=%d framePhoto=%d frameButton=%d scalePropDown=%d scaleNone=%d\n",
           (int)NSImageAlignCenter, (int)NSImageAlignTop, (int)NSImageAlignRight,
           (int)NSImageFrameNone, (int)NSImageFramePhoto, (int)NSImageFrameButton,
           (int)NSImageScaleProportionallyDown, (int)NSImageScaleNone);

    NSImageCell *c = [[NSImageCell alloc] init];
    printf("INIT alignment=%ld scaling=%ld frameStyle=%ld refuses=%d\n",
           (long)[c imageAlignment], (long)[c imageScaling],
           (long)[c imageFrameStyle], [c refusesFirstResponder]);

    [c setImageAlignment: NSImageAlignTop];
    [c setImageScaling: NSImageScaleNone];
    [c setImageFrameStyle: NSImageFramePhoto];
    printf("SET alignment=%ld scaling=%ld frameStyle=%ld\n",
           (long)[c imageAlignment], (long)[c imageScaling],
           (long)[c imageFrameStyle]);
  }
  return 0;
}
