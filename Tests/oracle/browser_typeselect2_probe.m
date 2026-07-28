#import <Cocoa/Cocoa.h>
#include <stdio.h>

/* Follow up on the type select probe: case sensitivity, whether the scan wraps
   past the end of the column, where it starts relative to the selected row,
   and whether a string from browser:typeSelectStringForRow:inColumn: is what
   the search matches against. */

static NSArray *rows;

@interface Base : NSObject <NSBrowserDelegate>
@end

@implementation Base
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
@end

/* The cell strings are useless for searching; the delegate hands out the real
   ones, in reverse row order, so a match proves which string was used. */
@interface Renamer : Base
@end

@implementation Renamer
- (void) browser: (NSBrowser *)sender
 willDisplayCell: (id)cell
	   atRow: (NSInteger)row
	  column: (NSInteger)column
{
  [cell setStringValue: @"-"];
  [cell setLeaf: YES];
}
- (NSString *) browser: (NSBrowser *)browser
typeSelectStringForRow: (NSInteger)row
	      inColumn: (NSInteger)column
{
  return [rows objectAtIndex: ([rows count] - 1 - row)];
}
@end

static NSWindow *window;
static NSBrowser *browser;

static void
sendKey(NSString *chars)
{
  NSEvent *e = [NSEvent keyEventWithType: NSEventTypeKeyDown
				location: NSZeroPoint
			   modifierFlags: 0
			       timestamp: 0.0
			    windowNumber: [window windowNumber]
				 context: nil
			      characters: chars
	     charactersIgnoringModifiers: chars
			       isARepeat: NO
				 keyCode: 0];
  [[window firstResponder] keyDown: e];
  NSInteger r = [browser selectedRowInColumn: 0];
  printf("    typed '%s' -> row %ld (%s)\n", [chars UTF8String], (long)r,
    r >= 0 ? [[rows objectAtIndex: r] UTF8String] : "none");
}

/* Each case gets a fresh browser: AppKit keeps a search string alive across
   keystrokes for a while, and a stale one would poison the next case. */
static void
reset(id delegate, NSInteger startRow)
{
  browser = [[NSBrowser alloc] initWithFrame: NSMakeRect(0, 0, 400, 200)];
  [browser setMaxVisibleColumns: 1];
  [browser setDelegate: delegate];
  [window setContentView: browser];
  [browser loadColumnZero];
  [browser selectRow: startRow inColumn: 0];
  [window makeFirstResponder: browser];
  printf("  selection starts at row %ld (%s)\n", (long)startRow,
    [[rows objectAtIndex: startRow] UTF8String]);
}

int main(void)
{
  @autoreleasepool
    {
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

      printf("rows: alpha beta Bravo charlie delta\n");

      printf("--- uppercase key against lowercase rows\n");
      reset([[Base alloc] init], 0);
      sendKey(@"D");

      printf("--- lowercase key against a capitalised row\n");
      reset([[Base alloc] init], 3);
      sendKey(@"b");

      printf("--- does the scan wrap past the last row\n");
      reset([[Base alloc] init], 3);
      sendKey(@"a");

      printf("--- can the search land on the row already selected\n");
      reset([[Base alloc] init], 2);
      sendKey(@"B");

      printf("--- prefix or substring\n");
      reset([[Base alloc] init], 0);
      sendKey(@"e");

      printf("--- string from the delegate, rows reversed, cells all \"-\"\n");
      reset([[Renamer alloc] init], 0);
      sendKey(@"c");

      printf("done\n");
    }
  return 0;
}
