/* Apple oracle for NSTableRowView and NSDockTile.  Dumps the real selector
   surface of NSTableRowView (the setter names here look wrong), its init
   defaults and round-trips, and the dock tile the application vends.  Portable
   so the same file runs under GNUstep for an A/B. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
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

static const char *
nilstr(id o)
{
  return o == nil ? "nil" : "set";
}

static void
hasSel(id o, const char *name)
{
  SEL s = NSSelectorFromString([NSString stringWithUTF8String: name]);

  printf("  HAS %-46s %d\n", name, [o respondsToSelector: s]);
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    SECTION("NSTableRowView selectors")
    NSTableRowView *v = [[NSTableRowView alloc] initWithFrame:
      NSMakeRect(0, 0, 100, 20)];

    hasSel(v, "isEmphasized");
    hasSel(v, "setEmphasized:");
    hasSel(v, "interiorBackgroundStyle");
    hasSel(v, "isFloating");
    hasSel(v, "setFloating:");
    hasSel(v, "isSelected");
    hasSel(v, "setSelected:");
    hasSel(v, "selectionHighlightStyle");
    hasSel(v, "setSelectionHighlightStyle:");
    hasSel(v, "draggingDestinationFeedbackStyle");
    hasSel(v, "setDraggingDestinationFeedbackStyle:");
    hasSel(v, "setTableViewDraggingDestinationFeedbackStyle:");
    hasSel(v, "indentationForDropOperation");
    hasSel(v, "setIndentationForDropOperation:");
    hasSel(v, "isTargetForDropOperation");
    hasSel(v, "targetForDropOperation");
    hasSel(v, "setTargetForDropOperation:");
    hasSel(v, "isGroupRowStyle");
    hasSel(v, "groupRowStyle");
    hasSel(v, "setGroupRowStyle:");
    hasSel(v, "numberOfColumns");
    hasSel(v, "backgroundColor");
    hasSel(v, "setBackgroundColor:");
    hasSel(v, "isNextRowSelected");
    hasSel(v, "setNextRowSelected:");
    hasSel(v, "isPreviousRowSelected");
    hasSel(v, "setPreviousRowSelected:");
    hasSel(v, "viewAtColumn:");
    ENDSECTION

    SECTION("NSTableRowView defaults")
    NSTableRowView *v = [[NSTableRowView alloc] initWithFrame:
      NSMakeRect(0, 0, 100, 20)];

    printf("INIT emphasized=%d floating=%d selected=%d\n",
           [v isEmphasized], [v isFloating], [v isSelected]);
    printf("INIT selectionHighlightStyle=%ld interiorBackgroundStyle=%ld\n",
           (long)[v selectionHighlightStyle], (long)[v interiorBackgroundStyle]);
    printf("INIT draggingDestinationFeedbackStyle=%ld indentation=%g\n",
           (long)[v draggingDestinationFeedbackStyle],
           (double)[v indentationForDropOperation]);
    printf("INIT numberOfColumns=%ld backgroundColor=%s\n",
           (long)[v numberOfColumns], nilstr([v backgroundColor]));
    printf("INIT nextRowSelected=%d previousRowSelected=%d\n",
           [v isNextRowSelected], [v isPreviousRowSelected]);
    ENDSECTION

    SECTION("NSTableRowView round trips")
    NSTableRowView *v = [[NSTableRowView alloc] initWithFrame:
      NSMakeRect(0, 0, 100, 20)];
    NSColor *c = [NSColor redColor];

    [v setEmphasized: YES];
    [v setFloating: YES];
    [v setSelected: YES];
    [v setGroupRowStyle: YES];
    [v setNextRowSelected: YES];
    [v setPreviousRowSelected: YES];
    [v setIndentationForDropOperation: 12.5];
    [v setBackgroundColor: c];
    [v setSelectionHighlightStyle: NSTableViewSelectionHighlightStyleSourceList];
    printf("SET emphasized=%d floating=%d selected=%d next=%d prev=%d\n",
           [v isEmphasized], [v isFloating], [v isSelected],
           [v isNextRowSelected], [v isPreviousRowSelected]);
    printf("SET indentation=%g backgroundColorSame=%d highlightStyle=%ld\n",
           (double)[v indentationForDropOperation], [v backgroundColor] == c,
           (long)[v selectionHighlightStyle]);
    ENDSECTION

    SECTION("NSTableViewSelectionHighlightStyle enum")
    printf("HIGHLIGHT none=%ld regular=%ld sourceList=%ld\n",
           (long)NSTableViewSelectionHighlightStyleNone,
           (long)NSTableViewSelectionHighlightStyleRegular,
           (long)NSTableViewSelectionHighlightStyleSourceList);
    ENDSECTION

    SECTION("the application dock tile")
    NSDockTile *t = [NSApp dockTile];

    printf("APPTILE nonnil=%d contentView=%s size=%gx%g\n",
           t != nil, nilstr([t contentView]),
           (double)[t size].width, (double)[t size].height);
    printf("APPTILE badgeLabel=%s showsApplicationBadge=%d owner=%s\n",
           nilstr([t badgeLabel]), [t showsApplicationBadge],
           nilstr([t owner]));
    ENDSECTION

    SECTION("dock tile round trips")
    NSDockTile *t = [NSApp dockTile];
    NSView *v = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 10, 10)];

    [t setBadgeLabel: @"7"];
    printf("SET badgeLabel=%s\n", [[t badgeLabel] UTF8String]);
    [t setShowsApplicationBadge: NO];
    printf("SET showsApplicationBadge=%d\n", [t showsApplicationBadge]);
    [t setContentView: v];
    printf("SET contentViewSame=%d\n", [t contentView] == v);
    ENDSECTION

    SECTION("allocating a dock tile directly")
    NSDockTile *t = [[NSDockTile alloc] init];

    printf("ALLOC nonnil=%d contentView=%s size=%gx%g badge=%d\n",
           t != nil, nilstr([t contentView]),
           (double)[t size].width, (double)[t size].height,
           [t showsApplicationBadge]);
    ENDSECTION
  }
  return 0;
}
