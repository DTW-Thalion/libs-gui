#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import <objc/runtime.h>

static NSData *
makePDF(CGRect *boxes, int n)
{
  NSMutableData *data = [NSMutableData data];
  CGDataConsumerRef cons = CGDataConsumerCreateWithCFData((CFMutableDataRef)data);
  CGContextRef ctx = CGPDFContextCreate(cons, &boxes[0], NULL);
  int i;

  for (i = 0; i < n; i++)
    {
      CFMutableDictionaryRef info;
      CFDataRef boxData;

      info = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks,
                                       &kCFTypeDictionaryValueCallBacks);
      boxData = CFDataCreate(NULL, (const UInt8 *)&boxes[i], sizeof(CGRect));
      CFDictionarySetValue(info, kCGPDFContextMediaBox, boxData);
      CGPDFContextBeginPage(ctx, info);
      CGContextSetRGBFillColor(ctx, 1, 0, 0, 1);
      CGContextFillRect(ctx, CGRectMake(CGRectGetMinX(boxes[i]),
                                        CGRectGetMinY(boxes[i]), 10, 10));
      CGPDFContextEndPage(ctx);
      CFRelease(boxData);
      CFRelease(info);
    }
  CGPDFContextClose(ctx);
  CGContextRelease(ctx);
  CGDataConsumerRelease(cons);
  return data;
}

static void
line(const char *what, NSImageRep *rep)
{
  NSRect b = NSMakeRect(0, 0, 0, 0);

  if ([rep isKindOfClass: [NSPDFImageRep class]])
    b = [(NSPDFImageRep *)rep bounds];
  printf("%-40s %-16s size=%g x %g pixels=%ld x %ld bounds=%g %g %g %g\n",
         what, class_getName([rep class]),
         (double)[rep size].width, (double)[rep size].height,
         (long)[rep pixelsWide], (long)[rep pixelsHigh],
         (double)b.origin.x, (double)b.origin.y,
         (double)b.size.width, (double)b.size.height);
  fflush(stdout);
}

int
main(int argc, const char *argv[])
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  CGRect one[1] = { CGRectMake(0, 0, 200, 100) };
  CGRect off[1] = { CGRectMake(10, 20, 200, 100) };
  CGRect frac[1] = { CGRectMake(0, 0, 200.5, 100.25) };
  CGRect two[2] = { CGRectMake(0, 0, 200, 100), CGRectMake(0, 0, 400, 300) };
  NSData *d1 = makePDF(one, 1);
  NSData *dOff = makePDF(off, 1);
  NSData *dFrac = makePDF(frac, 1);
  NSData *d2 = makePDF(two, 2);
  NSPDFImageRep *r;
  NSImage *image;
  NSBitmapImageRep *canvas;
  int i;

  printf("=== is anything but setCurrentPage: a trigger ===\n");
  r = [NSPDFImageRep imageRepWithData: d1];
  for (i = 0; i < 3; i++)
    [r size];
  line("after reading size three times", r);
  [r bounds];
  line("after -bounds", r);
  [r pageCount];
  line("after -pageCount", r);
  [r currentPage];
  line("after -currentPage", r);
  [r PDFRepresentation];
  line("after -PDFRepresentation", r);
  [r setSize: NSMakeSize(80, 40)];
  line("after -setSize: 80x40", r);
  [r setCurrentPage: 0];
  line("after -setCurrentPage: 0", r);

  printf("=== drawing a fresh rep ===\n");
  canvas = [[NSBitmapImageRep alloc]
             initWithBitmapDataPlanes: NULL pixelsWide: 300 pixelsHigh: 200
                           bitsPerSample: 8 samplesPerPixel: 4 hasAlpha: YES
                                isPlanar: NO
                          colorSpaceName: NSCalibratedRGBColorSpace
                             bytesPerRow: 0 bitsPerPixel: 0];
  r = [NSPDFImageRep imageRepWithData: d1];
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext:
    [NSGraphicsContext graphicsContextWithBitmapImageRep: canvas]];
  printf("draw returned %d\n", (int)[r draw]);
  [NSGraphicsContext restoreGraphicsState];
  line("after -draw", r);

  printf("=== what the page box gives ===\n");
  r = [NSPDFImageRep imageRepWithData: dOff];
  [r setCurrentPage: 0];
  line("box origin 10,20 after setCurrentPage", r);
  r = [NSPDFImageRep imageRepWithData: dFrac];
  [r setCurrentPage: 0];
  line("box 200.5x100.25 after setCurrentPage", r);
  r = [NSPDFImageRep imageRepWithData: d2];
  [r setCurrentPage: 1];
  [r setSize: NSMakeSize(80, 40)];
  line("page 1 then setSize: 80x40", r);
  [r setPixelsWide: 7];
  [r setCurrentPage: 0];
  line("setPixelsWide: 7 then setCurrentPage: 0", r);

  printf("=== through NSImage ===\n");
  image = [[NSImage alloc] initWithData: d2];
  printf("NSImage size=%g x %g reps=%lu\n",
         (double)[image size].width, (double)[image size].height,
         (unsigned long)[[image representations] count]);
  for (i = 0; i < (int)[[image representations] count]; i++)
    line("  from NSImage", [[image representations] objectAtIndex: i]);
  [image lockFocus];
  [image unlockFocus];
  printf("NSImage after lockFocus size=%g x %g reps=%lu\n",
         (double)[image size].width, (double)[image size].height,
         (unsigned long)[[image representations] count]);
  for (i = 0; i < (int)[[image representations] count]; i++)
    line("  from NSImage", [[image representations] objectAtIndex: i]);

  printf("=== NSEPSImageRep ===\n");
  printf("NSEPSImageRep pixelsWide responds=%d\n",
         (int)[NSEPSImageRep instancesRespondToSelector: @selector(pixelsWide)]);

  fflush(stdout);
  [pool release];
  return 0;
}
