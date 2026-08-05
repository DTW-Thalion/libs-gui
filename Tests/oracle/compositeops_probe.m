#import <Cocoa/Cocoa.h>
#include <stdio.h>

#define SIDE 20

static struct { const char *name; NSCompositingOperation op; } ops[] = {
  { "Clear          ", NSCompositingOperationClear },
  { "Copy           ", NSCompositingOperationCopy },
  { "SourceOver     ", NSCompositingOperationSourceOver },
  { "SourceIn       ", NSCompositingOperationSourceIn },
  { "SourceOut      ", NSCompositingOperationSourceOut },
  { "SourceAtop     ", NSCompositingOperationSourceAtop },
  { "DestinationOver", NSCompositingOperationDestinationOver },
  { "DestinationIn  ", NSCompositingOperationDestinationIn },
  { "DestinationOut ", NSCompositingOperationDestinationOut },
  { "DestinationAtop", NSCompositingOperationDestinationAtop },
  { "XOR            ", NSCompositingOperationXOR },
  { "PlusDarker     ", NSCompositingOperationPlusDarker },
  { "PlusLighter    ", NSCompositingOperationPlusLighter },
};

static void
run(int op, int dest, CGFloat salpha, int *out)
{
  NSImage *image;
  NSBitmapImageRep *rep;
  unsigned char *p;

  image = [[NSImage alloc] initWithSize: NSMakeSize(SIDE, SIDE)];
  [image lockFocus];
  if (dest == 0)
    {
      [[NSColor colorWithDeviceRed: 1 green: 0 blue: 0 alpha: 1] set];
      NSRectFill(NSMakeRect(0, 0, SIDE, SIDE));
    }
  else
    {
      NSRectFillUsingOperation(NSMakeRect(0, 0, SIDE, SIDE),
                               NSCompositingOperationClear);
    }
  [[NSColor colorWithDeviceRed: 0 green: 0 blue: 1 alpha: salpha] set];
  NSRectFillUsingOperation(NSMakeRect(0, 0, SIDE, SIDE), ops[op].op);
  rep = [[NSBitmapImageRep alloc]
    initWithFocusedViewRect: NSMakeRect(0, 0, SIDE, SIDE)];
  [image unlockFocus];

  if (rep == nil || [rep samplesPerPixel] < 4)
    {
      out[0] = out[1] = out[2] = out[3] = -1;
      return;
    }
  p = [rep bitmapData] + (SIDE / 2) * [rep bytesPerRow]
    + (SIDE / 2) * ([rep bitsPerPixel] / 8);
  out[0] = p[0]; out[1] = p[1]; out[2] = p[2]; out[3] = p[3];
}

int
main(void)
{
  @autoreleasepool
    {
      int i;
      int a[4], b[4], c[4];
      NSBitmapImageRep *rep;

      /* What the readback layout is, so the numbers can be read. */
      {
        NSImage *image = [[NSImage alloc] initWithSize: NSMakeSize(SIDE, SIDE)];
        [image lockFocus];
        [[NSColor colorWithDeviceRed: 1 green: 0 blue: 0 alpha: 0.5] set];
        NSRectFill(NSMakeRect(0, 0, SIDE, SIDE));
        rep = [[NSBitmapImageRep alloc]
          initWithFocusedViewRect: NSMakeRect(0, 0, SIDE, SIDE)];
        [image unlockFocus];
        printf("readback spp=%ld bps=%ld bpp=%ld format=%lu alpha=%d\n",
               (long)[rep samplesPerPixel], (long)[rep bitsPerSample],
               (long)[rep bitsPerPixel], (unsigned long)[rep bitmapFormat],
               (int)[rep hasAlpha]);
        {
          unsigned char *p = [rep bitmapData]
            + (SIDE / 2) * [rep bytesPerRow]
            + (SIDE / 2) * ([rep bitsPerPixel] / 8);
          printf("half red fill reads %d %d %d %d\n",
                 p[0], p[1], p[2], p[3]);
        }
      }

      printf("%-16s %-16s %-16s %-16s\n", "operator",
             "blue on red", "blue on cleared", "half blue on red");
      for (i = 0; i < (int)(sizeof(ops) / sizeof(ops[0])); i++)
        {
          run(i, 0, 1.0, a);
          run(i, 1, 1.0, b);
          run(i, 0, 0.5, c);
          printf("%s %3d %3d %3d %3d  %3d %3d %3d %3d  %3d %3d %3d %3d\n",
                 ops[i].name, a[0], a[1], a[2], a[3], b[0], b[1], b[2], b[3],
                 c[0], c[1], c[2], c[3]);
        }
    }
  return 0;
}
