/* Apple oracle for NSSearchFieldCell and NSTextBlock.  Probes the init
   defaults, the setter round-trips, what maximumRecents does with values out
   of its range, and the text block's value/margin/border defaults.  Portable
   so the same file runs under GNUstep for an A/B. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
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

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    SECTION("NSSearchFieldCell init defaults")
    NSSearchFieldCell *c = [[NSSearchFieldCell alloc] initTextCell: @"find"];

    printf("INIT maximumRecents=%ld sendsWholeSearchString=%d\n",
           (long)[c maximumRecents], [c sendsWholeSearchString]);
    printf("INIT sendsSearchStringImmediately=%d\n",
           [c sendsSearchStringImmediately]);
    printf("INIT recentSearches=%s count=%lu\n",
           nilstr([c recentSearches]),
           (unsigned long)[[c recentSearches] count]);
    printf("INIT recentsAutosaveName=%s searchMenuTemplate=%s\n",
           nilstr([c recentsAutosaveName]), nilstr([c searchMenuTemplate]));
    printf("INIT cancelButtonCell=%s searchButtonCell=%s\n",
           nilstr([c cancelButtonCell]), nilstr([c searchButtonCell]));
    ENDSECTION

    SECTION("maximumRecents out of range")
    NSSearchFieldCell *c = [[NSSearchFieldCell alloc] initTextCell: @"find"];
    NSInteger values[] = { -5, -1, 0, 1, 5, 254, 255, 1000 };
    int i;

    for (i = 0; i < 8; i++)
      {
        [c setMaximumRecents: values[i]];
        printf("SET %-5ld -> %ld\n", (long)values[i], (long)[c maximumRecents]);
      }
    ENDSECTION

    SECTION("NSSearchFieldCell round trips")
    NSSearchFieldCell *c = [[NSSearchFieldCell alloc] initTextCell: @"find"];
    NSArray *searches = [NSArray arrayWithObjects: @"one", @"two", nil];
    NSMenu *menu = [[NSMenu alloc] initWithTitle: @"m"];

    [c setSendsWholeSearchString: YES];
    [c setSendsSearchStringImmediately: YES];
    [c setRecentSearches: searches];
    [c setRecentsAutosaveName: @"saved"];
    [c setSearchMenuTemplate: menu];
    printf("SET whole=%d immediate=%d autosave=%s menuSame=%d\n",
           [c sendsWholeSearchString], [c sendsSearchStringImmediately],
           [[c recentsAutosaveName] UTF8String],
           [c searchMenuTemplate] == menu);
    printf("SET recentCount=%lu equal=%d same=%d\n",
           (unsigned long)[[c recentSearches] count],
           [[c recentSearches] isEqualToArray: searches],
           [c recentSearches] == searches);
    ENDSECTION

    SECTION("recentSearches past maximumRecents")
    NSSearchFieldCell *c = [[NSSearchFieldCell alloc] initTextCell: @"find"];
    NSArray *many = [NSArray arrayWithObjects: @"1", @"2", @"3", @"4", @"5",
      nil];

    [c setMaximumRecents: 3];
    [c setRecentSearches: many];
    printf("TRUNCATE max=3 given=5 -> count=%lu\n",
           (unsigned long)[[c recentSearches] count]);
    ENDSECTION

    SECTION("NSTextBlockValueType enum")
    printf("VALUETYPE absolute=%ld percentage=%ld\n",
           (long)NSTextBlockAbsoluteValueType,
           (long)NSTextBlockPercentageValueType);
    printf("DIMENSION width=%ld minWidth=%ld maxWidth=%ld height=%ld\n",
           (long)NSTextBlockWidth, (long)NSTextBlockMinimumWidth,
           (long)NSTextBlockMaximumWidth, (long)NSTextBlockHeight);
    printf("LAYER padding=%ld border=%ld margin=%ld\n",
           (long)NSTextBlockPadding, (long)NSTextBlockBorder,
           (long)NSTextBlockMargin);
    ENDSECTION

    SECTION("NSTextBlock init defaults")
    NSTextBlock *b = [[NSTextBlock alloc] init];

    printf("INIT contentWidth=%g type=%ld\n",
           (double)[b contentWidth], (long)[b contentWidthValueType]);
    printf("INIT backgroundColor=%s\n", nilstr([b backgroundColor]));
    printf("INIT verticalAlignment=%ld\n", (long)[b verticalAlignment]);
    printf("INIT widthTop=%g widthLeft=%g (border layer)\n",
           (double)[b widthForLayer: NSTextBlockBorder edge: NSMinYEdge],
           (double)[b widthForLayer: NSTextBlockBorder edge: NSMinXEdge]);
    printf("INIT borderColorTop=%s\n",
           nilstr([b borderColorForEdge: NSMinYEdge]));
    ENDSECTION

    SECTION("NSTextBlock round trips")
    NSTextBlock *b = [[NSTextBlock alloc] init];
    NSColor *red = [NSColor redColor];

    [b setContentWidth: 50.0 type: NSTextBlockAbsoluteValueType];
    printf("SET contentWidth=%g type=%ld\n",
           (double)[b contentWidth], (long)[b contentWidthValueType]);

    [b setBackgroundColor: red];
    printf("SET backgroundColorSame=%d\n", [b backgroundColor] == red);

    [b setWidth: 3.0 type: NSTextBlockAbsoluteValueType
      forLayer: NSTextBlockBorder];
    printf("SET borderWidthTop=%g type=%ld\n",
           (double)[b widthForLayer: NSTextBlockBorder edge: NSMinYEdge],
           (long)[b widthValueTypeForLayer: NSTextBlockBorder
                                      edge: NSMinYEdge]);

    [b setWidth: 7.0 type: NSTextBlockAbsoluteValueType
      forLayer: NSTextBlockMargin edge: NSMaxXEdge];
    printf("SET marginRight=%g marginLeftUnset=%g\n",
           (double)[b widthForLayer: NSTextBlockMargin edge: NSMaxXEdge],
           (double)[b widthForLayer: NSTextBlockMargin edge: NSMinXEdge]);

    [b setBorderColor: red forEdge: NSMinYEdge];
    printf("SET borderColorTopSame=%d borderColorBottom=%s\n",
           [b borderColorForEdge: NSMinYEdge] == red,
           nilstr([b borderColorForEdge: NSMaxYEdge]));

    [b setBorderColor: [NSColor blueColor]];
    printf("SET allEdgesBlue top=%d bottom=%d\n",
           [b borderColorForEdge: NSMinYEdge] == [NSColor blueColor],
           [b borderColorForEdge: NSMaxYEdge] == [NSColor blueColor]);
    ENDSECTION
  }
  return 0;
}
