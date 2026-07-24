/* Apple oracle: NSAlert button key equivalents, printed by length + char code
   (a raw %s hides control characters like \r and \e).  Portable A/B. */
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
    [a addButtonWithTitle: @"OK"];
    [a addButtonWithTitle: @"Cancel"];
    [a addButtonWithTitle: @"Maybe"];
    NSArray *btns = [a buttons];
    for (NSUInteger i = 0; i < [btns count]; i++)
      {
        NSButton *b = [btns objectAtIndex: i];
        NSString *ke = [b keyEquivalent];
        printf("btn[%lu] title='%s' len=%lu",
               (unsigned long)i, [[b title] UTF8String],
               (unsigned long)[ke length]);
        if ([ke length] > 0)
          printf(" char0=%d", (int)[ke characterAtIndex: 0]);
        printf("\n");
      }
  }
  return 0;
}
