/* Apple oracle: the exact NSTrackingAreaOptions constant values, and the
   userInfo/owner/rect/copy behaviour of a valid tracking area. */
#import <Cocoa/Cocoa.h>

int
main(int argc, const char **argv)
{
  @autoreleasepool
  {
    NSLog(@"OPT EnteredExited=0x%lX MouseMoved=0x%lX CursorUpdate=0x%lX",
          (unsigned long)NSTrackingMouseEnteredAndExited,
          (unsigned long)NSTrackingMouseMoved,
          (unsigned long)NSTrackingCursorUpdate);
    NSLog(@"OPT ActiveWhenFirstResponder=0x%lX ActiveInKeyWindow=0x%lX "
          @"ActiveInActiveApp=0x%lX ActiveAlways=0x%lX",
          (unsigned long)NSTrackingActiveWhenFirstResponder,
          (unsigned long)NSTrackingActiveInKeyWindow,
          (unsigned long)NSTrackingActiveInActiveApp,
          (unsigned long)NSTrackingActiveAlways);
    NSLog(@"OPT AssumeInside=0x%lX InVisibleRect=0x%lX EnabledDuringMouseDrag=0x%lX",
          (unsigned long)NSTrackingAssumeInside,
          (unsigned long)NSTrackingInVisibleRect,
          (unsigned long)NSTrackingEnabledDuringMouseDrag);

    NSDictionary *info = @{@"k": @"v"};
    id owner = [[NSObject alloc] init];
    NSRect r = NSMakeRect(10, 20, 30, 40);
    NSTrackingAreaOptions opts =
      NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways;

    NSTrackingArea *a = [[NSTrackingArea alloc] initWithRect: r
        options: opts owner: owner userInfo: info];
    NSTrackingArea *c = [a copy];
    NSLog(@"TA copy rect=%@ options=%lu ownerSame=%d userInfoV=%@ distinct=%d",
          NSStringFromRect([c rect]), (unsigned long)[c options],
          [c owner] == owner, [[c userInfo] objectForKey: @"k"], c != a);

    NSTrackingArea *b = [[NSTrackingArea alloc] initWithRect: r
        options: NSTrackingMouseMoved | NSTrackingActiveAlways owner: owner
        userInfo: nil];
    NSLog(@"TA nilInfo userInfo=%@", [b userInfo] == nil ? @"nil" : @"nonnil");
  }
  return 0;
}
