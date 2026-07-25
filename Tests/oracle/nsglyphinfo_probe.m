/* Oracle: NSGlyphInfo name and deprecated-glyph factories. */
#import <Cocoa/Cocoa.h>

int
main(void)
{
  @autoreleasepool
    {
      NSFont *f = [NSFont systemFontOfSize: 12];

      NSGlyphInfo *a = [NSGlyphInfo glyphInfoWithGlyphName: @"A"
                                                   forFont: f
                                                baseString: @"A"];
      printf("name 'A': nil=%d glyphName=%s cc=%ld cid=%lu base=%s\n",
             a == nil, a ? [[a glyphName] UTF8String] : "(nil)",
             (long)[a characterCollection], (unsigned long)[a characterIdentifier],
             a ? [[a baseString] UTF8String] : "(nil)");

      NSGlyphInfo *bad = [NSGlyphInfo glyphInfoWithGlyphName: @"NoSuchGlyphXYZ"
                                                     forFont: f
                                                  baseString: @"A"];
      printf("name 'NoSuchGlyphXYZ': nil=%d\n", bad == nil);

      NSGlyphInfo *nilBase = [NSGlyphInfo glyphInfoWithGlyphName: @"A"
                                                        forFont: f
                                                     baseString: nil];
      printf("name 'A' baseString nil: nil=%d\n", nilBase == nil);

      NSGlyphInfo *nilFont = [NSGlyphInfo glyphInfoWithGlyphName: @"A"
                                                        forFont: nil
                                                     baseString: @"A"];
      printf("name 'A' font nil: nil=%d\n", nilFont == nil);

      CGGlyph g = 0;
      UniChar ch = 'A';
      CTFontGetGlyphsForCharacters((CTFontRef)f, &ch, &g, 1);
      printf("CGGlyph for 'A' = %u\n", g);

      if ([NSGlyphInfo respondsToSelector:
            @selector(glyphInfoWithGlyph:forFont:baseString:)])
        {
          NSGlyphInfo *dg = [NSGlyphInfo glyphInfoWithGlyph: (NSGlyph)g
                                                    forFont: f
                                                 baseString: @"A"];
          printf("deprecated glyph %u: nil=%d glyphName=%s cc=%ld cid=%lu\n",
                 g, dg == nil, dg ? [[dg glyphName] UTF8String] : "(nil)",
                 (long)[dg characterCollection],
                 (unsigned long)[dg characterIdentifier]);

          NSGlyphInfo *dg0 = [NSGlyphInfo glyphInfoWithGlyph: 0
                                                     forFont: f
                                                  baseString: @"A"];
          printf("deprecated glyph 0: nil=%d\n", dg0 == nil);
        }
      else
        {
          printf("deprecated glyphInfoWithGlyph: not available\n");
        }
    }
  return 0;
}
