/* Apple oracle for the NSTabViewItem coverage test.  Probes the NSTabState
   enum, the init defaults (identifier, label, view, initialFirstResponder,
   tabState, toolTip, viewController, and the deprecated color) and the plain
   setter round-trips.  Portable so the same file runs under GNUstep for an
   A/B. */
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

    printf("ENUM tabState Selected=%d Background=%d Pressed=%d\n",
           (int)NSSelectedTab, (int)NSBackgroundTab, (int)NSPressedTab);

    NSTabViewItem *it = [[NSTabViewItem alloc] initWithIdentifier: @"myId"];
    printf("INIT ident=%s label=%s view=%s ifr=%s tabState=%d toolTip=%s vc=%s\n",
           [it identifier] == nil ? "nil" : [[[it identifier] description] UTF8String],
           [it label] == nil ? "nil" : [[it label] UTF8String],
           [it view] == nil ? "nil" : "set",
           [it initialFirstResponder] == nil ? "nil" : "set",
           (int)[it tabState],
           [it toolTip] == nil ? "nil" : [[it toolTip] UTF8String],
           [it viewController] == nil ? "nil" : "set");
    if ([it respondsToSelector: @selector(color)])
      printf("INIT color=%s\n", [it color] == nil ? "nil" : "set");
    else
      printf("INIT color=unavailable\n");

    NSTabViewItem *st = [[NSTabViewItem alloc] initWithIdentifier: @"x"];
    [st setLabel: @"L"];
    [st setIdentifier: @"ID2"];
    [st setToolTip: @"T"];
    printf("SET label=%s ident=%s toolTip=%s\n",
           [st label] == nil ? "nil" : [[st label] UTF8String],
           [st identifier] == nil ? "nil" : [[[st identifier] description] UTF8String],
           [st toolTip] == nil ? "nil" : [[st toolTip] UTF8String]);
  }
  return 0;
}
