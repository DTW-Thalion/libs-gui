/* What does AppKit do with a PATTERN colour when you ask it for an RGB colour
   space or for a component, and may a gradient hold one?

   GNUstep raises NSInvalidArgumentException "[GSPatternColor
   -colorUsingColorSpaceName:device:] should be overridden by subclass" from the
   conversion, so every caller has to guard it. If AppKit answers nil instead,
   the repair belongs in the colour class and every backend benefits.

   Built without any window server: the pattern image is made from a bitmap rep
   whose bytes are written directly, and the gradient is drawn into a bitmap
   context. */
#import <Cocoa/Cocoa.h>
#import <stdio.h>

static NSImage *
redPatch(void)
{
  NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
    initWithBitmapDataPlanes: NULL
                  pixelsWide: 4
                  pixelsHigh: 4
               bitsPerSample: 8
             samplesPerPixel: 4
                    hasAlpha: YES
                    isPlanar: NO
              colorSpaceName: NSCalibratedRGBColorSpace
                 bytesPerRow: 16
                bitsPerPixel: 32];
  unsigned char *b = [rep bitmapData];
  int i;
  NSImage *img;

  for (i = 0; i < 16; i++)
    {
      b[i*4+0] = 255; b[i*4+1] = 0; b[i*4+2] = 0; b[i*4+3] = 255;
    }
  img = [[NSImage alloc] initWithSize: NSMakeSize(4, 4)];
  [img addRepresentation: rep];
  [rep release];
  return [img autorelease];
}

int
main(int argc, const char **argv)
{
  setbuf(stdout, NULL);   /* unbuffered: the last line printed is where it died */
  @autoreleasepool
    {
      NSColor *pattern;
      NSColor *conv;

      printf("building the pattern image\n");
      pattern = [NSColor colorWithPatternImage: redPatch()];
      printf("pattern colour built            = %s\n",
             pattern == nil ? "nil" : "ok");

      printf("colorSpaceName                  = %s\n",
             [[pattern colorSpaceName] UTF8String]);

      @try {
        conv = [pattern colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
        printf("->NSCalibratedRGBColorSpace     = %s\n",
               conv == nil ? "nil" : [[conv colorSpaceName] UTF8String]);
      } @catch (NSException *e) {
        printf("->NSCalibratedRGBColorSpace RAISED %s: %s\n",
               [[e name] UTF8String], [[e reason] UTF8String]);
      }

      @try {
        conv = [pattern colorUsingColorSpaceName: NSDeviceRGBColorSpace];
        printf("->NSDeviceRGBColorSpace         = %s\n",
               conv == nil ? "nil" : [[conv colorSpaceName] UTF8String]);
      } @catch (NSException *e) {
        printf("->NSDeviceRGBColorSpace RAISED %s: %s\n",
               [[e name] UTF8String], [[e reason] UTF8String]);
      }

      if ([pattern respondsToSelector: @selector(colorUsingType:)])
        {
          @try {
            conv = [pattern colorUsingType: NSColorTypeComponentBased];
            printf("colorUsingType:ComponentBased   = %s\n",
                   conv == nil ? "nil" : [[conv colorSpaceName] UTF8String]);
          } @catch (NSException *e) {
            printf("colorUsingType RAISED %s: %s\n",
                   [[e name] UTF8String], [[e reason] UTF8String]);
          }
        }

      @try {
        printf("redComponent                    = %g\n", (double)[pattern redComponent]);
      } @catch (NSException *e) {
        printf("redComponent RAISED %s: %s\n",
               [[e name] UTF8String], [[e reason] UTF8String]);
      }

      /* May a gradient hold a pattern colour at all? */
      @try {
        NSGradient *g = [[NSGradient alloc]
          initWithStartingColor: pattern
                    endingColor: [NSColor colorWithCalibratedWhite: 1.0 alpha: 1.0]];
        printf("gradient alloc/init             = %s, stops=%d\n",
               g == nil ? "nil" : "built", g == nil ? 0 : (int)[g numberOfColorStops]);
        if (g != nil)
          {
            NSBitmapImageRep *dst = [[NSBitmapImageRep alloc]
              initWithBitmapDataPlanes: NULL pixelsWide: 100 pixelsHigh: 100
                         bitsPerSample: 8 samplesPerPixel: 4 hasAlpha: YES
                              isPlanar: NO colorSpaceName: NSCalibratedRGBColorSpace
                           bytesPerRow: 400 bitsPerPixel: 32];
            NSGraphicsContext *gc = [NSGraphicsContext
              graphicsContextWithBitmapImageRep: dst];

            [NSGraphicsContext saveGraphicsState];
            [NSGraphicsContext setCurrentContext: gc];
            @try {
              [g drawInRect: NSMakeRect(0, 0, 100, 100) angle: 90.0];
              printf("linear draw                     = no raise\n");
            } @catch (NSException *e) {
              printf("linear draw RAISED %s: %s\n",
                     [[e name] UTF8String], [[e reason] UTF8String]);
            }
            @try {
              [g drawFromCenter: NSMakePoint(50, 50) radius: 0
                       toCenter: NSMakePoint(50, 50) radius: 50 options: 0];
              printf("radial draw                     = no raise\n");
            } @catch (NSException *e) {
              printf("radial draw RAISED %s: %s\n",
                     [[e name] UTF8String], [[e reason] UTF8String]);
            }
            [NSGraphicsContext restoreGraphicsState];

            {
              NSColor *c = [[dst colorAtX: 50 y: 50]
                colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
              printf("centre pixel after linear+radial= %s\n",
                     c == nil ? "nil" : [[c description] UTF8String]);
            }
            [dst release];
            [g release];
          }
      } @catch (NSException *e) {
        printf("gradient init RAISED %s: %s\n",
               [[e name] UTF8String], [[e reason] UTF8String]);
      }

      /* And what an interpolated stop answers, which is what GSGState asks. */
      @try {
        NSGradient *g = [[NSGradient alloc]
          initWithStartingColor: pattern
                    endingColor: [NSColor colorWithCalibratedWhite: 1.0 alpha: 1.0]];
        NSColor *mid = [g interpolatedColorAtLocation: 0.5];
        printf("interpolatedColorAtLocation:0.5 = %s\n",
               mid == nil ? "nil" : [[mid colorSpaceName] UTF8String]);
        [g release];
      } @catch (NSException *e) {
        printf("interpolatedColorAtLocation RAISED %s: %s\n",
               [[e name] UTF8String], [[e reason] UTF8String]);
      }
    }
  return 0;
}
