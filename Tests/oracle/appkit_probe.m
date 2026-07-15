/* Apple oracle for the NSToolbarItem coverage test.  Probes the visibility
   priority enum, the init defaults (identifier, label, paletteLabel, toolTip,
   tag, visibilityPriority, autovalidates, enabled, min/max size, image/view/
   menuFormRepresentation/target/action, allowsDuplicatesInToolbar) and the
   plain setter round-trips.  Portable so the same file runs under GNUstep for
   an A/B. */
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

    printf("ENUM vis Standard=%d Low=%d High=%d User=%d\n",
           (int)NSToolbarItemVisibilityPriorityStandard,
           (int)NSToolbarItemVisibilityPriorityLow,
           (int)NSToolbarItemVisibilityPriorityHigh,
           (int)NSToolbarItemVisibilityPriorityUser);

    NSToolbarItem *it =
        [[NSToolbarItem alloc] initWithItemIdentifier: @"probeItem"];
    printf("INIT ident=%s label=%s palette=%s tooltip=%s\n",
           [it itemIdentifier] == nil ? "nil" : [[it itemIdentifier] UTF8String],
           [it label] == nil ? "nil" : [[it label] UTF8String],
           [it paletteLabel] == nil ? "nil" : [[it paletteLabel] UTF8String],
           [it toolTip] == nil ? "nil" : [[it toolTip] UTF8String]);
    printf("INIT tag=%ld vis=%ld auto=%d enabled=%d\n",
           (long)[it tag], (long)[it visibilityPriority],
           [it autovalidates], [it isEnabled]);
    printf("INIT image=%s view=%s menuForm=%s target=%s action=%s\n",
           [it image] == nil ? "nil" : "set",
           [it view] == nil ? "nil" : "set",
           [it menuFormRepresentation] == nil ? "nil" : "set",
           [it target] == nil ? "nil" : "set",
           [it action] == NULL ? "NULL" : "set");
    printf("INIT minSize=%gx%g maxSize=%gx%g\n",
           [it minSize].width, [it minSize].height,
           [it maxSize].width, [it maxSize].height);
    if ([it respondsToSelector: @selector(allowsDuplicatesInToolbar)])
      printf("INIT allowsDup=%d\n", [it allowsDuplicatesInToolbar]);
    else
      printf("INIT allowsDup=unavailable\n");

    NSToolbarItem *st =
        [[NSToolbarItem alloc] initWithItemIdentifier: @"setItem"];
    [st setLabel: @"L"];
    [st setPaletteLabel: @"P"];
    [st setToolTip: @"T"];
    [st setTag: 42];
    [st setVisibilityPriority: NSToolbarItemVisibilityPriorityHigh];
    [st setAutovalidates: NO];
    [st setEnabled: NO];
    [st setMinSize: NSMakeSize(10, 20)];
    [st setMaxSize: NSMakeSize(30, 40)];
    printf("SET label=%s palette=%s tooltip=%s tag=%ld vis=%ld auto=%d enabled=%d\n",
           [[st label] UTF8String], [[st paletteLabel] UTF8String],
           [[st toolTip] UTF8String], (long)[st tag],
           (long)[st visibilityPriority], [st autovalidates], [st isEnabled]);
    printf("SET minSize=%gx%g maxSize=%gx%g\n",
           [st minSize].width, [st minSize].height,
           [st maxSize].width, [st maxSize].height);
  }
  return 0;
}
