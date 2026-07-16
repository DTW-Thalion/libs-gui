/* Apple oracle, pass 3.  NSNibConnector is in AppKit's binary but not in its
   headers any more, so it is reached through the runtime rather than compiled
   against.  Also NSSharingServicePickerToolbarItem's delegate, whose setter is
   a no-op here.  Portable so the same file runs under GNUstep for an A/B. */
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

static id
get(id o, const char *name)
{
  return [o performSelector: NSSelectorFromString(
    [NSString stringWithUTF8String: name])];
}

static void
put(id o, const char *name, id arg)
{
  [o performSelector: NSSelectorFromString(
    [NSString stringWithUTF8String: name]) withObject: arg];
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];
    Class connector = NSClassFromString(@"NSNibConnector");

    printf("NSNibConnector: %s\n", connector == Nil ? "ABSENT" : "present");

    SECTION("NSNibConnector defaults")
    id c = [[connector alloc] init];

    printf("INIT nonnil=%d source=%s destination=%s label=%s\n",
           c != nil, nilstr(get(c, "source")), nilstr(get(c, "destination")),
           nilstr(get(c, "label")));
    ENDSECTION

    SECTION("NSNibConnector round trips")
    id c = [[connector alloc] init];
    NSString *src = @"theSource";
    NSString *dst = @"theDestination";

    put(c, "setSource:", src);
    put(c, "setDestination:", dst);
    put(c, "setLabel:", @"theLabel");
    printf("SET sourceSame=%d destinationSame=%d label=%s\n",
           get(c, "source") == src, get(c, "destination") == dst,
           [[get(c, "label") description] UTF8String]);

    put(c, "setSource:", nil);
    put(c, "setLabel:", nil);
    printf("SETNIL source=%s label=%s\n", nilstr(get(c, "source")),
           nilstr(get(c, "label")));
    ENDSECTION

    SECTION("NSNibConnector replaceObject:withObject:")
    id c = [[connector alloc] init];
    NSString *a = @"objectA";
    NSString *b = @"objectB";

    put(c, "setSource:", a);
    put(c, "setDestination:", a);
    [c performSelector: NSSelectorFromString(@"replaceObject:withObject:")
            withObject: a withObject: b];
    printf("REPLACE source=%s destination=%s\n",
           [[get(c, "source") description] UTF8String],
           [[get(c, "destination") description] UTF8String]);

    [c performSelector: NSSelectorFromString(@"replaceObject:withObject:")
            withObject: @"notHeld" withObject: @"other"];
    printf("REPLACE-MISS source=%s destination=%s\n",
           [[get(c, "source") description] UTF8String],
           [[get(c, "destination") description] UTF8String]);
    ENDSECTION

    SECTION("NSNibConnector isEqual")
    id x = [[connector alloc] init];
    id y = [[connector alloc] init];

    printf("EMPTY selfEqual=%d twoEmptyEqual=%d\n",
           [x isEqual: x], [x isEqual: y]);

    put(x, "setSource:", @"s"); put(x, "setDestination:", @"d");
    put(x, "setLabel:", @"l");
    put(y, "setSource:", @"s"); put(y, "setDestination:", @"d");
    put(y, "setLabel:", @"l");
    printf("SAMEVALUES equal=%d\n", [x isEqual: y]);

    put(y, "setLabel:", @"different");
    printf("DIFFERENTLABEL equal=%d\n", [x isEqual: y]);
    ENDSECTION

    SECTION("NSNibConnector establishConnection")
    id c = [[connector alloc] init];

    @try {
      [c performSelector: NSSelectorFromString(@"establishConnection")];
      printf("ESTABLISH ok on an empty one\n");
    }
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
