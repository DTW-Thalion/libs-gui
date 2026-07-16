/* Apple oracle for NSSharingServicePickerToolbarItem (a stub here: the getters
   answer nil and the setters do nothing) and for whether AppKit still has
   NSNibConnector at all, which decides whether that class can be compared
   against anything.  Apple-only. */
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

@interface PickerDelegate : NSObject <NSSharingServicePickerToolbarItemDelegate>
@end
@implementation PickerDelegate
- (NSArray *) itemsForSharingServicePickerToolbarItem:
  (NSSharingServicePickerToolbarItem *)item
{
  return [NSArray arrayWithObject: @"item"];
}
@end

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    SECTION("NSNibConnector: does AppKit have it?")
    Class c = NSClassFromString(@"NSNibConnector");

    printf("NSNibConnector class=%s\n", c == Nil ? "ABSENT" : "present");
    if (c != Nil)
      {
        id conn = [[c alloc] init];
        const char *sels[] = { "source", "setSource:", "destination",
                               "setDestination:", "label", "setLabel:",
                               "establishConnection",
                               "replaceObject:withObject:", NULL };
        int i;

        printf("NSNibConnector init nonnil=%d\n", conn != nil);
        for (i = 0; sels[i] != NULL; i++)
          {
            SEL s = NSSelectorFromString([NSString stringWithUTF8String:
              sels[i]]);

            printf("  HAS %-28s %d\n", sels[i], [conn respondsToSelector: s]);
          }
      }
    ENDSECTION

    SECTION("NSSharingServicePickerToolbarItem defaults")
    NSSharingServicePickerToolbarItem *item;

    item = [[NSSharingServicePickerToolbarItem alloc]
      initWithItemIdentifier: @"share"];
    printf("INIT nonnil=%d identifier=%s\n", item != nil,
           [[item itemIdentifier] UTF8String]);
    printf("INIT delegate=%s activityItemsConfiguration=%s\n",
           [item delegate] == nil ? "nil" : "set",
           [item activityItemsConfiguration] == nil ? "nil" : "set");
    ENDSECTION

    SECTION("NSSharingServicePickerToolbarItem round trips")
    NSSharingServicePickerToolbarItem *item;
    PickerDelegate *d = [[PickerDelegate alloc] init];

    item = [[NSSharingServicePickerToolbarItem alloc]
      initWithItemIdentifier: @"share"];
    [item setDelegate: d];
    printf("SET delegateSame=%d\n", [item delegate] == d);

    /* the configuration is any object, so a string will do to see whether it
       is kept */
    [item setActivityItemsConfiguration: (id)@"config"];
    printf("SET configSame=%d config=%s\n",
           [item activityItemsConfiguration] == (id)@"config",
           [item activityItemsConfiguration] == nil ? "nil"
             : [[[item activityItemsConfiguration] description] UTF8String]);

    [item setDelegate: nil];
    printf("SET delegateNil=%s\n", [item delegate] == nil ? "nil" : "set");
    ENDSECTION

    SECTION("is the delegate retained?")
    NSSharingServicePickerToolbarItem *item;
    PickerDelegate *d = [[PickerDelegate alloc] init];
    NSUInteger before;
    NSUInteger after;

    item = [[NSSharingServicePickerToolbarItem alloc]
      initWithItemIdentifier: @"share"];
    before = [d retainCount];
    [item setDelegate: d];
    after = [d retainCount];
    printf("DELEGATE retainCount before=%lu after=%lu (weak if unchanged)\n",
           (unsigned long)before, (unsigned long)after);
    ENDSECTION
  }
  return 0;
}
