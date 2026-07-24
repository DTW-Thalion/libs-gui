#import <Cocoa/Cocoa.h>

@interface ProbeCell : NSCell
{
@public
  BOOL drew;
  NSRect drewFrame;
}
@end

@implementation ProbeCell
- (void) drawWithFrame: (NSRect)f inView: (NSView *)v
{
  drew = YES;
  drewFrame = f;
}
@end

int
main(int argc, const char *argv[])
{
  @autoreleasepool
    {
      ProbeCell *c = [[ProbeCell alloc] initTextCell: @"hello"];
      NSRect ef = NSMakeRect(3, 5, 40, 18);

      c->drew = NO;
      [c drawWithExpansionFrame: ef inView: nil];
      printf("drawWithExpansionFrame: called drawWithFrame:inView: -> %s\n",
        c->drew ? "YES" : "NO");
      printf("drawWithExpansionFrame: passed frame -> (%g %g %g %g) [expansion is (3 5 40 18)]\n",
        c->drewFrame.origin.x, c->drewFrame.origin.y,
        c->drewFrame.size.width, c->drewFrame.size.height);
    }
  return 0;
}
