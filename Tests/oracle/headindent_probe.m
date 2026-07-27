#import <Cocoa/Cocoa.h>

/* Does AppKit's convenience string drawing honour paragraph headIndent
   (the continuation-line indent) on WRAPPED lines, or ignore it the same
   way it ignores firstLineHeadIndent?  Render a multi-line string into a
   bitmap with indent 0 and indent 20 and read back the left edge of each
   drawn line. */

static NSAttributedString *makeString(CGFloat indent)
{
  NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
  [ps setFirstLineHeadIndent: indent];
  [ps setHeadIndent: indent];
  [ps setLineBreakMode: NSLineBreakByWordWrapping];
  NSDictionary *attrs = @{ NSFontAttributeName: [NSFont systemFontOfSize: 12],
                           NSForegroundColorAttributeName: [NSColor blackColor],
                           NSParagraphStyleAttributeName: ps };
  return [[NSAttributedString alloc]
    initWithString: @"The quick brown fox jumps over the lazy dog near the river"
        attributes: attrs];
}

/* Draw into a white bitmap of size WxH and print the leftmost dark-pixel
   column for each detected text line. */
static void renderAndScan(const char *label, NSAttributedString *s,
                          int W, int H)
{
  NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
    initWithBitmapDataPlanes: NULL
                  pixelsWide: W
                  pixelsHigh: H
               bitsPerSample: 8
             samplesPerPixel: 4
                    hasAlpha: YES
                    isPlanar: NO
              colorSpaceName: NSDeviceRGBColorSpace
                 bytesPerRow: 0
                bitsPerPixel: 0];

  NSGraphicsContext *gc =
    [NSGraphicsContext graphicsContextWithBitmapImageRep: rep];
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext: gc];
  [[NSColor whiteColor] setFill];
  NSRectFill(NSMakeRect(0, 0, W, H));
  /* leave a small left inset so a flush line still has room to the left */
  [s drawWithRect: NSMakeRect(4, 0, 120, H)
          options: NSStringDrawingUsesLineFragmentOrigin];
  [NSGraphicsContext restoreGraphicsState];

  unsigned char *bytes = [rep bitmapData];
  NSInteger bpr = [rep bytesPerRow];
  NSInteger spp = [rep samplesPerPixel];

  printf("%s (WxH=%dx%d):\n", label, W, H);
  int inLine = 0, y0 = 0;
  for (int y = 0; y < H; y++)
    {
      int darkCount = 0, leftmost = -1;
      for (int x = 0; x < W; x++)
        {
          unsigned char *px = bytes + y * bpr + x * spp;
          /* dark = low luminance and opaque */
          int lum = (px[0] * 30 + px[1] * 59 + px[2] * 11) / 100;
          if (lum < 110 && px[3] > 40)
            {
              darkCount++;
              if (leftmost < 0) leftmost = x;
            }
        }
      int isText = (darkCount > 2);
      if (isText && !inLine) { inLine = 1; y0 = y; }
      if (!isText && inLine)
        {
          inLine = 0; /* line ended at y-1 */
        }
      (void)y0;
    }

  /* second pass: group and report leftmost per line */
  inLine = 0;
  int lineLeft = 10000, lineNo = 0;
  for (int y = 0; y <= H; y++)
    {
      int darkCount = 0, leftmost = -1;
      if (y < H)
        for (int x = 0; x < W; x++)
          {
            unsigned char *px = bytes + y * bpr + x * spp;
            int lum = (px[0] * 30 + px[1] * 59 + px[2] * 11) / 100;
            if (lum < 110 && px[3] > 40) { darkCount++; if (leftmost < 0) leftmost = x; }
          }
      int isText = (y < H) && (darkCount > 2);
      if (isText)
        {
          inLine = 1;
          if (leftmost >= 0 && leftmost < lineLeft) lineLeft = leftmost;
        }
      else if (inLine)
        {
          printf("  line %d leftmost x = %d\n", ++lineNo, lineLeft);
          inLine = 0; lineLeft = 10000;
        }
    }
}

int main(void)
{
  @autoreleasepool
    {
      int W = 160, H = 120;

      /* boundingRect side: force wrap with a narrow width */
      NSStringDrawingOptions lf = NSStringDrawingUsesLineFragmentOrigin;
      NSRect r0 = [makeString(0.0)  boundingRectWithSize: NSMakeSize(120, 1000) options: lf];
      NSRect r20 = [makeString(20.0) boundingRectWithSize: NSMakeSize(120, 1000) options: lf];
      printf("boundingRect (width=120, wrapped):\n");
      printf("  indent 0  : origin=(%.1f,%.1f) size=(%.1f x %.1f)\n",
             r0.origin.x, r0.origin.y, r0.size.width, r0.size.height);
      printf("  indent 20 : origin=(%.1f,%.1f) size=(%.1f x %.1f)\n",
             r20.origin.x, r20.origin.y, r20.size.width, r20.size.height);
      printf("\n");

      renderAndScan("DRAW indent 0",  makeString(0.0),  W, H);
      renderAndScan("DRAW indent 20", makeString(20.0), W, H);
    }
  return 0;
}
