/* Apple oracle for the NSTreeNode coverage test: the represented object, the
   leaf/child/parent relationships built through mutableChildNodes, the index
   path (including the root) and descendantNodeAtIndexPath:. */
#import <Cocoa/Cocoa.h>

int
main(int argc, const char **argv)
{
  @autoreleasepool
  {
    NSTreeNode *root = [NSTreeNode treeNodeWithRepresentedObject: @"root"];
    NSIndexPath *rip = [root indexPath];
    NSLog(@"TN root repObj=%@ isLeaf=%d childCount=%lu parent=%@ ipNil=%d ipLen=%lu",
          [root representedObject], [root isLeaf],
          (unsigned long)[[root childNodes] count],
          [root parentNode] == nil ? @"nil" : @"set",
          rip == nil, (unsigned long)[rip length]);

    NSTreeNode *c0 = [NSTreeNode treeNodeWithRepresentedObject: @"c0"];
    NSTreeNode *c1 = [NSTreeNode treeNodeWithRepresentedObject: @"c1"];
    [[root mutableChildNodes] addObject: c0];
    [[root mutableChildNodes] addObject: c1];
    NSLog(@"TN afterAdd rootLeaf=%d childCount=%lu c0parentSame=%d",
          [root isLeaf], (unsigned long)[[root childNodes] count],
          [c0 parentNode] == root);
    NSLog(@"TN c1 ipLen=%lu idx0=%lu",
          (unsigned long)[[c1 indexPath] length],
          (unsigned long)[[c1 indexPath] indexAtPosition: 0]);

    NSTreeNode *gc = [NSTreeNode treeNodeWithRepresentedObject: @"gc"];
    [[c1 mutableChildNodes] addObject: gc];
    NSLog(@"TN gc ipLen=%lu p0=%lu p1=%lu",
          (unsigned long)[[gc indexPath] length],
          (unsigned long)[[gc indexPath] indexAtPosition: 0],
          (unsigned long)[[gc indexPath] indexAtPosition: 1]);

    NSIndexPath *ip = [[NSIndexPath indexPathWithIndex: 1] indexPathByAddingIndex: 0];
    NSLog(@"TN descendant[1,0]same=%d", [root descendantNodeAtIndexPath: ip] == gc);

    NSIndexPath *empty = [[NSIndexPath alloc] init];
    NSLog(@"TN descendantEmpty=%@ (len=%lu)",
          [root descendantNodeAtIndexPath: empty] == root ? @"self" : @"other",
          (unsigned long)[empty length]);
  }
  return 0;
}
