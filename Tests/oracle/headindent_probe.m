#import <Cocoa/Cocoa.h>

/* Does AppKit's convenience boundingRect zero origin.x unconditionally, or
   only cancel the head indent (leaving an alignment offset)?  And does the
   drawing honour the indent on every line?  Probe alignment x indent. */

static NSAttributedString *makeString(CGFloat indent, NSTextAlignment align)
{
  NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
  [ps setFirstLineHeadIndent: indent];
  [ps setHeadIndent: indent];
  [ps setAlignment: align];
  [ps setLineBreakMode: NSLineBreakByWordWrapping];
  NSDictionary *attrs = @{ NSFontAttributeName: [NSFont systemFontOfSize: 12],
                           NSForegroundColorAttributeName: [NSColor blackColor],
                           NSParagraphStyleAttributeName: ps };
  return [[NSAttributedString alloc]
    initWithString: @"The quick brown fox jumps over the lazy dog near the river"
        attributes: attrs];
}

static const char *alignName(NSTextAlignment a)
{
  switch (a) { case NSTextAlignmentLeft: return "left";
               case NSTextAlignmentCenter: return "center";
               case NSTextAlignmentRight: return "right";
               default: return "?"; }
}

static void reportBounds(NSTextAlignment a)
{
  NSStringDrawingOptions lf = NSStringDrawingUsesLineFragmentOrigin;
  NSRect r0  = [makeString(0.0,  a) boundingRectWithSize: NSMakeSize(120, 1000) options: lf];
  NSRect r20 = [makeString(20.0, a) boundingRectWithSize: NSMakeSize(120, 1000) options: lf];
  printf("boundingRect align=%-6s indent 0  : origin=(%.1f,%.1f) size=(%.1f x %.1f)\n",
         alignName(a), r0.origin.x, r0.origin.y, r0.size.width, r0.size.height);
  printf("boundingRect align=%-6s indent 20 : origin=(%.1f,%.1f) size=(%.1f x %.1f)\n",
         alignName(a), r20.origin.x, r20.origin.y, r20.size.width, r20.size.height);
}

/* single line (no wrap) to mirror the original #350 NoteCell case:
   only firstLineHeadIndent set, headIndent 0 */
static void reportSingleLine(void)
{
  NSStringDrawingOptions lf = NSStringDrawingUsesLineFragmentOrigin;
  for (int hi = 0; hi <= 1; hi++)
    {
      NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
      [ps setFirstLineHeadIndent: 20.0];
      if (hi) [ps setHeadIndent: 20.0];
      NSDictionary *attrs = @{ NSFontAttributeName: [NSFont systemFontOfSize: 12],
                               NSParagraphStyleAttributeName: ps };
      NSAttributedString *s = [[NSAttributedString alloc]
        initWithString: @"Hello" attributes: attrs];
      NSRect r = [s boundingRectWithSize: NSMakeSize(1000, 1000) options: lf];
      printf("single-line firstLineHeadIndent=20 headIndent=%d : origin=(%.1f,%.1f) size=(%.1f x %.1f)\n",
             hi ? 20 : 0, r.origin.x, r.origin.y, r.size.width, r.size.height);
    }
}

int main(void)
{
  @autoreleasepool
    {
      reportSingleLine();
      printf("\n");
      reportBounds(NSTextAlignmentLeft);
      reportBounds(NSTextAlignmentCenter);
      reportBounds(NSTextAlignmentRight);
    }
  return 0;
}
