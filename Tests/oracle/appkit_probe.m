/* Apple oracle for NSPasteboardItem.  Probes init (empty types), the return
   values and round-trips of setData:/setString:, whether setting data adds the
   type to -types, and -availableTypeFromArray:.  Portable so the same file runs
   under GNUstep for an A/B. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

static const char *
s(NSString *v)
{
  return v == nil ? "nil" : (const char *)[v UTF8String];
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    NSString *t1 = @"public.data";
    NSString *t2 = @"public.utf8-plain-text";

    NSPasteboardItem *a = [[NSPasteboardItem alloc] init];
    printf("INIT typesCount=%lu\n", (unsigned long)[[a types] count]);

    NSData *d = [@"bytes" dataUsingEncoding: NSUTF8StringEncoding];
    BOOL rd = [a setData: d forType: t1];
    printf("SETDATA ret=%d typesCount=%lu contains=%d roundtrip=%d\n",
           rd, (unsigned long)[[a types] count],
           [[a types] containsObject: t1],
           [[a dataForType: t1] isEqual: d]);

    NSPasteboardItem *b = [[NSPasteboardItem alloc] init];
    BOOL rs = [b setString: @"hello" forType: t2];
    printf("SETSTRING ret=%d typesCount=%lu contains=%d roundtrip=%d\n",
           rs, (unsigned long)[[b types] count],
           [[b types] containsObject: t2],
           [[b stringForType: t2] isEqualToString: @"hello"]);

    printf("AVAIL fromArray=%s\n",
           s([b availableTypeFromArray: [NSArray arrayWithObjects: t2, t1, nil]]));
  }
  return 0;
}
