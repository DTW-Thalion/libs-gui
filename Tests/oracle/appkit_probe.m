/* Supplementary Apple probe: the exact values needed to write correct
   (relaxed) assertions for the #461-#471 remediation. */
#import <Cocoa/Cocoa.h>

int main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    /* #461: gray->RGB replication, alpha preservation, white/black gray. */
    {
      NSColor *g = [[NSColor colorWithDeviceWhite: 0.5 alpha: 1]
                     colorUsingColorSpaceName: NSDeviceRGBColorSpace];
      printf("C461 gray0.5->RGB = r%.4f g%.4f b%.4f\n",
             [g redComponent], [g greenComponent], [g blueComponent]);
      NSColor *a = [[NSColor colorWithDeviceRed: 0.2 green: 0.4 blue: 0.6 alpha: 0.5]
                     colorUsingColorSpaceName: NSDeviceWhiteColorSpace];
      printf("C461 alpha-after-conv = %.4f\n", [a alphaComponent]);
      NSColor *w = [[NSColor colorWithDeviceRed: 1 green: 1 blue: 1 alpha: 1]
                     colorUsingColorSpaceName: NSDeviceWhiteColorSpace];
      NSColor *bl = [[NSColor colorWithDeviceRed: 0 green: 0 blue: 0 alpha: 1]
                      colorUsingColorSpaceName: NSDeviceWhiteColorSpace];
      printf("C461 white->gray=%.4f black->gray=%.4f\n", [w whiteComponent], [bl whiteComponent]);
    }

    /* #463: exact-stop returns that stop's colour. */
    {
      NSColor *red = [NSColor colorWithCalibratedRed: 1 green: 0 blue: 0 alpha: 1];
      NSColor *green = [NSColor colorWithCalibratedRed: 0 green: 1 blue: 0 alpha: 1];
      NSColor *blue = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 1 alpha: 1];
      NSGradient *g = [[NSGradient alloc] initWithColorsAndLocations:
                        red, (CGFloat)0.0, green, (CGFloat)0.2, blue, (CGFloat)1.0, nil];
      NSColor *at = [[g interpolatedColorAtLocation: 0.2] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
      printf("C463 at-stop-0.2 = r%.3f g%.3f b%.3f\n",
             [at redComponent], [at greenComponent], [at blueComponent]);
      NSColor *above = [[g interpolatedColorAtLocation: 1.5] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
      printf("C463 above-last = r%.3f g%.3f b%.3f\n",
             [above redComponent], [above greenComponent], [above blueComponent]);
    }

    /* #471: does addTabStop insert sorted even though setTabStops does not? */
    {
      NSMutableParagraphStyle *p = [[NSMutableParagraphStyle alloc] init];
      NSTextTab *t100 = [[NSTextTab alloc] initWithType: NSLeftTabStopType location: 100];
      NSTextTab *t200 = [[NSTextTab alloc] initWithType: NSLeftTabStopType location: 200];
      NSTextTab *t300 = [[NSTextTab alloc] initWithType: NSLeftTabStopType location: 300];
      NSTextTab *t150 = [[NSTextTab alloc] initWithType: NSLeftTabStopType location: 150];
      [p setTabStops: [NSArray arrayWithObjects: t100, t200, t300, nil]];
      [p addTabStop: t150];
      NSArray *ts = [p tabStops];
      printf("C471 after addTabStop(150) into [100,200,300]: ");
      for (NSUInteger i = 0; i < [ts count]; i++)
        printf("%.0f ", [[ts objectAtIndex: i] location]);
      printf("(count=%ld)\n", (long)[ts count]);
      /* removeTabStop by matching object */
      NSMutableParagraphStyle *p2 = [[NSMutableParagraphStyle alloc] init];
      [p2 setTabStops: [NSArray arrayWithObjects: t100, t200, t300, nil]];
      [p2 removeTabStop: t200];
      printf("C471 after removeTabStop(200): count=%ld\n", (long)[[p2 tabStops] count]);
    }

    /* #464: mixed stringValue. */
    {
      NSButtonCell *cell = [[NSButtonCell alloc] init];
      [cell setAllowsMixedState: YES];
      [cell setState: NSMixedState];
      printf("C464 Mixed stringValue='%s'\n", [[cell stringValue] UTF8String]);
    }

    /* #469: selectAll in list mode, and radio selectCellWithTag/deselect. */
    {
      NSButtonCell *proto = [[NSButtonCell alloc] init];
      NSMatrix *ml = [[NSMatrix alloc] initWithFrame: NSMakeRect(0,0,100,100)
                      mode: NSListModeMatrix prototype: proto numberOfRows: 2 numberOfColumns: 2];
      [ml selectAll: nil];
      printf("C469 list selectAll count=%ld\n", (long)[[ml selectedCells] count]);
      [ml deselectAllCells];
      printf("C469 list deselectAll count=%ld\n", (long)[[ml selectedCells] count]);
    }

    printf("DONE\n");
  }
  return 0;
}
