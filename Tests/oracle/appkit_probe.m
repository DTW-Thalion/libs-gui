/* Apple oracle for the NSShadow coverage test: the defaults (offset, blur
   radius and colour), whether the colour can be cleared, the accessor
   round-trip and copy. */
#import <Cocoa/Cocoa.h>

int
main(int argc, const char **argv)
{
  @autoreleasepool
  {
    NSShadow *s = [[NSShadow alloc] init];

    NSLog(@"SHADOW default offset=%@ blur=%g",
          NSStringFromSize([s shadowOffset]), [s shadowBlurRadius]);
    if ([s shadowColor] == nil)
      NSLog(@"SHADOW default color is nil");
    else
      NSLog(@"SHADOW default color=%@ alpha=%g colorSpace=%@",
            [s shadowColor], [[s shadowColor] alphaComponent],
            [[s shadowColor] colorSpaceName]);

    [s setShadowColor: [NSColor redColor]];
    [s setShadowColor: nil];
    NSLog(@"SHADOW after setShadowColor:nil -> %@",
          [s shadowColor] == nil ? @"nil" : [s shadowColor]);

    [s setShadowOffset: NSMakeSize(3.0, -4.0)];
    [s setShadowBlurRadius: 7.5];
    NSLog(@"SHADOW roundtrip offset=%@ blur=%g",
          NSStringFromSize([s shadowOffset]), [s shadowBlurRadius]);

    [s setShadowColor: [NSColor blueColor]];
    NSShadow *c = [s copy];
    [c setShadowBlurRadius: 99.0];
    NSLog(@"SHADOW copy distinct=%d copyBlur=%g origBlurAfterCopyMutated=%g",
          c != s, [c shadowBlurRadius], [s shadowBlurRadius]);
  }
  return 0;
}
