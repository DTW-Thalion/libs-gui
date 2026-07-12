/* Apple oracle for the NSPopUpButtonCell coverage test: defaults, the menu
   item list, auto-selection, duplicate-title handling and selection. */
#import <Cocoa/Cocoa.h>

int main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    NSPopUpButtonCell *c = [[NSPopUpButtonCell alloc] initTextCell: @"" pullsDown: NO];
    printf("PUB defaults: pullsDown=%d autoenables=%d usesItemFromMenu=%d altersState=%d\n",
           [c pullsDown], [c autoenablesItems], [c usesItemFromMenu], [c altersStateOfSelectedItem]);
    printf("PUB defaults: preferredEdge=%lu (maxY=%lu) arrowPosition=%ld numItems=%ld selIndex=%ld\n",
           (unsigned long)[c preferredEdge], (unsigned long)NSMaxYEdge,
           (long)[c arrowPosition], (long)[c numberOfItems], (long)[c indexOfSelectedItem]);

    /* Adding the first item auto-selects it. */
    [c addItemWithTitle: @"alpha"];
    printf("PUB after add alpha: numItems=%ld selIndex=%ld selTitle='%s'\n",
           (long)[c numberOfItems], (long)[c indexOfSelectedItem],
           [[c titleOfSelectedItem] UTF8String]);
    [c addItemsWithTitles: [NSArray arrayWithObjects: @"beta", @"gamma", nil]];
    printf("PUB after add 2 more: numItems=%ld selIndex=%ld titles=%s\n",
           (long)[c numberOfItems], (long)[c indexOfSelectedItem],
           [[[c itemTitles] componentsJoinedByString: @","] UTF8String]);

    /* Duplicate title moves the item; no duplicate is created. */
    [c addItemWithTitle: @"beta"];
    printf("PUB after add dup beta: numItems=%ld indexOf beta=%ld\n",
           (long)[c numberOfItems], (long)[c indexOfItemWithTitle: @"beta"]);

    /* Insert at a position. */
    [c insertItemWithTitle: @"inserted" atIndex: 1];
    printf("PUB insert at 1: title@1='%s' numItems=%ld\n",
           [[c itemTitleAtIndex: 1] UTF8String], (long)[c numberOfItems]);

    /* Queries. */
    printf("PUB indexOf gamma=%ld itemWithTitle alpha!=nil:%d lastItem title='%s'\n",
           (long)[c indexOfItemWithTitle: @"gamma"],
           [c itemWithTitle: @"alpha"] != nil, [[[c lastItem] title] UTF8String]);
    printf("PUB indexOf missing=%ld\n", (long)[c indexOfItemWithTitle: @"nope"]);

    /* Tag lookup. */
    [[c itemAtIndex: 2] setTag: 42];
    printf("PUB indexOfItemWithTag 42=%ld tag99=%ld\n",
           (long)[c indexOfItemWithTag: 42], (long)[c indexOfItemWithTag: 99]);

    /* Selection. */
    [c selectItemAtIndex: 2];
    printf("PUB select 2: selIndex=%ld selTitle='%s'\n",
           (long)[c indexOfSelectedItem], [[c titleOfSelectedItem] UTF8String]);
    [c selectItemWithTitle: @"alpha"];
    printf("PUB selectWithTitle alpha: selIndex=%ld\n", (long)[c indexOfSelectedItem]);

    /* Removal (removing the selected item). */
    [c selectItemAtIndex: 0];
    [c removeItemAtIndex: 0];
    printf("PUB remove selected 0: numItems=%ld selIndex=%ld\n",
           (long)[c numberOfItems], (long)[c indexOfSelectedItem]);
    [c removeAllItems];
    printf("PUB removeAll: numItems=%ld selIndex=%ld\n",
           (long)[c numberOfItems], (long)[c indexOfSelectedItem]);

    /* Property round-trips. */
    [c setPullsDown: YES];
    [c setAutoenablesItems: NO];
    [c setPreferredEdge: NSMinXEdge];
    [c setArrowPosition: NSPopUpArrowAtBottom];
    printf("PUB roundtrip pullsDown=%d autoenables=%d preferredEdge=%lu arrow=%ld\n",
           [c pullsDown], [c autoenablesItems],
           (unsigned long)[c preferredEdge], (long)[c arrowPosition]);

    printf("DONE\n");
  }
  return 0;
}
