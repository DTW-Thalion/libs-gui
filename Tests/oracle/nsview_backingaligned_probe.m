/* Oracle: -[NSView backingAlignedRect:options:] per-edge rounding on a scale-1
   backing store. Each call is guarded so an invalid option set does not abort
   the rest. */
#import <Cocoa/Cocoa.h>

static void
align(NSView *v, const char *label, NSRect r, NSAlignmentOptions opts)
{
  @try
    {
      NSRect o = [v backingAlignedRect: r options: opts];
      printf("%-32s in={%.2f,%.2f,%.2f,%.2f} -> out={%g,%g,%g,%g}\n",
             label, r.origin.x, r.origin.y, r.size.width, r.size.height,
             o.origin.x, o.origin.y, o.size.width, o.size.height);
    }
  @catch (NSException *e)
    {
      printf("%-32s RAISED %s\n", label, [[e name] UTF8String]);
    }
}

int
main(void)
{
  @autoreleasepool
    {
      NSView *v = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 100, 100)];
      NSRect r = NSMakeRect(10.3, 20.7, 5.4, 6.8);
      printf("=== rect {10.3,20.7,5.4,6.8} minX=10.3 minY=20.7 maxX=15.7 maxY=27.5 ===\n");
      align(v, "AllEdgesNearest", r, NSAlignAllEdgesNearest);
      align(v, "AllEdgesInward", r, NSAlignAllEdgesInward);
      align(v, "AllEdgesOutward", r, NSAlignAllEdgesOutward);

      printf("\n--- flipped ---\n");
      align(v, "AllEdgesNearest|Flipped", r, NSAlignAllEdgesNearest | NSAlignRectFlipped);
      align(v, "AllEdgesInward|Flipped", r, NSAlignAllEdgesInward | NSAlignRectFlipped);
      align(v, "AllEdgesOutward|Flipped", r, NSAlignAllEdgesOutward | NSAlignRectFlipped);

      printf("\n--- width/height instead of a second edge ---\n");
      align(v, "MinXNear|WidthNear|MinYNear|HeightNear", r,
            NSAlignMinXNearest | NSAlignWidthNearest | NSAlignMinYNearest | NSAlignHeightNearest);
      align(v, "MinXIn|WidthIn|MinYIn|HeightIn", r,
            NSAlignMinXInward | NSAlignWidthInward | NSAlignMinYInward | NSAlignHeightInward);
      align(v, "MinXOut|WidthOut|MinYOut|HeightOut", r,
            NSAlignMinXOutward | NSAlignWidthOutward | NSAlignMinYOutward | NSAlignHeightOutward);
      align(v, "MaxXNear|WidthNear|MaxYNear|HeightNear", r,
            NSAlignMaxXNearest | NSAlignWidthNearest | NSAlignMaxYNearest | NSAlignHeightNearest);

      printf("\n--- mixed per-edge rounding ---\n");
      align(v, "MinXIn|MaxXOut|MinYNear|MaxYNear", r,
            NSAlignMinXInward | NSAlignMaxXOutward | NSAlignMinYNearest | NSAlignMaxYNearest);

      printf("\n--- invalid / partial option sets ---\n");
      align(v, "MinXInward only", r, NSAlignMinXInward);
      align(v, "zero options", r, 0);
      align(v, "MinX|MaxX only (no Y)", r, NSAlignMinXNearest | NSAlignMaxXNearest);
      align(v, "MinX|Width|MaxX (X overspec)", r,
            NSAlignMinXNearest | NSAlignWidthNearest | NSAlignMaxXNearest
            | NSAlignMinYNearest | NSAlignHeightNearest);

      printf("\n=== negative-origin {-3.4,-5.6,2.2,3.3} minX=-3.4 minY=-5.6 maxX=-1.2 maxY=-2.3 ===\n");
      NSRect n = NSMakeRect(-3.4, -5.6, 2.2, 3.3);
      align(v, "AllEdgesNearest", n, NSAlignAllEdgesNearest);
      align(v, "AllEdgesInward", n, NSAlignAllEdgesInward);
      align(v, "AllEdgesOutward", n, NSAlignAllEdgesOutward);

      printf("\n=== already-integral {4,5,6,7} ===\n");
      align(v, "AllEdgesNearest", NSMakeRect(4, 5, 6, 7), NSAlignAllEdgesNearest);
      align(v, "AllEdgesInward", NSMakeRect(4, 5, 6, 7), NSAlignAllEdgesInward);

      printf("\n=== half-integer {2.5,3.5,1.5,4.5} rounding direction ===\n");
      NSRect h = NSMakeRect(2.5, 3.5, 1.5, 4.5);
      align(v, "AllEdgesNearest", h, NSAlignAllEdgesNearest);
    }
  return 0;
}
