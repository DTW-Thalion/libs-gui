/* Apple oracle for NSTextAlternatives, NSToolbarItemGroup and
   NSMenuToolbarItem.  Probes the init defaults, the getter storage semantics
   (retain vs copy, live vs snapshot), the setter round-trips, -copy, and the
   NSTextAlternatives notification name and userInfo.  Portable so the same
   file runs under GNUstep for an A/B. */
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

@interface Observer : NSObject
{
@public
  int count;
  id object;
  NSDictionary *info;
}
@end

@implementation Observer
- (void) got: (NSNotification *)n
{
  count++;
  object = [n object];
  info = [[n userInfo] copy];
}
@end

static void
probeTextAlternatives(void)
{
  SECTION("NSTextAlternatives")
  NSString *primary = @"colour";
  NSArray *alts = [NSArray arrayWithObjects: @"color", @"colours", nil];
  NSTextAlternatives *ta;

  ta = [[NSTextAlternatives alloc] initWithPrimaryString: primary
                                     alternativeStrings: alts];
  printf("INIT nonnil=%d\n", ta != nil);
  printf("PRIMARY equal=%d same=%d value=%s\n",
         [[ta primaryString] isEqualToString: primary],
         [ta primaryString] == primary,
         [[ta primaryString] UTF8String]);
  printf("ALTS equal=%d same=%d count=%lu class=%s\n",
         [[ta alternativeStrings] isEqualToArray: alts],
         [ta alternativeStrings] == alts,
         (unsigned long)[[ta alternativeStrings] count],
         [NSStringFromClass([[ta alternativeStrings] class]) UTF8String]);
  /* Two getter calls: same object back, or a fresh copy each time? */
  printf("PRIMARY stable=%d ALTS stable=%d\n",
         [ta primaryString] == [ta primaryString],
         [ta alternativeStrings] == [ta alternativeStrings]);
  ENDSECTION

  /* Live or snapshot: mutate the objects that were handed to -init. */
  SECTION("NSTextAlternatives mutable")
  NSMutableString *mprimary = [NSMutableString stringWithString: @"abc"];
  NSMutableArray *malts = [NSMutableArray arrayWithObject: @"x"];
  NSTextAlternatives *ta;

  ta = [[NSTextAlternatives alloc] initWithPrimaryString: mprimary
                                     alternativeStrings: malts];
  [mprimary appendString: @"DEF"];
  [malts addObject: @"y"];
  printf("MUTATED primary=%s altcount=%lu\n",
         [[ta primaryString] UTF8String],
         (unsigned long)[[ta alternativeStrings] count]);
  printf("PRIMARY class=%s\n",
         [NSStringFromClass([[ta primaryString] class]) UTF8String]);
  ENDSECTION

  SECTION("NSTextAlternatives nil")
  NSTextAlternatives *ta;

  ta = [[NSTextAlternatives alloc] initWithPrimaryString: nil
                                     alternativeStrings: nil];
  printf("NILINIT nonnil=%d primary=%s alts=%s\n",
         ta != nil, nilstr([ta primaryString]), nilstr([ta alternativeStrings]));
  ENDSECTION

  SECTION("NSTextAlternatives notification")
  NSString *primary = @"colour";
  NSArray *alts = [NSArray arrayWithObjects: @"color", nil];
  NSTextAlternatives *ta;
  Observer *obs = [[Observer alloc] init];

  printf("NAME value=%s\n",
         [NSTextAlternativesSelectedAlternativeStringNotification UTF8String]);

  ta = [[NSTextAlternatives alloc] initWithPrimaryString: primary
                                     alternativeStrings: alts];
  [[NSNotificationCenter defaultCenter]
    addObserver: obs
       selector: @selector(got:)
           name: NSTextAlternativesSelectedAlternativeStringNotification
         object: nil];
  [ta noteSelectedAlternativeString: @"color"];
  printf("POSTED count=%d objectIsTa=%d\n", obs->count, obs->object == ta);
  printf("USERINFO keys=%s\n",
         [[[[obs->info allKeys] sortedArrayUsingSelector: @selector(compare:)]
            componentsJoinedByString: @","] UTF8String]);
  printf("USERINFO NSAlternativeString=%s\n",
         [[[obs->info objectForKey: @"NSAlternativeString"] description]
           UTF8String]);
  [[NSNotificationCenter defaultCenter] removeObserver: obs];
  ENDSECTION
}

static void
probeToolbarItemGroup(void)
{
  SECTION("NSToolbarItemGroup")
  NSToolbarItemGroup *g;
  NSToolbarItem *a, *b;
  NSArray *items;

  g = [[NSToolbarItemGroup alloc] initWithItemIdentifier: @"grp"];
  printf("INIT nonnil=%d identifier=%s subitems=%s\n",
         g != nil, [[g itemIdentifier] UTF8String], nilstr([g subitems]));
  printf("INIT subcount=%lu subclass=%s\n",
         (unsigned long)[[g subitems] count],
         [NSStringFromClass([[g subitems] class]) UTF8String]);

  a = [[NSToolbarItem alloc] initWithItemIdentifier: @"a"];
  b = [[NSToolbarItem alloc] initWithItemIdentifier: @"b"];
  items = [NSArray arrayWithObjects: a, b, nil];
  [g setSubitems: items];
  printf("SET count=%lu equal=%d same=%d first=%s\n",
         (unsigned long)[[g subitems] count],
         [[g subitems] isEqualToArray: items],
         [g subitems] == items,
         [[[[g subitems] objectAtIndex: 0] itemIdentifier] UTF8String]);
  ENDSECTION

  SECTION("NSToolbarItemGroup copy")
  NSToolbarItemGroup *g, *copy;
  NSToolbarItem *a;

  g = [[NSToolbarItemGroup alloc] initWithItemIdentifier: @"grp"];
  a = [[NSToolbarItem alloc] initWithItemIdentifier: @"a"];
  [g setSubitems: [NSArray arrayWithObject: a]];
  copy = [g copy];
  printf("COPY nonnil=%d identifier=%s subcount=%lu sameArray=%d\n",
         copy != nil, [[copy itemIdentifier] UTF8String],
         (unsigned long)[[copy subitems] count],
         [copy subitems] == [g subitems]);
  ENDSECTION

  SECTION("NSToolbarItemGroup nil subitems")
  NSToolbarItemGroup *g;

  g = [[NSToolbarItemGroup alloc] initWithItemIdentifier: @"grp"];
  [g setSubitems: [NSArray arrayWithObject:
    [[NSToolbarItem alloc] initWithItemIdentifier: @"a"]]];
  [g setSubitems: nil];
  printf("SETNIL subitems=%s count=%lu\n",
         nilstr([g subitems]), (unsigned long)[[g subitems] count]);
  ENDSECTION

  /* Which of Apple's group API does this runtime have?  Informational: tells
     us what GNUstep is missing without asserting anything. */
  SECTION("NSToolbarItemGroup selectors")
  NSToolbarItemGroup *g = [[NSToolbarItemGroup alloc]
                            initWithItemIdentifier: @"grp"];
  const char *sels[] = { "subitems", "setSubitems:", "selectionMode",
                         "setSelectionMode:", "selectedIndex",
                         "setSelectedIndex:", "controlRepresentation",
                         "setControlRepresentation:", "isSelectedAtIndex:",
                         "setSelected:atIndex:", NULL };
  int i;

  for (i = 0; sels[i] != NULL; i++)
    {
      SEL s = NSSelectorFromString([NSString stringWithUTF8String: sels[i]]);

      printf("HAS %-28s %d\n", sels[i], [g respondsToSelector: s]);
    }
  ENDSECTION
}

static void
probeMenuToolbarItem(void)
{
  SECTION("NSMenuToolbarItem")
  NSMenuToolbarItem *mi;
  NSMenu *menu;

  mi = [[NSMenuToolbarItem alloc] initWithItemIdentifier: @"mti"];
  printf("INIT nonnil=%d identifier=%s showsIndicator=%d menu=%s image=%s\n",
         mi != nil, [[mi itemIdentifier] UTF8String],
         [mi showsIndicator], nilstr([mi menu]), nilstr([mi image]));

  menu = [[NSMenu alloc] initWithTitle: @"m"];
  [mi setMenu: menu];
  printf("SETMENU same=%d title=%s\n",
         [mi menu] == menu, [[[mi menu] title] UTF8String]);

  [mi setShowsIndicator: NO];
  printf("SHOWS no=%d imageAfterNo=%s\n", [mi showsIndicator],
         nilstr([mi image]));
  [mi setShowsIndicator: YES];
  printf("SHOWS yes=%d imageAfterYes=%s\n", [mi showsIndicator],
         nilstr([mi image]));
  ENDSECTION
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    probeTextAlternatives();
    probeToolbarItemGroup();
    probeMenuToolbarItem();
  }
  return 0;
}
