/* Apple oracle for the NSDatePickerCell coverage test.  Probes the enum
   values, the init defaults (style/mode/elements/timeInterval/min/max/
   dateValue/colors/calendar/locale/timeZone), whether dateValue is clamped to
   [minDate,maxDate] on set and on later min/max changes, and the plain setter
   round-trips.  Portable so the same file runs under GNUstep for an A/B.
   Dates are printed as timeIntervalSinceReferenceDate so the two sides compare
   without locale/formatting noise. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

static const char *
iv(NSDate *d)
{
  static char buf[64];
  if (d == nil) return "nil";
  snprintf(buf, sizeof(buf), "%.1f", [d timeIntervalSinceReferenceDate]);
  return buf;
}

static NSDate *
at(double t)
{
  return [NSDate dateWithTimeIntervalSinceReferenceDate: t];
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    printf("ENUM style TFS=%d CC=%d TF=%d\n",
           (int)NSTextFieldAndStepperDatePickerStyle,
           (int)NSClockAndCalendarDatePickerStyle,
           (int)NSTextFieldDatePickerStyle);
    printf("ENUM mode Single=%d Range=%d\n",
           (int)NSSingleDateMode, (int)NSRangeDateMode);
    printf("ENUM elem HM=0x%x HMS=0x%x TZ=0x%x YM=0x%x YMD=0x%x Era=0x%x\n",
           (unsigned)NSHourMinuteDatePickerElementFlag,
           (unsigned)NSHourMinuteSecondDatePickerElementFlag,
           (unsigned)NSTimeZoneDatePickerElementFlag,
           (unsigned)NSYearMonthDatePickerElementFlag,
           (unsigned)NSYearMonthDayDatePickerElementFlag,
           (unsigned)NSEraDatePickerElementFlag);

    /* init defaults */
    NSDatePickerCell *c = [[NSDatePickerCell alloc] init];
    printf("INIT style=%lu mode=%lu elements=0x%lx timeInterval=%g "
           "minDate=%s maxDate=%s draws=%d bg=%s txt=%s dateValue=%s\n",
           (unsigned long)[c datePickerStyle], (unsigned long)[c datePickerMode],
           (unsigned long)[c datePickerElements], [c timeInterval],
           iv([c minDate]), iv([c maxDate]), [c drawsBackground],
           [c backgroundColor] == nil ? "nil" : "set",
           [c textColor] == nil ? "nil" : "set",
           iv([c dateValue]));
    printf("INIT calendar=%s locale=%s tz=%s\n",
           [c calendar] == nil ? "nil" : [[[c calendar] calendarIdentifier] UTF8String],
           [c locale] == nil ? "nil" : [[[c locale] localeIdentifier] UTF8String],
           [c timeZone] == nil ? "nil" : [[[c timeZone] name] UTF8String]);

    /* clamping of dateValue to [minDate, maxDate] (min=0, max=1e6) */
    NSDatePickerCell *cl = [[NSDatePickerCell alloc] init];
    [cl setMinDate: at(0.0)];
    [cl setMaxDate: at(1000000.0)];
    [cl setDateValue: at(-1000000.0)];
    printf("CLAMP below-min -> %s\n", iv([cl dateValue]));
    [cl setDateValue: at(2000000.0)];
    printf("CLAMP above-max -> %s\n", iv([cl dateValue]));
    [cl setDateValue: at(500000.0)];
    printf("CLAMP in-range -> %s\n", iv([cl dateValue]));

    /* re-clamp when min/max move past the current value */
    NSDatePickerCell *rc = [[NSDatePickerCell alloc] init];
    [rc setDateValue: at(500000.0)];
    [rc setMinDate: at(600000.0)];
    printf("RECLAMP minAboveValue -> %s\n", iv([rc dateValue]));
    NSDatePickerCell *rc2 = [[NSDatePickerCell alloc] init];
    [rc2 setDateValue: at(500000.0)];
    [rc2 setMaxDate: at(400000.0)];
    printf("RECLAMP maxBelowValue -> %s\n", iv([rc2 dateValue]));

    /* plain setter round-trips */
    NSDatePickerCell *st = [[NSDatePickerCell alloc] init];
    [st setDatePickerStyle: NSClockAndCalendarDatePickerStyle];
    [st setDatePickerMode: NSRangeDateMode];
    [st setDatePickerElements: NSYearMonthDayDatePickerElementFlag];
    [st setTimeInterval: 3600.0];
    [st setDrawsBackground: YES];
    printf("SET style=%lu mode=%lu elements=0x%lx timeInterval=%g draws=%d\n",
           (unsigned long)[st datePickerStyle], (unsigned long)[st datePickerMode],
           (unsigned long)[st datePickerElements], [st timeInterval],
           [st drawsBackground]);
  }
  return 0;
}
