#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

static void
dumpMethods(Class c, const char *label)
{
  unsigned int n = 0;
  Method *m = class_copyMethodList(c, &n);
  unsigned int i;

  printf("== instance methods of %s (%u)\n", label, n);
  for (i = 0; i < n; i++)
    {
      printf("   %s\n", sel_getName(method_getName(m[i])));
    }
  free(m);
}

static const char *
str(NSString *s)
{
  return s ? [s UTF8String] : "(nil)";
}

static void
showString(NSDatePickerCell *cell, const char *label)
{
  printf("  %-46s -> '%s'\n", label, str([cell stringValue]));
}

int
main(int argc, const char **argv)
{
  @autoreleasepool
    {
      [NSApplication sharedApplication];

      printf("NSDatePicker superclass: %s\n",
             class_getName([NSDatePicker superclass]));
      printf("NSDatePickerCell superclass: %s\n",
             class_getName([NSDatePickerCell superclass]));
      printf("NSDatePicker cellClass: %s\n",
             class_getName([NSDatePicker cellClass]));

      dumpMethods([NSDatePicker class], "NSDatePicker");
      dumpMethods([NSDatePickerCell class], "NSDatePickerCell");

      NSDate *ref = [NSDate dateWithTimeIntervalSinceReferenceDate: 700000000.0];
      NSDate *lo = [NSDate dateWithTimeIntervalSinceReferenceDate: 600000000.0];
      NSDate *hi = [NSDate dateWithTimeIntervalSinceReferenceDate: 800000000.0];

      NSDatePicker *dp = [[NSDatePicker alloc]
        initWithFrame: NSMakeRect(0, 0, 180, 24)];
      NSDatePickerCell *cell = [dp cell];

      printf("== defaults\n");
      printf("  cell class: %s\n", class_getName([cell class]));
      printf("  style=%lu mode=%lu elements=0x%lx\n",
             (unsigned long)[dp datePickerStyle],
             (unsigned long)[dp datePickerMode],
             (unsigned long)[dp datePickerElements]);
      printf("  dateValue=%s timeInterval=%f\n",
             str([[dp dateValue] description]), [dp timeInterval]);
      printf("  minDate=%s maxDate=%s\n",
             str([[dp minDate] description]), str([[dp maxDate] description]));
      printf("  drawsBackground=%d bezeled=%d bordered=%d\n",
             [dp drawsBackground], [dp isBezeled], [dp isBordered]);
      printf("  backgroundColor=%s textColor=%s\n",
             str([[dp backgroundColor] description]),
             str([[dp textColor] description]));
      printf("  calendar=%s locale=%s timeZone=%s\n",
             str([[dp calendar] calendarIdentifier]),
             str([[dp locale] localeIdentifier]),
             str([[dp timeZone] name]));
      printf("  formatter=%s\n", class_getName([[cell formatter] class]));
      if ([[cell formatter] isKindOfClass: [NSDateFormatter class]])
        {
          NSDateFormatter *f = (NSDateFormatter *)[cell formatter];
          printf("  dateFormat='%s' dateStyle=%lu timeStyle=%lu\n",
                 str([f dateFormat]), (unsigned long)[f dateStyle],
                 (unsigned long)[f timeStyle]);
        }
      printf("  cell editable=%d selectable=%d enabled=%d continuous=%d\n",
             [cell isEditable], [cell isSelectable], [cell isEnabled],
             [cell isContinuous]);
      printf("  dp acceptsFirstResponder=%d needsPanelToBecomeKey=%d\n",
             [dp acceptsFirstResponder], [dp needsPanelToBecomeKey]);
      printf("  dp subviews=%lu\n", (unsigned long)[[dp subviews] count]);
      printf("  refusesFirstResponder=%d\n", [dp refusesFirstResponder]);
      printf("  cell action=%s target=%s\n",
             [cell action] ? sel_getName([cell action]) : "(null)",
             [cell target] ? class_getName([[cell target] class]) : "(nil)");

      /* Deterministic formatting environment. */
      [dp setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US"]];
      [dp setTimeZone: [NSTimeZone timeZoneWithName: @"GMT"]];
      [dp setDateValue: ref];

      printf("== displayed string per element mask (en_US, GMT, ref 700000000)\n");
      printf("  dateValue now = %s\n", str([[dp dateValue] description]));
      [dp setDatePickerElements: NSDatePickerElementFlagYearMonthDay
        | NSDatePickerElementFlagHourMinuteSecond];
      showString(cell, "YearMonthDay|HourMinuteSecond (default)");
      [dp setDatePickerElements: NSDatePickerElementFlagYearMonthDay];
      showString(cell, "YearMonthDay");
      [dp setDatePickerElements: NSDatePickerElementFlagYearMonth];
      showString(cell, "YearMonth");
      [dp setDatePickerElements: NSDatePickerElementFlagHourMinute];
      showString(cell, "HourMinute");
      [dp setDatePickerElements: NSDatePickerElementFlagHourMinuteSecond];
      showString(cell, "HourMinuteSecond");
      [dp setDatePickerElements: NSDatePickerElementFlagYearMonthDay
        | NSDatePickerElementFlagEra];
      showString(cell, "YearMonthDay|Era");
      [dp setDatePickerElements: NSDatePickerElementFlagHourMinuteSecond
        | NSDatePickerElementFlagTimeZone];
      showString(cell, "HourMinuteSecond|TimeZone");
      [dp setDatePickerElements: NSDatePickerElementFlagYearMonthDay
        | NSDatePickerElementFlagHourMinuteSecond
        | NSDatePickerElementFlagEra | NSDatePickerElementFlagTimeZone];
      showString(cell, "everything");

      printf("== element mask normalisation\n");
      [dp setDatePickerElements: 0];
      printf("  set 0        -> 0x%lx\n", (unsigned long)[dp datePickerElements]);
      [dp setDatePickerElements: NSDatePickerElementFlagYearMonthDay];
      printf("  set 0x00e0   -> 0x%lx\n", (unsigned long)[dp datePickerElements]);
      [dp setDatePickerElements: 0x0004];
      printf("  set 0x0004   -> 0x%lx\n", (unsigned long)[dp datePickerElements]);
      [dp setDatePickerElements: 0xffff];
      printf("  set 0xffff   -> 0x%lx\n", (unsigned long)[dp datePickerElements]);

      printf("== locale sensitivity (YearMonthDay|HourMinuteSecond)\n");
      [dp setDatePickerElements: NSDatePickerElementFlagYearMonthDay
        | NSDatePickerElementFlagHourMinuteSecond];
      [dp setLocale: [NSLocale localeWithLocaleIdentifier: @"de_DE"]];
      showString(cell, "de_DE");
      [dp setLocale: [NSLocale localeWithLocaleIdentifier: @"en_GB"]];
      showString(cell, "en_GB");
      [dp setLocale: [NSLocale localeWithLocaleIdentifier: @"ja_JP"]];
      showString(cell, "ja_JP");
      [dp setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US"]];
      [dp setTimeZone: [NSTimeZone timeZoneWithName: @"America/New_York"]];
      showString(cell, "en_US, America/New_York");
      [dp setTimeZone: [NSTimeZone timeZoneWithName: @"GMT"]];

      printf("== cell size per style (default elements)\n");
      NSDatePickerStyle styles[3];
      styles[0] = NSDatePickerStyleTextFieldAndStepper;
      styles[1] = NSDatePickerStyleClockAndCalendar;
      styles[2] = NSDatePickerStyleTextField;
      int i;
      for (i = 0; i < 3; i++)
        {
          NSDatePicker *p = [[NSDatePicker alloc]
            initWithFrame: NSMakeRect(0, 0, 180, 24)];
          [p setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US"]];
          [p setTimeZone: [NSTimeZone timeZoneWithName: @"GMT"]];
          [p setDateValue: ref];
          [p setDatePickerStyle: styles[i]];
          NSSize cs = [[p cell] cellSize];
          NSSize is = [p intrinsicContentSize];
          printf("  style %d: cellSize=%.1fx%.1f intrinsic=%.1fx%.1f subviews=%lu"
                 " stringValue='%s'\n",
                 i, cs.width, cs.height, is.width, is.height,
                 (unsigned long)[[p subviews] count], str([[p cell] stringValue]));
          [p setDatePickerElements: NSDatePickerElementFlagYearMonthDay];
          cs = [[p cell] cellSize];
          printf("  style %d ymd only: cellSize=%.1fx%.1f\n", i, cs.width, cs.height);
        }

      printf("== min/max clamping\n");
      NSDatePicker *c1 = [[NSDatePicker alloc]
        initWithFrame: NSMakeRect(0, 0, 180, 24)];
      [c1 setDateValue: ref];
      [c1 setMinDate: lo];
      [c1 setMaxDate: hi];
      printf("  in-range value kept: %f\n",
             [[c1 dateValue] timeIntervalSinceReferenceDate]);
      [c1 setDateValue: [NSDate dateWithTimeIntervalSinceReferenceDate: 100.0]];
      printf("  set below min -> %f\n",
             [[c1 dateValue] timeIntervalSinceReferenceDate]);
      [c1 setDateValue: [NSDate dateWithTimeIntervalSinceReferenceDate: 900000000.0]];
      printf("  set above max -> %f\n",
             [[c1 dateValue] timeIntervalSinceReferenceDate]);
      [c1 setDateValue: ref];
      [c1 setMinDate: [NSDate dateWithTimeIntervalSinceReferenceDate: 750000000.0]];
      printf("  raise min above value -> value=%f min=%f\n",
             [[c1 dateValue] timeIntervalSinceReferenceDate],
             [[c1 minDate] timeIntervalSinceReferenceDate]);
      [c1 setMinDate: nil];
      [c1 setDateValue: ref];
      [c1 setMaxDate: [NSDate dateWithTimeIntervalSinceReferenceDate: 650000000.0]];
      printf("  lower max below value -> value=%f max=%f\n",
             [[c1 dateValue] timeIntervalSinceReferenceDate],
             [[c1 maxDate] timeIntervalSinceReferenceDate]);

      printf("== objectValue and setObjectValue\n");
      NSDatePicker *c2 = [[NSDatePicker alloc]
        initWithFrame: NSMakeRect(0, 0, 180, 24)];
      printf("  default objectValue class=%s\n",
             class_getName([[[c2 cell] objectValue] class]));
      [c2 setDateValue: ref];
      printf("  objectValue after setDateValue: class=%s equal=%d\n",
             class_getName([[[c2 cell] objectValue] class]),
             [[[c2 cell] objectValue] isEqual: ref]);
      @try
        {
          [[c2 cell] setObjectValue: @"not a date"];
          printf("  setObjectValue: a string -> dateValue=%s\n",
                 str([[c2 dateValue] description]));
        }
      @catch (NSException *e)
        {
          printf("  setObjectValue: a string raises %s\n", str([e name]));
        }

      printf("== range mode\n");
      NSDatePicker *c3 = [[NSDatePicker alloc]
        initWithFrame: NSMakeRect(0, 0, 180, 24)];
      [c3 setDateValue: ref];
      [c3 setDatePickerMode: NSDatePickerModeRange];
      printf("  mode=%lu timeInterval=%f\n",
             (unsigned long)[c3 datePickerMode], [c3 timeInterval]);
      [c3 setTimeInterval: 86400.0];
      printf("  after setTimeInterval:86400 -> %f dateValue=%f\n",
             [c3 timeInterval],
             [[c3 dateValue] timeIntervalSinceReferenceDate]);

      printf("== coding\n");
      NSDatePicker *c4 = [[NSDatePicker alloc]
        initWithFrame: NSMakeRect(0, 0, 180, 24)];
      [c4 setDateValue: ref];
      [c4 setMinDate: lo];
      [c4 setMaxDate: hi];
      [c4 setDatePickerStyle: NSDatePickerStyleClockAndCalendar];
      [c4 setDatePickerMode: NSDatePickerModeRange];
      [c4 setDatePickerElements: NSDatePickerElementFlagYearMonthDay];
      [c4 setDrawsBackground: YES];
      [c4 setBackgroundColor: [NSColor redColor]];
      [c4 setTextColor: [NSColor blueColor]];
      [c4 setTimeInterval: 3600.0];
      NSData *d = [NSKeyedArchiver archivedDataWithRootObject: c4
                                        requiringSecureCoding: NO
                                                        error: NULL];
      NSDatePicker *c5 = [NSKeyedUnarchiver unarchivedObjectOfClass:
        [NSDatePicker class] fromData: d error: NULL];
      printf("  decoded style=%lu mode=%lu elements=0x%lx interval=%f\n",
             (unsigned long)[c5 datePickerStyle],
             (unsigned long)[c5 datePickerMode],
             (unsigned long)[c5 datePickerElements], [c5 timeInterval]);
      printf("  decoded date=%f min=%f max=%f drawsBackground=%d\n",
             [[c5 dateValue] timeIntervalSinceReferenceDate],
             [[c5 minDate] timeIntervalSinceReferenceDate],
             [[c5 maxDate] timeIntervalSinceReferenceDate],
             [c5 drawsBackground]);

      printf("== hit testing and tracking\n");
      NSWindow *w = [[NSWindow alloc]
        initWithContentRect: NSMakeRect(0, 0, 300, 200)
                  styleMask: NSWindowStyleMaskTitled
                    backing: NSBackingStoreBuffered
                      defer: NO];
      NSDatePicker *c6 = [[NSDatePicker alloc]
        initWithFrame: NSMakeRect(10, 10, 180, 24)];
      [[w contentView] addSubview: c6];
      printf("  hitTest inside = %s\n",
             class_getName([[[w contentView] hitTest: NSMakePoint(20, 20)] class]));
      @try
        {
      printf("  cell hitTestForEvent mask for a click in the middle = %lu\n",
             (unsigned long)[[c6 cell]
               hitTestForEvent: [NSEvent mouseEventWithType: NSEventTypeLeftMouseDown
                                                   location: NSMakePoint(100, 22)
                                              modifierFlags: 0
                                                  timestamp: 0
                                               windowNumber: [w windowNumber]
                                                    context: nil
                                                eventNumber: 0
                                                 clickCount: 1
                                                   pressure: 1.0]
                        inRect: [c6 bounds]
                        ofView: c6]);
        }
      @catch (NSException *e)
        {
          printf("  hitTestForEvent raises %s\n", str([e name]));
        }
      [w makeFirstResponder: c6];
      printf("  firstResponder after makeFirstResponder = %s\n",
             class_getName([[w firstResponder] class]));

      printf("== keyboard editing\n");
      [c6 setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US"]];
      [c6 setTimeZone: [NSTimeZone timeZoneWithName: @"GMT"]];
      [c6 setDateValue: ref];
      printf("  before keys: %f '%s'\n",
             [[c6 dateValue] timeIntervalSinceReferenceDate],
             str([[c6 cell] stringValue]));
      @try
        {
          NSEvent *up = [NSEvent keyEventWithType: NSEventTypeKeyDown
                                         location: NSZeroPoint
                                    modifierFlags: NSEventModifierFlagNumericPad
                                        timestamp: 0
                                     windowNumber: [w windowNumber]
                                          context: nil
                                       characters: @""
                      charactersIgnoringModifiers: @""
                                        isARepeat: NO
                                          keyCode: 126];
          [[w firstResponder] keyDown: up];
          printf("  after up arrow: %f '%s'\n",
                 [[c6 dateValue] timeIntervalSinceReferenceDate],
                 str([[c6 cell] stringValue]));
          NSEvent *dn = [NSEvent keyEventWithType: NSEventTypeKeyDown
                                         location: NSZeroPoint
                                    modifierFlags: NSEventModifierFlagNumericPad
                                        timestamp: 0
                                     windowNumber: [w windowNumber]
                                          context: nil
                                       characters: @""
                      charactersIgnoringModifiers: @""
                                        isARepeat: NO
                                          keyCode: 125];
          [[w firstResponder] keyDown: dn];
          printf("  after down arrow: %f '%s'\n",
                 [[c6 dateValue] timeIntervalSinceReferenceDate],
                 str([[c6 cell] stringValue]));
          NSEvent *digit = [NSEvent keyEventWithType: NSEventTypeKeyDown
                                            location: NSZeroPoint
                                       modifierFlags: 0
                                           timestamp: 0
                                        windowNumber: [w windowNumber]
                                             context: nil
                                          characters: @"5"
                         charactersIgnoringModifiers: @"5"
                                           isARepeat: NO
                                             keyCode: 23];
          [[w firstResponder] keyDown: digit];
          printf("  after typing 5: %f '%s'\n",
                 [[c6 dateValue] timeIntervalSinceReferenceDate],
                 str([[c6 cell] stringValue]));
        }
      @catch (NSException *e)
        {
          printf("  key events raise %s: %s\n", str([e name]), str([e reason]));
        }

      printf("== drawing\n");
      NSDatePicker *c7 = [[NSDatePicker alloc]
        initWithFrame: NSMakeRect(0, 0, 180, 24)];
      [c7 setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US"]];
      [c7 setTimeZone: [NSTimeZone timeZoneWithName: @"GMT"]];
      [c7 setDateValue: ref];
      NSBitmapImageRep *rep = [c7 bitmapImageRepForCachingDisplayInRect: [c7 bounds]];
      [c7 cacheDisplayInRect: [c7 bounds] toBitmapImageRep: rep];
      printf("  text style bitmap %ldx%ld\n",
             (long)[rep pixelsWide], (long)[rep pixelsHigh]);
      NSDatePicker *c8 = [[NSDatePicker alloc]
        initWithFrame: NSMakeRect(0, 0, 200, 160)];
      [c8 setDatePickerStyle: NSDatePickerStyleClockAndCalendar];
      [c8 setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US"]];
      [c8 setTimeZone: [NSTimeZone timeZoneWithName: @"GMT"]];
      [c8 setDateValue: ref];
      printf("  calendar style stringValue='%s' subviews=%lu\n",
             str([[c8 cell] stringValue]), (unsigned long)[[c8 subviews] count]);

      printf("done\n");
    }
  return 0;
}
