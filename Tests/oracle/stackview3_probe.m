#import <Cocoa/Cocoa.h>

@interface FixedView : NSView
{
  NSSize _intrinsic;
}
- (id) initWithIntrinsicSize: (NSSize)size;
@end

@implementation FixedView
- (id) initWithIntrinsicSize: (NSSize)size
{
  self = [super initWithFrame: NSMakeRect(0, 0, size.width, size.height)];
  if (self != nil)
    _intrinsic = size;
  return self;
}
- (NSSize) intrinsicContentSize
{
  return _intrinsic;
}
@end

static NSStackView *
stack(CGFloat width, NSSize a, NSSize b, NSSize c, NSWindow **window)
{
  NSWindow *w = [[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, width, 200)
              styleMask: NSWindowStyleMaskBorderless
                backing: NSBackingStoreBuffered
                  defer: NO];
  NSStackView *sv = [[NSStackView alloc]
    initWithFrame: NSMakeRect(0, 0, width, 200)];
  NSSize sizes[3];
  int i;

  sizes[0] = a; sizes[1] = b; sizes[2] = c;
  [w setContentView: sv];
  for (i = 0; i < 3; i++)
    [sv addArrangedSubview: [[FixedView alloc] initWithIntrinsicSize: sizes[i]]];
  [sv setOrientation: NSUserInterfaceLayoutOrientationHorizontal];
  [sv setSpacing: 10];
  *window = w;
  return sv;
}

static void
dump(const char *what, NSStackView *sv)
{
  NSArray *arranged = [sv arrangedSubviews];
  int i;

  [sv layoutSubtreeIfNeeded];
  printf("%-46s", what);
  for (i = 0; i < (int)[arranged count]; i++)
    {
      NSRect f = [[arranged objectAtIndex: i] frame];

      printf(" %g %g %g %g /", (double)f.origin.x, (double)f.origin.y,
             (double)f.size.width, (double)f.size.height);
    }
  printf("\n");
  fflush(stdout);
}

int
main(int argc, const char *argv[])
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSSize small = NSMakeSize(10, 20);
  NSSize big = NSMakeSize(100, 30);
  NSWindow *w;
  NSStackView *sv;

  /* 10, 10 and 100 wide, total 120, gaps 20.  At 170 the equal width is 50,
     which is less than the widest view but the total still fits. */
  printf("=== FillEqually, equal width below one intrinsic width ===\n");
  sv = stack(170, small, small, big, &w);
  [sv setDistribution: NSStackViewDistributionFillEqually];
  dump("FillEqually 170 (10,10,100) equal would be 50", sv);

  sv = stack(300, small, small, big, &w);
  [sv setDistribution: NSStackViewDistributionFillEqually];
  dump("FillEqually 300 (10,10,100) equal would be 93", sv);

  printf("=== Fill with one big view ===\n");
  sv = stack(200, small, small, big, &w);
  [sv setDistribution: NSStackViewDistributionFill];
  dump("Fill 200 (10,10,100) slack 60", sv);

  sv = stack(100, small, small, big, &w);
  [sv setDistribution: NSStackViewDistributionFill];
  dump("Fill 100 (10,10,100) no room", sv);

  printf("=== FillProportionally with one big view, no room ===\n");
  sv = stack(100, small, small, big, &w);
  [sv setDistribution: NSStackViewDistributionFillProportionally];
  dump("FillProportionally 100 (10,10,100)", sv);

  fflush(stdout);
  [pool release];
  return 0;
}
