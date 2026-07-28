/* Ground truth for the content bindings on NSTreeController, NSOutlineView and
   NSBrowser. Mirrors, assertion for assertion, the coverage written for
   GNUstep so the two can be compared directly. */
#import <Cocoa/Cocoa.h>

#define SHOW(label, fmt, ...) printf("  %-44s " fmt "\n", label, __VA_ARGS__)
#define YESNO(x) ((x) ? "YES" : "no")

@interface ProbeNode : NSObject
{
  NSString *name;
  NSMutableArray *children;
}
@property (retain) NSString *name;
- (NSMutableArray *) children;
- (BOOL) isLeaf;
@end

@implementation ProbeNode
@synthesize name;
- (id) init
{
  self = [super init];
  if (self != nil) { children = [[NSMutableArray alloc] init]; }
  return self;
}
- (NSMutableArray *) children { return children; }
- (BOOL) isLeaf { return [children count] == 0; }
@end

static ProbeNode *mk(NSString *n)
{
  ProbeNode *x = [[ProbeNode alloc] init];
  [x setName: n];
  return x;
}

/* count how many times a name appears, to see whether Apple de-duplicates */
static int countOf(NSArray *a, NSString *s)
{
  int c = 0;
  for (id o in a) { if ([o isEqual: s]) c++; }
  return c;
}

int main(void)
{
  setbuf(stdout, NULL);
  @autoreleasepool
    {
      [NSApplication sharedApplication];

      NSMutableDictionary *model = [NSMutableDictionary dictionaryWithObject:
        [NSMutableArray arrayWithObject: mk(@"first")] forKey: @"roots"];
      NSObjectController *oc =
        [[NSObjectController alloc] initWithContent: model];

      NSTreeController *tc = [[NSTreeController alloc] init];
      [tc setChildrenKeyPath: @"children"];
      [tc setLeafKeyPath: @"isLeaf"];

      printf("== NSTreeController ==\n");
      NSArray *e = [tc exposedBindings];
      SHOW("exposedBindings", "%s", [[e description] UTF8String]);
      SHOW("contains contentArray", "%s", YESNO([e containsObject: NSContentArrayBinding]));
      SHOW("contains content", "%s", YESNO([e containsObject: NSContentBinding]));
      SHOW("contains selectionIndexPaths", "%s",
           YESNO([e containsObject: NSSelectionIndexPathsBinding]));
      SHOW("infoForBinding before bind is nil", "%s",
           YESNO([tc infoForBinding: NSContentArrayBinding] == nil));

      [tc bind: NSContentArrayBinding toObject: oc
    withKeyPath: @"content.roots" options: nil];
      NSDictionary *info = [tc infoForBinding: NSContentArrayBinding];
      SHOW("infoForBinding after bind non-nil", "%s", YESNO(info != nil));
      SHOW("observed object is the controller", "%s",
           YESNO([info objectForKey: NSObservedObjectKey] == oc));
      SHOW("observed key path", "%s",
           [[[info objectForKey: NSObservedKeyPathKey] description] UTF8String]);
      SHOW("content count after bind", "%d", (int)[[tc content] count]);

      NSMutableArray *fresh = [NSMutableArray arrayWithObjects:
        mk(@"a"), mk(@"b"), mk(@"c"), nil];
      [oc setValue: fresh forKeyPath: @"content.roots"];
      SHOW("content count after replacing value", "%d", (int)[[tc content] count]);
      SHOW("arrangedObjects non-nil", "%s", YESNO([tc arrangedObjects] != nil));
      SHOW("arrangedObjects childNodes count", "%d",
           (int)[[[tc arrangedObjects] childNodes] count]);

      [tc unbind: NSContentArrayBinding];
      SHOW("infoForBinding after unbind is nil", "%s",
           YESNO([tc infoForBinding: NSContentArrayBinding] == nil));
      [tc bind: NSContentArrayBinding toObject: oc
    withKeyPath: @"content.roots" options: nil];
      SHOW("can rebind after unbind", "%s",
           YESNO([tc infoForBinding: NSContentArrayBinding] != nil));

      printf("== NSOutlineView ==\n");
      NSOutlineView *ov = [[NSOutlineView alloc]
        initWithFrame: NSMakeRect(0, 0, 300, 200)];
      NSArray *oe = [ov exposedBindings];
      SHOW("exposedBindings", "%s", [[oe description] UTF8String]);
      SHOW("contains content", "%s", YESNO([oe containsObject: NSContentBinding]));
      SHOW("contains selectionIndexes", "%s",
           YESNO([oe containsObject: NSSelectionIndexesBinding]));
      SHOW("contains sortDescriptors", "%s",
           YESNO([oe containsObject: NSSortDescriptorsBinding]));
      SHOW("times 'content' appears", "%d", countOf(oe, NSContentBinding));
      SHOW("times 'selectionIndexes' appears", "%d",
           countOf(oe, NSSelectionIndexesBinding));
      SHOW("times 'sortDescriptors' appears", "%d",
           countOf(oe, NSSortDescriptorsBinding));
      SHOW("infoForBinding before bind is nil", "%s",
           YESNO([ov infoForBinding: NSContentBinding] == nil));

      NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier: @"name"];
      [ov addTableColumn: col];
      [ov setOutlineTableColumn: col];
      @try
        {
          [ov bind: NSContentBinding toObject: tc
        withKeyPath: @"arrangedObjects" options: nil];
          SHOW("bind content to tree controller", "%s", "OK");
          SHOW("infoForBinding after bind non-nil", "%s",
               YESNO([ov infoForBinding: NSContentBinding] != nil));
          SHOW("observed object is the tree controller", "%s",
               YESNO([[ov infoForBinding: NSContentBinding]
                       objectForKey: NSObservedObjectKey] == tc));
          [ov reloadData];
          SHOW("numberOfRows after binding 3 roots", "%d", (int)[ov numberOfRows]);
          SHOW("itemAtRow:0 non-nil", "%s",
               YESNO([ov numberOfRows] > 0 && [ov itemAtRow: 0] != nil));
          [ov unbind: NSContentBinding];
          SHOW("infoForBinding after unbind is nil", "%s",
               YESNO([ov infoForBinding: NSContentBinding] == nil));
        }
      @catch (NSException *ex)
        {
          SHOW("outline view binding RAISED", "%s: %s",
               [[ex name] UTF8String], [[ex reason] UTF8String]);
        }

      printf("== NSBrowser ==\n");
      NSBrowser *br = [[NSBrowser alloc]
        initWithFrame: NSMakeRect(0, 0, 300, 200)];
      NSArray *be = [br exposedBindings];
      SHOW("exposedBindings", "%s", [[be description] UTF8String]);
      SHOW("contains content", "%s", YESNO([be containsObject: NSContentBinding]));
      SHOW("contains contentValues", "%s",
           YESNO([be containsObject: NSContentValuesBinding]));
      SHOW("infoForBinding before bind is nil", "%s",
           YESNO([br infoForBinding: NSContentBinding] == nil));
      @try
        {
          [br bind: NSContentBinding toObject: tc
        withKeyPath: @"arrangedObjects" options: nil];
          SHOW("bind content to tree controller", "%s", "OK");
          SHOW("infoForBinding after bind non-nil", "%s",
               YESNO([br infoForBinding: NSContentBinding] != nil));
          SHOW("observed object is the tree controller", "%s",
               YESNO([[br infoForBinding: NSContentBinding]
                       objectForKey: NSObservedObjectKey] == tc));
          SHOW("observed key path", "%s",
               [[[[br infoForBinding: NSContentBinding]
                   objectForKey: NSObservedKeyPathKey] description] UTF8String]);
          [br unbind: NSContentBinding];
          SHOW("infoForBinding after unbind is nil", "%s",
               YESNO([br infoForBinding: NSContentBinding] == nil));
        }
      @catch (NSException *ex)
        {
          SHOW("browser binding RAISED", "%s: %s",
               [[ex name] UTF8String], [[ex reason] UTF8String]);
        }

      printf("== done ==\n");
    }
  return 0;
}
