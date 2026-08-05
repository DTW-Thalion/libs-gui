#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

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
stackOfWidth(CGFloat width, NSWindow **window)
{
  NSWindow *w = [[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, width, 200)
              styleMask: NSWindowStyleMaskBorderless
                backing: NSBackingStoreBuffered
                  defer: NO];
  NSStackView *sv = [[NSStackView alloc]
    initWithFrame: NSMakeRect(0, 0, width, 200)];
  NSSize sizes[3] = {{40, 20}, {60, 30}, {20, 10}};
  int i;

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
  printf("%-40s", what);
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
  NSWindow *w;
  NSStackView *sv;

  printf("=== EqualSpacing, room to spare (200 wide, content 120) ===\n");
  sv = stackOfWidth(200, &w);
  [sv setDistribution: NSStackViewDistributionEqualSpacing];
  dump("EqualSpacing 200", sv);

  printf("=== EqualSpacing with no room (100 wide, content 120) ===\n");
  sv = stackOfWidth(100, &w);
  [sv setDistribution: NSStackViewDistributionEqualSpacing];
  dump("EqualSpacing 100", sv);

  printf("=== EqualSpacing exactly at the spacing (160 wide) ===\n");
  sv = stackOfWidth(160, &w);
  [sv setDistribution: NSStackViewDistributionEqualSpacing];
  dump("EqualSpacing 160", sv);

  printf("=== EqualCentering ===\n");
  sv = stackOfWidth(200, &w);
  [sv setDistribution: NSStackViewDistributionEqualCentering];
  dump("EqualCentering 200", sv);

  printf("=== FillProportionally, smaller and larger ===\n");
  sv = stackOfWidth(100, &w);
  [sv setDistribution: NSStackViewDistributionFillProportionally];
  dump("FillProportionally 100", sv);
  sv = stackOfWidth(300, &w);
  [sv setDistribution: NSStackViewDistributionFillProportionally];
  dump("FillProportionally 300", sv);

  printf("=== FillEqually and Fill with no room (100 wide) ===\n");
  sv = stackOfWidth(100, &w);
  [sv setDistribution: NSStackViewDistributionFillEqually];
  dump("FillEqually 100", sv);
  sv = stackOfWidth(100, &w);
  [sv setDistribution: NSStackViewDistributionFill];
  dump("Fill 100", sv);

  fflush(stdout);
  [pool release];
  return 0;
}
