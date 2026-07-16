/* Apple oracle, pass 2 for NSAppearance.  Which named appearances allow
   vibrancy, what the name constants are, what the current appearance is before
   anything sets it, and how bestMatchFromAppearancesWithNames: chooses.
   Apple-only. */
#import <Cocoa/Cocoa.h>
#include <stdio.h>

#define SECTION(NAME) \
  printf("\n== " NAME " ==\n"); \
  @try {

#define ENDSECTION \
  } @catch (NSException *e) { \
    printf("EXCEPTION %s: %s\n", [[e name] UTF8String], \
           [[e reason] UTF8String]); \
  }

static void
dumpBest(NSString *ofName, NSArray *names, const char *tag)
{
  NSAppearance *a = [NSAppearance appearanceNamed: ofName];
  NSString *best = [a bestMatchFromAppearancesWithNames: names];

  printf("%-46s -> %s\n", tag, best == nil ? "nil" : [best UTF8String]);
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    SECTION("name constants and vibrancy")
    NSArray *names = [NSArray arrayWithObjects:
      NSAppearanceNameAqua,
      NSAppearanceNameDarkAqua,
      NSAppearanceNameVibrantLight,
      NSAppearanceNameVibrantDark,
      NSAppearanceNameAccessibilityHighContrastAqua,
      NSAppearanceNameAccessibilityHighContrastDarkAqua,
      NSAppearanceNameAccessibilityHighContrastVibrantLight,
      NSAppearanceNameAccessibilityHighContrastVibrantDark,
      nil];
    NSUInteger i;

    for (i = 0; i < [names count]; i++)
      {
        NSString *n = [names objectAtIndex: i];
        NSAppearance *a = [NSAppearance appearanceNamed: n];

        printf("NAME %-52s nonnil=%d nameBack=%-8s vibrancy=%d\n",
               [n UTF8String], a != nil,
               [[a name] isEqualToString: n] ? "same" : "DIFFERENT",
               [a allowsVibrancy]);
      }
    ENDSECTION

    SECTION("current appearance before anything sets it")
    NSAppearance *cur = [NSAppearance currentAppearance];

    printf("CURRENT nonnil=%d name=%s\n", cur != nil,
           cur == nil ? "-" : [[cur name] UTF8String]);
    ENDSECTION

    SECTION("bestMatchFromAppearancesWithNames")
    NSArray *aquaDark = [NSArray arrayWithObjects: NSAppearanceNameAqua,
      NSAppearanceNameDarkAqua, nil];
    NSArray *darkAqua = [NSArray arrayWithObjects: NSAppearanceNameDarkAqua,
      NSAppearanceNameAqua, nil];
    NSArray *onlyDark = [NSArray arrayWithObject: NSAppearanceNameDarkAqua];
    NSArray *onlyVibrantLight = [NSArray arrayWithObject:
      NSAppearanceNameVibrantLight];
    NSArray *vibrantThenAqua = [NSArray arrayWithObjects:
      NSAppearanceNameVibrantLight, NSAppearanceNameAqua, nil];

    dumpBest(NSAppearanceNameAqua, aquaDark, "aqua of [aqua, darkAqua]");
    dumpBest(NSAppearanceNameAqua, darkAqua, "aqua of [darkAqua, aqua]");
    dumpBest(NSAppearanceNameAqua, onlyDark, "aqua of [darkAqua]");
    dumpBest(NSAppearanceNameAqua, onlyVibrantLight, "aqua of [vibrantLight]");
    dumpBest(NSAppearanceNameAqua, vibrantThenAqua,
      "aqua of [vibrantLight, aqua]");
    dumpBest(NSAppearanceNameDarkAqua, aquaDark, "darkAqua of [aqua, darkAqua]");
    dumpBest(NSAppearanceNameDarkAqua, [NSArray arrayWithObject:
      NSAppearanceNameAqua], "darkAqua of [aqua]");
    dumpBest(NSAppearanceNameVibrantLight, aquaDark,
      "vibrantLight of [aqua, darkAqua]");
    dumpBest(NSAppearanceNameAqua, [NSArray array], "aqua of []");
    dumpBest(NSAppearanceNameAqua, [NSArray arrayWithObject: @"Bogus"],
      "aqua of [Bogus]");
    ENDSECTION

    SECTION("bogus appearance behaviour")
    NSAppearance *b = [NSAppearance appearanceNamed: @"NotAnAppearance"];

    printf("BOGUS nonnil=%d name=%s vibrancy=%d\n",
           b != nil, [[b name] UTF8String], [b allowsVibrancy]);
    printf("BOGUS best of [aqua] = %s\n",
           [b bestMatchFromAppearancesWithNames:
             [NSArray arrayWithObject: NSAppearanceNameAqua]] == nil ? "nil"
             : [[b bestMatchFromAppearancesWithNames:
                  [NSArray arrayWithObject: NSAppearanceNameAqua]] UTF8String]);
    ENDSECTION
  }
  return 0;
}
