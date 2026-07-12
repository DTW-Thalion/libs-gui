/* Apple oracle for the NSTableHeaderCell coverage test: init defaults,
   sortIndicatorRectForBounds: geometry, setHighlighted:, and stringValue. */
#import <Cocoa/Cocoa.h>

int main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    NSTableHeaderCell *c = [[NSTableHeaderCell alloc] initTextCell: @"Col"];
    printf("THC defaults: align=%ld drawsBg=%d bezeled=%d bordered=%d wraps=%d\n",
           (long)[c alignment], [c drawsBackground], [c isBezeled],
           [c isBordered], [c wraps]);
    printf("THC stringValue='%s' font!=nil:%d textColor!=nil:%d bgColor!=nil:%d\n",
           [[c stringValue] UTF8String], [c font] != nil,
           [c textColor] != nil, [c backgroundColor] != nil);

    /* sort indicator rect: right-aligned within the bounds. */
    NSRect bounds = NSMakeRect(10, 5, 100, 20);
    NSRect sir = [c sortIndicatorRectForBounds: bounds];
    printf("THC sortIndicatorRect for (10,5,100,20) = (%g,%g,%g,%g)\n",
           sir.origin.x, sir.origin.y, sir.size.width, sir.size.height);
    printf("THC sortIndicator rightEdge==boundsRightEdge:%d insideBounds:%d\n",
           (int)(NSMaxX(sir) == NSMaxX(bounds)),
           (int)(sir.origin.x >= bounds.origin.x && NSMaxX(sir) <= NSMaxX(bounds)
                 && sir.size.width > 0));

    /* highlighted round-trip. */
    [c setHighlighted: YES];
    printf("THC setHighlighted YES -> isHighlighted=%d\n", [c isHighlighted]);
    [c setHighlighted: NO];
    printf("THC setHighlighted NO -> isHighlighted=%d\n", [c isHighlighted]);

    printf("DONE\n");
  }
  return 0;
}
