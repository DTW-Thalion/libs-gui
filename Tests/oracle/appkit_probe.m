/* Apple oracle for the NSLevelIndicatorCell coverage test.  Probes the enum
   values, init and per-style defaults (min/max/warning/critical/ticks/value),
   value clamping to [min,max] (on set-value and on later min/max changes),
   the tickMarkValueAtIndex: formula and its out-of-range behaviour, and the
   plain setter round-trips.  Portable so the same file runs under GNUstep for
   an A/B.  Prints enum values as numbers (they can differ Apple vs GNUstep);
   the tests assert named constants, not these numbers. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

/* Apple's style getter is -levelIndicatorStyle; GNUstep implements -style
   instead (the setter -setLevelIndicatorStyle: matches on both).  Declare the
   Apple name so it compiles everywhere and pick whichever the object answers. */
@interface NSLevelIndicatorCell (OracleCompat)
- (NSLevelIndicatorStyle) levelIndicatorStyle;
@end

static long
styleOf(NSLevelIndicatorCell *c)
{
  if ([c respondsToSelector: @selector(levelIndicatorStyle)])
    return (long)[c levelIndicatorStyle];
#ifndef __APPLE__
  if ([c respondsToSelector: @selector(style)])
    return (long)[c style];
#endif
  return -999;
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    NSLevelIndicatorStyle styles[4];
    int i;

    /* NSCell touches the backend (font enumerator) under GNUstep, so the
       shared application has to exist first; harmless on macOS. */
    [NSApplication sharedApplication];

    printf("ENUM Relevancy=%d Continuous=%d Discrete=%d Rating=%d\n",
           (int)NSRelevancyLevelIndicatorStyle,
           (int)NSContinuousCapacityLevelIndicatorStyle,
           (int)NSDiscreteCapacityLevelIndicatorStyle,
           (int)NSRatingLevelIndicatorStyle);

    /* init defaults */
    NSLevelIndicatorCell *c = [[NSLevelIndicatorCell alloc] init];
    printf("INIT style=%ld min=%g max=%g warn=%g crit=%g ticks=%ld major=%ld value=%g\n",
           styleOf(c), [c minValue], [c maxValue], [c warningValue],
           [c criticalValue], (long)[c numberOfTickMarks],
           (long)[c numberOfMajorTickMarks], [c doubleValue]);

    /* per-style init defaults */
    styles[0] = NSRelevancyLevelIndicatorStyle;
    styles[1] = NSContinuousCapacityLevelIndicatorStyle;
    styles[2] = NSDiscreteCapacityLevelIndicatorStyle;
    styles[3] = NSRatingLevelIndicatorStyle;
    for (i = 0; i < 4; i++)
      {
        NSLevelIndicatorCell *s =
            [[NSLevelIndicatorCell alloc] initWithLevelIndicatorStyle: styles[i]];
        printf("STYLEINIT style=%d min=%g max=%g warn=%g crit=%g value=%g\n",
               (int)styles[i], [s minValue], [s maxValue], [s warningValue],
               [s criticalValue], [s doubleValue]);
      }

    /* value clamping to [min,max] at set-value time (min=2, max=8) */
    NSLevelIndicatorCell *cl = [[NSLevelIndicatorCell alloc] init];
    [cl setMinValue: 2.0];
    [cl setMaxValue: 8.0];
    [cl setDoubleValue: 100.0];
    printf("CLAMP set=100 -> value=%g\n", [cl doubleValue]);
    [cl setDoubleValue: -100.0];
    printf("CLAMP set=-100 -> value=%g\n", [cl doubleValue]);
    [cl setDoubleValue: 5.0];
    printf("CLAMP set=5 -> value=%g\n", [cl doubleValue]);

    /* re-clamp when min/max move past the current value */
    NSLevelIndicatorCell *rc = [[NSLevelIndicatorCell alloc] init];
    [rc setMinValue: 0.0];
    [rc setMaxValue: 10.0];
    [rc setDoubleValue: 5.0];
    [rc setMaxValue: 3.0];
    printf("RECLAMP maxTo3 value(was5)=%g\n", [rc doubleValue]);
    [rc setMinValue: 4.0];
    printf("RECLAMP minTo4 value=%g\n", [rc doubleValue]);

    /* tickMarkValueAtIndex: formula (min=0, max=10, 11 ticks) */
    NSLevelIndicatorCell *t = [[NSLevelIndicatorCell alloc] init];
    [t setMinValue: 0.0];
    [t setMaxValue: 10.0];
    [t setNumberOfTickMarks: 11];
    @try
      {
        printf("TICK n=11 [0]=%g [5]=%g [10]=%g\n",
               [t tickMarkValueAtIndex: 0], [t tickMarkValueAtIndex: 5],
               [t tickMarkValueAtIndex: 10]);
      }
    @catch (NSException *e)
      {
        printf("TICK in-range raised %s\n", [[e name] UTF8String]);
      }
    @try
      {
        double v = [t tickMarkValueAtIndex: 11];
        printf("TICK[11] no-raise value=%g\n", v);
      }
    @catch (NSException *e)
      {
        printf("TICK[11] raised %s\n", [[e name] UTF8String]);
      }
    @try
      {
        double v = [t tickMarkValueAtIndex: -1];
        printf("TICK[-1] no-raise value=%g\n", v);
      }
    @catch (NSException *e)
      {
        printf("TICK[-1] raised %s\n", [[e name] UTF8String]);
      }

    /* plain setter round-trips */
    NSLevelIndicatorCell *st = [[NSLevelIndicatorCell alloc] init];
    [st setWarningValue: 7.5];
    [st setCriticalValue: 9.25];
    [st setNumberOfMajorTickMarks: 3];
    [st setNumberOfTickMarks: 9];
    [st setMinValue: 1.0];
    [st setMaxValue: 20.0];
    printf("SET warn=%g crit=%g major=%ld ticks=%ld min=%g max=%g\n",
           [st warningValue], [st criticalValue],
           (long)[st numberOfMajorTickMarks], (long)[st numberOfTickMarks],
           [st minValue], [st maxValue]);
  }
  return 0;
}
