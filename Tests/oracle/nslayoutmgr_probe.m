#import <Cocoa/Cocoa.h>

int
main(int argc, const char *argv[])
{
  @autoreleasepool
    {
      NSLayoutManager *lm = [[NSLayoutManager alloc] init];

      printf("=== NSLayoutManager defaults ===\n");
      printf("hyphenationFactor default: %g\n", (double)[lm hyphenationFactor]);
      printf("allowsNonContiguousLayout default: %d\n",
             (int)[lm allowsNonContiguousLayout]);
      printf("hasNonContiguousLayout default: %d\n",
             (int)[lm hasNonContiguousLayout]);

      [lm setHyphenationFactor: 0.7f];
      printf("after setHyphenationFactor:0.7 -> %g\n",
             (double)[lm hyphenationFactor]);

      [lm setAllowsNonContiguousLayout: YES];
      printf("after setAllowsNonContiguousLayout:YES -> allows=%d has=%d\n",
             (int)[lm allowsNonContiguousLayout],
             (int)[lm hasNonContiguousLayout]);

      [lm setAllowsNonContiguousLayout: NO];
      printf("after setAllowsNonContiguousLayout:NO -> allows=%d\n",
             (int)[lm allowsNonContiguousLayout]);

      printf("\n=== NSCollectionViewItem defaults ===\n");
      NSCollectionViewItem *item = [[NSCollectionViewItem alloc] init];
      printf("highlightState default: %ld\n", (long)[item highlightState]);
      printf("isSelected default: %d\n", (int)[item isSelected]);

      [item setHighlightState: NSCollectionViewItemHighlightForSelection];
      printf("after setHighlightState:ForSelection(1) -> highlight=%ld selected=%d\n",
             (long)[item highlightState], (int)[item isSelected]);

      [item setSelected: YES];
      printf("after setSelected:YES -> selected=%d highlight=%ld\n",
             (int)[item isSelected], (long)[item highlightState]);

      [item setHighlightState: NSCollectionViewItemHighlightAsDropTarget];
      printf("after setHighlightState:AsDropTarget(3) -> highlight=%ld\n",
             (long)[item highlightState]);
    }
  return 0;
}
