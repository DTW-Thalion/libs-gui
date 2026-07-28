#import <Cocoa/Cocoa.h>
#include <stdio.h>

/* When does AppKit send browser:didChangeLastColumn:toColumn:?  Drive a
   browser through loadColumnZero, addColumn and setLastColumn: and log every
   callback with the values it carries. */

@interface Watcher : NSObject <NSBrowserDelegate>
@end

@implementation Watcher
- (NSInteger) browser: (NSBrowser *)sender numberOfRowsInColumn: (NSInteger)column
{
  return 3;
}
- (void) browser: (NSBrowser *)sender
 willDisplayCell: (id)cell
	   atRow: (NSInteger)row
	  column: (NSInteger)column
{
  [cell setStringValue: @"row"];
  [cell setLeaf: (column > 1)];
}
- (void) browser: (NSBrowser *)browser
didChangeLastColumn: (NSInteger)oldLastColumn
	toColumn: (NSInteger)column
{
  printf("    callback old=%ld new=%ld (lastColumn now %ld)\n",
    (long)oldLastColumn, (long)column, (long)[browser lastColumn]);
}
@end

int main(void)
{
  @autoreleasepool
    {
      setbuf(stdout, NULL);
      [NSApplication sharedApplication];

      NSBrowser *b = [[NSBrowser alloc]
	initWithFrame: NSMakeRect(0, 0, 400, 200)];
      Watcher *w = [[Watcher alloc] init];

      [b setDelegate: w];
      printf("loadColumnZero\n");
      [b loadColumnZero];
      printf("  lastColumn %ld\n", (long)[b lastColumn]);

      printf("setLastColumn: 0 (already there)\n");
      [b setLastColumn: 0];
      printf("  lastColumn %ld\n", (long)[b lastColumn]);

      printf("addColumn\n");
      [b addColumn];
      printf("  lastColumn %ld\n", (long)[b lastColumn]);

      printf("selectRow 0 inColumn 0\n");
      [b selectRow: 0 inColumn: 0];
      printf("  lastColumn %ld\n", (long)[b lastColumn]);

      printf("setLastColumn: 0\n");
      [b setLastColumn: 0];
      printf("  lastColumn %ld\n", (long)[b lastColumn]);

      printf("reloadColumn: 0\n");
      [b reloadColumn: 0];
      printf("  lastColumn %ld\n", (long)[b lastColumn]);

      printf("done\n");
    }
  return 0;
}
