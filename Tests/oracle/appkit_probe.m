/* Apple oracle for NSMenuItemCell.  Probes init defaults (needsSizing,
   highlighted, needsDisplay), setMenuItem: (identity, needsSizing after, tag,
   enabled follows the item), and the highlighted / needsSizing / needsDisplay
   setters.  Portable so the same file runs under GNUstep for an A/B. */
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

    NSMenuItemCell *c = [[NSMenuItemCell alloc] init];
    printf("INIT needsSizing=%d highlighted=%d needsDisplay=%d\n",
           [c needsSizing], [c isHighlighted], [c needsDisplay]);

    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle: @"Item"
                                                  action: NULL
                                           keyEquivalent: @""];
    [item setTag: 42];
    [item setEnabled: NO];
    [c setMenuItem: item];
    printf("SETITEM same=%d needsSizingAfter=%d tag=%ld enabled=%d\n",
           [c menuItem] == item, [c needsSizing], (long)[c tag],
           [c isEnabled]);

    [c setHighlighted: YES];
    printf("SETHIGH highlighted=%d\n", [c isHighlighted]);

    [c setNeedsSizing: NO];
    printf("SETSIZING needsSizing=%d\n", [c needsSizing]);

    [c setNeedsDisplay: YES];
    printf("SETDISPLAY needsDisplay=%d\n", [c needsDisplay]);
  }
  return 0;
}
