/* Probe of real Apple AppKit behaviour for the coverage tests in PRs
   #461-#471.  Compiled on a macOS Actions runner against -framework Cocoa
   to establish the correct contract, so GNUstep divergences can be
   classified as quirks vs bugs.  Prints one line per behaviour the tests
   assert; risky calls are wrapped in @try.
*/
#import <Cocoa/Cocoa.h>

int main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    /* ===== #461 NSColor conversions ===== */
    {
      NSColor *red = [NSColor colorWithDeviceRed: 1 green: 0 blue: 0 alpha: 1];
      NSColor *mid = [NSColor colorWithDeviceRed: 0.5 green: 0.5 blue: 0.5 alpha: 1];
      NSColor *gw = [red colorUsingColorSpaceName: NSDeviceWhiteColorSpace];
      NSColor *mw = [mid colorUsingColorSpaceName: NSDeviceWhiteColorSpace];
      printf("COLOR red->white = %.4f (avg=0.3333 luma=0.299)\n", [gw whiteComponent]);
      printf("COLOR mid->white = %.4f\n", [mw whiteComponent]);
      NSColor *cmyk = [red colorUsingColorSpaceName: NSDeviceCMYKColorSpace];
      printf("COLOR red->cmyk = c%.3f m%.3f y%.3f k%.3f\n",
             [cmyk cyanComponent], [cmyk magentaComponent],
             [cmyk yellowComponent], [cmyk blackComponent]);
      NSColor *reg = [NSColor colorWithDeviceCyan: 1 magenta: 1 yellow: 1 black: 1 alpha: 1];
      NSColor *rw = [reg colorUsingColorSpaceName: NSDeviceWhiteColorSpace];
      printf("COLOR registration-black->white = %.4f\n", [rw whiteComponent]);
      NSColor *g = [NSColor colorWithDeviceWhite: 0 alpha: 1];
      NSColor *c5 = [NSColor colorWithDeviceCyan: 0 magenta: 0 yellow: 0 black: 0 alpha: 1];
      printf("COLOR numberOfComponents gray=%ld cmyk=%ld\n",
             (long)[g numberOfComponents], (long)[c5 numberOfComponents]);
    }

    /* ===== #462 NSCell state machine ===== */
    {
      NSCell *cell = [[NSCell alloc] initTextCell: @"x"];
      printf("CELL new state=%ld allowsMixed=%d\n", (long)[cell state], [cell allowsMixedState]);
      [cell setState: 5];
      printf("CELL setState 5 -> %ld (On=%ld)\n", (long)[cell state], (long)NSOnState);
      [cell setState: -3];
      printf("CELL setState -3 (mixed off) -> %ld\n", (long)[cell state]);
      [cell setState: NSMixedState];
      printf("CELL setState Mixed (mixed off) -> %ld\n", (long)[cell state]);
      [cell setAllowsMixedState: YES];
      [cell setState: NSOffState];
      printf("CELL 3-state cycle from Off: next=%ld ", (long)[cell nextState]);
      [cell setState: NSMixedState];
      printf("fromMixed=%ld ", (long)[cell nextState]);
      [cell setState: NSOnState];
      printf("fromOn=%ld (Off=%ld Mixed=%ld On=%ld)\n", (long)[cell nextState],
             (long)NSOffState, (long)NSMixedState, (long)NSOnState);
      [cell setState: NSMixedState];
      [cell setAllowsMixedState: NO];
      printf("CELL disallow-mixed while Mixed -> %ld\n", (long)[cell state]);
    }

    /* ===== #463 NSGradient interpolation ===== */
    {
      NSColor *red = [NSColor colorWithCalibratedRed: 1 green: 0 blue: 0 alpha: 1];
      NSColor *green = [NSColor colorWithCalibratedRed: 0 green: 1 blue: 0 alpha: 1];
      NSColor *blue = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 1 alpha: 1];
      NSGradient *g = [[NSGradient alloc] initWithColorsAndLocations:
                        red, (CGFloat)0.0, green, (CGFloat)0.2, blue, (CGFloat)1.0, nil];
      printf("GRAD stops=%ld\n", (long)[g numberOfColorStops]);
      NSColor *c1 = [[g interpolatedColorAtLocation: 0.1] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
      printf("GRAD @0.1 (mid of 0..0.2) = r%.3f g%.3f b%.3f\n",
             [c1 redComponent], [c1 greenComponent], [c1 blueComponent]);
      NSColor *c2 = [[g interpolatedColorAtLocation: 0.6] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
      printf("GRAD @0.6 (mid of 0.2..1) = r%.3f g%.3f b%.3f\n",
             [c2 redComponent], [c2 greenComponent], [c2 blueComponent]);
      NSGradient *g2 = [[NSGradient alloc] initWithColorsAndLocations:
                         red, (CGFloat)0.25, blue, (CGFloat)0.75, nil];
      NSColor *below = [[g2 interpolatedColorAtLocation: 0.1] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
      printf("GRAD below-first-stop @0.1 = r%.3f g%.3f b%.3f (clamp to red?)\n",
             [below redComponent], [below greenComponent], [below blueComponent]);
    }

    /* ===== #464 NSButtonCell state/value ===== */
    {
      NSButtonCell *cell = [[NSButtonCell alloc] init];
      [cell setIntValue: 5];
      printf("BTN setInt 5 -> state=%ld intValue=%d\n", (long)[cell state], [cell intValue]);
      [cell setState: NSOnState];
      printf("BTN On: stringValue='%s' objectValue.int=%d\n",
             [[cell stringValue] UTF8String], [[cell objectValue] intValue]);
      [cell setState: NSOffState];
      printf("BTN Off: stringValue='%s'\n", [[cell stringValue] UTF8String]);
      [cell setStringValue: @"x"];
      printf("BTN setString 'x' -> state=%ld\n", (long)[cell state]);
      [cell setStringValue: @""];
      printf("BTN setString '' -> state=%ld\n", (long)[cell state]);
      [cell setAllowsMixedState: YES];
      [cell setState: NSMixedState];
      printf("BTN Mixed: intValue=%d objectValue.int=%d\n",
             [cell intValue], [[cell objectValue] intValue]);
    }

    /* ===== #465 NSSliderCell tick marks ===== */
    {
      NSSliderCell *cell = [[NSSliderCell alloc] init];
      [cell setMinValue: 0]; [cell setMaxValue: 10];
      printf("SLIDER defaults ticks=%ld onlyTicks=%d\n",
             (long)[cell numberOfTickMarks], [cell allowsTickMarkValuesOnly]);
      printf("SLIDER 0 ticks closest(3.7)=%.4f\n", [cell closestTickMarkValueToValue: 3.7]);
      [cell setNumberOfTickMarks: 1];
      printf("SLIDER 1 tick closest(3.7)=%.4f valueAt(0)=%.4f\n",
             [cell closestTickMarkValueToValue: 3.7], [cell tickMarkValueAtIndex: 0]);
      [cell setNumberOfTickMarks: 11];
      printf("SLIDER 11 ticks valueAt 0=%.3f 5=%.3f 10=%.3f\n",
             [cell tickMarkValueAtIndex: 0], [cell tickMarkValueAtIndex: 5], [cell tickMarkValueAtIndex: 10]);
      printf("SLIDER closest 3.4=%.2f 3.6=%.2f 2.5=%.2f 7.5=%.2f -5=%.2f 15=%.2f\n",
             [cell closestTickMarkValueToValue: 3.4], [cell closestTickMarkValueToValue: 3.6],
             [cell closestTickMarkValueToValue: 2.5], [cell closestTickMarkValueToValue: 7.5],
             [cell closestTickMarkValueToValue: -5], [cell closestTickMarkValueToValue: 15]);
      @try { [cell tickMarkValueAtIndex: 99]; printf("SLIDER valueAt(99): no exception\n"); }
      @catch (NSException *e) { printf("SLIDER valueAt(99): raises %s\n", [[e name] UTF8String]); }
    }

    /* ===== #468 NSImageRep registry ===== */
    {
      printf("IMGREP bitmap registered=%d\n",
             [[NSImageRep registeredImageRepClasses] containsObject: [NSBitmapImageRep class]]);
      printf("IMGREP tiff->%s png->%s bogus->%s\n",
             [NSStringFromClass([NSImageRep imageRepClassForFileType: @"tiff"]) UTF8String],
             [NSStringFromClass([NSImageRep imageRepClassForFileType: @"png"]) UTF8String],
             [NSStringFromClass([NSImageRep imageRepClassForFileType: @"bogustype"]) UTF8String]);
      @try { [NSImageRep registerImageRepClass: [NSObject class]];
             printf("IMGREP register NSObject: accepted (no exception)\n"); }
      @catch (NSException *e) { printf("IMGREP register NSObject: raises %s\n", [[e name] UTF8String]); }
    }

    /* ===== #466 NSAttributedString queries ===== */
    {
      NSFont *font = [NSFont systemFontOfSize: 12];
      NSParagraphStyle *ps = [NSParagraphStyle defaultParagraphStyle];
      NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
        font, NSFontAttributeName, [NSColor redColor], NSForegroundColorAttributeName,
        ps, NSParagraphStyleAttributeName, [NSNumber numberWithInt: 2], NSKernAttributeName, nil];
      NSAttributedString *s = [[NSAttributedString alloc] initWithString: @"hello" attributes: attrs];
      NSDictionary *fa = [s fontAttributesInRange: NSMakeRange(0,5)];
      NSDictionary *ra = [s rulerAttributesInRange: NSMakeRange(0,5)];
      printf("ATTRQ fontAttrs: hasFont=%d hasColor=%d hasKern=%d hasPara=%d count=%ld\n",
             [fa objectForKey: NSFontAttributeName] != nil,
             [fa objectForKey: NSForegroundColorAttributeName] != nil,
             [fa objectForKey: NSKernAttributeName] != nil,
             [fa objectForKey: NSParagraphStyleAttributeName] != nil, (long)[fa count]);
      printf("ATTRQ rulerAttrs: hasPara=%d count=%ld\n",
             [ra objectForKey: NSParagraphStyleAttributeName] != nil, (long)[ra count]);
      NSAttributedString *plain = [[NSAttributedString alloc] initWithString: @"plain"];
      printf("ATTRQ ruler(no-para) count=%ld\n",
             (long)[[plain rulerAttributesInRange: NSMakeRange(0,5)] count]);
    }

    /* ===== #467 NSAttributedString mutation ===== */
    {
      NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString: @"hello world"];
      [s superscriptRange: NSMakeRange(0,5)];
      int lv1 = [[s attribute: NSSuperscriptAttributeName atIndex: 0 effectiveRange: NULL] intValue];
      [s superscriptRange: NSMakeRange(0,5)];
      int lv2 = [[s attribute: NSSuperscriptAttributeName atIndex: 0 effectiveRange: NULL] intValue];
      printf("ATTRM superscript once=%d twice=%d\n", lv1, lv2);
      NSMutableAttributedString *s2 = [[NSMutableAttributedString alloc] initWithString: @"hello world"];
      [s2 setAlignment: NSCenterTextAlignment range: NSMakeRange(0,5)];
      id inr = [s2 attribute: NSParagraphStyleAttributeName atIndex: 0 effectiveRange: NULL];
      id outr = [s2 attribute: NSParagraphStyleAttributeName atIndex: 6 effectiveRange: NULL];
      printf("ATTRM setAlignment(0,5): idx0 hasPara=%d idx6 hasPara=%d (Apple may extend to paragraph)\n",
             inr != nil, outr != nil);
    }

    /* ===== #469 NSMatrix selection ===== */
    {
      NSButtonCell *proto = [[NSButtonCell alloc] init];
      NSMatrix *m = [[NSMatrix alloc] initWithFrame: NSMakeRect(0,0,100,100)
                     mode: NSRadioModeMatrix prototype: proto numberOfRows: 2 numberOfColumns: 2];
      printf("MATRIX radio: allowsEmpty=%d selRow=%ld selCol=%ld selCount=%ld\n",
             [m allowsEmptySelection], (long)[m selectedRow], (long)[m selectedColumn],
             (long)[[m selectedCells] count]);
      NSMatrix *ml = [[NSMatrix alloc] initWithFrame: NSMakeRect(0,0,100,100)
                      mode: NSListModeMatrix prototype: proto numberOfRows: 2 numberOfColumns: 2];
      printf("MATRIX list initial selCount=%ld\n", (long)[[ml selectedCells] count]);
      [ml selectCellAtRow: 0 column: 1];
      [ml selectCellAtRow: 1 column: 0];
      printf("MATRIX list after 2 selectCellAtRow selCount=%ld (accumulates?)\n",
             (long)[[ml selectedCells] count]);
    }

    /* ===== #470 NSColorList editing ===== */
    {
      NSColorList *list = [[NSColorList alloc] initWithName: @"UnitTestList"];
      printf("CLIST new editable=%d keys=%ld colorForMissing=%d\n",
             [list isEditable], (long)[[list allKeys] count],
             [list colorWithKey: @"missing"] == nil);
      [list setColor: [NSColor redColor] forKey: @"one"];
      [list setColor: [NSColor greenColor] forKey: @"two"];
      [list setColor: [NSColor blueColor] forKey: @"three"];
      printf("CLIST order after 3 = %s,%s,%s\n",
             [[[list allKeys] objectAtIndex:0] UTF8String],
             [[[list allKeys] objectAtIndex:1] UTF8String],
             [[[list allKeys] objectAtIndex:2] UTF8String]);
      [list insertColor: [NSColor blueColor] key: @"three" atIndex: 0];
      printf("CLIST after move 'three' to 0: first=%s count=%ld\n",
             [[[list allKeys] objectAtIndex:0] UTF8String], (long)[[list allKeys] count]);
    }

    /* ===== #471 NSParagraphStyle tab stops ===== */
    {
      NSParagraphStyle *d = [NSParagraphStyle defaultParagraphStyle];
      NSArray *ts = [d tabStops];
      printf("PARA default tabStops count=%ld defaultTabInterval=%.3f\n",
             (long)[ts count], [d defaultTabInterval]);
      if ([ts count] >= 2)
        printf("PARA default tab[0]=%.3f tab[1]=%.3f last=%.3f\n",
               [[ts objectAtIndex:0] location], [[ts objectAtIndex:1] location],
               [[ts lastObject] location]);
      NSMutableParagraphStyle *p = [[NSMutableParagraphStyle alloc] init];
      NSTextTab *t300 = [[NSTextTab alloc] initWithType: NSLeftTabStopType location: 300];
      NSTextTab *t100 = [[NSTextTab alloc] initWithType: NSLeftTabStopType location: 100];
      NSTextTab *t200 = [[NSTextTab alloc] initWithType: NSLeftTabStopType location: 200];
      [p setTabStops: [NSArray arrayWithObjects: t300, t100, t200, nil]];
      printf("PARA setTabStops(300,100,200) -> [0]=%.0f [1]=%.0f [2]=%.0f (sorted?)\n",
             [[[p tabStops] objectAtIndex:0] location],
             [[[p tabStops] objectAtIndex:1] location],
             [[[p tabStops] objectAtIndex:2] location]);
    }

    printf("DONE\n");
  }
  return 0;
}
