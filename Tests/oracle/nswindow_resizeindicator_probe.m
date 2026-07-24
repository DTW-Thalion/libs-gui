#import <Cocoa/Cocoa.h>

int
main(int argc, const char *argv[])
{
  @autoreleasepool
    {
      NSApplication *app = [NSApplication sharedApplication];
      (void) app;

      NSWindow *rw = [[NSWindow alloc]
        initWithContentRect: NSMakeRect(0, 0, 200, 200)
                  styleMask: NSWindowStyleMaskTitled | NSWindowStyleMaskResizable
                    backing: NSBackingStoreBuffered
                      defer: NO];
      printf("resizable default -> %d\n", [rw showsResizeIndicator]);
      [rw setShowsResizeIndicator: NO];
      printf("resizable after set NO -> %d\n", [rw showsResizeIndicator]);
      [rw setShowsResizeIndicator: YES];
      printf("resizable after set YES -> %d\n", [rw showsResizeIndicator]);

      NSWindow *nw = [[NSWindow alloc]
        initWithContentRect: NSMakeRect(0, 0, 200, 200)
                  styleMask: NSWindowStyleMaskTitled
                    backing: NSBackingStoreBuffered
                      defer: NO];
      printf("non-resizable default -> %d\n", [nw showsResizeIndicator]);
      [nw setShowsResizeIndicator: YES];
      printf("non-resizable after set YES -> %d\n", [nw showsResizeIndicator]);
      [nw setShowsResizeIndicator: NO];
      printf("non-resizable after set NO -> %d\n", [nw showsResizeIndicator]);
    }
  return 0;
}
