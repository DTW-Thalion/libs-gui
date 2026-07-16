/* Apple oracle for NSTokenFieldCell and NSPageController.  Probes the
   enumeration values, the class defaults, the init defaults, the round-trips,
   and what a page controller does when asked to select an index it has no
   object for.  Portable so the same file runs under GNUstep for an A/B. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

#define SECTION(NAME) \
  printf("\n== " NAME " ==\n"); \
  @try {

#define ENDSECTION \
  } @catch (NSException *e) { \
    printf("EXCEPTION %s: %s\n", [[e name] UTF8String], \
           [[e reason] UTF8String]); \
  }

static const char *
nilstr(id o)
{
  return o == nil ? "nil" : "set";
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    SECTION("NSTokenStyle enum")
    printf("TOKENSTYLE default=%ld plainText=%ld rounded=%ld\n",
           (long)NSDefaultTokenStyle, (long)NSPlainTextTokenStyle,
           (long)NSRoundedTokenStyle);
    ENDSECTION

    SECTION("NSTokenFieldCell class defaults")
    NSCharacterSet *set = [NSTokenFieldCell defaultTokenizingCharacterSet];

    printf("CLASS defaultCompletionDelay=%g\n",
           (double)[NSTokenFieldCell defaultCompletionDelay]);
    printf("CLASS defaultTokenizingCharacterSet=%s hasComma=%d hasSemi=%d\n",
           nilstr(set),
           set == nil ? -1 : [set characterIsMember: ','],
           set == nil ? -1 : [set characterIsMember: ';']);
    ENDSECTION

    SECTION("NSTokenFieldCell init defaults")
    NSTokenFieldCell *c = [[NSTokenFieldCell alloc] initTextCell: @"x"];
    NSCharacterSet *set = [c tokenizingCharacterSet];

    printf("INIT tokenStyle=%ld completionDelay=%g\n",
           (long)[c tokenStyle], (double)[c completionDelay]);
    printf("INIT tokenizingCharacterSet=%s hasComma=%d\n",
           nilstr(set), set == nil ? -1 : [set characterIsMember: ',']);
    ENDSECTION

    SECTION("NSTokenFieldCell round trips")
    NSTokenFieldCell *c = [[NSTokenFieldCell alloc] initTextCell: @"x"];
    NSCharacterSet *semi = [NSCharacterSet characterSetWithCharactersInString:
      @";"];

    [c setTokenStyle: NSRoundedTokenStyle];
    [c setCompletionDelay: 2.5];
    [c setTokenizingCharacterSet: semi];
    printf("SET tokenStyle=%ld completionDelay=%g setSame=%d\n",
           (long)[c tokenStyle], (double)[c completionDelay],
           [c tokenizingCharacterSet] == semi);
    ENDSECTION

    SECTION("NSPageControllerTransitionStyle enum")
    printf("TRANSITION stackHistory=%ld stackBook=%ld horizontalStrip=%ld\n",
           (long)NSPageControllerTransitionStyleStackHistory,
           (long)NSPageControllerTransitionStyleStackBook,
           (long)NSPageControllerTransitionStyleHorizontalStrip);
    ENDSECTION

    SECTION("NSPageController init defaults")
    NSPageController *p = [[NSPageController alloc] init];

    printf("INIT transitionStyle=%ld delegate=%s\n",
           (long)[p transitionStyle], nilstr([p delegate]));
    printf("INIT arrangedObjects=%s count=%lu selectedIndex=%ld\n",
           nilstr([p arrangedObjects]),
           (unsigned long)[[p arrangedObjects] count],
           (long)[p selectedIndex]);
    printf("INIT selectedViewController=%s\n",
           nilstr([p selectedViewController]));
    ENDSECTION

    SECTION("NSPageController round trips")
    NSPageController *p = [[NSPageController alloc] init];
    NSArray *objects = [NSArray arrayWithObjects: @"a", @"b", @"c", nil];

    [p setTransitionStyle: NSPageControllerTransitionStyleHorizontalStrip];
    printf("SET transitionStyle=%ld\n", (long)[p transitionStyle]);

    [p setArrangedObjects: objects];
    printf("SET arrangedCount=%lu equal=%d same=%d\n",
           (unsigned long)[[p arrangedObjects] count],
           [[p arrangedObjects] isEqualToArray: objects],
           [p arrangedObjects] == objects);
    printf("SET selectedIndexAfterArranged=%ld\n", (long)[p selectedIndex]);
    ENDSECTION

    SECTION("NSPageController selecting with objects")
    NSPageController *p = [[NSPageController alloc] init];
    NSArray *objects = [NSArray arrayWithObjects: @"a", @"b", @"c", nil];

    [p setArrangedObjects: objects];
    [p setSelectedIndex: 2];
    printf("SEL2 selectedIndex=%ld selectedViewController=%s\n",
           (long)[p selectedIndex], nilstr([p selectedViewController]));
    ENDSECTION

    SECTION("NSPageController selecting with no objects")
    NSPageController *p = [[NSPageController alloc] init];

    @try {
      [p setSelectedIndex: 0];
      printf("EMPTY-SEL0 ok selectedIndex=%ld\n", (long)[p selectedIndex]);
    } @catch (NSException *e) {
      printf("EMPTY-SEL0 raised %s\n", [[e name] UTF8String]);
    }
    ENDSECTION

    SECTION("NSPageController selecting out of range")
    NSPageController *p = [[NSPageController alloc] init];

    [p setArrangedObjects: [NSArray arrayWithObject: @"a"]];
    @try {
      [p setSelectedIndex: 9];
      printf("OUT-OF-RANGE ok selectedIndex=%ld\n", (long)[p selectedIndex]);
    } @catch (NSException *e) {
      printf("OUT-OF-RANGE raised %s\n", [[e name] UTF8String]);
    }
    ENDSECTION

    SECTION("NSPageController navigateBack on an empty controller")
    NSPageController *p = [[NSPageController alloc] init];

    @try {
      [p navigateBack: nil];
      printf("EMPTY-BACK ok selectedIndex=%ld\n", (long)[p selectedIndex]);
    } @catch (NSException *e) {
      printf("EMPTY-BACK raised %s\n", [[e name] UTF8String]);
    }
    ENDSECTION
  }
  return 0;
}
