/* Apple oracle for the NSComboBoxCell coverage test: defaults, the
   internal item list, selection, and completedString:. */
#import <Cocoa/Cocoa.h>

int main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    NSComboBoxCell *c = [[NSComboBoxCell alloc] initTextCell: @""];
    printf("CB defaults: usesDataSource=%d hasVScroller=%d completes=%d buttonBordered=%d\n",
           [c usesDataSource], [c hasVerticalScroller], [c completes], [c isButtonBordered]);
    printf("CB defaults: numVisible=%ld itemHeight=%g intercell=%gx%g selected=%ld numItems=%ld\n",
           (long)[c numberOfVisibleItems], [c itemHeight],
           [c intercellSpacing].width, [c intercellSpacing].height,
           (long)[c indexOfSelectedItem], (long)[c numberOfItems]);

    /* Internal item list. */
    [c addItemWithObjectValue: @"alpha"];
    [c addItemsWithObjectValues: [NSArray arrayWithObjects: @"beta", @"gamma", nil]];
    printf("CB after add 3: numItems=%ld item0=%s item2=%s\n",
           (long)[c numberOfItems], [[c itemObjectValueAtIndex: 0] UTF8String],
           [[c itemObjectValueAtIndex: 2] UTF8String]);
    printf("CB objectValues=%s\n", [[[c objectValues] componentsJoinedByString: @","] UTF8String]);
    printf("CB indexOf beta=%ld indexOf missing=%ld (NSNotFound=%ld)\n",
           (long)[c indexOfItemWithObjectValue: @"beta"],
           (long)[c indexOfItemWithObjectValue: @"zzz"], (long)NSNotFound);

    [c insertItemWithObjectValue: @"inserted" atIndex: 1];
    printf("CB after insert at 1: item1=%s numItems=%ld\n",
           [[c itemObjectValueAtIndex: 1] UTF8String], (long)[c numberOfItems]);

    /* Selection. */
    [c selectItemAtIndex: 2];
    printf("CB select 2: selIndex=%ld selValue=%s\n",
           (long)[c indexOfSelectedItem], [[c objectValueOfSelectedItem] UTF8String]);
    [c selectItemWithObjectValue: @"alpha"];
    printf("CB selectWithValue alpha: selIndex=%ld\n", (long)[c indexOfSelectedItem]);
    [c selectItemWithObjectValue: @"nothere"];
    printf("CB selectWithValue missing: selIndex=%ld selValue nil:%d\n",
           (long)[c indexOfSelectedItem], [c objectValueOfSelectedItem] == nil);
    [c selectItemAtIndex: 0];
    [c deselectItemAtIndex: 0];
    printf("CB deselect: selIndex=%ld\n", (long)[c indexOfSelectedItem]);

    /* Removal. */
    [c removeItemWithObjectValue: @"beta"];
    printf("CB after remove beta: numItems=%ld indexOf beta=%ld\n",
           (long)[c numberOfItems], (long)[c indexOfItemWithObjectValue: @"beta"]);
    [c removeItemAtIndex: 0];
    printf("CB after removeAt 0: item0=%s numItems=%ld\n",
           [[c itemObjectValueAtIndex: 0] UTF8String], (long)[c numberOfItems]);
    [c removeAllItems];
    printf("CB after removeAll: numItems=%ld\n", (long)[c numberOfItems]);

    /* completedString: prefix completion against the item list. */
    NSComboBoxCell *cc = [[NSComboBoxCell alloc] initTextCell: @""];
    [cc addItemsWithObjectValues:
      [NSArray arrayWithObjects: @"Apple", @"Apricot", @"Banana", nil]];
    printf("CB completedString 'Ap'='%s' 'Ban'='%s' 'xyz'='%s'\n",
           [[cc completedString: @"Ap"] UTF8String],
           [[cc completedString: @"Ban"] UTF8String],
           [[cc completedString: @"xyz"] UTF8String]);

    printf("DONE\n");
  }
  return 0;
}
