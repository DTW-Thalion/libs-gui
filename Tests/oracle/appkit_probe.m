/* Apple oracle, pass 6 for NSToolbarItemGroup.  Pins the corners the earlier
   passes left ambiguous, all on a factory-built group where the selection API
   is live: what selectedIndex means under SelectAny, what setSelectedIndex: -1
   does, whether setSelectedIndex: clears the other selections, what changing
   the selection mode does to an existing selection, and whether replacing the
   subitems resets it.  Apple-only. */
#import <Cocoa/Cocoa.h>
#include <stdio.h>

#define SECTION(NAME) \
  printf("\n== " NAME " ==\n"); \
  @try {

#define ENDSECTION \
  } @catch (NSException *e) { \
    printf("EXCEPTION %s: %s\n", [[e name] UTF8String], \
           [[e reason] UTF8String]); \
  }

@interface NSToolbarItemGroup (Probe)
+ (id) groupWithItemIdentifier: (NSString *)identifier
                        titles: (NSArray *)titles
                 selectionMode: (NSToolbarItemGroupSelectionMode)mode
                        labels: (NSArray *)labels
                        target: (id)target
                        action: (SEL)action;
@end

static void
dumpSelection(NSToolbarItemGroup *g, const char *tag)
{
  NSUInteger i;
  NSUInteger count = [[g subitems] count];

  printf("%s selectedIndex=%ld selected=[", tag, (long)[g selectedIndex]);
  for (i = 0; i < count; i++)
    {
      printf("%d%s", [g isSelectedAtIndex: i], i + 1 == count ? "" : ",");
    }
  printf("]\n");
}

static NSToolbarItemGroup *
factoryGroup(NSToolbarItemGroupSelectionMode mode)
{
  NSArray *titles = [NSArray arrayWithObjects: @"T0", @"T1", @"T2", nil];
  NSArray *labels = [NSArray arrayWithObjects: @"L0", @"L1", @"L2", nil];

  return [NSToolbarItemGroup groupWithItemIdentifier: @"grp"
                                              titles: titles
                                       selectionMode: mode
                                              labels: labels
                                              target: nil
                                              action: NULL];
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    /* Is selectedIndex the last one selected, or the lowest/highest? */
    SECTION("SelectAny selectedIndex meaning")
    NSToolbarItemGroup *g = factoryGroup(NSToolbarItemGroupSelectionModeSelectAny);

    [g setSelected: YES atIndex: 2];
    dumpSelection(g, "SEL2");
    [g setSelected: YES atIndex: 0];
    dumpSelection(g, "THEN-SEL0");
    [g setSelected: YES atIndex: 1];
    dumpSelection(g, "THEN-SEL1");
    ENDSECTION

    SECTION("SelectAny setSelectedIndex")
    NSToolbarItemGroup *g = factoryGroup(NSToolbarItemGroupSelectionModeSelectAny);

    [g setSelected: YES atIndex: 0];
    [g setSelected: YES atIndex: 2];
    dumpSelection(g, "SEL02");
    [g setSelectedIndex: 1];
    dumpSelection(g, "SETIDX1");
    ENDSECTION

    SECTION("setSelectedIndex -1")
    NSToolbarItemGroup *one = factoryGroup(NSToolbarItemGroupSelectionModeSelectOne);
    NSToolbarItemGroup *any = factoryGroup(NSToolbarItemGroupSelectionModeSelectAny);

    [one setSelected: YES atIndex: 1];
    dumpSelection(one, "ONE-SEL1");
    @try { [one setSelectedIndex: -1]; dumpSelection(one, "ONE-SETIDXneg1"); }
    @catch (NSException *e) { printf("ONE-SETIDXneg1 raised %s\n",
      [[e name] UTF8String]); }

    [any setSelected: YES atIndex: 1];
    @try { [any setSelectedIndex: -1]; dumpSelection(any, "ANY-SETIDXneg1"); }
    @catch (NSException *e) { printf("ANY-SETIDXneg1 raised %s\n",
      [[e name] UTF8String]); }
    ENDSECTION

    SECTION("Momentary setSelectedIndex")
    NSToolbarItemGroup *g = factoryGroup(NSToolbarItemGroupSelectionModeMomentary);

    [g setSelectedIndex: 1];
    dumpSelection(g, "MOM-SETIDX1");
    ENDSECTION

    SECTION("changing the selection mode with a live selection")
    NSToolbarItemGroup *g = factoryGroup(NSToolbarItemGroupSelectionModeSelectAny);

    [g setSelected: YES atIndex: 0];
    [g setSelected: YES atIndex: 2];
    dumpSelection(g, "ANY-SEL02");
    [g setSelectionMode: NSToolbarItemGroupSelectionModeSelectOne];
    dumpSelection(g, "NOW-SELECTONE");
    [g setSelectionMode: NSToolbarItemGroupSelectionModeMomentary];
    dumpSelection(g, "NOW-MOMENTARY");
    [g setSelectionMode: NSToolbarItemGroupSelectionModeSelectAny];
    dumpSelection(g, "BACK-TO-ANY");
    ENDSECTION

    SECTION("replacing the subitems")
    NSToolbarItemGroup *g = factoryGroup(NSToolbarItemGroupSelectionModeSelectOne);
    NSToolbarItem *x, *y;

    [g setSelected: YES atIndex: 2];
    dumpSelection(g, "BEFORE");
    x = [[NSToolbarItem alloc] initWithItemIdentifier: @"x"];
    y = [[NSToolbarItem alloc] initWithItemIdentifier: @"y"];
    [g setSubitems: [NSArray arrayWithObjects: x, y, nil]];
    dumpSelection(g, "AFTER-SETSUBITEMS");
    ENDSECTION

    /* Does selection work at all once subitems come from setSubitems:? */
    SECTION("select after replacing the subitems")
    NSToolbarItemGroup *g = factoryGroup(NSToolbarItemGroupSelectionModeSelectOne);
    NSToolbarItem *x, *y;

    x = [[NSToolbarItem alloc] initWithItemIdentifier: @"x"];
    y = [[NSToolbarItem alloc] initWithItemIdentifier: @"y"];
    [g setSubitems: [NSArray arrayWithObjects: x, y, nil]];
    @try { [g setSelected: YES atIndex: 1]; dumpSelection(g, "SEL1"); }
    @catch (NSException *e) { printf("SEL1 raised %s\n", [[e name] UTF8String]); }
    ENDSECTION
  }
  return 0;
}
