/* Apple oracle for the NSTextTab coverage test: the derived alignment and
   tab-stop type from the two initialisers, the options round-trip, equality,
   ordering and copy. */
#import <Cocoa/Cocoa.h>

int
main(int argc, const char **argv)
{
  @autoreleasepool
  {
    int t;

    for (t = 0; t <= 3; t++)
      {
        NSTextTab *tab = [[NSTextTab alloc] initWithType: t location: 50.0 + t];
        NSLog(@"TAB type=%d -> loc=%g tabStopType=%d alignment=%ld",
              t, [tab location], (int)[tab tabStopType], (long)[tab alignment]);
      }

    NSTextTab *l = [[NSTextTab alloc] initWithTextAlignment: NSTextAlignmentLeft
                                                   location: 10 options: @{}];
    NSLog(@"TAB align=Left -> tabStopType=%d alignment=%ld",
          (int)[l tabStopType], (long)[l alignment]);

    NSTextTab *r = [[NSTextTab alloc] initWithTextAlignment: NSTextAlignmentRight
                                                   location: 20 options: @{}];
    NSLog(@"TAB align=Right noopts -> tabStopType=%d alignment=%ld",
          (int)[r tabStopType], (long)[r alignment]);

    NSTextTab *rd = [[NSTextTab alloc] initWithTextAlignment: NSTextAlignmentRight
        location: 20
         options: @{NSTabColumnTerminatorsAttributeName:
                      [NSCharacterSet whitespaceCharacterSet]}];
    NSLog(@"TAB align=Right +terminators -> tabStopType=%d optsCount=%lu",
          (int)[rd tabStopType], (unsigned long)[[rd options] count]);

    NSTextTab *c = [[NSTextTab alloc] initWithTextAlignment: NSTextAlignmentCenter
                                                   location: 30 options: @{}];
    NSLog(@"TAB align=Center -> tabStopType=%d alignment=%ld",
          (int)[c tabStopType], (long)[c alignment]);

    NSTextTab *j = [[NSTextTab alloc] initWithTextAlignment: NSTextAlignmentJustified
                                                   location: 40 options: @{}];
    NSLog(@"TAB align=Justified -> tabStopType=%d alignment=%ld",
          (int)[j tabStopType], (long)[j alignment]);

    NSTextTab *a1 = [[NSTextTab alloc] initWithType: NSLeftTabStopType location: 100];
    NSTextTab *a2 = [[NSTextTab alloc] initWithType: NSLeftTabStopType location: 100];
    NSTextTab *a3 = [[NSTextTab alloc] initWithType: NSRightTabStopType location: 100];
    NSTextTab *a4 = [[NSTextTab alloc] initWithType: NSLeftTabStopType location: 50];
    NSLog(@"TAB isEqual same=%d difftype=%d diffloc=%d",
          [a1 isEqual: a2], [a1 isEqual: a3], [a1 isEqual: a4]);
    NSLog(@"TAB compare a4(50) vs a1(100) = %ld", (long)[a4 compare: a1]);

    NSTextTab *cp = [a3 copy];
    NSLog(@"TAB copy loc=%g tabStopType=%d isEqual=%d",
          [cp location], (int)[cp tabStopType], [cp isEqual: a3]);

    NSLog(@"ALIGN consts left=%ld right=%ld center=%ld justified=%ld natural=%ld",
          (long)NSTextAlignmentLeft, (long)NSTextAlignmentRight,
          (long)NSTextAlignmentCenter, (long)NSTextAlignmentJustified,
          (long)NSTextAlignmentNatural);
  }
  return 0;
}
