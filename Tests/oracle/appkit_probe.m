/* Apple oracle, pass 2 for NSSearchFieldCell.  What maximumRecents -1 (the
   default) and 0 mean for how many recent searches are kept, and how setting
   the autosave name interacts with searches already set.  Apple-only. */
#import <Cocoa/Cocoa.h>
#include <stdio.h>

static NSArray *
manySearches(int n)
{
  NSMutableArray *a = [NSMutableArray array];
  int i;

  for (i = 0; i < n; i++)
    {
      [a addObject: [NSString stringWithFormat: @"s%d", i]];
    }
  return a;
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    printf("== what -1 means for truncation ==\n");
    {
      NSSearchFieldCell *c = [[NSSearchFieldCell alloc] initTextCell: @"f"];

      printf("DEFAULT max=%ld\n", (long)[c maximumRecents]);
      [c setRecentSearches: manySearches(20)];
      printf("DEFAULT given 20 -> count=%lu\n",
             (unsigned long)[[c recentSearches] count]);
    }
    {
      NSSearchFieldCell *c = [[NSSearchFieldCell alloc] initTextCell: @"f"];

      [c setMaximumRecents: -1];
      [c setRecentSearches: manySearches(20)];
      printf("EXPLICIT -1 given 20 -> count=%lu\n",
             (unsigned long)[[c recentSearches] count]);
    }
    {
      NSSearchFieldCell *c = [[NSSearchFieldCell alloc] initTextCell: @"f"];

      [c setMaximumRecents: 0];
      [c setRecentSearches: manySearches(5)];
      printf("ZERO given 5 -> count=%lu\n",
             (unsigned long)[[c recentSearches] count]);
    }

    printf("\n== autosave name and searches ==\n");
    {
      NSSearchFieldCell *c = [[NSSearchFieldCell alloc] initTextCell: @"f"];

      [c setRecentSearches: [NSArray arrayWithObjects: @"a", @"b", nil]];
      printf("SET-THEN-AUTOSAVE before=%lu",
             (unsigned long)[[c recentSearches] count]);
      [c setRecentsAutosaveName: @"probeSaveA"];
      printf(" after=%lu\n", (unsigned long)[[c recentSearches] count]);
    }
    {
      NSSearchFieldCell *c = [[NSSearchFieldCell alloc] initTextCell: @"f"];

      [c setRecentsAutosaveName: @"probeSaveB"];
      printf("AUTOSAVE-THEN-SET before=%lu",
             (unsigned long)[[c recentSearches] count]);
      [c setRecentSearches: [NSArray arrayWithObjects: @"a", @"b", nil]];
      printf(" after=%lu\n", (unsigned long)[[c recentSearches] count]);
    }

    printf("\n== recentSearches identity ==\n");
    {
      NSSearchFieldCell *c = [[NSSearchFieldCell alloc] initTextCell: @"f"];
      NSArray *given = [NSArray arrayWithObjects: @"a", @"b", nil];

      [c setRecentSearches: given];
      printf("SAME=%d EQUAL=%d CLASS=%s\n",
             [c recentSearches] == given,
             [[c recentSearches] isEqualToArray: given],
             [NSStringFromClass([[c recentSearches] class]) UTF8String]);
    }

    printf("\n== setRecentSearches: nil ==\n");
    {
      NSSearchFieldCell *c = [[NSSearchFieldCell alloc] initTextCell: @"f"];

      [c setRecentSearches: [NSArray arrayWithObject: @"a"]];
      @try {
        [c setRecentSearches: nil];
        printf("NIL ok recentSearches=%s count=%lu\n",
               [c recentSearches] == nil ? "nil" : "set",
               (unsigned long)[[c recentSearches] count]);
      } @catch (NSException *e) {
        printf("NIL raised %s\n", [[e name] UTF8String]);
      }
    }
  }
  return 0;
}
