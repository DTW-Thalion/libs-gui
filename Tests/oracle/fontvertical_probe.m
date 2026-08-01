/* Ground truth for a font's vertical metrics: is -ascender the typographic
   ascender, or the top of the font's bounding box (which is larger and can
   exceed the point size)?  And how is a default line height derived from it?
   GNUstep's opal backend reports an ascender of 14.79 for a 12 point font and
   a bounding rect spanning every glyph, where its cairo and xlib backends
   report 12 and a box the height of ascender - descender.  */
#import <Cocoa/Cocoa.h>
#import <stdio.h>

static void
dump(NSFont *f)
{
  NSLayoutManager *lm = [NSLayoutManager new];
  NSRect b = [f boundingRectForFont];

  printf("== %s %g\n", [[f fontName] UTF8String], (double)[f pointSize]);
  printf("   ascender            %g\n", (double)[f ascender]);
  printf("   descender           %g\n", (double)[f descender]);
  printf("   capHeight           %g\n", (double)[f capHeight]);
  printf("   xHeight             %g\n", (double)[f xHeight]);
  printf("   leading             %g\n", (double)[f leading]);
  printf("   boundingRectForFont %g %g %g %g\n",
         (double)b.origin.x, (double)b.origin.y,
         (double)b.size.width, (double)b.size.height);
  printf("   defaultLineHeight   %g\n", (double)[lm defaultLineHeightForFont: f]);
  printf("   defaultBaseline     %g\n", (double)[lm defaultBaselineOffsetForFont: f]);
  printf("   ascender > pointSize? %s\n",
         ([f ascender] > [f pointSize]) ? "YES" : "no");
  printf("   box height vs (asc-desc): %g vs %g\n",
         (double)b.size.height, (double)([f ascender] - [f descender]));
  [lm release];
}

int
main(int argc, const char **argv)
{
  @autoreleasepool
    {
      dump([NSFont fontWithName: @"Helvetica" size: 12]);
      dump([NSFont fontWithName: @"Helvetica" size: 24]);
      dump([NSFont systemFontOfSize: 12]);
      dump([NSFont userFontOfSize: 12]);

      /* A head indent applies to the first line and to every wrapped
         continuation line, so both start at the same x. */
      {
        NSMutableParagraphStyle *p = [[NSMutableParagraphStyle alloc] init];
        NSTextStorage *ts;
        NSLayoutManager *lm = [NSLayoutManager new];
        NSTextContainer *tc = [[NSTextContainer alloc]
          initWithContainerSize: NSMakeSize(150, 80)];
        NSUInteger gi, ng;

        [p setFirstLineHeadIndent: 24.0];
        [p setHeadIndent: 24.0];
        [p setLineBreakMode: NSLineBreakByWordWrapping];
        ts = [[NSTextStorage alloc]
          initWithString: @"The quick brown fox jumps over the lazy dog"
              attributes: @{NSFontAttributeName: [NSFont systemFontOfSize: 12],
                            NSParagraphStyleAttributeName: p}];
        [tc setLineFragmentPadding: 0.0];
        [lm addTextContainer: tc];
        [ts addLayoutManager: lm];
        ng = [lm numberOfGlyphs];
        printf("== layout, 150x80 container, head indent 24, %d glyphs\n", (int)ng);
        for (gi = 0; gi < ng; )
          {
            NSRange lr;
            NSRect fr = [lm lineFragmentRectForGlyphAtIndex: gi effectiveRange: &lr];
            NSPoint loc = [lm locationForGlyphAtIndex: lr.location];
            printf("   fragment x=%g y=%g w=%g h=%g firstGlyph.x=%g\n",
                   (double)fr.origin.x, (double)fr.origin.y,
                   (double)fr.size.width, (double)fr.size.height, (double)loc.x);
            gi = NSMaxRange(lr);
          }
      }
    }
  return 0;
}
