#import <Cocoa/Cocoa.h>
#include <stdio.h>

#define SIDE 20

/* Fill the destination, then composite the source over it with OP, and read
 * the centre pixel back.  Grey levels are chosen so that the candidate
 * formulas disagree: for source 0.8 over destination 0.6, a darken blend
 * gives 0.6 (153) and a linear burn gives 0.4 (102).
 */
static void
run(NSCompositingOperation op,
    CGFloat dg, CGFloat da, CGFloat sg, CGFloat sa, const char *what)
{
  NSImage *image;
  NSBitmapImageRep *rep;
  unsigned char *p;

  image = [[NSImage alloc] initWithSize: NSMakeSize(SIDE, SIDE)];
  [image lockFocus];
  NSRectFillUsingOperation(NSMakeRect(0, 0, SIDE, SIDE),
                           NSCompositingOperationClear);
  [[NSColor colorWithDeviceRed: dg green: dg blue: dg alpha: da] set];
  NSRectFillUsingOperation(NSMakeRect(0, 0, SIDE, SIDE),
                           NSCompositingOperationCopy);
  [[NSColor colorWithDeviceRed: sg green: sg blue: sg alpha: sa] set];
  NSRectFillUsingOperation(NSMakeRect(0, 0, SIDE, SIDE), op);
  rep = [[NSBitmapImageRep alloc]
    initWithFocusedViewRect: NSMakeRect(0, 0, SIDE, SIDE)];
  [image unlockFocus];

  p = [rep bitmapData] + (SIDE / 2) * [rep bytesPerRow]
    + (SIDE / 2) * ([rep bitsPerPixel] / 8);
  printf("%-46s dst %.2f/%.2f src %.2f/%.2f -> %3d %3d %3d %3d\n",
         what, dg, da, sg, sa, p[0], p[1], p[2], p[3]);
}

int
main(void)
{
  @autoreleasepool
    {
      printf("PlusDarker\n");
      run(NSCompositingOperationPlusDarker, 0.6, 1.0, 0.8, 1.0,
          "opaque over opaque, darken 153 burn 102");
      run(NSCompositingOperationPlusDarker, 0.6, 1.0, 0.4, 1.0,
          "opaque over opaque, darken 102 burn 0");
      run(NSCompositingOperationPlusDarker, 0.8, 1.0, 0.8, 1.0,
          "opaque over opaque, darken 204 burn 153");
      run(NSCompositingOperationPlusDarker, 0.6, 1.0, 0.8, 0.5,
          "half source over opaque");
      run(NSCompositingOperationPlusDarker, 0.6, 0.5, 0.8, 1.0,
          "opaque source over half destination");
      run(NSCompositingOperationPlusDarker, 0.6, 0.5, 0.8, 0.5,
          "half over half");
      run(NSCompositingOperationPlusDarker, 0.0, 1.0, 0.8, 1.0,
          "over black");
      run(NSCompositingOperationPlusDarker, 1.0, 1.0, 0.8, 1.0,
          "over white");

      printf("PlusLighter\n");
      run(NSCompositingOperationPlusLighter, 0.6, 1.0, 0.8, 1.0,
          "opaque over opaque, add clamps to 255");
      run(NSCompositingOperationPlusLighter, 0.2, 1.0, 0.3, 1.0,
          "opaque over opaque, add 128");
      run(NSCompositingOperationPlusLighter, 0.2, 1.0, 0.3, 0.5,
          "half source over opaque");
      run(NSCompositingOperationPlusLighter, 0.2, 0.5, 0.3, 1.0,
          "opaque source over half destination");

      printf("Darken and Multiply for comparison\n");
      run(NSCompositingOperationDestinationOver, 0.6, 1.0, 0.8, 1.0,
          "destination over, for the harness");
    }
  return 0;
}
