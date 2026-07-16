/* Apple oracle, pass 2: NSNibConnector's semantics (AppKit does still have the
   class) and NSSharingServicePickerToolbarItem's delegate.  Portable so the
   same file runs under GNUstep for an A/B.  activityItemsConfiguration is left
   out: AppKit has no such selector, so there is nothing to compare. */
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

/* Declared so this builds on both sides. */
@interface NSNibConnector (Probe)
- (id) source;
- (void) setSource: (id)o;
- (id) destination;
- (void) setDestination: (id)o;
- (NSString *) label;
- (void) setLabel: (NSString *)l;
- (void) establishConnection;
- (void) replaceObject: (id)a withObject: (id)b;
@end

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    SECTION("NSNibConnector defaults")
    NSNibConnector *c = [[NSNibConnector alloc] init];

    printf("INIT nonnil=%d source=%s destination=%s label=%s\n",
           c != nil, nilstr([c source]), nilstr([c destination]),
           nilstr([c label]));
    ENDSECTION

    SECTION("NSNibConnector round trips")
    NSNibConnector *c = [[NSNibConnector alloc] init];
    NSString *src = @"theSource";
    NSString *dst = @"theDestination";

    [c setSource: src];
    [c setDestination: dst];
    [c setLabel: @"theLabel"];
    printf("SET sourceSame=%d destinationSame=%d label=%s\n",
           [c source] == src, [c destination] == dst,
           [[c label] UTF8String]);

    [c setSource: nil];
    [c setLabel: nil];
    printf("SETNIL source=%s label=%s\n", nilstr([c source]),
           nilstr([c label]));
    ENDSECTION

    SECTION("NSNibConnector replaceObject:withObject:")
    NSNibConnector *c = [[NSNibConnector alloc] init];
    NSString *a = @"objectA";
    NSString *b = @"objectB";

    [c setSource: a];
    [c setDestination: a];
    [c replaceObject: a withObject: b];
    printf("REPLACE source=%s destination=%s\n",
           [[c source] UTF8String], [[c destination] UTF8String]);

    /* replacing something it does not hold changes nothing */
    [c replaceObject: @"notHeld" withObject: @"other"];
    printf("REPLACE-MISS source=%s destination=%s\n",
           [[c source] UTF8String], [[c destination] UTF8String]);
    ENDSECTION

    SECTION("NSNibConnector isEqual")
    NSNibConnector *x = [[NSNibConnector alloc] init];
    NSNibConnector *y = [[NSNibConnector alloc] init];

    printf("EMPTY selfEqual=%d twoEmptyEqual=%d\n",
           [x isEqual: x], [x isEqual: y]);

    [x setSource: @"s"]; [x setDestination: @"d"]; [x setLabel: @"l"];
    [y setSource: @"s"]; [y setDestination: @"d"]; [y setLabel: @"l"];
    printf("SAMEVALUES equal=%d\n", [x isEqual: y]);

    [y setLabel: @"different"];
    printf("DIFFERENTLABEL equal=%d\n", [x isEqual: y]);
    ENDSECTION

    SECTION("NSNibConnector establishConnection")
    NSNibConnector *c = [[NSNibConnector alloc] init];

    @try { [c establishConnection]; printf("ESTABLISH ok on an empty one\n"); }
    @catch (NSException *e) { printf("ESTABLISH raised %s\n",
      [[e name] UTF8String]); }
    ENDSECTION

    SECTION("NSSharingServicePickerToolbarItem delegate")
    NSSharingServicePickerToolbarItem *item;
    id d = [[NSObject alloc] init];

    item = [[NSSharingServicePickerToolbarItem alloc]
      initWithItemIdentifier: @"share"];
    printf("INIT nonnil=%d delegate=%s\n", item != nil, nilstr([item delegate]));

    [item setDelegate: (id)d];
    printf("SET delegateSame=%d\n", [item delegate] == d);

    [item setDelegate: nil];
    printf("SETNIL delegate=%s\n", nilstr([item delegate]));
    ENDSECTION
  }
  return 0;
}
