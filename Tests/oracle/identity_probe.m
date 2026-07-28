#import <Cocoa/Cocoa.h>
#include <stdio.h>

/* #294 says Cocoa treats each NSTextList as its own object rather than
   comparing marker formats.  Check that, and the same question for
   NSTextBlock and NSTextTab, since range lookups compare blocks by
   containsObject:. */

int main(void)
{
  @autoreleasepool
    {
      setbuf(stdout, NULL);

      NSTextList *l1 = [[NSTextList alloc] initWithMarkerFormat: @"{box}" options: 0];
      NSTextList *l2 = [[NSTextList alloc] initWithMarkerFormat: @"{box}" options: 0];

      printf("two lists, same marker format      isEqual=%d\n", (int)[l1 isEqual: l2]);
      printf("a list against itself              isEqual=%d\n", (int)[l1 isEqual: l1]);

      NSTextBlock *b1 = [[NSTextBlock alloc] init];
      NSTextBlock *b2 = [[NSTextBlock alloc] init];

      printf("two default text blocks            isEqual=%d\n", (int)[b1 isEqual: b2]);
      printf("a block against itself             isEqual=%d\n", (int)[b1 isEqual: b1]);

      NSTextTable *t1 = [[NSTextTable alloc] init];
      NSTextTable *t2 = [[NSTextTable alloc] init];

      printf("two default text tables            isEqual=%d\n", (int)[t1 isEqual: t2]);

      NSTextTab *tab1 = [[NSTextTab alloc] initWithType: NSLeftTabStopType location: 36.0];
      NSTextTab *tab2 = [[NSTextTab alloc] initWithType: NSLeftTabStopType location: 36.0];
      NSTextTab *tab3 = [[NSTextTab alloc] initWithType: NSLeftTabStopType location: 72.0];

      printf("two tabs, same type and location   isEqual=%d\n", (int)[tab1 isEqual: tab2]);
      printf("two tabs, different location       isEqual=%d\n", (int)[tab1 isEqual: tab3]);

      printf("done\n");
    }
  return 0;
}
