/* Apple oracle for the NSHelpManager coverage test: the shared instance, the
   context help set/get/remove round-trip, and the context help mode flag. */
#import <Cocoa/Cocoa.h>

int
main(int argc, const char **argv)
{
  @autoreleasepool
  {
    NSHelpManager *hm = [NSHelpManager sharedHelpManager];
    NSLog(@"HM singleton=%d", hm == [NSHelpManager sharedHelpManager]);

    id obj = [[NSObject alloc] init];
    NSLog(@"HM unregistered=%@",
          [hm contextHelpForObject: obj] == nil ? @"nil" : @"set");

    NSAttributedString *help =
      [[NSAttributedString alloc] initWithString: @"Help text"];
    [hm setContextHelp: help forObject: obj];
    NSAttributedString *got = [hm contextHelpForObject: obj];
    NSLog(@"HM afterSet present=%d equal=%d string=%@",
          got != nil, [got isEqual: help],
          got == nil ? @"(nil)" : [got string]);

    [hm removeContextHelpForObject: obj];
    NSLog(@"HM afterRemove=%@",
          [hm contextHelpForObject: obj] == nil ? @"nil" : @"set");

    NSLog(@"HM modeDefault=%d", [NSHelpManager isContextHelpModeActive]);
    [NSHelpManager setContextHelpModeActive: YES];
    NSLog(@"HM modeAfterSet=%d", [NSHelpManager isContextHelpModeActive]);
    [NSHelpManager setContextHelpModeActive: NO];
    NSLog(@"HM modeAfterClear=%d", [NSHelpManager isContextHelpModeActive]);
  }
  return 0;
}
