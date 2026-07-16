/* Apple oracle, pass 3 for NSToolbarItemGroup.  Pass 2 showed the selection API
   is inert on a bare programmatically-built group (selectedIndex stays -1 in
   every mode).  This pass dumps the real method surface from the runtime and
   retries selection with view-backed subitems and with the group installed in a
   real toolbar on a window, to find out where the selection state actually
   lives.  Apple-only. */
#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
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
dumpMethods(Class c, const char *tag)
{
  unsigned int n = 0;
  Method *list = class_copyMethodList(c, &n);
  unsigned int i;
  NSMutableArray *names = [NSMutableArray array];

  for (i = 0; i < n; i++)
    {
      [names addObject: NSStringFromSelector(method_getName(list[i]))];
    }
  free(list);
  [names sortUsingSelector: @selector(compare:)];
  printf("%s (%u):\n", tag, n);
  for (NSString *s in names)
    {
      printf("  %s\n", [s UTF8String]);
    }
}

static NSToolbarItemGroup *
makeGroup(NSToolbarItemGroupSelectionMode mode, BOOL withViews)
{
  NSToolbarItemGroup *g;
  NSMutableArray *subs = [NSMutableArray array];
  int i;

  g = [[NSToolbarItemGroup alloc] initWithItemIdentifier: @"grp"];
  for (i = 0; i < 3; i++)
    {
      NSToolbarItem *it = [[NSToolbarItem alloc] initWithItemIdentifier:
        [NSString stringWithFormat: @"i%d", i]];

      if (withViews)
        {
          NSButton *b = [[NSButton alloc] initWithFrame:
            NSMakeRect(0, 0, 40, 24)];

          [b setButtonType: NSButtonTypePushOnPushOff];
          [b setTitle: [NSString stringWithFormat: @"b%d", i]];
          [it setView: b];
        }
      [it setLabel: [NSString stringWithFormat: @"L%d", i]];
      [subs addObject: it];
    }
  [g setSubitems: subs];
  [g setSelectionMode: mode];
  return g;
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

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    SECTION("method surface")
    dumpMethods(objc_getMetaClass("NSToolbarItemGroup"), "CLASS METHODS");
    dumpMethods([NSToolbarItemGroup class], "INSTANCE METHODS");
    ENDSECTION

    SECTION("factory name hunt")
    const char *cands[] = {
      "groupWithItemIdentifier:titles:selectionMode:labels:targets:actions:",
      "groupWithItemIdentifier:images:selectionMode:labels:targets:actions:",
      NULL };
    int i;

    for (i = 0; cands[i] != NULL; i++)
      {
        SEL s = NSSelectorFromString([NSString stringWithUTF8String: cands[i]]);

        printf("CLASS RESPONDS %-64s %d\n", cands[i],
               [NSToolbarItemGroup respondsToSelector: s]);
      }
    ENDSECTION

    SECTION("selection with view-backed subitems")
    NSToolbarItemGroup *g = makeGroup(NSToolbarItemGroupSelectionModeSelectOne,
                                      YES);

    dumpSelection(g, "FRESH");
    [g setSelected: YES atIndex: 1];
    dumpSelection(g, "SEL1");
    [g setSelectedIndex: 2];
    dumpSelection(g, "SETIDX2");
    ENDSECTION

    SECTION("selection inside a real toolbar on a window")
    NSToolbarItemGroup *g = makeGroup(NSToolbarItemGroupSelectionModeSelectOne,
                                      YES);
    NSWindow *w;
    NSToolbar *tb;

    w = [[NSWindow alloc] initWithContentRect: NSMakeRect(0, 0, 400, 300)
                                    styleMask: NSWindowStyleMaskTitled
                                      backing: NSBackingStoreBuffered
                                        defer: NO];
    tb = [[NSToolbar alloc] initWithIdentifier: @"tb"];
    [w setToolbar: tb];
    [tb insertItemWithItemIdentifier: @"grp" atIndex: 0];
    printf("TOOLBAR items=%lu\n", (unsigned long)[[tb items] count]);
    dumpSelection(g, "INTOOLBAR-FRESH");
    [g setSelected: YES atIndex: 1];
    dumpSelection(g, "INTOOLBAR-SEL1");
    ENDSECTION

    /* Does the group's own view exist, and is it a segmented control?  That is
       where the selection would have to live. */
    SECTION("group view")
    NSToolbarItemGroup *g = makeGroup(NSToolbarItemGroupSelectionModeSelectOne,
                                      NO);

    printf("VIEW view=%s\n",
           [g view] == nil ? "nil"
             : [NSStringFromClass([[g view] class]) UTF8String]);
    printf("VIEW subitem0 view=%s\n",
           [[[g subitems] objectAtIndex: 0] view] == nil ? "nil"
             : [NSStringFromClass([[[[g subitems] objectAtIndex: 0] view] class])
                 UTF8String]);
    ENDSECTION
  }
  return 0;
}
