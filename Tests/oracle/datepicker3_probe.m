#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

static NSDateFormatter *fmt = nil;
static NSWindow *win = nil;
static int actionCount = 0;

@interface Recorder : NSObject
{
@public
  int validateCalls;
  NSTimeInterval lastInterval;
  NSDate *lastProposed;
}
@end

@implementation Recorder
- (void) act: (id)sender
{
  actionCount++;
}
- (void) datePickerCell: (NSDatePickerCell *)cell
validateProposedDateValue: (NSDate **)proposed
           timeInterval: (NSTimeInterval *)interval
{
  validateCalls++;
  lastProposed = *proposed;
  lastInterval = *interval;
}
@end

static const char *
str(NSString *s)
{
  return s ? [s UTF8String] : "(nil)";
}

static const char *
show(NSDate *d)
{
  return d ? [[fmt stringFromDate: d] UTF8String] : "(nil)";
}

static NSEvent *
arrow(unichar c)
{
  unsigned short code = 126;

  if (c == NSDownArrowFunctionKey) code = 125;
  else if (c == NSLeftArrowFunctionKey) code = 123;
  else if (c == NSRightArrowFunctionKey) code = 124;
  return [NSEvent keyEventWithType: NSEventTypeKeyDown
                          location: NSZeroPoint
                     modifierFlags: NSEventModifierFlagFunction
                                    | NSEventModifierFlagNumericPad
                         timestamp: 0
                      windowNumber: [win windowNumber]
                           context: nil
                        characters: [NSString stringWithCharacters: &c length: 1]
       charactersIgnoringModifiers: [NSString stringWithCharacters: &c length: 1]
                         isARepeat: NO
                           keyCode: code];
}

int
main(int argc, const char **argv)
{
  @autoreleasepool
    {
      [NSApplication sharedApplication];

      fmt = [[NSDateFormatter alloc] init];
      [fmt setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
      [fmt setTimeZone: [NSTimeZone timeZoneWithName: @"GMT"]];
      [fmt setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US_POSIX"]];

      NSDate *base = [fmt dateFromString: @"2023-03-08 20:26:40"];
      NSDate *lo = [fmt dateFromString: @"2023-01-01 00:00:00"];
      NSDate *hi = [fmt dateFromString: @"2023-12-31 00:00:00"];

      win = [[NSWindow alloc]
        initWithContentRect: NSMakeRect(0, 0, 400, 300)
                  styleMask: NSWindowStyleMaskTitled
                    backing: NSBackingStoreBuffered
                      defer: NO];

      printf("== copying a cell\n");
      {
        NSDatePicker *dp = [[NSDatePicker alloc]
          initWithFrame: NSMakeRect(0, 0, 200, 26)];
        NSDatePickerCell *cell = [dp cell];
        NSDatePickerCell *copy;

        [dp setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US"]];
        [dp setTimeZone: [NSTimeZone timeZoneWithName: @"GMT"]];
        [dp setDateValue: base];
        [dp setMinDate: lo];
        [dp setMaxDate: hi];
        [dp setBackgroundColor: [NSColor redColor]];
        [dp setTextColor: [NSColor blueColor]];
        [dp setDrawsBackground: YES];
        [dp setDatePickerElements: NSDatePickerElementFlagYearMonthDay];
        [dp setDatePickerStyle: NSDatePickerStyleClockAndCalendar];
        [dp setDatePickerMode: NSDatePickerModeRange];

        copy = [cell copy];
        printf("  copy class = %s\n", class_getName([copy class]));
        printf("  responds to copyWithZone: own imp = %d\n",
               class_getInstanceMethod([NSDatePickerCell class],
                 @selector(copyWithZone:))
                 != class_getInstanceMethod([NSActionCell class],
                      @selector(copyWithZone:)));
        printf("  same colour object: bg %d text %d\n",
               [copy backgroundColor] == [cell backgroundColor],
               [copy textColor] == [cell textColor]);
        printf("  same date object: min %d max %d value %d\n",
               [copy minDate] == [cell minDate],
               [copy maxDate] == [cell maxDate],
               [copy dateValue] == [cell dateValue]);
        printf("  copy: value=%s min=%s max=%s\n",
               show([copy dateValue]), show([copy minDate]),
               show([copy maxDate]));
        printf("  copy: elements=0x%lx style=%lu mode=%lu draws=%d\n",
               (unsigned long)[copy datePickerElements],
               (unsigned long)[copy datePickerStyle],
               (unsigned long)[copy datePickerMode], [copy drawsBackground]);
        printf("  copy: bg=%s text=%s\n",
               str([[copy backgroundColor] description]),
               str([[copy textColor] description]));

        /* Changing the original must leave the copy alone. */
        [dp setMinDate: [fmt dateFromString: @"2020-01-01 00:00:00"]];
        [dp setBackgroundColor: [NSColor greenColor]];
        printf("  after changing the original: copy min=%s bg=%s\n",
               show([copy minDate]),
               str([[copy backgroundColor] description]));
        [copy release];
        printf("  original still alive: min=%s bg=%s\n",
               show([cell minDate]),
               str([[cell backgroundColor] description]));
      }

      printf("== range mode\n");
      {
        Recorder *r = [[Recorder alloc] init];
        NSDatePicker *dp = [[NSDatePicker alloc]
          initWithFrame: NSMakeRect(0, 0, 260, 26)];

        [dp setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US"]];
        [dp setTimeZone: [NSTimeZone timeZoneWithName: @"GMT"]];
        [dp setDatePickerElements: NSDatePickerElementFlagYearMonthDay];
        [dp setDateValue: base];
        printf("  single: interval=%f cellSize=%.1fx%.1f\n",
               [dp timeInterval], [[dp cell] cellSize].width,
               [[dp cell] cellSize].height);
        [dp setDatePickerMode: NSDatePickerModeRange];
        printf("  range:  interval=%f cellSize=%.1fx%.1f value=%s\n",
               [dp timeInterval], [[dp cell] cellSize].width,
               [[dp cell] cellSize].height, show([dp dateValue]));
        [dp setTimeInterval: 3.0 * 86400.0];
        printf("  after setTimeInterval: 3 days -> interval=%f value=%s\n",
               [dp timeInterval], show([dp dateValue]));
        printf("  cellSize with an interval = %.1fx%.1f\n",
               [[dp cell] cellSize].width, [[dp cell] cellSize].height);

        [dp setDatePickerStyle: NSDatePickerStyleClockAndCalendar];
        printf("  calendar style range cellSize = %.1fx%.1f\n",
               [[dp cell] cellSize].width, [[dp cell] cellSize].height);
        [dp setDatePickerStyle: NSDatePickerStyleTextFieldAndStepper];

        [[win contentView] addSubview: dp];
        [win makeFirstResponder: dp];
        [dp setTarget: r];
        [dp setAction: @selector(act:)];
        [dp setDelegate: r];
        actionCount = 0;
        [dp keyDown: arrow(NSUpArrowFunctionKey)];
        printf("  up arrow in range mode: value=%s interval=%f actions=%d"
               " validate=%d proposedInterval=%f\n",
               show([dp dateValue]), [dp timeInterval], actionCount,
               r->validateCalls, r->lastInterval);
        [dp keyDown: arrow(NSRightArrowFunctionKey)];
        [dp keyDown: arrow(NSRightArrowFunctionKey)];
        [dp keyDown: arrow(NSRightArrowFunctionKey)];
        [dp keyDown: arrow(NSUpArrowFunctionKey)];
        printf("  three rights then up: value=%s interval=%f\n",
               show([dp dateValue]), [dp timeInterval]);
        [dp keyDown: arrow(NSRightArrowFunctionKey)];
        [dp keyDown: arrow(NSUpArrowFunctionKey)];
        printf("  another right then up: value=%s interval=%f\n",
               show([dp dateValue]), [dp timeInterval]);
        [dp removeFromSuperview];
      }

      printf("== the background and the text colour\n");
      {
        NSDatePicker *dp = [[NSDatePicker alloc]
          initWithFrame: NSMakeRect(0, 0, 200, 26)];

        printf("  default draws=%d bg=%s text=%s bezeled=%d\n",
               [dp drawsBackground],
               str([[dp backgroundColor] description]),
               str([[dp textColor] description]), [dp isBezeled]);
        [dp setDrawsBackground: YES];
        [dp setBackgroundColor: [NSColor redColor]];
        [dp setTextColor: [NSColor greenColor]];
        NSBitmapImageRep *rep = [dp bitmapImageRepForCachingDisplayInRect:
          [dp bounds]];
        [dp cacheDisplayInRect: [dp bounds] toBitmapImageRep: rep];
        NSColor *corner = [[rep colorAtX: 3 y: 3]
          colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
        NSColor *middle = [[rep colorAtX: 100 y: 13]
          colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
        printf("  a red background: corner r=%.2f g=%.2f b=%.2f,"
               " middle r=%.2f g=%.2f b=%.2f\n",
               [corner redComponent], [corner greenComponent],
               [corner blueComponent], [middle redComponent],
               [middle greenComponent], [middle blueComponent]);
        [dp setDrawsBackground: NO];
        [dp cacheDisplayInRect: [dp bounds] toBitmapImageRep: rep];
        corner = [[rep colorAtX: 3 y: 3]
          colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
        printf("  with drawsBackground NO: corner r=%.2f g=%.2f b=%.2f\n",
               [corner redComponent], [corner greenComponent],
               [corner blueComponent]);
      }

      printf("== elements mask again\n");
      {
        NSDatePicker *dp = [[NSDatePicker alloc]
          initWithFrame: NSMakeRect(0, 0, 200, 26)];

        [dp setDatePickerElements: NSDatePickerElementFlagYearMonthDay
          | NSDatePickerElementFlagEra];
        printf("  ymd|era (0x1e0) reads back 0x%lx\n",
               (unsigned long)[dp datePickerElements]);
        [dp setDatePickerElements: NSDatePickerElementFlagEra];
        printf("  era alone (0x100) reads back 0x%lx\n",
               (unsigned long)[dp datePickerElements]);
      }

      printf("done\n");
    }
  return 0;
}
