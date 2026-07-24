#import <Cocoa/Cocoa.h>

static void
dump(NSTextView *tv, const char *label)
{
  id v = [[tv textStorage] attribute: NSCharacterShapeAttributeName
                             atIndex: 0
                      effectiveRange: NULL];
  printf("%s: NSCharacterShapeAttributeName at 0 -> %s\n",
    label, v == nil ? "nil" : [[v description] UTF8String]);
}

int
main(int argc, const char *argv[])
{
  @autoreleasepool
    {
      NSApplication *app = [NSApplication sharedApplication];
      (void) app;
      NSTextView *tv = [[NSTextView alloc]
        initWithFrame: NSMakeRect(0, 0, 200, 100)];
      [tv setString: @"hello"];
      [tv setSelectedRange: NSMakeRange(0, 5)];

      dump(tv, "initial");
      [tv toggleTraditionalCharacterShape: nil];
      dump(tv, "after 1st toggle");
      [tv toggleTraditionalCharacterShape: nil];
      dump(tv, "after 2nd toggle");
    }
  return 0;
}
