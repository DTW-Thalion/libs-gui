/* Oracle: does -hasHorizontalScroller report the configured value or the
   autohide visibility, and does autohide respect the configured flags? */
#import <Cocoa/Cocoa.h>

int
main(void)
{
  @autoreleasepool
    {
      [NSApplication sharedApplication];

      NSScrollView *sv = [[NSScrollView alloc]
        initWithFrame: NSMakeRect(0, 0, 100, 100)];
      [sv setHasHorizontalScroller: YES];
      printf("setHasHorizontalScroller:YES -> hasHorizontalScroller=%d\n",
             [sv hasHorizontalScroller]);
      [sv setHasHorizontalScroller: NO];
      printf("setHasHorizontalScroller:NO -> hasHorizontalScroller=%d\n",
             [sv hasHorizontalScroller]);

      /* configured YES, autohide on, content that does not need horizontal */
      [sv setHasHorizontalScroller: YES];
      [sv setHasVerticalScroller: YES];
      [sv setAutohidesScrollers: YES];
      {
        NSView *doc = [[NSView alloc]
          initWithFrame: NSMakeRect(0, 0, 50, 500)];
        [sv setDocumentView: doc];
        [sv tile];
      }
      printf("narrow+tall (autohide): hasHoriz=%d hasVert=%d horizHidden=%d\n",
             [sv hasHorizontalScroller], [sv hasVerticalScroller],
             [[sv horizontalScroller] isHidden]);

      /* configured NO horizontal, autohide on, wide+tall content */
      {
        NSScrollView *sv2 = [[NSScrollView alloc]
          initWithFrame: NSMakeRect(0, 0, 100, 100)];
        NSView *doc2 = [[NSView alloc]
          initWithFrame: NSMakeRect(0, 0, 500, 500)];
        [sv2 setHasVerticalScroller: YES];
        [sv2 setHasHorizontalScroller: NO];
        [sv2 setAutohidesScrollers: YES];
        [sv2 setDocumentView: doc2];
        [sv2 tile];
        printf("hasHoriz=NO + wide+tall (autohide): hasHoriz=%d hasVert=%d\n",
               [sv2 hasHorizontalScroller], [sv2 hasVerticalScroller]);
      }
    }
  return 0;
}
