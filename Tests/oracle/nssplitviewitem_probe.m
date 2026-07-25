/* Oracle: NSSplitViewItem factory differentiation and behavior/isCollapsed. */
#import <Cocoa/Cocoa.h>

static void
dump(const char *label, NSSplitViewItem *i)
{
  printf("%-12s behavior=%ld holdingPriority=%g canCollapse=%d springLoaded=%d"
         " collapsed=%d automaticMaxThickness=%g\n",
         label, (long)[i behavior], [i holdingPriority],
         [i canCollapse], [i isSpringLoaded], [i isCollapsed],
         [i automaticMaximumThickness]);
}

int
main(void)
{
  @autoreleasepool
    {
      NSViewController *vc = [[NSViewController alloc] init];

      printf("enum: Default=%d Sidebar=%d ContentList=%d\n",
             (int)NSSplitViewItemBehaviorDefault,
             (int)NSSplitViewItemBehaviorSidebar,
             (int)NSSplitViewItemBehaviorContentList);

      dump("plain", [NSSplitViewItem splitViewItemWithViewController: vc]);
      dump("sidebar", [NSSplitViewItem sidebarWithViewController: vc]);
      dump("contentList", [NSSplitViewItem contentListWithViewController: vc]);
    }
  return 0;
}
