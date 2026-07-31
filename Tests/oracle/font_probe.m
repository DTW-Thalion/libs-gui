/* macOS ground truth for the font and glyph metric assertions. */
#import <Cocoa/Cocoa.h>

static NSGlyph
layoutGlyph(NSFont *f, NSString *s, unsigned idx)
{
  NSTextStorage *ts;
  NSLayoutManager *lm;
  NSTextContainer *tc;
  NSGlyph g;

  ts = [[NSTextStorage alloc] initWithString: s];
  [ts addAttribute: NSFontAttributeName value: f
             range: NSMakeRange(0, [s length])];
  lm = [[NSLayoutManager alloc] init];
  tc = [[NSTextContainer alloc] initWithContainerSize: NSMakeSize(1000, 1000)];
  [lm addTextContainer: tc];
  [ts addLayoutManager: lm];
  g = ([lm numberOfGlyphs] > idx) ? [lm glyphAtIndex: idx] : NSNullGlyph;
  return g;
}

int
main(int argc, char **argv)
{
  @autoreleasepool {
    [NSApplication sharedApplication];

    NSFont *f = [NSFont systemFontOfSize: 14];
    NSFont *big = [NSFont systemFontOfSize: 28];
    NSFont *mono = [NSFont userFixedPitchFontOfSize: 14];

    printf("fonts: 14=%s 28=%s mono=%s\n", [[f fontName] UTF8String],
      [[big fontName] UTF8String], [[mono fontName] UTF8String]);

    /* ---- fontmetrics.m assertions ---- */
    printf("A empty width      = %g  (expect 0)\n", (double)[f widthOfString: @""]);
    double wi = [f widthOfString: @"i"], wiiii = [f widthOfString: @"iiii"];
    double wW = [f widthOfString: @"W"], wWWWW = [f widthOfString: @"WWWW"];
    printf("B i=%g iiii=%g (4*i=%g)  W=%g WWWW=%g (4*W=%g)\n",
      wi, wiiii, 4 * wi, wW, wWWWW, 4 * wW);
    printf("C Wi@14=%g Wi@28=%g (2x=%g)\n", (double)[f widthOfString: @"Wi"],
      (double)[big widthOfString: @"Wi"], 2 * (double)[f widthOfString: @"Wi"]);
    printf("D ascender 14=%g 28=%g (2x=%g)\n", (double)[f ascender],
      (double)[big ascender], 2 * (double)[f ascender]);
    printf("E descender 14=%g   maxAdvancement=%g  (>= wW %g?)\n",
      (double)[f descender], (double)[f maximumAdvancement].width, wW);

    /* ---- glyph acquisition routes ---- */
    NSGlyph cW = (NSGlyph)'W', ci = (NSGlyph)'i';
    NSGlyph nW = [f glyphWithName: @"W"], ni = [f glyphWithName: @"i"];
    NSGlyph lW = layoutGlyph(f, @"Wi", 0), li = layoutGlyph(f, @"Wi", 1);
    printf("F cast      W=%lu adv=%g | i=%lu adv=%g\n", (unsigned long)cW,
      (double)[f advancementForGlyph: cW].width, (unsigned long)ci,
      (double)[f advancementForGlyph: ci].width);
    printf("G glyphWName W=%lu adv=%g | i=%lu adv=%g\n", (unsigned long)nW,
      (double)[f advancementForGlyph: nW].width, (unsigned long)ni,
      (double)[f advancementForGlyph: ni].width);
    printf("H layoutMgr W=%lu adv=%g | i=%lu adv=%g\n", (unsigned long)lW,
      (double)[f advancementForGlyph: lW].width, (unsigned long)li,
      (double)[f advancementForGlyph: li].width);

    /* ---- glyphmetrics.m assertions, using the layout glyphs ---- */
    NSSize aW = [f advancementForGlyph: lW], ai = [f advancementForGlyph: li];
    NSRect bW = [f boundingRectForGlyph: lW], bi = [f boundingRectForGlyph: li];
    printf("I adv W=%g i=%g (W>i?)\n", (double)aW.width, (double)ai.width);
    NSGlyph bigW = layoutGlyph(big, @"Wi", 0);
    printf("J adv W@28=%g (2x14=%g)\n",
      (double)[big advancementForGlyph: bigW].width, 2 * (double)aW.width);
    printf("K bbox W={%g %g %g %g} i={%g %g %g %g} (i ink %g < adv %g?)\n",
      (double)bW.origin.x, (double)bW.origin.y, (double)bW.size.width,
      (double)bW.size.height, (double)bi.origin.x, (double)bi.origin.y,
      (double)bi.size.width, (double)bi.size.height,
      (double)bi.size.width, (double)ai.width);
    NSGlyph mW = layoutGlyph(mono, @"Wi", 0), mi = layoutGlyph(mono, @"Wi", 1);
    printf("L mono adv i=%g W=%g (equal?)\n",
      (double)[mono advancementForGlyph: mi].width,
      (double)[mono advancementForGlyph: mW].width);
    NSGlyph lA = layoutGlyph(f, @"A", 0);
    printf("M glyphIsEncoded: layoutA(%lu)=%d cast'A'(%lu)=%d\n",
      (unsigned long)lA, (int)[f glyphIsEncoded: lA],
      (unsigned long)(NSGlyph)'A', (int)[f glyphIsEncoded: (NSGlyph)'A']);
  }
  return 0;
}
