#import <Cocoa/Cocoa.h>

static NSRect measure(CGFloat indent, NSStringDrawingOptions opts)
{
  NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
  [ps setFirstLineHeadIndent: indent];
  [ps setHeadIndent: indent];
  NSDictionary *attrs = @{ NSFontAttributeName: [NSFont systemFontOfSize: 12],
                           NSParagraphStyleAttributeName: ps };
  NSAttributedString *s = [[NSAttributedString alloc]
    initWithString: @"Hello world" attributes: attrs];
  return [s boundingRectWithSize: NSMakeSize(1000, 1000) options: opts];
}

int main(void)
{
  @autoreleasepool
    {
      NSRect a0 = measure(0.0, 0);
      NSRect a20 = measure(20.0, 0);
      printf("opts=0                origin/size:\n");
      printf("  indent 0  : origin=(%.1f,%.1f) size=(%.1f x %.1f)\n",
             a0.origin.x, a0.origin.y, a0.size.width, a0.size.height);
      printf("  indent 20 : origin=(%.1f,%.1f) size=(%.1f x %.1f)\n",
             a20.origin.x, a20.origin.y, a20.size.width, a20.size.height);
      printf("  width delta = %.1f\n", a20.size.width - a0.size.width);

      NSStringDrawingOptions lf = NSStringDrawingUsesLineFragmentOrigin;
      NSRect b0 = measure(0.0, lf);
      NSRect b20 = measure(20.0, lf);
      printf("opts=UsesLineFragmentOrigin:\n");
      printf("  indent 0  : origin=(%.1f,%.1f) size=(%.1f x %.1f)\n",
             b0.origin.x, b0.origin.y, b0.size.width, b0.size.height);
      printf("  indent 20 : origin=(%.1f,%.1f) size=(%.1f x %.1f)\n",
             b20.origin.x, b20.origin.y, b20.size.width, b20.size.height);
      printf("  width delta = %.1f\n", b20.size.width - b0.size.width);
    }
  return 0;
}
