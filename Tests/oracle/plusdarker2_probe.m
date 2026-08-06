#import <Cocoa/Cocoa.h>
#include <stdio.h>

#define SIDE 20

static void
readCentre(NSBitmapImageRep *rep, int *out)
{
  unsigned char *p = [rep bitmapData] + (SIDE / 2) * [rep bytesPerRow]
    + (SIDE / 2) * ([rep bitsPerPixel] / 8);

  out[0] = p[0]; out[1] = p[1]; out[2] = p[2]; out[3] = p[3];
}

/* Build the destination, read it back, composite the source, read it back,
 * so that the destination is never assumed.
 */
static void
run(NSCompositingOperation op, const char *opname,
    CGFloat dg, CGFloat da, CGFloat sg, CGFloat sa)
{
  NSImage *image;
  NSBitmapImageRep *before;
  NSBitmapImageRep *after;
  int b[4], a[4];

  image = [[NSImage alloc] initWithSize: NSMakeSize(SIDE, SIDE)];
  [image lockFocus];
  NSRectFillUsingOperation(NSMakeRect(0, 0, SIDE, SIDE),
                           NSCompositingOperationClear);
  [[NSColor colorWithDeviceRed: dg green: dg blue: dg alpha: da] set];
  NSRectFillUsingOperation(NSMakeRect(0, 0, SIDE, SIDE),
                           NSCompositingOperationCopy);
  before = [[NSBitmapImageRep alloc]
    initWithFocusedViewRect: NSMakeRect(0, 0, SIDE, SIDE)];
  [[NSColor colorWithDeviceRed: sg green: sg blue: sg alpha: sa] set];
  NSRectFillUsingOperation(NSMakeRect(0, 0, SIDE, SIDE), op);
  after = [[NSBitmapImageRep alloc]
    initWithFocusedViewRect: NSMakeRect(0, 0, SIDE, SIDE)];
  [image unlockFocus];

  readCentre(before, b);
  readCentre(after, a);
  printf("%-12s dst %.2f/%.2f is %3d/%3d  src %.2f/%.2f  -> %3d %3d\n",
         opname, dg, da, b[0], b[3], sg, sa, a[0], a[3]);
}

int
main(void)
{
  @autoreleasepool
    {
      CGFloat das[] = { 1.0, 0.5, 0.25 };
      CGFloat sas[] = { 1.0, 0.5, 0.25 };
      int i, j;

      printf("op           destination        source          result\n");
      for (i = 0; i < 3; i++)
        {
          for (j = 0; j < 3; j++)
            {
              run(NSCompositingOperationPlusDarker, "PlusDarker",
                  0.6, das[i], 0.8, sas[j]);
            }
        }
      for (i = 0; i < 3; i++)
        {
          for (j = 0; j < 3; j++)
            {
              run(NSCompositingOperationPlusLighter, "PlusLighter",
                  0.2, das[i], 0.3, sas[j]);
            }
        }
      /* And the two neighbours, to have a reference in the same harness. */
      run(NSCompositingOperationSourceOver, "SourceOver", 0.6, 1.0, 0.8, 0.5);
      run(NSCompositingOperationSourceOver, "SourceOver", 0.6, 0.5, 0.8, 0.5);
    }
  return 0;
}
