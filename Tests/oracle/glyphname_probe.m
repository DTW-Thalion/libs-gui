/* What AppKit answers for -[NSFont glyphWithName:], and whether that glyph can
   be measured by -advancementForGlyph:. libs-back #193 turns on this: on the
   cairo backend the two use different conventions.

   -widthOfString: does not exist in modern AppKit, so the string width comes
   from -sizeWithAttributes:. */
#import <Cocoa/Cocoa.h>
#include <stdio.h>

static double
stringWidth(NSFont *f, NSString *s)
{
  return (double)[s sizeWithAttributes:
    [NSDictionary dictionaryWithObject: f forKey: NSFontAttributeName]].width;
}

static void
report(NSFont *f, NSString *name, NSString *asString)
{
  NSGlyph g = [f glyphWithName: name];
  NSSize adv = [f advancementForGlyph: g];
  NSRect box = [f boundingRectForGlyph: g];

  printf("  name %-14s glyph %-6lu advance %8.4f  box %7.3f x %7.3f\n",
         [name UTF8String], (unsigned long)g, (double)adv.width,
         (double)box.size.width, (double)box.size.height);
  if (asString != nil)
    {
      printf("    string %-4s width %8.4f  same as the glyph advance: %s\n",
             [asString UTF8String], stringWidth(f, asString),
             (fabs(stringWidth(f, asString) - adv.width) < 0.01) ? "YES" : "NO");
    }
}

int
main(void)
{
  @autoreleasepool
    {
      NSFont *fonts[3];
      const char *labels[3] = {"Helvetica", "system font", "Times-Roman"};
      int i;

      fonts[0] = [NSFont fontWithName: @"Helvetica" size: 14];
      fonts[1] = [NSFont systemFontOfSize: 14];
      fonts[2] = [NSFont fontWithName: @"Times-Roman" size: 14];

      printf("NSGlyph size %lu, NSNullGlyph %lu\n",
             (unsigned long)sizeof(NSGlyph), (unsigned long)NSNullGlyph);

      for (i = 0; i < 3; i++)
        {
          NSFont *f = fonts[i];

          printf("=== %s -> %s\n", labels[i],
                 f ? [[f fontName] UTF8String] : "MISSING");
          if (f == nil)
            {
              continue;
            }
          report(f, @"W", @"W");
          report(f, @"i", @"i");
          report(f, @"eight", @"8");
          report(f, @"zero", @"0");
          /* a name no font carries */
          report(f, @"notaglyphname", nil);
          /* what the character cast measures, which is what cairo assumes */
          printf("    the character cast (NSGlyph)'W' = %lu advances %8.4f\n",
                 (unsigned long)(NSGlyph)'W',
                 (double)[f advancementForGlyph: (NSGlyph)'W'].width);
        }
    }
  return 0;
}
