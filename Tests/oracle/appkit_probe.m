/* What -[NSBitmapImageRep colorAtX:y:] answers when the alpha is zero, and
 * for the ordinary cases either side of it.
 */
#import <Cocoa/Cocoa.h>
#include <stdio.h>
#include <math.h>

static NSBitmapImageRep *
makeRep(NSBitmapFormat fmt)
{
  return [[NSBitmapImageRep alloc]
    initWithBitmapDataPlanes: NULL pixelsWide: 2 pixelsHigh: 2
                bitsPerSample: 8 samplesPerPixel: 4 hasAlpha: YES
                     isPlanar: NO colorSpaceName: NSDeviceRGBColorSpace
                 bitmapFormat: fmt bytesPerRow: 8 bitsPerPixel: 32];
}

static const char *
fmt1(CGFloat v)
{
  static char buf[8][40];
  static int n = 0;
  char *b = buf[n++ % 8];

  if (isnan((double)v))
    snprintf(b, 40, "NaN");
  else if (isinf((double)v))
    snprintf(b, 40, "%sinf", v < 0 ? "-" : "+");
  else
    snprintf(b, 40, "%.4f", (double)v);
  return b;
}

static void
probe(const char *what, NSBitmapFormat fmt,
      NSUInteger r, NSUInteger g, NSUInteger b, NSUInteger a)
{
  NSBitmapImageRep *ir = makeRep(fmt);
  NSUInteger px[5];
  NSUInteger back[5];
  NSColor *c;

  px[0] = r; px[1] = g; px[2] = b; px[3] = a;
  [ir setPixel: px atX: 0 y: 0];
  [ir getPixel: back atX: 0 y: 0];
  c = [ir colorAtX: 0 y: 0];

  printf("%-46s stored %3lu %3lu %3lu %3lu -> back %3lu %3lu %3lu %3lu\n",
         what,
         (unsigned long)r, (unsigned long)g, (unsigned long)b, (unsigned long)a,
         (unsigned long)back[0], (unsigned long)back[1],
         (unsigned long)back[2], (unsigned long)back[3]);
  if (c == nil)
    {
      printf("%-46s   colorAtX:y: = nil\n", "");
    }
  else
    {
      printf("%-46s   colorAtX:y: space=%s r=%s g=%s b=%s a=%s\n", "",
             [[c colorSpaceName] UTF8String],
             fmt1([c redComponent]), fmt1([c greenComponent]),
             fmt1([c blueComponent]), fmt1([c alphaComponent]));
    }
  [ir release];
}

int
main(void)
{
  @autoreleasepool
    {
      printf("=== premultiplied, alpha last (bitmapFormat 0) ===\n");
      probe("opaque red", 0, 255, 0, 0, 255);
      probe("half transparent red, premultiplied", 0, 128, 0, 0, 128);
      probe("ALPHA ZERO with a non zero red", 0, 255, 0, 0, 0);
      probe("ALPHA ZERO, all zero", 0, 0, 0, 0, 0);

      printf("\n=== non premultiplied, alpha last ===\n");
      probe("opaque red", NSAlphaNonpremultipliedBitmapFormat, 255, 0, 0, 255);
      probe("half transparent red", NSAlphaNonpremultipliedBitmapFormat,
            255, 0, 0, 128);
      probe("ALPHA ZERO with a non zero red",
            NSAlphaNonpremultipliedBitmapFormat, 255, 0, 0, 0);

      printf("\n=== premultiplied, alpha FIRST (a,r,g,b order) ===\n");
      probe("ALPHA ZERO with a non zero red",
            NSAlphaFirstBitmapFormat, 0, 255, 0, 0);
    }
  return 0;
}
