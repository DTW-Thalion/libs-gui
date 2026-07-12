/* Apple oracle: exact re-selection rule when removing the selected item
   from an NSPopUpButtonCell. */
#import <Cocoa/Cocoa.h>

static NSPopUpButtonCell *make(void)
{
  NSPopUpButtonCell *c = [[NSPopUpButtonCell alloc] initTextCell: @"" pullsDown: NO];
  [c addItemsWithTitles: [NSArray arrayWithObjects: @"a", @"b", @"c", @"d", nil]];
  return c;
}

int main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    /* Remove the selected middle item. */
    NSPopUpButtonCell *c1 = make();
    [c1 selectItemAtIndex: 1];        /* b */
    [c1 removeItemAtIndex: 1];        /* -> a c d */
    printf("PUB rm selected middle(1): selIndex=%ld selTitle='%s'\n",
           (long)[c1 indexOfSelectedItem], [[c1 titleOfSelectedItem] UTF8String]);

    /* Remove the selected last item. */
    NSPopUpButtonCell *c2 = make();
    [c2 selectItemAtIndex: 3];        /* d */
    [c2 removeItemAtIndex: 3];        /* -> a b c */
    printf("PUB rm selected last(3): selIndex=%ld selTitle='%s'\n",
           (long)[c2 indexOfSelectedItem], [[c2 titleOfSelectedItem] UTF8String]);

    /* Remove a non-selected item below the selection. */
    NSPopUpButtonCell *c3 = make();
    [c3 selectItemAtIndex: 2];        /* c */
    [c3 removeItemAtIndex: 0];        /* -> b c d, selection follows c */
    printf("PUB rm non-selected below (sel2 rm0): selIndex=%ld selTitle='%s'\n",
           (long)[c3 indexOfSelectedItem], [[c3 titleOfSelectedItem] UTF8String]);

    /* Remove the only item. */
    NSPopUpButtonCell *c4 = [[NSPopUpButtonCell alloc] initTextCell: @"" pullsDown: NO];
    [c4 addItemWithTitle: @"only"];
    [c4 removeItemAtIndex: 0];
    printf("PUB rm only item: numItems=%ld selIndex=%ld\n",
           (long)[c4 numberOfItems], (long)[c4 indexOfSelectedItem]);

    printf("DONE\n");
  }
  return 0;
}
