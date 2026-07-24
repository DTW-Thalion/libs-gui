/* Apple oracle: NSAlert button contract - button order, tag/return-code
   mapping, and default key equivalents.  Portable so the same file runs under
   GNUstep for an A/B comparison. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

int
main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    NSAlert *a = [[NSAlert alloc] init];
    [a setMessageText: @"Msg"];
    [a setInformativeText: @"Info"];
    NSButton *b0 = [a addButtonWithTitle: @"OK"];
    NSButton *b1 = [a addButtonWithTitle: @"Cancel"];
    NSButton *b2 = [a addButtonWithTitle: @"Maybe"];
    NSArray *btns = [a buttons];

    printf("count=%lu\n", (unsigned long)[btns count]);
    printf("constants First=%ld Second=%ld Third=%ld\n",
           (long)NSAlertFirstButtonReturn, (long)NSAlertSecondButtonReturn,
           (long)NSAlertThirdButtonReturn);
    printf("returned-is-array: b0==[0]:%d b1==[1]:%d b2==[2]:%d\n",
           b0 == [btns objectAtIndex: 0], b1 == [btns objectAtIndex: 1],
           b2 == [btns objectAtIndex: 2]);
    for (NSUInteger i = 0; i < [btns count]; i++)
      {
        NSButton *b = [btns objectAtIndex: i];
        printf("btn[%lu] title='%s' tag=%ld keyEquiv='%s'\n",
               (unsigned long)i, [[b title] UTF8String], (long)[b tag],
               [[b keyEquivalent] UTF8String]);
      }
    printf("default alertStyle=%ld (Warning=%ld)\n",
           (long)[a alertStyle], (long)NSAlertStyleWarning);
    printf("messageText='%s' informative='%s'\n",
           [[a messageText] UTF8String], [[a informativeText] UTF8String]);
  }
  return 0;
}
