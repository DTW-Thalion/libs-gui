#import <Cocoa/Cocoa.h>

static void dump(NSString *label, NSRect r)
{
  printf("%-42s {%g, %g, %g, %g}\n", [label UTF8String],
         r.origin.x, r.origin.y, r.size.width, r.size.height);
}

int
main(int argc, const char *argv[])
{
  @autoreleasepool
    {
      [NSApplication sharedApplication];

      // 1. windowless, no superview
      NSView *v = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 100, 80)];
      dump(@"windowless, no superview", [v visibleRect]);

      // 2. windowless, inside a windowless superview
      NSView *sup = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 200, 200)];
      NSView *child = [[NSView alloc] initWithFrame: NSMakeRect(10, 10, 50, 50)];
      [sup addSubview: child];
      dump(@"windowless child of windowless super", [child visibleRect]);
      dump(@"windowless super itself", [sup visibleRect]);

      // 3. hidden, windowless
      NSView *h = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 100, 80)];
      [h setHidden: YES];
      dump(@"windowless + hidden", [h visibleRect]);

      // 4. installed in a window, fully visible
      NSWindow *w = [[NSWindow alloc]
        initWithContentRect: NSMakeRect(0, 0, 300, 200)
                  styleMask: NSWindowStyleMaskBorderless
                    backing: NSBackingStoreBuffered
                      defer: NO];
      NSView *inWin = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 120, 90)];
      [[w contentView] addSubview: inWin];
      dump(@"in window, fully visible (120x90)", [inWin visibleRect]);

      // 5. in window but hidden
      [inWin setHidden: YES];
      dump(@"in window, hidden", [inWin visibleRect]);
      [inWin setHidden: NO];

      // 6. in window, partly outside the contentView (clipped)
      NSView *edge = [[NSView alloc] initWithFrame: NSMakeRect(250, 150, 100, 100)];
      [[w contentView] addSubview: edge];
      dump(@"in window, partly clipped by content", [edge visibleRect]);
    }
  return 0;
}
