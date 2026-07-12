/* Apple oracle for the NSTextContainer coverage test: the defaults (container
   size, line fragment padding, tracking flags, layout manager, text view),
   the accessor round-trips, isSimpleRectangularTextContainer and
   containsPoint:. */
#import <Cocoa/Cocoa.h>

int
main(int argc, const char **argv)
{
  @autoreleasepool
  {
    NSTextContainer *t = [[NSTextContainer alloc] init];
    NSLog(@"TC init size=%@ padding=%g wTracks=%d hTracks=%d lm=%@ tv=%@ simple=%d",
          NSStringFromSize([t containerSize]), [t lineFragmentPadding],
          [t widthTracksTextView], [t heightTracksTextView],
          [t layoutManager] == nil ? @"nil" : @"set",
          [t textView] == nil ? @"nil" : @"set",
          [t isSimpleRectangularTextContainer]);

    NSTextContainer *s = [[NSTextContainer alloc]
      initWithContainerSize: NSMakeSize(100, 200)];
    NSLog(@"TC initWithContainerSize size=%@", NSStringFromSize([s containerSize]));

    [s setContainerSize: NSMakeSize(50, 60)];
    [s setLineFragmentPadding: 3.0];
    [s setWidthTracksTextView: YES];
    [s setHeightTracksTextView: YES];
    NSLog(@"TC roundtrip size=%@ padding=%g wTracks=%d hTracks=%d",
          NSStringFromSize([s containerSize]), [s lineFragmentPadding],
          [s widthTracksTextView], [s heightTracksTextView]);

    NSTextContainer *p = [[NSTextContainer alloc]
      initWithContainerSize: NSMakeSize(100, 200)];
    NSLog(@"TC containsPoint in=%d out=%d edge=%d",
          [p containsPoint: NSMakePoint(10, 10)],
          [p containsPoint: NSMakePoint(150, 10)],
          [p containsPoint: NSMakePoint(100, 200)]);
  }
  return 0;
}
