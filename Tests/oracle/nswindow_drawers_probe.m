#import <Cocoa/Cocoa.h>

int
main(int argc, const char *argv[])
{
  @autoreleasepool
    {
      NSApplication *app = [NSApplication sharedApplication];
      (void) app;
      NSWindow *w = [[NSWindow alloc]
        initWithContentRect: NSMakeRect(0, 0, 300, 300)
                  styleMask: NSWindowStyleMaskTitled
                    backing: NSBackingStoreBuffered
                      defer: NO];

      NSArray *d0 = [w drawers];
      printf("default drawers -> %s, count=%lu\n",
        d0 == nil ? "nil" : "non-nil", (unsigned long)[d0 count]);

      NSDrawer *dr = [[NSDrawer alloc]
        initWithContentSize: NSMakeSize(100, 200) preferredEdge: NSMinXEdge];
      [dr setParentWindow: w];

      NSArray *d1 = [w drawers];
      printf("after setParentWindow: count=%lu contains=%s\n",
        (unsigned long)[d1 count], [d1 containsObject: dr] ? "YES" : "NO");
      printf("drawer.parentWindow == w -> %s\n", [dr parentWindow] == w ? "YES" : "NO");

      NSDrawer *dr2 = [[NSDrawer alloc]
        initWithContentSize: NSMakeSize(100, 200) preferredEdge: NSMaxXEdge];
      [dr2 setParentWindow: w];
      printf("two drawers -> count=%lu\n", (unsigned long)[[w drawers] count]);

      [dr2 setParentWindow: nil];
      printf("after one setParentWindow:nil -> count=%lu\n",
        (unsigned long)[[w drawers] count]);
    }
  return 0;
}
