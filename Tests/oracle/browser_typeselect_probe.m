#import <Cocoa/Cocoa.h>
#include <stdio.h>

/* Which type select delegate methods does an NSBrowser send, in what order,
   with what arguments?  Drive a browser with synthetic key events under four
   delegates: no type select methods, typeSelectStringForRow only,
   shouldTypeSelectForEvent only, nextTypeSelectMatch only. */

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

@interface WithString : Base
@end

@implementation WithString
- (NSString *) browser: (NSBrowser *)browser
typeSelectStringForRow: (NSInteger)row
	      inColumn: (NSInteger)column
{
  NSString *s = [NSString stringWithFormat: @"zz%@", [rows objectAtIndex: row]];
  printf("    typeSelectStringForRow row=%ld column=%ld -> %s\n",
    (long)row, (long)column, [s UTF8String]);
  return s;
}
@end

@interface WithShould : Base
{
@public
  BOOL answer;
}
@end

@implementation WithShould
- (BOOL) browser: (NSBrowser *)browser
shouldTypeSelectForEvent: (NSEvent *)event
withCurrentSearchString: (NSString *)searchString
{
  printf("    shouldTypeSelectForEvent chars=%s searchString=%s -> %s\n",
    [[event charactersIgnoringModifiers] UTF8String],
    searchString ? [searchString UTF8String] : "(nil)",
    answer ? "YES" : "NO");
  return answer;
}
@end

@interface WithNext : Base
{
@public
  NSInteger answer;
}
@end

@implementation WithNext
- (NSInteger) browser: (NSBrowser *)browser
nextTypeSelectMatchFromRow: (NSInteger)startRow
		toRow: (NSInteger)endRow
	     inColumn: (NSInteger)column
	    forString: (NSString *)searchString
{
  printf("    nextTypeSelectMatch start=%ld end=%ld column=%ld string=%s -> %ld\n",
    (long)startRow, (long)endRow, (long)column,
    searchString ? [searchString UTF8String] : "(nil)", (long)answer);
  return answer;
}
- (NSString *) browser: (NSBrowser *)browser
typeSelectStringForRow: (NSInteger)row
	      inColumn: (NSInteger)column
{
  printf("    typeSelectStringForRow row=%ld\n", (long)row);
  return [rows objectAtIndex: row];
}
@end

static NSWindow *window;
static NSBrowser *browser;

static void
sendKey(NSString *chars, NSTimeInterval stamp)
{
  NSEvent *e = [NSEvent keyEventWithType: NSEventTypeKeyDown
				location: NSZeroPoint
			   modifierFlags: 0
			       timestamp: stamp
			    windowNumber: [window windowNumber]
				 context: nil
			      characters: chars
	     charactersIgnoringModifiers: chars
			       isARepeat: NO
				 keyCode: 0];
  printf("  key '%s' at t=%.1f\n", [chars UTF8String], stamp);
  [[window firstResponder] keyDown: e];
  printf("    selectedRow now %ld (%s)\n", (long)[browser selectedRowInColumn: 0],
    [browser selectedRowInColumn: 0] >= 0
      ? [[rows objectAtIndex: [browser selectedRowInColumn: 0]] UTF8String]
      : "none");
}

static void
run(NSString *label, id delegate)
{
  printf("%s\n", [label UTF8String]);
  [browser setDelegate: delegate];
  [browser loadColumnZero];
  [browser setAllowsTypeSelect: YES];
  [browser selectRow: 0 inColumn: 0];
  [window makeFirstResponder: browser];
  printf("  first responder is %s\n",
    [NSStringFromClass([[window firstResponder] class]) UTF8String]);
  sendKey(@"b", 1.0);
  sendKey(@"r", 1.1);
  sendKey(@"d", 20.0);
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
      browser = [[NSBrowser alloc] initWithFrame: NSMakeRect(0, 0, 400, 200)];
      [browser setMaxVisibleColumns: 1];
      [window setContentView: browser];
      [window makeKeyAndOrderFront: nil];
      printf("window is key: %s\n", [window isKeyWindow] ? "yes" : "no");
      printf("allowsTypeSelect default: %s\n",
	[browser allowsTypeSelect] ? "yes" : "no");

      run(@"--- no type select delegate methods (rows: alpha beta Bravo charlie delta)",
	[[Base alloc] init]);

      run(@"--- typeSelectStringForRow:inColumn: implemented", [[WithString alloc] init]);

      WithShould *s = [[WithShould alloc] init];
      s->answer = YES;
      run(@"--- shouldTypeSelectForEvent: returning YES", s);
      WithShould *s2 = [[WithShould alloc] init];
      s2->answer = NO;
      run(@"--- shouldTypeSelectForEvent: returning NO", s2);

      WithNext *n = [[WithNext alloc] init];
      n->answer = 3;
      run(@"--- nextTypeSelectMatchFromRow: returning 3", n);
      WithNext *n2 = [[WithNext alloc] init];
      n2->answer = -1;
      run(@"--- nextTypeSelectMatchFromRow: returning -1", n2);

      printf("done\n");
    }
  return 0;
}
