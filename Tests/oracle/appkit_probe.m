/* Apple oracle for the NSScroller coverage test: init defaults (vertical
   and horizontal), value/knob clamping, and the accessors. */
#import <Cocoa/Cocoa.h>

int main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    printf("SCR +scrollerWidth=%g regular=%g small=%g\n",
           [NSScroller scrollerWidth],
           [NSScroller scrollerWidthForControlSize: NSRegularControlSize],
           [NSScroller scrollerWidthForControlSize: NSSmallControlSize]);

    /* Vertical scroller (taller than wide). */
    NSScroller *v = [[NSScroller alloc] initWithFrame: NSMakeRect(0, 0, 15, 200)];
    printf("SCR vert: floatValue=%g knobProp=%g arrows=%ld hitPart=%ld enabled=%d controlSize=%ld\n",
           [v floatValue], [v knobProportion], (long)[v arrowsPosition],
           (long)[v hitPart], [v isEnabled], (long)[v controlSize]);

    /* Horizontal scroller (wider than tall). */
    NSScroller *h = [[NSScroller alloc] initWithFrame: NSMakeRect(0, 0, 200, 15)];
    printf("SCR horiz: floatValue=%g arrows=%ld\n", [h floatValue], (long)[h arrowsPosition]);

    /* Value and knob proportion, with clamping. */
    NSScroller *s = [[NSScroller alloc] initWithFrame: NSMakeRect(0, 0, 15, 200)];
    [s setFloatValue: 0.5 knobProportion: 0.25];
    printf("SCR setFloat 0.5 knob 0.25 -> floatValue=%g knobProp=%g enabled=%d\n",
           [s floatValue], [s knobProportion], [s isEnabled]);
    [s setFloatValue: 2.0 knobProportion: 0.25];
    printf("SCR setFloat 2.0 -> floatValue=%g (clamp to 1)\n", [s floatValue]);
    [s setFloatValue: -1.0 knobProportion: 0.25];
    printf("SCR setFloat -1.0 -> floatValue=%g (clamp to 0)\n", [s floatValue]);
    [s setKnobProportion: 1.5];
    printf("SCR setKnob 1.5 -> knobProp=%g (clamp to 1)\n", [s knobProportion]);
    [s setKnobProportion: -0.5];
    printf("SCR setKnob -0.5 -> knobProp=%g (clamp to 0)\n", [s knobProportion]);

    /* Accessor round-trips. */
    [s setArrowsPosition: NSScrollerArrowsNone];
    printf("SCR setArrows None -> %ld (none=%ld)\n", (long)[s arrowsPosition], (long)NSScrollerArrowsNone);
    [s setControlSize: NSSmallControlSize];
    printf("SCR setControlSize Small -> %ld (small=%ld)\n", (long)[s controlSize], (long)NSSmallControlSize);
    printf("SCR usableParts=%ld noPart=%ld\n", (long)[s usableParts], (long)NSScrollerNoPart);

    printf("DONE\n");
  }
  return 0;
}
