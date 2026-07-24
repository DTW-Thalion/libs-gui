/* Apple oracle: config of NSImageView/NSSlider/NSSegmentedControl factories. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>
@interface Tg : NSObject @end
@implementation Tg - (void) go: (id)s {} @end

int main(void)
{
  @autoreleasepool {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];
    Tg *t = [Tg new];
    NSImage *im = [[NSImage alloc] initWithSize: NSMakeSize(16,16)];

    NSImageView *iv = [NSImageView imageViewWithImage: im];
    printf("imageView: img=%d editable=%d frameStyle=%ld align=%ld scaling=%ld\n",
      [iv image] == im, [iv isEditable], (long)[iv imageFrameStyle],
      (long)[iv imageAlignment], (long)[iv imageScaling]);

    NSSlider *s1 = [NSSlider sliderWithTarget: t action: @selector(go:)];
    printf("slider/ta: min=%g max=%g val=%g tgt=%d act=%s vertical=%ld\n",
      [s1 minValue], [s1 maxValue], [s1 doubleValue], [s1 target] == t,
      s1.action ? sel_getName(s1.action) : "(nil)", (long)[s1 isVertical]);

    NSSlider *s2 = [NSSlider sliderWithValue: 5 minValue: 2 maxValue: 9
                                      target: t action: @selector(go:)];
    printf("slider/vmm: min=%g max=%g val=%g tgt=%d\n",
      [s2 minValue], [s2 maxValue], [s2 doubleValue], [s2 target] == t);

    NSSegmentedControl *sc = [NSSegmentedControl
      segmentedControlWithLabels: @[@"A", @"B", @"C"]
      trackingMode: NSSegmentSwitchTrackingSelectOne
      target: t action: @selector(go:)];
    printf("segControl: count=%ld label0='%s' mode=%ld tgt=%d sel=%ld\n",
      (long)[sc segmentCount], [[sc labelForSegment: 0] UTF8String],
      (long)[sc trackingMode], [sc target] == t, (long)[sc selectedSegment]);
  }
  return 0;
}
