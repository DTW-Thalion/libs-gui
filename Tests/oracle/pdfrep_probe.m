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
report(NSString *what, NSPDFImageRep *rep)
{
  NSRect b = [rep bounds];

  printf("%-28s class=%s size=%g x %g pixelsWide=%ld pixelsHigh=%ld "
         "bounds=%g %g %g %g pages=%ld current=%ld bps=%ld cs=%s "
         "alpha=%d opaque=%d bytes=%lu\n",
         [what UTF8String], class_getName([rep class]),
         (double)[rep size].width, (double)[rep size].height,
         (long)[rep pixelsWide], (long)[rep pixelsHigh],
         (double)b.origin.x, (double)b.origin.y,
         (double)b.size.width, (double)b.size.height,
         (long)[rep pageCount], (long)[rep currentPage],
         (long)[rep bitsPerSample],
         [[rep colorSpaceName] UTF8String],
         (int)[rep hasAlpha], (int)[rep isOpaque],
         (unsigned long)[[rep PDFRepresentation] length]);
  fflush(stdout);
}

int
main(int argc, const char *argv[])
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  CGRect one[1] = { CGRectMake(0, 0, 200, 100) };
  CGRect off[1] = { CGRectMake(10, 20, 200, 100) };
  CGRect three[3] = { CGRectMake(0, 0, 200, 100),
                      CGRectMake(0, 0, 400, 300),
                      CGRectMake(0, 0, 100, 50) };
  CGRect frac[1] = { CGRectMake(0, 0, 200.5, 100.25) };
  NSData *d1 = makePDF(one, 1);
  NSData *d2 = makePDF(off, 1);
  NSData *d3 = makePDF(three, 3);
  NSData *d4 = makePDF(frac, 1);
  NSPDFImageRep *r1, *r2, *r3, *r4;
  NSImageRep *plain;
  NSImage *image;
  NSArray *reps;
  int i;

  printf("NSImageRepMatchesDevice=%ld\n", (long)NSImageRepMatchesDevice);
  plain = [[NSImageRep alloc] init];
  printf("bare NSImageRep pixelsWide=%ld pixelsHigh=%ld size=%g x %g\n",
         (long)[plain pixelsWide], (long)[plain pixelsHigh],
         (double)[plain size].width, (double)[plain size].height);

  printf("canInitWithData=%d\n", (int)[NSPDFImageRep canInitWithData: d1]);

  r1 = [NSPDFImageRep imageRepWithData: d1];
  report(@"1 page 200x100", r1);
  r2 = [NSPDFImageRep imageRepWithData: d2];
  report(@"1 page box origin 10,20", r2);
  r4 = [NSPDFImageRep imageRepWithData: d4];
  report(@"1 page 200.5x100.25", r4);

  r3 = [NSPDFImageRep imageRepWithData: d3];
  report(@"3 pages, initial", r3);
  for (i = -1; i < 4; i++)
    {
      @try
        {
          [r3 setCurrentPage: i];
          report([NSString stringWithFormat: @"3 pages, currentPage %d", i], r3);
        }
      @catch (NSException *e)
        {
          printf("setCurrentPage %d raised %s\n", i, [[e name] UTF8String]);
          fflush(stdout);
        }
    }

  printf("--- setting the pixel size by hand ---\n");
  [r1 setPixelsWide: 400];
  [r1 setPixelsHigh: 200];
  report(@"after setPixelsWide 400", r1);
  [r1 setSize: NSMakeSize(50, 25)];
  report(@"after setSize 50x25", r1);

  printf("--- +imageRepsWithData: and NSImage ---\n");
  reps = [NSImageRep imageRepsWithData: d3];
  printf("imageRepsWithData count=%lu\n", (unsigned long)[reps count]);
  for (i = 0; i < (int)[reps count]; i++)
    {
      NSImageRep *r = [reps objectAtIndex: i];
      printf("  rep %d class=%s size=%g x %g pixelsWide=%ld pixelsHigh=%ld\n",
             i, class_getName([r class]),
             (double)[r size].width, (double)[r size].height,
             (long)[r pixelsWide], (long)[r pixelsHigh]);
    }
  image = [[NSImage alloc] initWithData: d3];
  printf("NSImage size=%g x %g reps=%lu\n",
         (double)[image size].width, (double)[image size].height,
         (unsigned long)[[image representations] count]);
  for (i = 0; i < (int)[[image representations] count]; i++)
    {
      NSImageRep *r = [[image representations] objectAtIndex: i];
      printf("  image rep %d class=%s size=%g x %g pixelsWide=%ld pixelsHigh=%ld\n",
             i, class_getName([r class]),
             (double)[r size].width, (double)[r size].height,
             (long)[r pixelsWide], (long)[r pixelsHigh]);
    }

  printf("--- NSEPSImageRep for comparison ---\n");
  printf("NSEPSImageRep responds to pixelsWide=%d\n",
         (int)[NSEPSImageRep instancesRespondToSelector: @selector(pixelsWide)]);

  fflush(stdout);
  [pool release];
  return 0;
}
