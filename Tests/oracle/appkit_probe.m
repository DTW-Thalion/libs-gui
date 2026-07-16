/* Apple oracle, pass 4 for NSToolbarItemGroup.  Pass 3 found the real factory
   names (singular target:/action:) and the internal _buttonAtIndex:/_viewsArray
   methods, which suggests selection state lives in the buttons the factory
   builds.  This pass drives selection through a factory-built group in every
   selection mode.  Apple-only. */
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
+ (id) groupWithItemIdentifier: (NSString *)identifier
                        images: (NSArray *)images
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

    SECTION("factory shape")
    NSToolbarItemGroup *g = factoryGroup(NSToolbarItemGroupSelectionModeSelectOne);
    NSUInteger i;

    printf("FACTORY nonnil=%d class=%s identifier=%s subcount=%lu\n",
           g != nil, [NSStringFromClass([g class]) UTF8String],
           [[g itemIdentifier] UTF8String],
           (unsigned long)[[g subitems] count]);
    printf("FACTORY selMode=%ld selIdx=%ld ctlRep=%ld isGroupItem=%d\n",
           (long)[g selectionMode], (long)[g selectedIndex],
           (long)[g controlRepresentation], [g isGroupItem]);
    printf("FACTORY groupView=%s\n",
           [g view] == nil ? "nil"
             : [NSStringFromClass([[g view] class]) UTF8String]);
    for (i = 0; i < [[g subitems] count]; i++)
      {
        NSToolbarItem *it = [[g subitems] objectAtIndex: i];

        printf("SUB%lu class=%s identifier=%s label=%s view=%s\n",
               (unsigned long)i, [NSStringFromClass([it class]) UTF8String],
               [[it itemIdentifier] UTF8String], [[it label] UTF8String],
               [it view] == nil ? "nil"
                 : [NSStringFromClass([[it view] class]) UTF8String]);
      }
    ENDSECTION

    SECTION("factory SelectOne")
    NSToolbarItemGroup *g = factoryGroup(NSToolbarItemGroupSelectionModeSelectOne);

    dumpSelection(g, "FRESH");
    [g setSelected: YES atIndex: 0];
    dumpSelection(g, "SEL0");
    [g setSelected: YES atIndex: 2];
    dumpSelection(g, "SEL2");
    [g setSelected: NO atIndex: 2];
    dumpSelection(g, "DESEL2");
    [g setSelectedIndex: 1];
    dumpSelection(g, "SETIDX1");
    ENDSECTION

    SECTION("factory SelectAny")
    NSToolbarItemGroup *g = factoryGroup(NSToolbarItemGroupSelectionModeSelectAny);

    [g setSelected: YES atIndex: 0];
    [g setSelected: YES atIndex: 2];
    dumpSelection(g, "SEL02");
    [g setSelected: NO atIndex: 0];
    dumpSelection(g, "DESEL0");
    ENDSECTION

    SECTION("factory Momentary")
    NSToolbarItemGroup *g = factoryGroup(NSToolbarItemGroupSelectionModeMomentary);

    [g setSelected: YES atIndex: 1];
    dumpSelection(g, "SEL1");
    ENDSECTION

    SECTION("factory out of range")
    NSToolbarItemGroup *g = factoryGroup(NSToolbarItemGroupSelectionModeSelectOne);

    @try { printf("ISSEL99=%d\n", [g isSelectedAtIndex: 99]); }
    @catch (NSException *e) { printf("ISSEL99 raised %s\n",
      [[e name] UTF8String]); }
    @try { [g setSelected: YES atIndex: 99]; printf("SETSEL99 ok\n"); }
    @catch (NSException *e) { printf("SETSEL99 raised %s\n",
      [[e name] UTF8String]); }
    @try { [g setSelectedIndex: 99]; printf("SETIDX99 ok idx=%ld\n",
      (long)[g selectedIndex]); }
    @catch (NSException *e) { printf("SETIDX99 raised %s\n",
      [[e name] UTF8String]); }
    ENDSECTION

    SECTION("factory labels/titles mismatch and empties")
    NSToolbarItemGroup *g;

    g = [NSToolbarItemGroup groupWithItemIdentifier: @"g2"
                                             titles: [NSArray array]
                                      selectionMode:
           NSToolbarItemGroupSelectionModeSelectOne
                                             labels: [NSArray array]
                                             target: nil
                                             action: NULL];
    printf("EMPTY nonnil=%d subcount=%lu selIdx=%ld\n",
           g != nil, (unsigned long)[[g subitems] count], (long)[g selectedIndex]);

    g = [NSToolbarItemGroup groupWithItemIdentifier: @"g3"
                                             titles:
           [NSArray arrayWithObjects: @"A", @"B", nil]
                                      selectionMode:
           NSToolbarItemGroupSelectionModeSelectOne
                                             labels: nil
                                             target: nil
                                             action: NULL];
    printf("NILLABELS nonnil=%d subcount=%lu label0=%s\n",
           g != nil, (unsigned long)[[g subitems] count],
           [[g subitems] count] > 0
             ? [[[[g subitems] objectAtIndex: 0] label] UTF8String] : "-");
    ENDSECTION

    SECTION("images factory")
    NSImage *img = [[NSImage alloc] initWithSize: NSMakeSize(16, 16)];
    NSToolbarItemGroup *g;

    g = [NSToolbarItemGroup groupWithItemIdentifier: @"g4"
                                             images:
           [NSArray arrayWithObjects: img, img, nil]
                                      selectionMode:
           NSToolbarItemGroupSelectionModeSelectAny
                                             labels:
           [NSArray arrayWithObjects: @"IA", @"IB", nil]
                                             target: nil
                                             action: NULL];
    printf("IMAGES nonnil=%d subcount=%lu label0=%s image0=%s\n",
           g != nil, (unsigned long)[[g subitems] count],
           [[g subitems] count] > 0
             ? [[[[g subitems] objectAtIndex: 0] label] UTF8String] : "-",
           [[g subitems] count] > 0
             && [[[g subitems] objectAtIndex: 0] image] != nil ? "set" : "nil");
    ENDSECTION
  }
  return 0;
}
