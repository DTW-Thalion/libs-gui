#import <Cocoa/Cocoa.h>
#include <objc/runtime.h>
#include <stdio.h>
#include <string.h>

static NSBitmapImageRep *
makeRep(NSInteger w, NSInteger h, NSInteger bps, NSInteger spp, BOOL alpha,
        BOOL planar, NSString *space, NSBitmapFormat format)
{
  return [[NSBitmapImageRep alloc]
    initWithBitmapDataPlanes: NULL
                  pixelsWide: w
                  pixelsHigh: h
               bitsPerSample: bps
             samplesPerPixel: spp
                    hasAlpha: alpha
                    isPlanar: planar
              colorSpaceName: space
                bitmapFormat: format
                 bytesPerRow: 0
                bitsPerPixel: 0];
}

static void
clearRep(NSBitmapImageRep *rep)
{
  memset([rep bitmapData], 0, [rep bytesPerRow] * [rep pixelsHigh]);
}

static void
dumpRow(const char *label, NSBitmapImageRep *rep, NSInteger row)
{
  unsigned char *p = [rep bitmapData] + row * [rep bytesPerRow];
  NSInteger i;

  printf("%s row %ld:", label, (long)row);
  for (i = 0; i < 4 * 4; i++)
    {
      printf(" %02x", p[i]);
    }
  printf("\n");
}

static void
fillWith(NSBitmapImageRep *rep, NSColor *colour, NSRect rect, BOOL flush)
{
  NSGraphicsContext *ctxt = [NSGraphicsContext
    graphicsContextWithBitmapImageRep: rep];

  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext: ctxt];
  [colour set];
  NSRectFill(rect);
  if (flush)
    {
      [ctxt flushGraphics];
    }
  [NSGraphicsContext restoreGraphicsState];
}

int
main(void)
{
  @autoreleasepool
    {
      NSBitmapImageRep *rep;
      NSGraphicsContext *ctxt;
      unsigned char *p;
      NSInteger y;

      /* 1. the shape of the representation the issue uses */
      rep = makeRep(8, 8, 8, 4, YES, NO, NSDeviceRGBColorSpace, 0);
      printf("A rep 8x8 rgba: bytesPerRow=%ld bitsPerPixel=%ld format=%lu "
             "planar=%d spp=%ld\n",
             (long)[rep bytesPerRow], (long)[rep bitsPerPixel],
             (unsigned long)[rep bitmapFormat], (int)[rep isPlanar],
             (long)[rep samplesPerPixel]);

      ctxt = [NSGraphicsContext graphicsContextWithBitmapImageRep: rep];
      printf("A context=%s flipped=%d drawingToScreen=%d cg=%s attrs=%s\n",
             ctxt ? "non-nil" : "nil", (int)[ctxt isFlipped],
             (int)[ctxt isDrawingToScreen],
             [ctxt CGContext] ? "non-null" : "null",
             [ctxt attributes] ? [[[ctxt attributes] description] UTF8String]
                               : "nil");

      /* 2. an opaque fill over the whole area, read back without a flush */
      clearRep(rep);
      fillWith(rep, [NSColor redColor], NSMakeRect(0, 0, 8, 8), NO);
      dumpRow("B unflushed", rep, 0);
      [[NSGraphicsContext graphicsContextWithBitmapImageRep: rep]
        flushGraphics];
      dumpRow("B flushed  ", rep, 0);

      /* 3. which rows of the buffer does the bottom half of the context
       * reach?  This is the orientation of row 0. */
      clearRep(rep);
      fillWith(rep, [NSColor redColor], NSMakeRect(0, 0, 8, 4), YES);
      for (y = 0; y < 8; y++)
        {
          p = [rep bitmapData] + y * [rep bytesPerRow];
          printf("C y=%ld first=%02x %02x %02x %02x\n", (long)y,
                 p[0], p[1], p[2], p[3]);
        }

      /* 4. and the left half, for the horizontal direction */
      clearRep(rep);
      fillWith(rep, [NSColor redColor], NSMakeRect(0, 0, 4, 8), YES);
      p = [rep bitmapData];
      printf("D x=0 %02x%02x%02x%02x x=7 %02x%02x%02x%02x\n",
             p[0], p[1], p[2], p[3], p[28], p[29], p[30], p[31]);

      /* 5. is what lands in the buffer premultiplied? */
      clearRep(rep);
      fillWith(rep, [NSColor colorWithDeviceRed: 1.0 green: 0.0 blue: 0.0
                                          alpha: 0.5],
               NSMakeRect(0, 0, 8, 8), YES);
      p = [rep bitmapData];
      printf("E half-alpha red over cleared: %02x %02x %02x %02x\n",
             p[0], p[1], p[2], p[3]);

      /* 6. and does a second fill composite over the first? */
      fillWith(rep, [NSColor colorWithDeviceRed: 0.0 green: 0.0 blue: 1.0
                                          alpha: 0.5],
               NSMakeRect(0, 0, 8, 8), YES);
      p = [rep bitmapData];
      printf("F half-alpha blue over that: %02x %02x %02x %02x\n",
             p[0], p[1], p[2], p[3]);

      /* 7. does the representation's own accessor agree with the bytes? */
      printf("G colorAtX:0 y:0 = %s\n",
             [[[rep colorAtX: 0 y: 0] description] UTF8String]);

      /* 8. the formats it will and will not take */
      {
        struct { const char *what; NSBitmapImageRep *rep; } cases[] = {
          { "planar rgba",
            makeRep(8, 8, 8, 4, YES, YES, NSDeviceRGBColorSpace, 0) },
          { "rgb no alpha",
            makeRep(8, 8, 8, 3, NO, NO, NSDeviceRGBColorSpace, 0) },
          { "alpha first",
            makeRep(8, 8, 8, 4, YES, NO, NSDeviceRGBColorSpace,
                    NSBitmapFormatAlphaFirst) },
          { "non premultiplied",
            makeRep(8, 8, 8, 4, YES, NO, NSDeviceRGBColorSpace,
                    NSBitmapFormatAlphaNonpremultiplied) },
          { "16 bits per sample",
            makeRep(8, 8, 16, 4, YES, NO, NSDeviceRGBColorSpace, 0) },
          { "grey no alpha",
            makeRep(8, 8, 8, 1, NO, NO, NSDeviceWhiteColorSpace, 0) },
          { "grey with alpha",
            makeRep(8, 8, 8, 2, YES, NO, NSDeviceWhiteColorSpace, 0) },
          { "calibrated rgba",
            makeRep(8, 8, 8, 4, YES, NO, NSCalibratedRGBColorSpace, 0) },
        };
        int i;

        for (i = 0; i < (int)(sizeof(cases) / sizeof(cases[0])); i++)
          {
            NSGraphicsContext *c;

            if (cases[i].rep == nil)
              {
                printf("H %-20s rep=nil\n", cases[i].what);
                continue;
              }
            c = [NSGraphicsContext
              graphicsContextWithBitmapImageRep: cases[i].rep];
            printf("H %-20s ctxt=%s", cases[i].what, c ? "non-nil" : "nil");
            if (c != nil)
              {
                clearRep(cases[i].rep);
                fillWith(cases[i].rep, [NSColor redColor],
                         NSMakeRect(0, 0, 8, 8), YES);
                p = [cases[i].rep bitmapData];
                printf(" bytes=%02x %02x %02x %02x %02x %02x",
                       p[0], p[1], p[2], p[3], p[4], p[5]);
              }
            printf("\n");
          }
      }

      /* 9. does the context outlive the rep it was made for, and does a
       * second context for the same rep see the first one's drawing? */
      rep = makeRep(8, 8, 8, 4, YES, NO, NSDeviceRGBColorSpace, 0);
      clearRep(rep);
      fillWith(rep, [NSColor redColor], NSMakeRect(0, 0, 8, 8), YES);
      fillWith(rep, [NSColor greenColor], NSMakeRect(0, 0, 4, 4), YES);
      p = [rep bitmapData];
      printf("I two contexts, row 0: %02x%02x%02x%02x at x=0, "
             "%02x%02x%02x%02x at x=7\n",
             p[0], p[1], p[2], p[3], p[28], p[29], p[30], p[31]);

      /* 10. a fill that runs past the edge of the representation */
      clearRep(rep);
      fillWith(rep, [NSColor redColor], NSMakeRect(-4, -4, 40, 40), YES);
      dumpRow("J oversized", rep, 0);

      /* 11. the same drawing through NSImage lockFocus, for comparison */
      printf("K NSGraphicsContext class = %s\n",
             class_getName([[NSGraphicsContext
               graphicsContextWithBitmapImageRep: rep] class]));
    }
  return 0;
}
