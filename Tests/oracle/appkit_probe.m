/* Apple oracle for the NSSegmentedCell coverage test: the segment count,
   per-segment label/width/enabled/tag/tooltip, selection (SelectOne
   tracking), and selectSegmentWithTag:. */
#import <Cocoa/Cocoa.h>

int main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    NSSegmentedCell *c = [[NSSegmentedCell alloc] init];
    printf("SEG defaults: count=%ld selected=%ld tracking=%ld\n",
           (long)[c segmentCount], (long)[c selectedSegment], (long)[c trackingMode]);

    [c setSegmentCount: 3];
    printf("SEG after setCount 3: count=%ld\n", (long)[c segmentCount]);
    printf("SEG seg0 defaults: label='%s' width=%g enabled=%d tag=%ld selected=%d\n",
           [[c labelForSegment: 0] UTF8String], [c widthForSegment: 0],
           [c isEnabledForSegment: 0], (long)[c tagForSegment: 0],
           [c isSelectedForSegment: 0]);

    /* Per-segment accessors round-trip. */
    [c setLabel: @"One" forSegment: 0];
    [c setLabel: @"Two" forSegment: 1];
    [c setLabel: @"Three" forSegment: 2];
    [c setWidth: 40.0 forSegment: 1];
    [c setTag: 77 forSegment: 2];
    [c setToolTip: @"tip" forSegment: 0];
    printf("SEG accessors: label1='%s' width1=%g tag2=%ld tooltip0='%s'\n",
           [[c labelForSegment: 1] UTF8String], [c widthForSegment: 1],
           (long)[c tagForSegment: 2], [[c toolTipForSegment: 0] UTF8String]);

    /* Selection: SelectOne tracking moves the single selection. */
    [c setSelectedSegment: 1];
    printf("SEG select 1: selected=%ld isSel1=%d isSel0=%d\n",
           (long)[c selectedSegment], [c isSelectedForSegment: 1], [c isSelectedForSegment: 0]);
    [c setSelectedSegment: 2];
    printf("SEG select 2: selected=%ld isSel2=%d isSel1=%d (SelectOne deselects 1)\n",
           (long)[c selectedSegment], [c isSelectedForSegment: 2], [c isSelectedForSegment: 1]);
    [c setSelected: NO forSegment: 2];
    printf("SEG deselect 2: selected=%ld isSel2=%d\n",
           (long)[c selectedSegment], [c isSelectedForSegment: 2]);

    /* selectSegmentWithTag:. */
    [c selectSegmentWithTag: 77];
    printf("SEG selectWithTag 77: selected=%ld\n", (long)[c selectedSegment]);

    /* Disabled segments cannot be selected. */
    [c setSelected: NO forSegment: 2];
    [c setEnabled: NO forSegment: 0];
    [c setSelectedSegment: 0];
    printf("SEG select disabled 0: selected=%ld isSel0=%d enabled0=%d\n",
           (long)[c selectedSegment], [c isSelectedForSegment: 0], [c isEnabledForSegment: 0]);

    /* Shrinking the count. */
    [c setSegmentCount: 2];
    printf("SEG shrink to 2: count=%ld label1='%s'\n",
           (long)[c segmentCount], [[c labelForSegment: 1] UTF8String]);

    /* Segment style round-trip. */
    [c setSegmentStyle: NSSegmentStyleRounded];
    printf("SEG setSegmentStyle Rounded -> %ld (rounded=%ld)\n",
           (long)[c segmentStyle], (long)NSSegmentStyleRounded);

    printf("DONE\n");
  }
  return 0;
}
