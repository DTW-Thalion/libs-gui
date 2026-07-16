/* Apple oracle, pass 7 for NSToolbarItemGroup.  Last pass before implementing:
   where the factory puts the target and the action, what the titles become,
   what happens when the labels array is shorter than the titles, and what the
   generated subitems look like.  Apple-only. */
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

@interface Target : NSObject
- (void) fire: (id)sender;
@end
@implementation Target
- (void) fire: (id)sender { }
@end

@interface NSToolbarItemGroup (Probe)
+ (id) groupWithItemIdentifier: (NSString *)identifier
                        titles: (NSArray *)titles
                 selectionMode: (NSToolbarItemGroupSelectionMode)mode
                        labels: (NSArray *)labels
                        target: (id)target
                        action: (SEL)action;
@end

static void
dumpItem(NSToolbarItem *it, Target *t, const char *tag)
{
  printf("%s identifier=%s label=%s paletteLabel=%s targetIsT=%d action=%s\n",
         tag, [[it itemIdentifier] UTF8String], [[it label] UTF8String],
         [[it paletteLabel] UTF8String], [it target] == t,
         [it action] == NULL ? "NULL"
           : [NSStringFromSelector([it action]) UTF8String]);
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];
    Target *t = [[Target alloc] init];

    SECTION("where target and action land")
    NSToolbarItemGroup *g;
    NSUInteger i;

    g = [NSToolbarItemGroup groupWithItemIdentifier: @"grp"
           titles: [NSArray arrayWithObjects: @"T0", @"T1", nil]
           selectionMode: NSToolbarItemGroupSelectionModeSelectOne
           labels: [NSArray arrayWithObjects: @"L0", @"L1", nil]
           target: t
           action: @selector(fire:)];
    dumpItem(g, t, "GROUP");
    printf("GROUP label=%s\n", [[g label] UTF8String]);
    for (i = 0; i < [[g subitems] count]; i++)
      {
        char tag[16];

        snprintf(tag, sizeof(tag), "SUB%lu", (unsigned long)i);
        dumpItem([[g subitems] objectAtIndex: i], t, tag);
      }
    ENDSECTION

    SECTION("labels shorter than titles")
    NSToolbarItemGroup *g;
    NSUInteger i;

    g = [NSToolbarItemGroup groupWithItemIdentifier: @"grp"
           titles: [NSArray arrayWithObjects: @"T0", @"T1", @"T2", nil]
           selectionMode: NSToolbarItemGroupSelectionModeSelectOne
           labels: [NSArray arrayWithObject: @"L0"]
           target: nil
           action: NULL];
    printf("SHORTLABELS subcount=%lu\n", (unsigned long)[[g subitems] count]);
    for (i = 0; i < [[g subitems] count]; i++)
      {
        printf("  SUB%lu label='%s'\n", (unsigned long)i,
               [[[[g subitems] objectAtIndex: i] label] UTF8String]);
      }
    ENDSECTION

    SECTION("nil titles")
    NSToolbarItemGroup *g;

    g = [NSToolbarItemGroup groupWithItemIdentifier: @"grp"
           titles: nil
           selectionMode: NSToolbarItemGroupSelectionModeSelectOne
           labels: [NSArray arrayWithObjects: @"L0", @"L1", nil]
           target: nil
           action: NULL];
    printf("NILTITLES nonnil=%d subcount=%lu\n",
           g != nil, (unsigned long)[[g subitems] count]);
    ENDSECTION

    SECTION("identifier shape")
    NSToolbarItemGroup *g;
    NSString *sub0;

    g = [NSToolbarItemGroup groupWithItemIdentifier: @"grp"
           titles: [NSArray arrayWithObject: @"T0"]
           selectionMode: NSToolbarItemGroupSelectionModeSelectOne
           labels: [NSArray arrayWithObject: @"L0"]
           target: nil
           action: NULL];
    sub0 = [[[g subitems] objectAtIndex: 0] itemIdentifier];
    printf("SUBID len=%lu dashes=%d unique=%d\n",
           (unsigned long)[sub0 length],
           (int)[[sub0 componentsSeparatedByString: @"-"] count] - 1,
           ![sub0 isEqualToString: @"grp"]);
    ENDSECTION

    SECTION("selection is live on a hand built group after a factory group")
    /* Confirms the bare-init group really is the inert one, so the difference
       is set up by the factory and not by the subitems. */
    NSToolbarItemGroup *bare = [[NSToolbarItemGroup alloc]
                                 initWithItemIdentifier: @"bare"];
    NSToolbarItem *a = [[NSToolbarItem alloc] initWithItemIdentifier: @"a"];

    [bare setSubitems: [NSArray arrayWithObject: a]];
    [bare setSelectionMode: NSToolbarItemGroupSelectionModeSelectOne];
    [bare setSelected: YES atIndex: 0];
    printf("BARE selectedIndex=%ld isSel0=%d\n",
           (long)[bare selectedIndex], [bare isSelectedAtIndex: 0]);
    ENDSECTION
  }
  return 0;
}
