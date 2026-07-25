/* Oracle: Foundation NSIntegralRectWithOptions contract (empty rect, size
   options, flipped tie, invalid option sets). Each call guarded. */
#import <Cocoa/Cocoa.h>

static void
t(const char *label, NSRect r, NSAlignmentOptions o)
{
  @try
    {
      NSRect x = NSIntegralRectWithOptions(r, o);
      printf("%-40s in={%.2f,%.2f,%.2f,%.2f} -> {%g,%g,%g,%g}\n",
             label, r.origin.x, r.origin.y, r.size.width, r.size.height,
             x.origin.x, x.origin.y, x.size.width, x.size.height);
    }
  @catch (NSException *e)
    {
      printf("%-40s RAISED %s\n", label, [[e name] UTF8String]);
    }
}

int
main(void)
{
  @autoreleasepool
    {
      NSRect r = NSMakeRect(10.3, 20.7, 5.4, 6.8);
      printf("=== {10.3,20.7,5.4,6.8} ===\n");
      t("AllEdgesNearest", r, NSAlignAllEdgesNearest);
      t("AllEdgesInward", r, NSAlignAllEdgesInward);
      t("AllEdgesOutward", r, NSAlignAllEdgesOutward);
      t("AllEdgesNearest|Flipped", r, NSAlignAllEdgesNearest | NSAlignRectFlipped);
      t("MinX|Width|MinY|Height Nearest", r,
        NSAlignMinXNearest | NSAlignWidthNearest | NSAlignMinYNearest | NSAlignHeightNearest);
      t("MaxX|Width|MaxY|Height Nearest", r,
        NSAlignMaxXNearest | NSAlignWidthNearest | NSAlignMaxYNearest | NSAlignHeightNearest);
      t("MinX|Width|MinY|Height Inward", r,
        NSAlignMinXInward | NSAlignWidthInward | NSAlignMinYInward | NSAlignHeightInward);

      printf("\n=== invalid / partial ===\n");
      t("MinXInward only", r, NSAlignMinXInward);
      t("zero options", r, 0);
      t("MinX|MaxX only (no Y)", r, NSAlignMinXNearest | NSAlignMaxXNearest);
      t("X overspecified", r,
        NSAlignMinXNearest | NSAlignWidthNearest | NSAlignMaxXNearest
        | NSAlignMinYNearest | NSAlignHeightNearest);

      printf("\n=== empty and zero-size rects ===\n");
      t("empty {0,0,0,0} Nearest", NSMakeRect(0, 0, 0, 0), NSAlignAllEdgesNearest);
      t("zero-size {5.3,6.7,0,0} Nearest", NSMakeRect(5.3, 6.7, 0, 0), NSAlignAllEdgesNearest);
      t("zero-size {5.3,6.7,0,0} Outward", NSMakeRect(5.3, 6.7, 0, 0), NSAlignAllEdgesOutward);
      t("zero-width {5.3,6.7,0,4.2} Nearest", NSMakeRect(5.3, 6.7, 0, 4.2), NSAlignAllEdgesNearest);

      printf("\n=== negatives {-3.4,-5.6,2.2,3.3} ===\n");
      NSRect n = NSMakeRect(-3.4, -5.6, 2.2, 3.3);
      t("AllEdgesNearest", n, NSAlignAllEdgesNearest);
      t("AllEdgesInward", n, NSAlignAllEdgesInward);
      t("AllEdgesOutward", n, NSAlignAllEdgesOutward);
      t("half-tie {2.5,3.5,1,1} Nearest", NSMakeRect(2.5, 3.5, 1, 1), NSAlignAllEdgesNearest);
      t("neg half-tie {-2.5,-3.5,1,1} Nearest", NSMakeRect(-2.5, -3.5, 1, 1), NSAlignAllEdgesNearest);
    }
  return 0;
}
