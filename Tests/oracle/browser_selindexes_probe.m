#import <Cocoa/Cocoa.h>
#include <stdio.h>

/* browser:selectionIndexesForProposedSelection:inColumn: — which selection
   paths ask it, what set is proposed, and what a different or empty answer
   does to the selection. */

static NSArray *rows;

@interface Filter : NSObject <NSBrowserDelegate>
{
@public
  NSIndexSet *answer;
  BOOL passThrough;
}
@end

@implementation Filter
- (NSInteger) browser: (NSBrowser *)sender numberOfRowsInColumn: (NSInteger)column
{
  return [rows count];
}
- (void) browser: (NSBrowser *)sender
 willDisplayCell: (id)cell
	   atRow: (NSInteger)row
	  column: (NSInteger)column
{
  [cell setStringValue: [rows objectAtIndex: row]];
  [cell setLeaf: YES];
}
- (NSIndexSet *) browser: (NSBrowser *)browser
selectionIndexesForProposedSelection: (NSIndexSet *)proposed
		inColumn: (NSInteger)column
{
  NSMutableString *s = [NSMutableString string];
  NSUInteger i = [proposed firstIndex];

  while (i != NSNotFound)
    {
      [s appendFormat: @"%lu ", (unsigned long)i];
      i = [proposed indexGreaterThanIndex: i];
    }
  printf("    proposed {%s} column=%ld -> %s\n", [s UTF8String], (long)column,
    passThrough ? "same" : [[answer description] UTF8String]);
  return passThrough ? proposed : answer;
}
@end

static NSWindow *window;

static void
report(NSBrowser *b, const char *what)
{
  NSIndexSet *sel = [b selectedRowIndexesInColumn: 0];
  NSMutableString *s = [NSMutableString string];
  NSUInteger i = [sel firstIndex];

  while (i != NSNotFound)
    {
      [s appendFormat: @"%lu ", (unsigned long)i];
      i = [sel indexGreaterThanIndex: i];
    }
  printf("  after %s selection is {%s} selectedRow=%ld\n", what, [s UTF8String],
    (long)[b selectedRowInColumn: 0]);
}

static NSBrowser *
freshBrowser(Filter *f)
{
  NSBrowser *b = [[NSBrowser alloc] initWithFrame: NSMakeRect(0, 0, 400, 200)];

  [b setMaxVisibleColumns: 1];
  [b setAllowsMultipleSelection: YES];
  [b setDelegate: f];
  [window setContentView: b];
  [b loadColumnZero];
  return b;
}

int main(void)
{
  @autoreleasepool
    {
      NSBrowser *b;
      Filter *f;

      setbuf(stdout, NULL);
      [NSApplication sharedApplication];
      [NSApp setActivationPolicy: NSApplicationActivationPolicyAccessory];

      rows = [[NSArray alloc] initWithObjects: @"alpha", @"beta", @"Bravo",
	       @"charlie", @"delta", nil];
      window = [[NSWindow alloc]
	initWithContentRect: NSMakeRect(0, 0, 400, 200)
		  styleMask: NSWindowStyleMaskTitled
		    backing: NSBackingStoreBuffered
		      defer: NO];

      f = [[Filter alloc] init];
      f->passThrough = YES;

      printf("--- selectRow:inColumn: with the delegate passing the set through\n");
      b = freshBrowser(f);
      [b selectRow: 2 inColumn: 0];
      report(b, "selectRow:2");

      printf("--- selectRowIndexes:inColumn: with the set passed through\n");
      b = freshBrowser(f);
      [b selectRowIndexes: [NSIndexSet indexSetWithIndex: 3] inColumn: 0];
      report(b, "selectRowIndexes:{3}");

      printf("--- selectRowIndexes: with two rows\n");
      b = freshBrowser(f);
      [b selectRowIndexes: [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(1, 2)]
		 inColumn: 0];
      report(b, "selectRowIndexes:{1,2}");

      printf("--- selectAll:\n");
      b = freshBrowser(f);
      [b selectAll: nil];
      report(b, "selectAll:");

      printf("--- delegate answers a different row\n");
      f = [[Filter alloc] init];
      f->answer = [NSIndexSet indexSetWithIndex: 4];
      b = freshBrowser(f);
      [b selectRowIndexes: [NSIndexSet indexSetWithIndex: 1] inColumn: 0];
      report(b, "selectRowIndexes:{1}");

      printf("--- delegate answers an empty set\n");
      f = [[Filter alloc] init];
      f->answer = [NSIndexSet indexSet];
      b = freshBrowser(f);
      [b selectRowIndexes: [NSIndexSet indexSetWithIndex: 1] inColumn: 0];
      report(b, "selectRowIndexes:{1}");

      printf("--- delegate answers nil\n");
      f = [[Filter alloc] init];
      f->answer = nil;
      b = freshBrowser(f);
      [b selectRowIndexes: [NSIndexSet indexSetWithIndex: 1] inColumn: 0];
      report(b, "selectRowIndexes:{1}");

      printf("--- and does deselecting ask as well\n");
      f = [[Filter alloc] init];
      f->passThrough = YES;
      b = freshBrowser(f);
      [b selectRowIndexes: [NSIndexSet indexSetWithIndex: 1] inColumn: 0];
      [b selectRowIndexes: [NSIndexSet indexSet] inColumn: 0];
      report(b, "selectRowIndexes:{}");

      printf("done\n");
    }
  return 0;
}
