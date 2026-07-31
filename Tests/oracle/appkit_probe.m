/* What an offscreen image starts as, and what a translucent fill leaves. */
#import <Cocoa/Cocoa.h>
#include <stdio.h>

static void
dump(NSBitmapImageRep *rep, const char *what)
{
  NSUInteger px[5] = {0, 0, 0, 0, 0};

  if (rep == nil)
    {
      printf("%-42s (no rep)\n", what);
      return;
    }
  [rep getPixel: px atX: 10 y: 10];
  printf("%-42s %3lu %3lu %3lu %3lu   spp=%ld alpha=%d\n", what,
         (unsigned long)px[0], (unsigned long)px[1], (unsigned long)px[2],
         (unsigned long)px[3], (long)[rep samplesPerPixel],
         (int)[rep hasAlpha]);
}

/* Draw into an image with lockFocus and read it back the way the tests do. */
static NSBitmapImageRep *
run(void (^body)(int w, int h))
{
  int w = 20, h = 20;
  NSImage *img = [[NSImage alloc] initWithSize: NSMakeSize(w, h)];
  NSBitmapImageRep *rep;

  [img lockFocus];
  body(w, h);
  rep = [[NSBitmapImageRep alloc]
          initWithFocusedViewRect: NSMakeRect(0, 0, w, h)];
  [img unlockFocus];
  return rep;
}

int
main(void)
{
  @autoreleasepool
    {
      NSBitmapImageRep *rep;

      /* 1. nothing drawn at all */
      rep = run(^(int w, int h) { });
      dump(rep, "bare canvas, nothing drawn");

      /* 2. half-transparent white on the bare canvas */
      rep = run(^(int w, int h) {
        [[NSColor colorWithDeviceRed: 1 green: 1 blue: 1 alpha: 0.5] set];
        NSRectFill(NSMakeRect(0, 0, w, h));
      });
      dump(rep, "white 50% on the bare canvas");

      /* 3. opaque red */
      rep = run(^(int w, int h) {
        [[NSColor colorWithDeviceRed: 1 green: 0 blue: 0 alpha: 1] set];
        NSRectFill(NSMakeRect(0, 0, w, h));
      });
      dump(rep, "opaque red only");

      /* 4. half-transparent white over opaque red, plain fill */
      rep = run(^(int w, int h) {
        [[NSColor colorWithDeviceRed: 1 green: 0 blue: 0 alpha: 1] set];
        NSRectFill(NSMakeRect(0, 0, w, h));
        [[NSColor colorWithDeviceRed: 1 green: 1 blue: 1 alpha: 0.5] set];
        NSRectFill(NSMakeRect(0, 0, w, h));
      });
      dump(rep, "white 50% over red, plain fill");

      /* 5. the same through the source-over operator */
      rep = run(^(int w, int h) {
        [[NSColor colorWithDeviceRed: 1 green: 0 blue: 0 alpha: 1] set];
        NSRectFill(NSMakeRect(0, 0, w, h));
        [[NSColor colorWithDeviceRed: 1 green: 1 blue: 1 alpha: 0.5] set];
        NSRectFillUsingOperation(NSMakeRect(0, 0, w, h),
                                 NSCompositingOperationSourceOver);
      });
      dump(rep, "white 50% over red, source-over");

      /* 6. a half-transparent grey image composited over black, which is what
       * the image alpha test builds */
      {
        int w = 20, h = 20;
        NSImage *src = [[NSImage alloc] initWithSize: NSMakeSize(4, 4)];

        [src lockFocus];
        [[NSColor colorWithDeviceRed: 128 / 255.0 green: 128 / 255.0
                                blue: 128 / 255.0 alpha: 128 / 255.0] set];
        NSRectFill(NSMakeRect(0, 0, 4, 4));
        [src unlockFocus];

        rep = run(^(int cw, int ch) {
          [[NSColor blackColor] set];
          NSRectFill(NSMakeRect(0, 0, cw, ch));
          [src drawInRect: NSMakeRect(0, 0, cw, ch)
                 fromRect: NSZeroRect
                operation: NSCompositingOperationSourceOver
                 fraction: 1.0];
        });
        dump(rep, "grey 50% image over black");
        (void)w; (void)h;
      }

      /* 7. what the source image itself holds */
      {
        NSImage *src = [[NSImage alloc] initWithSize: NSMakeSize(20, 20)];
        NSBitmapImageRep *srep;

        [src lockFocus];
        [[NSColor colorWithDeviceRed: 128 / 255.0 green: 128 / 255.0
                                blue: 128 / 255.0 alpha: 128 / 255.0] set];
        NSRectFill(NSMakeRect(0, 0, 20, 20));
        srep = [[NSBitmapImageRep alloc]
                 initWithFocusedViewRect: NSMakeRect(0, 0, 20, 20)];
        [src unlockFocus];
        dump(srep, "grey 50% fill, read straight back");
      }
    }
  return 0;
}
