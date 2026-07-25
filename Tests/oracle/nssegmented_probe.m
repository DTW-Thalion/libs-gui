/* Oracle: NSSegmentedControl tracking mode and multiple selection. */
#import <Cocoa/Cocoa.h>

int
main(void)
{
  @autoreleasepool
    {
      NSSegmentedControl *sc = [[NSSegmentedControl alloc]
        initWithFrame: NSMakeRect(0, 0, 200, 24)];
      [sc setSegmentCount: 3];

      printf("default trackingMode = %ld\n", (long)[sc trackingMode]);

      [sc setTrackingMode: NSSegmentSwitchTrackingSelectOne];
      [sc setSelected: YES forSegment: 0];
      [sc setSelected: YES forSegment: 2];
      printf("SelectOne: s0=%d s1=%d s2=%d selected=%ld\n",
             [sc isSelectedForSegment: 0], [sc isSelectedForSegment: 1],
             [sc isSelectedForSegment: 2], (long)[sc selectedSegment]);

      [sc setTrackingMode: NSSegmentSwitchTrackingSelectAny];
      printf("trackingMode after set SelectAny = %ld\n", (long)[sc trackingMode]);
      [sc setSelected: YES forSegment: 0];
      [sc setSelected: YES forSegment: 1];
      printf("SelectAny both: s0=%d s1=%d s2=%d selected=%ld\n",
             [sc isSelectedForSegment: 0], [sc isSelectedForSegment: 1],
             [sc isSelectedForSegment: 2], (long)[sc selectedSegment]);

      [sc setSelected: NO forSegment: 0];
      printf("SelectAny after deselect 0: s0=%d s1=%d selected=%ld\n",
             [sc isSelectedForSegment: 0], [sc isSelectedForSegment: 1],
             (long)[sc selectedSegment]);
    }
  return 0;
}
