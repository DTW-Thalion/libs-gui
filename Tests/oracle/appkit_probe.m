/* Apple oracle for the NSTextList coverage test: the marker-format token
   substitutions from markerForItemNumber:, the options and marker-format
   round-trip, the starting item number and copy. */
#import <Cocoa/Cocoa.h>

static NSString *
codepoints(NSString *s)
{
  NSMutableString *h = [NSMutableString string];
  NSUInteger i;
  for (i = 0; i < [s length]; i++)
    [h appendFormat: @"%04X ", [s characterAtIndex: i]];
  return h;
}

int
main(int argc, const char **argv)
{
  @autoreleasepool
  {
    NSArray *fmts = @[@"{decimal}", @"{lower-alpha}", @"{upper-alpha}",
                      @"{lower-latin}", @"{upper-latin}", @"{octal}",
                      @"{lower-hexadecimal}", @"{upper-hexadecimal}",
                      @"{lower-roman}", @"{upper-roman}",
                      @"{disc}", @"{circle}", @"{square}", @"{hyphen}",
                      @"{box}", @"{check}", @"{diamond}"];
    NSString *fmt;

    for (fmt in fmts)
      {
        NSTextList *l = [[NSTextList alloc] initWithMarkerFormat: fmt options: 0];
        NSString *m = [l markerForItemNumber: 3];
        NSLog(@"MARK %@ item3 -> '%@' cp=%@", fmt, m, codepoints(m));
      }

    /* Surrounding text and item 1 for the alpha case. */
    NSTextList *dec = [[NSTextList alloc] initWithMarkerFormat: @"({decimal})" options: 0];
    NSLog(@"MARK ({decimal}) item5 -> '%@'", [dec markerForItemNumber: 5]);
    NSTextList *al = [[NSTextList alloc] initWithMarkerFormat: @"{lower-alpha}" options: 0];
    NSLog(@"MARK {lower-alpha} item1 -> '%@'", [al markerForItemNumber: 1]);

    /* Options, marker format, default starting number, and whether
       markerForItemNumber: honours the starting number. */
    NSTextList *o = [[NSTextList alloc] initWithMarkerFormat: @"{decimal}"
        options: NSTextListPrependEnclosingMarker];
    NSLog(@"OPTS listOptions=%u markerFormat='%@' defaultStart=%ld",
          [o listOptions], [o markerFormat], (long)[o startingItemNumber]);
    [o setStartingItemNumber: 10];
    NSLog(@"OPTS afterSetStart=%ld markerItem1='%@'",
          (long)[o startingItemNumber], [o markerForItemNumber: 1]);

    NSTextList *cp = [o copy];
    NSLog(@"COPY markerFormat='%@' listOptions=%u start=%ld",
          [cp markerFormat], [cp listOptions], (long)[cp startingItemNumber]);
  }
  return 0;
}
