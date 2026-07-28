#import <Cocoa/Cocoa.h>
#include <stdio.h>

/* The drop half of the browser delegate: does driving NSBrowser's dragging
   destination methods reach browser:validateDrop:proposedRow:column:
   dropOperation: and browser:acceptDrop:atRow:column:dropOperation:, what row
   column and operation are proposed, and does writing through the pointers
   retarget the drop? */

static NSArray *rows;

@interface FakeDrag : NSObject
{
@public
  NSPoint location;
  NSPasteboard *pb;
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
- (NSInteger) draggingSequenceNumber { return 1; }
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
  printf("    validateDrop row=%ld column=%ld operation=%lu\n",
    (long)*row, (long)*column, (unsigned long)*dropOperation);
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

int main(void)
{
  @autoreleasepool
    {
      NSBrowser *b;
      Dropper *d;
      FakeDrag *drag;
      NSWindow *window;
      NSDragOperation op;

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

      d = [[Dropper alloc] init];
      d->answer = NSDragOperationCopy;

      b = [[NSBrowser alloc] initWithFrame: NSMakeRect(0, 0, 400, 200)];
      [b setMaxVisibleColumns: 1];
      [b setDelegate: d];
      [window setContentView: b];
      [b loadColumnZero];
      [b registerForDraggedTypes: [NSArray arrayWithObject: NSPasteboardTypeString]];

      drag = [[FakeDrag alloc] init];
      drag->pb = [NSPasteboard pasteboardWithUniqueName];
      [drag->pb declareTypes: [NSArray arrayWithObject: NSPasteboardTypeString]
		       owner: nil];
      [drag->pb setString: @"payload" forType: NSPasteboardTypeString];

      printf("browser frame %s, column width %g\n",
	[NSStringFromRect([b frame]) UTF8String], [b columnWidthForColumnContentWidth: 0]);

      printf("--- draggingEntered near the top of the column\n");
      drag->location = NSMakePoint(50, 190);
      op = [b draggingEntered: (id <NSDraggingInfo>)drag];
      printf("  draggingEntered returned %lu\n", (unsigned long)op);

      printf("--- draggingUpdated in the middle of the column\n");
      drag->location = NSMakePoint(50, 100);
      op = [b draggingUpdated: (id <NSDraggingInfo>)drag];
      printf("  draggingUpdated returned %lu\n", (unsigned long)op);

      printf("--- prepareForDragOperation then performDragOperation\n");
      printf("  prepare returned %d\n",
	[b prepareForDragOperation: (id <NSDraggingInfo>)drag]);
      printf("  perform returned %d\n",
	[b performDragOperation: (id <NSDraggingInfo>)drag]);

      printf("--- delegate retargets the drop to row 4 column 0 operation 1\n");
      d->retarget = YES;
      d->retargetRow = 4;
      d->retargetColumn = 0;
      d->retargetOperation = NSBrowserDropAbove;
      drag->location = NSMakePoint(50, 100);
      op = [b draggingUpdated: (id <NSDraggingInfo>)drag];
      printf("  draggingUpdated returned %lu\n", (unsigned long)op);
      printf("  perform returned %d\n",
	[b performDragOperation: (id <NSDraggingInfo>)drag]);

      printf("--- delegate refuses the drop\n");
      d->retarget = NO;
      d->answer = NSDragOperationNone;
      op = [b draggingUpdated: (id <NSDraggingInfo>)drag];
      printf("  draggingUpdated returned %lu\n", (unsigned long)op);
      printf("  perform returned %d\n",
	[b performDragOperation: (id <NSDraggingInfo>)drag]);

      printf("done\n");
    }
  return 0;
}
