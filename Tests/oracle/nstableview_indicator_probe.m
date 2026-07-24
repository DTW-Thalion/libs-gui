#import <Cocoa/Cocoa.h>

int
main(int argc, const char *argv[])
{
  @autoreleasepool
    {
      NSTableView *tv = [[NSTableView alloc] initWithFrame: NSMakeRect(0, 0, 200, 100)];
      NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier: @"c"];
      NSImage *img = [[NSImage alloc] initWithSize: NSMakeSize(8, 8)];
      NSImage *got;

      [tv addTableColumn: col];

      got = [tv indicatorImageInTableColumn: col];
      printf("default indicatorImageInTableColumn: -> %s\n", got == nil ? "nil" : "non-nil");

      [tv setIndicatorImage: img inTableColumn: col];
      got = [tv indicatorImageInTableColumn: col];
      printf("after set, indicatorImageInTableColumn: -> %s (same=%s)\n",
        got == nil ? "nil" : "non-nil", got == img ? "YES" : "NO");

      [tv setIndicatorImage: nil inTableColumn: col];
      got = [tv indicatorImageInTableColumn: col];
      printf("after set nil, indicatorImageInTableColumn: -> %s\n", got == nil ? "nil" : "non-nil");
    }
  return 0;
}
