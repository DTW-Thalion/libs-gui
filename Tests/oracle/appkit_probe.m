/* Apple oracle for the NSTrackingArea coverage test: the rect, options,
   owner and userInfo accessors, a nil userInfo, and copy. */
#import <Cocoa/Cocoa.h>

int
main(int argc, const char **argv)
{
  @autoreleasepool
  {
    NSDictionary *info = @{@"k": @"v"};
    id owner = [[NSObject alloc] init];
    NSRect r = NSMakeRect(10, 20, 30, 40);
    NSTrackingAreaOptions opts =
      NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways;

    NSTrackingArea *a = [[NSTrackingArea alloc] initWithRect: r
        options: opts owner: owner userInfo: info];
    NSLog(@"TA rect=%@ options=%lu ownerSame=%d userInfoCount=%lu userInfoV=%@",
          NSStringFromRect([a rect]), (unsigned long)[a options],
          [a owner] == owner, (unsigned long)[[a userInfo] count],
          [[a userInfo] objectForKey: @"k"]);

    NSTrackingArea *b = [[NSTrackingArea alloc] initWithRect: r
        options: NSTrackingMouseMoved owner: owner userInfo: nil];
    NSLog(@"TA nilInfo userInfo=%@", [b userInfo] == nil ? @"nil" : @"nonnil");

    NSTrackingArea *c = [a copy];
    NSLog(@"TA copy rect=%@ options=%lu ownerSame=%d userInfoV=%@ distinct=%d",
          NSStringFromRect([c rect]), (unsigned long)[c options],
          [c owner] == owner, [[c userInfo] objectForKey: @"k"], c != a);
  }
  return 0;
}
