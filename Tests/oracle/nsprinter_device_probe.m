#import <Cocoa/Cocoa.h>

static void dumpDict(const char *label, NSDictionary *d)
{
  printf("== %s (%lu entries)\n", label, (unsigned long)[d count]);
  for (NSString *k in [[d allKeys] sortedArrayUsingSelector: @selector(compare:)])
    {
      id v = [d objectForKey: k];
      printf("   %-26s (%s) %s\n", [k UTF8String],
             [NSStringFromClass([v class]) UTF8String],
             [[v description] UTF8String]);
    }
}

int main(int argc, const char **argv)
{
  @autoreleasepool
    {
      NSArray *names = [NSPrinter printerNames];
      NSArray *types = [NSPrinter printerTypes];

      printf("printerNames: %s\n", [[names description] UTF8String]);
      printf("printerTypes: %s\n", [[types description] UTF8String]);

      dumpDict("NSScreen mainScreen deviceDescription",
               [[NSScreen mainScreen] deviceDescription]);

      NSPrintInfo *pi = [NSPrintInfo sharedPrintInfo];
      printf("sharedPrintInfo printer: %s\n",
             [[[pi printer] description] UTF8String]);

      for (NSString *n in names)
        {
          NSPrinter *p = [NSPrinter printerWithName: n];

          printf("\n---- printer %s type=%s\n", [n UTF8String],
                 [[p type] UTF8String]);
          printf("     languageLevel=%ld isColor=%d\n",
                 (long)[p languageLevel], (int)[p isColor]);
          printf("     pageSizeForPaper(Letter)=%s\n",
                 NSStringFromSize([p pageSizeForPaper: @"Letter"]).UTF8String);
          printf("     imageRectForPaper(Letter)=%s\n",
                 NSStringFromRect([p imageRectForPaper: @"Letter"]).UTF8String);
          printf("     PPD table status=%ld\n",
                 (long)[p statusForTable: @"PPD"]);
          printf("     DefaultPageSize='%s' DefaultResolution='%s'\n",
                 [[p stringForKey: @"DefaultPageSize" inTable: @"PPD"] UTF8String],
                 [[p stringForKey: @"DefaultResolution" inTable: @"PPD"] UTF8String]);
          dumpDict("printer deviceDescription", [p deviceDescription]);
        }

      /* What the documented consumer expects of NSDeviceResolution. */
      NSDictionary *screenDesc = [[NSScreen mainScreen] deviceDescription];
      id res = [screenDesc objectForKey: NSDeviceResolution];
      printf("\nscreen NSDeviceResolution class=%s respondsTo sizeValue=%d\n",
             [NSStringFromClass([res class]) UTF8String],
             (int)[res respondsToSelector: @selector(sizeValue)]);
    }
  return 0;
}
