/* Apple oracle, pass 5 for NSTextAlternatives.  Pass 1 showed the strings are
   snapshotted at init.  This pass asks whether the getters hand back the same
   object on every call when the initialiser was given mutable objects, which is
   what tells us the getter returns storage rather than a fresh copy.
   Apple-only. */
#import <Cocoa/Cocoa.h>
#include <stdio.h>

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    NSMutableString *primary = [NSMutableString stringWithString: @"abc"];
    NSMutableArray *alts = [NSMutableArray arrayWithObject: @"x"];
    NSTextAlternatives *ta;

    ta = [[NSTextAlternatives alloc] initWithPrimaryString: primary
                                       alternativeStrings: alts];

    printf("MUTABLE-INPUT primaryStable=%d altsStable=%d\n",
           [ta primaryString] == [ta primaryString],
           [ta alternativeStrings] == [ta alternativeStrings]);
    printf("MUTABLE-INPUT primaryIsInput=%d altsIsInput=%d\n",
           [ta primaryString] == (NSString *)primary,
           [ta alternativeStrings] == (NSArray *)alts);
    printf("MUTABLE-INPUT primaryClass=%s altsClass=%s\n",
           [NSStringFromClass([[ta primaryString] class]) UTF8String],
           [NSStringFromClass([[ta alternativeStrings] class]) UTF8String]);

    /* Mutating the inputs afterwards must not show through. */
    [primary appendString: @"DEF"];
    [alts addObject: @"y"];
    printf("AFTER-MUTATION primary=%s altcount=%lu\n",
           [[ta primaryString] UTF8String],
           (unsigned long)[[ta alternativeStrings] count]);

    /* An immutable input: is the stored string the very object passed in? */
    NSString *lit = @"colour";
    NSArray *litAlts = [NSArray arrayWithObject: @"color"];
    NSTextAlternatives *ta2;

    ta2 = [[NSTextAlternatives alloc] initWithPrimaryString: lit
                                        alternativeStrings: litAlts];
    printf("IMMUTABLE-INPUT primaryIsInput=%d altsIsInput=%d stable=%d\n",
           [ta2 primaryString] == lit,
           [ta2 alternativeStrings] == litAlts,
           [ta2 primaryString] == [ta2 primaryString]);
  }
  return 0;
}
