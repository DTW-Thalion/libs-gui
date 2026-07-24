/* Oracle: NSAlignmentOptions constant values and -[NSView backingAlignedRect:
   options:] per-edge rounding on a scale-1 backing store. */
#import <Cocoa/Cocoa.h>

static void
dumpConst(const char *name, unsigned long long v)
{
  printf("%-24s = 0x%llx (%llu)\n", name, v, v);
}

static void
align(NSView *v, const char *label, NSRect r, NSAlignmentOptions opts)
{
  NSRect o = [v backingAlignedRect: r options: opts];
  printf("%-40s in={%.2f,%.2f,%.2f,%.2f} -> out={%g,%g,%g,%g}\n",
         label, r.origin.x, r.origin.y, r.size.width, r.size.height,
         o.origin.x, o.origin.y, o.size.width, o.size.height);
}

int
main(void)
{
  @autoreleasepool
    {
      printf("=== NSAlignmentOptions values ===\n");
      dumpConst("NSAlignMinXInward", NSAlignMinXInward);
      dumpConst("NSAlignMinYInward", NSAlignMinYInward);
      dumpConst("NSAlignMaxXInward", NSAlignMaxXInward);
      dumpConst("NSAlignMaxYInward", NSAlignMaxYInward);
      dumpConst("NSAlignWidthInward", NSAlignWidthInward);
      dumpConst("NSAlignHeightInward", NSAlignHeightInward);
      dumpConst("NSAlignMinXOutward", NSAlignMinXOutward);
      dumpConst("NSAlignMinYOutward", NSAlignMinYOutward);
      dumpConst("NSAlignMaxXOutward", NSAlignMaxXOutward);
      dumpConst("NSAlignMaxYOutward", NSAlignMaxYOutward);
      dumpConst("NSAlignWidthOutward", NSAlignWidthOutward);
      dumpConst("NSAlignHeightOutward", NSAlignHeightOutward);
      dumpConst("NSAlignMinXNearest", NSAlignMinXNearest);
      dumpConst("NSAlignMinYNearest", NSAlignMinYNearest);
      dumpConst("NSAlignMaxXNearest", NSAlignMaxXNearest);
      dumpConst("NSAlignMaxYNearest", NSAlignMaxYNearest);
      dumpConst("NSAlignWidthNearest", NSAlignWidthNearest);
      dumpConst("NSAlignHeightNearest", NSAlignHeightNearest);
      dumpConst("NSAlignRectFlipped", NSAlignRectFlipped);
      dumpConst("NSAlignAllEdgesInward", NSAlignAllEdgesInward);
      dumpConst("NSAlignAllEdgesOutward", NSAlignAllEdgesOutward);
      dumpConst("NSAlignAllEdgesNearest", NSAlignAllEdgesNearest);

      NSView *v = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 100, 100)];
      printf("\n=== view has no window; backing store scale is 1 ===\n");

      printf("\n=== rect {10.3, 20.7, 5.4, 6.8}: minX=10.3 minY=20.7 maxX=15.7 maxY=27.5 ===\n");
      NSRect r = NSMakeRect(10.3, 20.7, 5.4, 6.8);
      align(v, "AllEdgesNearest", r, NSAlignAllEdgesNearest);
      align(v, "AllEdgesInward", r, NSAlignAllEdgesInward);
      align(v, "AllEdgesOutward", r, NSAlignAllEdgesOutward);
      align(v, "MinXInward only", r, NSAlignMinXInward);
      align(v, "MaxXInward only", r, NSAlignMaxXInward);
      align(v, "MinXOutward only", r, NSAlignMinXOutward);
      align(v, "MaxXOutward only", r, NSAlignMaxXOutward);
      align(v, "MinYInward only", r, NSAlignMinYInward);
      align(v, "MaxYInward only", r, NSAlignMaxYInward);
      align(v, "MinX+Width Nearest", r,
            NSAlignMinXNearest | NSAlignWidthNearest);
      align(v, "MinY+Height Nearest", r,
            NSAlignMinYNearest | NSAlignHeightNearest);
      align(v, "AllEdgesNearest+Flipped", r,
            NSAlignAllEdgesNearest | NSAlignRectFlipped);
      align(v, "AllEdgesInward+Flipped", r,
            NSAlignAllEdgesInward | NSAlignRectFlipped);
      align(v, "MinYInward+Flipped", r,
            NSAlignMinYInward | NSAlignRectFlipped);
      align(v, "MaxYInward+Flipped", r,
            NSAlignMaxYInward | NSAlignRectFlipped);
      align(v, "zero options", r, 0);

      printf("\n=== negative-origin rect {-3.4, -5.6, 2.2, 3.3} ===\n");
      NSRect n = NSMakeRect(-3.4, -5.6, 2.2, 3.3);
      align(v, "AllEdgesNearest", n, NSAlignAllEdgesNearest);
      align(v, "AllEdgesInward", n, NSAlignAllEdgesInward);
      align(v, "AllEdgesOutward", n, NSAlignAllEdgesOutward);

      printf("\n=== already-integral rect {4,5,6,7} ===\n");
      align(v, "AllEdgesNearest", NSMakeRect(4, 5, 6, 7), NSAlignAllEdgesNearest);
    }
  return 0;
}
