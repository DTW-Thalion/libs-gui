/* Apple oracle for the NSTextTable coverage test: the enum values, the
   NSTextBlock and NSTextTable defaults and round-trips, and NSTextTableBlock. */
#import <Cocoa/Cocoa.h>

int
main(int argc, const char **argv)
{
  @autoreleasepool
  {
    NSLog(@"ENUM valueType abs=%d pct=%d",
          (int)NSTextBlockAbsoluteValueType, (int)NSTextBlockPercentageValueType);
    NSLog(@"ENUM dim W=%d minW=%d maxW=%d H=%d minH=%d maxH=%d",
          (int)NSTextBlockWidth, (int)NSTextBlockMinimumWidth,
          (int)NSTextBlockMaximumWidth, (int)NSTextBlockHeight,
          (int)NSTextBlockMinimumHeight, (int)NSTextBlockMaximumHeight);
    NSLog(@"ENUM layer pad=%d border=%d margin=%d",
          (int)NSTextBlockPadding, (int)NSTextBlockBorder, (int)NSTextBlockMargin);
    NSLog(@"ENUM valign top=%d mid=%d bot=%d base=%d",
          (int)NSTextBlockTopAlignment, (int)NSTextBlockMiddleAlignment,
          (int)NSTextBlockBottomAlignment, (int)NSTextBlockBaselineAlignment);
    NSLog(@"ENUM layout auto=%d fixed=%d",
          (int)NSTextTableAutomaticLayoutAlgorithm,
          (int)NSTextTableFixedLayoutAlgorithm);

    NSTextBlock *b = [[NSTextBlock alloc] init];
    NSLog(@"BLOCK default valign=%d widthW=%g bg=%@ borderMinX=%@",
          (int)[b verticalAlignment], [b valueForDimension: NSTextBlockWidth],
          [b backgroundColor] == nil ? @"nil" : @"set",
          [b borderColorForEdge: NSMinXEdge] == nil ? @"nil" : @"set");

    [b setContentWidth: 100 type: NSTextBlockAbsoluteValueType];
    NSLog(@"BLOCK contentWidth=%g type=%d",
          [b contentWidth], (int)[b contentWidthValueType]);
    [b setValue: 50 type: NSTextBlockPercentageValueType
       forDimension: NSTextBlockMinimumWidth];
    NSLog(@"BLOCK minW=%g minWtype=%d",
          [b valueForDimension: NSTextBlockMinimumWidth],
          (int)[b valueTypeForDimension: NSTextBlockMinimumWidth]);
    [b setWidth: 3 type: NSTextBlockAbsoluteValueType
       forLayer: NSTextBlockBorder edge: NSMaxYEdge];
    NSLog(@"BLOCK borderMaxY=%g", [b widthForLayer: NSTextBlockBorder edge: NSMaxYEdge]);
    [b setVerticalAlignment: NSTextBlockMiddleAlignment];
    NSLog(@"BLOCK valignSet=%d", (int)[b verticalAlignment]);

    NSTextTable *t = [[NSTextTable alloc] init];
    NSLog(@"TABLE default cols=%lu layout=%d collapses=%d hides=%d",
          (unsigned long)[t numberOfColumns], (int)[t layoutAlgorithm],
          [t collapsesBorders], [t hidesEmptyCells]);
    [t setNumberOfColumns: 3];
    [t setLayoutAlgorithm: NSTextTableFixedLayoutAlgorithm];
    [t setCollapsesBorders: YES];
    [t setHidesEmptyCells: YES];
    NSLog(@"TABLE rt cols=%lu layout=%d collapses=%d hides=%d",
          (unsigned long)[t numberOfColumns], (int)[t layoutAlgorithm],
          [t collapsesBorders], [t hidesEmptyCells]);

    NSTextTableBlock *tb = [[NSTextTableBlock alloc] initWithTable: t
      startingRow: 1 rowSpan: 2 startingColumn: 3 columnSpan: 4];
    NSLog(@"TBLOCK row=%d rspan=%d col=%d cspan=%d tableSame=%d",
          [tb startingRow], [tb rowSpan], [tb startingColumn],
          [tb columnSpan], [tb table] == t);
  }
  return 0;
}
