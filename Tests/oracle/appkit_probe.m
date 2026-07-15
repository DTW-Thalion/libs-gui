/* Apple oracle for the NSCollectionViewFlowLayout coverage test.  Probes the
   scroll-direction enum, the init defaults (minimumLineSpacing,
   minimumInteritemSpacing, itemSize, estimatedItemSize, scrollDirection,
   header/footer reference sizes, sectionInset, pin flags) and the plain setter
   round-trips.  Portable so the same file runs under GNUstep for an A/B. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    printf("ENUM scroll Vertical=%d Horizontal=%d\n",
           (int)NSCollectionViewScrollDirectionVertical,
           (int)NSCollectionViewScrollDirectionHorizontal);

    NSCollectionViewFlowLayout *l = [[NSCollectionViewFlowLayout alloc] init];
    printf("INIT lineSpacing=%g interitem=%g itemSize=%gx%g estItemSize=%gx%g scroll=%ld\n",
           [l minimumLineSpacing], [l minimumInteritemSpacing],
           [l itemSize].width, [l itemSize].height,
           [l estimatedItemSize].width, [l estimatedItemSize].height,
           (long)[l scrollDirection]);
    printf("INIT header=%gx%g footer=%gx%g inset=%g,%g,%g,%g\n",
           [l headerReferenceSize].width, [l headerReferenceSize].height,
           [l footerReferenceSize].width, [l footerReferenceSize].height,
           [l sectionInset].top, [l sectionInset].left,
           [l sectionInset].bottom, [l sectionInset].right);
    printf("INIT pinHeaders=%d pinFooters=%d\n",
           [l sectionHeadersPinToVisibleBounds],
           [l sectionFootersPinToVisibleBounds]);

    [l setMinimumLineSpacing: 5.0];
    [l setMinimumInteritemSpacing: 6.0];
    [l setItemSize: NSMakeSize(30, 40)];
    [l setEstimatedItemSize: NSMakeSize(11, 12)];
    [l setScrollDirection: NSCollectionViewScrollDirectionHorizontal];
    [l setHeaderReferenceSize: NSMakeSize(100, 20)];
    [l setFooterReferenceSize: NSMakeSize(100, 10)];
    [l setSectionInset: NSEdgeInsetsMake(1, 2, 3, 4)];
    [l setSectionHeadersPinToVisibleBounds: YES];
    [l setSectionFootersPinToVisibleBounds: YES];
    printf("SET lineSpacing=%g interitem=%g itemSize=%gx%g estItemSize=%gx%g scroll=%ld\n",
           [l minimumLineSpacing], [l minimumInteritemSpacing],
           [l itemSize].width, [l itemSize].height,
           [l estimatedItemSize].width, [l estimatedItemSize].height,
           (long)[l scrollDirection]);
    printf("SET header=%gx%g footer=%gx%g inset=%g,%g,%g,%g pinH=%d pinF=%d\n",
           [l headerReferenceSize].width, [l headerReferenceSize].height,
           [l footerReferenceSize].width, [l footerReferenceSize].height,
           [l sectionInset].top, [l sectionInset].left,
           [l sectionInset].bottom, [l sectionInset].right,
           [l sectionHeadersPinToVisibleBounds],
           [l sectionFootersPinToVisibleBounds]);
  }
  return 0;
}
