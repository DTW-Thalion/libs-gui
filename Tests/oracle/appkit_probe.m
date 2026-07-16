/* Apple oracle for the NSToolbarItemGroup selection API.  GNUstep implements
   none of this, so there is no B-side to compare against: this probe exists to
   pin down Apple's semantics (enum values, defaults, the convenience
   constructor, and how selection behaves in each selection mode) before
   implementing them.  Apple-only. */
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
makeGroup(NSToolbarItemGroupSelectionMode mode)
{
  NSToolbarItemGroup *g;
  NSToolbarItem *a, *b, *c;

  g = [[NSToolbarItemGroup alloc] initWithItemIdentifier: @"grp"];
  a = [[NSToolbarItem alloc] initWithItemIdentifier: @"a"];
  b = [[NSToolbarItem alloc] initWithItemIdentifier: @"b"];
  c = [[NSToolbarItem alloc] initWithItemIdentifier: @"c"];
  [g setSubitems: [NSArray arrayWithObjects: a, b, c, nil]];
  [g setSelectionMode: mode];
  return g;
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    SECTION("enums")
    printf("SELMODE momentary=%ld selectOne=%ld selectAny=%ld\n",
           (long)NSToolbarItemGroupSelectionModeMomentary,
           (long)NSToolbarItemGroupSelectionModeSelectOne,
           (long)NSToolbarItemGroupSelectionModeSelectAny);
    printf("CTLREP automatic=%ld expanded=%ld collapsed=%ld\n",
           (long)NSToolbarItemGroupControlRepresentationAutomatic,
           (long)NSToolbarItemGroupControlRepresentationExpanded,
           (long)NSToolbarItemGroupControlRepresentationCollapsed);
    ENDSECTION

    SECTION("init defaults")
    NSToolbarItemGroup *g = [[NSToolbarItemGroup alloc]
                              initWithItemIdentifier: @"grp"];

    printf("INIT selectionMode=%ld selectedIndex=%ld controlRep=%ld\n",
           (long)[g selectionMode], (long)[g selectedIndex],
           (long)[g controlRepresentation]);
    printf("INIT subcount=%lu\n", (unsigned long)[[g subitems] count]);
    ENDSECTION

    SECTION("selectedIndex with subitems, no selection")
    NSToolbarItemGroup *g = makeGroup(NSToolbarItemGroupSelectionModeSelectOne);

    dumpSelection(g, "FRESH");
    ENDSECTION

    SECTION("setSelected atIndex - SelectOne")
    NSToolbarItemGroup *g = makeGroup(NSToolbarItemGroupSelectionModeSelectOne);

    [g setSelected: YES atIndex: 0];
    dumpSelection(g, "SEL0");
    [g setSelected: YES atIndex: 2];
    dumpSelection(g, "SEL2");
    [g setSelected: NO atIndex: 2];
    dumpSelection(g, "DESEL2");
    ENDSECTION

    SECTION("setSelected atIndex - SelectAny")
    NSToolbarItemGroup *g = makeGroup(NSToolbarItemGroupSelectionModeSelectAny);

    [g setSelected: YES atIndex: 0];
    [g setSelected: YES atIndex: 2];
    dumpSelection(g, "SEL02");
    [g setSelected: NO atIndex: 0];
    dumpSelection(g, "DESEL0");
    ENDSECTION

    SECTION("setSelected atIndex - Momentary")
    NSToolbarItemGroup *g = makeGroup(NSToolbarItemGroupSelectionModeMomentary);

    [g setSelected: YES atIndex: 1];
    dumpSelection(g, "SEL1");
    ENDSECTION

    SECTION("setSelectedIndex")
    NSToolbarItemGroup *g = makeGroup(NSToolbarItemGroupSelectionModeSelectOne);

    [g setSelectedIndex: 1];
    dumpSelection(g, "SETIDX1");
    [g setSelectedIndex: -1];
    dumpSelection(g, "SETIDXneg1");
    ENDSECTION

    SECTION("out of range")
    NSToolbarItemGroup *g = makeGroup(NSToolbarItemGroupSelectionModeSelectOne);

    @try { printf("ISSEL99=%d\n", [g isSelectedAtIndex: 99]); }
    @catch (NSException *e) { printf("ISSEL99 raised %s: %s\n",
      [[e name] UTF8String], [[e reason] UTF8String]); }
    @try { [g setSelected: YES atIndex: 99]; printf("SETSEL99 ok\n"); }
    @catch (NSException *e) { printf("SETSEL99 raised %s: %s\n",
      [[e name] UTF8String], [[e reason] UTF8String]); }
    @try { [g setSelectedIndex: 99]; printf("SETIDX99 ok idx=%ld\n",
      (long)[g selectedIndex]); }
    @catch (NSException *e) { printf("SETIDX99 raised %s: %s\n",
      [[e name] UTF8String], [[e reason] UTF8String]); }
    ENDSECTION

    SECTION("selection survives setSubitems")
    NSToolbarItemGroup *g = makeGroup(NSToolbarItemGroupSelectionModeSelectOne);
    NSToolbarItem *x;

    [g setSelected: YES atIndex: 1];
    x = [[NSToolbarItem alloc] initWithItemIdentifier: @"x"];
    [g setSubitems: [NSArray arrayWithObject: x]];
    printf("AFTER-RESET selectedIndex=%ld subcount=%lu\n",
           (long)[g selectedIndex], (unsigned long)[[g subitems] count]);
    ENDSECTION

    SECTION("controlRepresentation round trip")
    NSToolbarItemGroup *g = [[NSToolbarItemGroup alloc]
                              initWithItemIdentifier: @"grp"];

    [g setControlRepresentation:
      NSToolbarItemGroupControlRepresentationCollapsed];
    printf("CTLREP set=%ld\n", (long)[g controlRepresentation]);
    [g setSelectionMode: NSToolbarItemGroupSelectionModeSelectAny];
    printf("SELMODE set=%ld\n", (long)[g selectionMode]);
    ENDSECTION

    SECTION("convenience constructor")
    NSToolbarItemGroup *g;
    NSArray *titles = [NSArray arrayWithObjects: @"One", @"Two", nil];

    g = [NSToolbarItemGroup groupWithItemIdentifier: @"grp"
                                             titles: titles
                                      selectionMode:
           NSToolbarItemGroupSelectionModeSelectOne
                                             labels: nil
                                            targets: nil
                                            actions: nil];
    printf("FACTORY nonnil=%d identifier=%s subcount=%lu selMode=%ld selIdx=%ld\n",
           g != nil, [[g itemIdentifier] UTF8String],
           (unsigned long)[[g subitems] count], (long)[g selectionMode],
           (long)[g selectedIndex]);
    if ([[g subitems] count] > 0)
      {
        NSToolbarItem *first = [[g subitems] objectAtIndex: 0];

        printf("FACTORY first class=%s label=%s identifier=%s\n",
               [NSStringFromClass([first class]) UTF8String],
               [[first label] UTF8String],
               [[first itemIdentifier] UTF8String]);
      }
    ENDSECTION
  }
  return 0;
}
