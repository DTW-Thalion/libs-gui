/* Apple oracle for the NSFontDescriptor coverage test: the attribute
   round-trip, the pointSize/postscriptName/symbolicTraits/matrix extractors
   (including their absent-value defaults and whether postscriptName strips
   spaces), and the derivation methods. */
#import <Cocoa/Cocoa.h>

int
main(int argc, const char **argv)
{
  @autoreleasepool
  {
    NSDictionary *attrs = @{NSFontNameAttribute: @"Helvetica",
                            NSFontSizeAttribute: @12};
    NSFontDescriptor *fd =
      [NSFontDescriptor fontDescriptorWithFontAttributes: attrs];
    NSLog(@"FD objName=%@ ps=%@ size=%g matrix=%@ traits=%u",
          [fd objectForKey: NSFontNameAttribute], [fd postscriptName],
          [fd pointSize], [fd matrix], (unsigned)[fd symbolicTraits]);

    NSFontDescriptor *sp = [NSFontDescriptor fontDescriptorWithFontAttributes:
      @{NSFontNameAttribute: @"Helvetica Neue"}];
    NSLog(@"FD spacedName ps=%@", [sp postscriptName]);

    NSFontDescriptor *e =
      [NSFontDescriptor fontDescriptorWithFontAttributes: @{}];
    NSLog(@"FD empty ps=%@ size=%g matrix=%@ traits=%u attrCount=%lu",
          [e postscriptName] == nil ? @"nil" : [e postscriptName],
          [e pointSize], [e matrix] == nil ? @"nil" : @"set",
          (unsigned)[e symbolicTraits], (unsigned long)[[e fontAttributes] count]);

    NSFontDescriptor *sized = [fd fontDescriptorWithSize: 24];
    NSLog(@"FD sized=%g origUnchanged=%g distinct=%d",
          [sized pointSize], [fd pointSize], sized != fd);

    NSFontDescriptor *merged = [fd fontDescriptorByAddingAttributes:
      @{NSFontSizeAttribute: @18, NSFontFamilyAttribute: @"Arial"}];
    NSLog(@"FD merged size=%g family=%@ keptName=%@",
          [merged pointSize], [merged objectForKey: NSFontFamilyAttribute],
          [merged objectForKey: NSFontNameAttribute]);

    NSFontDescriptor *tr = [e fontDescriptorWithSymbolicTraits:
      NSFontBoldTrait | NSFontItalicTrait];
    NSLog(@"FD traitsRoundtrip=%u boldMask=%u italicMask=%u",
          (unsigned)[tr symbolicTraits], (unsigned)NSFontBoldTrait,
          (unsigned)NSFontItalicTrait);
  }
  return 0;
}
