/* Apple oracle: NSCell focusRingMaskBoundsForFrame: and expansionFrameWithFrame:
   defaults, and whether they depend on the focus ring type. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

static void dumpRing(const char *label, NSCell *c, NSRect f)
{
  NSRect r = [c focusRingMaskBoundsForFrame: f inView: nil];
  printf("%s focusRingMaskBounds = (%g,%g,%g,%g)\n",
    label, r.origin.x, r.origin.y, r.size.width, r.size.height);
}

int main(void)
{
  @autoreleasepool {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    NSRect f = NSMakeRect(10, 20, 30, 40);
    NSCell *cell = [[NSCell alloc] initTextCell: @"x"];

    printf("default focusRingType = %ld\n", (long)[cell focusRingType]);
    dumpRing("default", cell, f);

    [cell setFocusRingType: NSFocusRingTypeNone];
    dumpRing("None", cell, f);

    [cell setFocusRingType: NSFocusRingTypeExterior];
    dumpRing("Exterior", cell, f);

    NSRect e = [cell expansionFrameWithFrame: f inView: nil];
    printf("expansionFrame = (%g,%g,%g,%g)\n",
      e.origin.x, e.origin.y, e.size.width, e.size.height);
  }
  return 0;
}
