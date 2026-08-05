#import <Cocoa/Cocoa.h>
#include <objc/runtime.h>
#include <stdio.h>

int
main(void)
{
  @autoreleasepool
    {
      NSImage *image;
      NSArray *reps;
      NSUInteger i;
      NSCachedImageRep *cached;

      [NSApplication sharedApplication];

      image = [[NSImage alloc] initWithSize: NSMakeSize(64, 64)];
      printf("A reps before focus: %lu\n",
             (unsigned long)[[image representations] count]);

      [image lockFocus];
      printf("B context during lockFocus: %s flipped=%d toScreen=%d\n",
             class_getName([[NSGraphicsContext currentContext] class]),
             (int)[[NSGraphicsContext currentContext] isFlipped],
             (int)[[NSGraphicsContext currentContext] isDrawingToScreen]);
      [[NSColor redColor] set];
      NSRectFill(NSMakeRect(0, 0, 64, 64));
      [image unlockFocus];

      reps = [image representations];
      printf("C reps after focus: %lu\n", (unsigned long)[reps count]);
      for (i = 0; i < [reps count]; i++)
        {
          NSImageRep *r = [reps objectAtIndex: i];

          printf("C   %s size=%s pixels=%ldx%ld\n",
                 class_getName([r class]),
                 [NSStringFromSize([r size]) UTF8String],
                 (long)[r pixelsWide], (long)[r pixelsHigh]);
          if ([r isKindOfClass: [NSCachedImageRep class]])
            {
              printf("C   its window = %s\n",
                     [(NSCachedImageRep *)r window] ? "non-nil" : "nil");
            }
        }

      /* And a cached representation made directly. */
      cached = [[NSCachedImageRep alloc] initWithSize: NSMakeSize(32, 32)
                                                depth: 0
                                             separate: YES
                                                alpha: YES];
      printf("D direct NSCachedImageRep = %s\n",
             cached ? class_getName([cached class]) : "nil");
      if (cached != nil)
        {
          printf("D   window = %s rect = %s\n",
                 [cached window] ? "non-nil" : "nil",
                 [NSStringFromRect([cached rect]) UTF8String]);
          if ([cached window] != nil)
            {
              NSWindow *w = [cached window];

              printf("D   window class = %s superclass = %s\n",
                     class_getName([w class]),
                     class_getName(class_getSuperclass([w class])));
              printf("D   in [NSApp windows] = %d, count = %lu\n",
                     (int)[[NSApp windows] containsObject: w],
                     (unsigned long)[[NSApp windows] count]);
            }
        }

      /* What NSImage answers for a bitmap-shaped question. */
      printf("E NSWindow superclass = %s\n",
             class_getName(class_getSuperclass([NSWindow class])));
      printf("F NSCachedImageRep superclass = %s\n",
             class_getName(class_getSuperclass([NSCachedImageRep class])));
    }
  return 0;
}
