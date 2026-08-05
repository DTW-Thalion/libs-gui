#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

/* Views with a fixed intrinsic content size, so every number below is stack
   view arithmetic and not font metrics. */
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
stackWithViews(NSWindow **window)
{
  NSWindow *w = [[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 200, 200)
              styleMask: NSWindowStyleMaskBorderless
                backing: NSBackingStoreBuffered
                  defer: NO];
  NSStackView *sv = [[NSStackView alloc] initWithFrame: NSMakeRect(0, 0, 200, 200)];
  NSSize sizes[3] = {{40, 20}, {60, 30}, {20, 10}};
  int i;

  [w setContentView: sv];
  for (i = 0; i < 3; i++)
    [sv addArrangedSubview: [[FixedView alloc] initWithIntrinsicSize: sizes[i]]];
  *window = w;
  return sv;
}

static void
dump(const char *what, NSStackView *sv)
{
  NSArray *arranged = [sv arrangedSubviews];
  int i;

  [sv layoutSubtreeIfNeeded];
  printf("%-34s stack=%g %g %g %g fitting=%g x %g\n", what,
         (double)[sv frame].origin.x, (double)[sv frame].origin.y,
         (double)[sv frame].size.width, (double)[sv frame].size.height,
         (double)[sv fittingSize].width, (double)[sv fittingSize].height);
  for (i = 0; i < (int)[arranged count]; i++)
    {
      NSRect f = [[arranged objectAtIndex: i] frame];

      printf("      view %d  %g %g %g %g\n", i, (double)f.origin.x,
             (double)f.origin.y, (double)f.size.width, (double)f.size.height);
    }
  fflush(stdout);
}

int
main(int argc, const char *argv[])
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *w;
  NSStackView *sv;
  NSStackView *fresh = [[NSStackView alloc] initWithFrame: NSMakeRect(0, 0, 200, 200)];
  NSStackViewDistribution dists[5] = {
    NSStackViewDistributionGravityAreas, NSStackViewDistributionFill,
    NSStackViewDistributionFillEqually, NSStackViewDistributionFillProportionally,
    NSStackViewDistributionEqualSpacing };
  const char *distNames[5] = { "GravityAreas", "Fill", "FillEqually",
                               "FillProportionally", "EqualSpacing" };
  NSLayoutAttribute aligns[4] = { NSLayoutAttributeLeading, NSLayoutAttributeCenterX,
                                  NSLayoutAttributeTrailing, NSLayoutAttributeWidth };
  const char *alignNames[4] = { "Leading", "CenterX", "Trailing", "Width" };
  int i;

  printf("=== defaults of a plain -initWithFrame: stack view ===\n");
  printf("orientation=%ld spacing=%g distribution=%ld alignment=%ld "
         "detachesHiddenViews=%d insets=%g %g %g %g arranged=%lu views=%lu\n",
         (long)[fresh orientation], (double)[fresh spacing],
         (long)[fresh distribution], (long)[fresh alignment],
         (int)[fresh detachesHiddenViews],
         (double)[fresh edgeInsets].top, (double)[fresh edgeInsets].left,
         (double)[fresh edgeInsets].bottom, (double)[fresh edgeInsets].right,
         (unsigned long)[[fresh arrangedSubviews] count],
         (unsigned long)[[fresh views] count]);
  printf("hugging h=%g v=%g clipping h=%g v=%g\n",
         (double)[fresh huggingPriorityForOrientation:
                    NSLayoutConstraintOrientationHorizontal],
         (double)[fresh huggingPriorityForOrientation:
                    NSLayoutConstraintOrientationVertical],
         (double)[fresh clippingResistancePriorityForOrientation:
                    NSLayoutConstraintOrientationHorizontal],
         (double)[fresh clippingResistancePriorityForOrientation:
                    NSLayoutConstraintOrientationVertical]);

  printf("=== horizontal, spacing 0 then 10 ===\n");
  sv = stackWithViews(&w);
  [sv setOrientation: NSUserInterfaceLayoutOrientationHorizontal];
  [sv setSpacing: 0];
  dump("horizontal spacing 0", sv);
  [sv setSpacing: 10];
  dump("horizontal spacing 10", sv);
  [sv setEdgeInsets: NSEdgeInsetsMake(5, 15, 5, 15)];
  dump("insets top5 left15 bottom5 right15", sv);

  printf("=== horizontal distributions, spacing 10, no insets ===\n");
  for (i = 0; i < 5; i++)
    {
      char label[64];

      sv = stackWithViews(&w);
      [sv setOrientation: NSUserInterfaceLayoutOrientationHorizontal];
      [sv setSpacing: 10];
      [sv setDistribution: dists[i]];
      snprintf(label, sizeof(label), "horizontal %s", distNames[i]);
      dump(label, sv);
    }

  printf("=== vertical, spacing 10, each alignment ===\n");
  for (i = 0; i < 4; i++)
    {
      char label[64];

      sv = stackWithViews(&w);
      [sv setOrientation: NSUserInterfaceLayoutOrientationVertical];
      [sv setSpacing: 10];
      [sv setAlignment: aligns[i]];
      snprintf(label, sizeof(label), "vertical align %s", alignNames[i]);
      dump(label, sv);
    }

  printf("=== does the stack view frame move when it is not a content view ===\n");
  {
    NSView *host = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 300, 300)];
    NSStackView *loose = [[NSStackView alloc]
      initWithFrame: NSMakeRect(10, 20, 200, 100)];
    NSSize sizes[3] = {{40, 20}, {60, 30}, {20, 10}};

    [host addSubview: loose];
    for (i = 0; i < 3; i++)
      [loose addArrangedSubview:
        [[FixedView alloc] initWithIntrinsicSize: sizes[i]]];
    [loose setOrientation: NSUserInterfaceLayoutOrientationHorizontal];
    [loose setSpacing: 10];
    dump("loose stack at 10,20 200x100", loose);
  }

  fflush(stdout);
  [pool release];
  return 0;
}
