/* Apple oracle for the NSColorSpace coverage test: the model enum values, and
   the model, component count, name, ICC data and singleton identity of the
   standard colour spaces. */
#import <Cocoa/Cocoa.h>

static void
dump(NSString *label, NSColorSpace *cs)
{
  NSLog(@"CS %@ model=%d comps=%d name=%@ icc=%@",
        label, (int)[cs colorSpaceModel], [cs numberOfColorComponents],
        [cs localizedName], [cs ICCProfileData] == nil ? @"nil" : @"set");
}

int
main(int argc, const char **argv)
{
  @autoreleasepool
  {
    NSLog(@"ENUM unknown=%d gray=%d rgb=%d cmyk=%d lab=%d deviceN=%d",
          (int)NSUnknownColorSpaceModel, (int)NSGrayColorSpaceModel,
          (int)NSRGBColorSpaceModel, (int)NSCMYKColorSpaceModel,
          (int)NSLABColorSpaceModel, (int)NSDeviceNColorSpaceModel);

    dump(@"genericRGB", [NSColorSpace genericRGBColorSpace]);
    dump(@"genericGray", [NSColorSpace genericGrayColorSpace]);
    dump(@"genericCMYK", [NSColorSpace genericCMYKColorSpace]);
    dump(@"deviceRGB", [NSColorSpace deviceRGBColorSpace]);
    dump(@"deviceGray", [NSColorSpace deviceGrayColorSpace]);
    dump(@"deviceCMYK", [NSColorSpace deviceCMYKColorSpace]);

    NSLog(@"CS singleton genericRGB=%d deviceRGB=%d generic-vs-device=%d",
          [NSColorSpace genericRGBColorSpace] == [NSColorSpace genericRGBColorSpace],
          [NSColorSpace deviceRGBColorSpace] == [NSColorSpace deviceRGBColorSpace],
          [NSColorSpace genericRGBColorSpace] == [NSColorSpace deviceRGBColorSpace]);
  }
  return 0;
}
