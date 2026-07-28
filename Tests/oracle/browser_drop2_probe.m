#import <Cocoa/Cocoa.h>
#include <stdio.h>

/* Second pass at the drop half: sweep the browser vertically to see which row
   and drop operation each location proposes, then check on fresh drag
   sessions what writing through the proposed row, column and operation
   pointers does, and what a refusal does. */

static NSArray *rows;
static NSInteger sequence = 100;

@interface FakeDrag : NSObject
{
@public
  NSPoint location;
  NSPasteboard *pb;
  NSInteger sequenceNumber;
}
@end

@implementation FakeDrag
- (NSWindow *) draggingDestinationWindow { return nil; }
- (NSDragOperation) draggingSourceOperationMask { return NSDragOperationEvery; }
- (NSPoint) draggingLocation { return location; }
- (NSPoint) draggedImageLocation { return location; }
- (NSImage *) draggedImage { return nil; }
- (NSPasteboard *) draggingPasteboard { return pb; }
- (id) draggingSource { return nil; }
- (NSInteger) draggingSequenceNumber { return sequenceNumber; }
- (void) slideDraggedImageTo: (NSPoint)screenPoint {}
- (NSArray *) namesOfPromisedFilesDroppedAtDestination: (NSURL *)dropDestination
{
  return nil;
}
- (BOOL) animatesToDestination { return NO; }
- (void) setAnimatesToDestination: (BOOL)flag {}
- (NSInteger) numberOfValidItemsForDrop { return 1; }
- (void) setNumberOfValidItemsForDrop: (NSInteger)n {}
- (NSDraggingFormation) draggingFormation { return NSDraggingFormationNone; }
- (void) setDraggingFormation: (NSDraggingFormation)f {}
- (BOOL) springLoadingHighlight { return NO; }
- (void) resetSpringLoading {}
- (void) enumerateDraggingItemsWithOptions: (NSDraggingItemEnumerationOptions)o
				   forView: (NSView *)v
				   classes: (NSArray *)c
			     searchOptions: (NSDictionary *)s
				usingBlock: (void (^)(NSDraggingItem *, NSInteger, BOOL *))b
{
}
@end

@interface Dropper : NSObject <NSBrowserDelegate>
{
@public
  NSInteger retargetRow;
  NSInteger retargetColumn;
  NSInteger retargetOperation;
  BOOL retarget;
  BOOL quiet;
  NSDragOperation answer;
}
@end

@implementation Dropper
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
- (NSDragOperation) browser: (NSBrowser *)browser
	       validateDrop: (id <NSDraggingInfo>)info
		proposedRow: (NSInteger *)row
		     column: (NSInteger *)column
	      dropOperation: (NSBrowserDropOperation *)dropOperation
{
  if (!quiet)
    {
      printf("    validateDrop row=%ld column=%ld operation=%lu\n",
	(long)*row, (long)*column, (unsigned long)*dropOperation);
    }
  else
    {
      printf("%ld/%ld/%lu ", (long)*row, (long)*column,
	(unsigned long)*dropOperation);
    }
  if (retarget)
    {
      *row = retargetRow;
      *column = retargetColumn;
      *dropOperation = retargetOperation;
    }
  return answer;
}
- (BOOL) browser: (NSBrowser *)browser
      acceptDrop: (id <NSDraggingInfo>)info
	   atRow: (NSInteger)row
	  column: (NSInteger)column
   dropOperation: (NSBrowserDropOperation)dropOperation
{
  printf("    acceptDrop row=%ld column=%ld operation=%lu\n", (long)row,
    (long)column, (unsigned long)dropOperation);
  return YES;
}
@end

static NSWindow *window;

static NSBrowser *
freshBrowser(Dropper *d)
{
  NSBrowser *b = [[NSBrowser alloc] initWithFrame: NSMakeRect(0, 0, 400, 200)];

  [b setMaxVisibleColumns: 1];
  [b setDelegate: d];
  [window setContentView: b];
  [b loadColumnZero];
  [b registerForDraggedTypes: [NSArray arrayWithObject: NSPasteboardTypeString]];
  return b;
}

static FakeDrag *
freshDrag(NSPoint where)
{
  FakeDrag *drag = [[FakeDrag alloc] init];

  drag->location = where;
  drag->sequenceNumber = ++sequence;
  drag->pb = [NSPasteboard pasteboardWithUniqueName];
  [drag->pb declareTypes: [NSArray arrayWithObject: NSPasteboardTypeString]
		   owner: nil];
  [drag->pb setString: @"payload" forType: NSPasteboardTypeString];
  return drag;
}

int main(void)
{
  @autoreleasepool
    {
      NSBrowser *b;
      Dropper *d;
      FakeDrag *drag;
      NSDragOperation op;
      CGFloat y;

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

      printf("--- row/column/operation proposed down the browser, 5 rows\n");
      d = [[Dropper alloc] init];
      d->answer = NSDragOperationCopy;
      d->quiet = YES;
      b = freshBrowser(d);
      printf("  frame of column 0 %s, browser is%s flipped\n",
	[NSStringFromRect([b frameOfColumn: 0]) UTF8String],
	[b isFlipped] ? "" : " not");
      for (y = 190; y >= 0; y -= 10)
	{
	  printf("  y=%3d -> ", (int)y);
	  drag = freshDrag(NSMakePoint(50, y));
	  [b draggingEntered: (id <NSDraggingInfo>)drag];
	  printf("\n");
	}

      printf("--- delegate retargets to row 4, column 0, operation DropOn\n");
      d = [[Dropper alloc] init];
      d->answer = NSDragOperationCopy;
      d->retarget = YES;
      d->retargetRow = 4;
      d->retargetColumn = 0;
      d->retargetOperation = NSBrowserDropOn;
      b = freshBrowser(d);
      drag = freshDrag(NSMakePoint(50, 120));
      op = [b draggingEntered: (id <NSDraggingInfo>)drag];
      printf("  draggingEntered returned %lu\n", (unsigned long)op);
      printf("  perform returned %d\n",
	[b performDragOperation: (id <NSDraggingInfo>)drag]);

      printf("--- delegate refuses\n");
      d = [[Dropper alloc] init];
      d->answer = NSDragOperationNone;
      b = freshBrowser(d);
      drag = freshDrag(NSMakePoint(50, 120));
      op = [b draggingEntered: (id <NSDraggingInfo>)drag];
      printf("  draggingEntered returned %lu\n", (unsigned long)op);
      printf("  perform returned %d\n",
	[b performDragOperation: (id <NSDraggingInfo>)drag]);

      printf("--- no drop delegate methods at all\n");
      b = [[NSBrowser alloc] initWithFrame: NSMakeRect(0, 0, 400, 200)];
      [b setMaxVisibleColumns: 1];
      [b setDelegate: [[Dropper alloc] init]];
      [window setContentView: b];
      [b loadColumnZero];
      drag = freshDrag(NSMakePoint(50, 120));
      printf("  unregistered browser draggingEntered returned %lu\n",
	(unsigned long)[b draggingEntered: (id <NSDraggingInfo>)drag]);

      printf("done\n");
    }
  return 0;
}
