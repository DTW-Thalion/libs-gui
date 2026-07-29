#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#include <unistd.h>

static NSWindow *win = nil;
static NSDate *base = nil;
static NSDateFormatter *fmt = nil;
static int actionCount = 0;

@interface Recorder : NSObject
{
@public
  int validateCalls;
  NSDate *lastProposed;
  NSDate *forced;
}
- (void) act: (id)sender;
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
  if (forced != nil)
    {
      *proposed = forced;
    }
}
@end

static NSDatePicker *
freshPicker(NSDatePickerElementFlags elements)
{
  NSDatePicker *dp = [[NSDatePicker alloc]
    initWithFrame: NSMakeRect(0, 0, 260, 26)];

  [dp setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US"]];
  [dp setTimeZone: [NSTimeZone timeZoneWithName: @"GMT"]];
  [dp setCalendar: [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian]];
  [dp setDatePickerElements: elements];
  [dp setDateValue: base];
  [[win contentView] addSubview: dp];
  [win makeFirstResponder: dp];
  return dp;
}

static NSEvent *
keyEvent(NSString *chars, unsigned short code, BOOL function)
{
  return [NSEvent keyEventWithType: NSEventTypeKeyDown
                          location: NSZeroPoint
                     modifierFlags: function
                       ? (NSEventModifierFlagFunction | NSEventModifierFlagNumericPad)
                       : 0
                         timestamp: 0
                      windowNumber: [win windowNumber]
                           context: nil
                        characters: chars
       charactersIgnoringModifiers: chars
                         isARepeat: NO
                           keyCode: code];
}

static NSEvent *
arrow(unichar c)
{
  unsigned short code = 126;

  if (c == NSDownArrowFunctionKey) code = 125;
  else if (c == NSLeftArrowFunctionKey) code = 123;
  else if (c == NSRightArrowFunctionKey) code = 124;
  return keyEvent([NSString stringWithCharacters: &c length: 1], code, YES);
}

static void
sendKey(NSDatePicker *dp, NSEvent *e)
{
  [dp keyDown: e];
}

static const char *
show(NSDatePicker *dp)
{
  return [[fmt stringFromDate: [dp dateValue]] UTF8String];
}

/* Send n right arrows, then one up arrow, and report the resulting date. */
static void
fieldAt(NSDatePickerElementFlags elements, int rights, const char *label)
{
  NSDatePicker *dp = freshPicker(elements);
  int i;

  for (i = 0; i < rights; i++)
    {
      sendKey(dp, arrow(NSRightArrowFunctionKey));
    }
  sendKey(dp, arrow(NSUpArrowFunctionKey));
  printf("  %-40s -> %s\n", label, show(dp));
  [dp removeFromSuperview];
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
      base = [fmt dateFromString: @"2023-03-08 20:26:40"];
      printf("base = %s\n", [[fmt stringFromDate: base] UTF8String]);

      win = [[NSWindow alloc]
        initWithContentRect: NSMakeRect(0, 0, 400, 200)
                  styleMask: NSWindowStyleMaskTitled
                    backing: NSBackingStoreBuffered
                      defer: NO];

      NSDatePickerElementFlags all = NSDatePickerElementFlagYearMonthDay
        | NSDatePickerElementFlagHourMinuteSecond;

      printf("== which field the up arrow changes after N right arrows"
             " (en_US, ymd+hms)\n");
      fieldAt(all, 0, "no right arrow");
      fieldAt(all, 1, "1 right");
      fieldAt(all, 2, "2 rights");
      fieldAt(all, 3, "3 rights");
      fieldAt(all, 4, "4 rights");
      fieldAt(all, 5, "5 rights");
      fieldAt(all, 6, "6 rights (past the end)");
      fieldAt(all, 7, "7 rights");

      printf("== the same with year-month-day only\n");
      fieldAt(NSDatePickerElementFlagYearMonthDay, 0, "no right arrow");
      fieldAt(NSDatePickerElementFlagYearMonthDay, 1, "1 right");
      fieldAt(NSDatePickerElementFlagYearMonthDay, 2, "2 rights");
      fieldAt(NSDatePickerElementFlagYearMonthDay, 3, "3 rights (past the end)");

      printf("== the same with hour-minute-second only\n");
      fieldAt(NSDatePickerElementFlagHourMinuteSecond, 0, "no right arrow");
      fieldAt(NSDatePickerElementFlagHourMinuteSecond, 1, "1 right");
      fieldAt(NSDatePickerElementFlagHourMinuteSecond, 2, "2 rights");

      printf("== the same with year-month only\n");
      fieldAt(NSDatePickerElementFlagYearMonth, 0, "no right arrow");
      fieldAt(NSDatePickerElementFlagYearMonth, 1, "1 right");

      printf("== the same with hour-minute only\n");
      fieldAt(NSDatePickerElementFlagHourMinute, 0, "no right arrow");
      fieldAt(NSDatePickerElementFlagHourMinute, 1, "1 right");

      printf("== left arrow from the first field\n");
      {
        NSDatePicker *dp = freshPicker(all);
        sendKey(dp, arrow(NSLeftArrowFunctionKey));
        sendKey(dp, arrow(NSUpArrowFunctionKey));
        printf("  left then up                             -> %s\n", show(dp));
        [dp removeFromSuperview];
      }

      printf("== a locale whose date order differs (de_DE, ymd only)\n");
      {
        NSDatePicker *dp = freshPicker(NSDatePickerElementFlagYearMonthDay);
        [dp setLocale: [NSLocale localeWithLocaleIdentifier: @"de_DE"]];
        [dp setDateValue: base];
        sendKey(dp, arrow(NSUpArrowFunctionKey));
        printf("  de_DE first field up                     -> %s\n", show(dp));
        [dp removeFromSuperview];
      }

      printf("== typing digits into the first field (month)\n");
      {
        NSDatePicker *dp = freshPicker(all);
        sendKey(dp, keyEvent(@"5", 23, NO));
        printf("  typed 5                                  -> %s\n", show(dp));
        [dp removeFromSuperview];

        dp = freshPicker(all);
        sendKey(dp, keyEvent(@"1", 18, NO));
        printf("  typed 1                                  -> %s\n", show(dp));
        sendKey(dp, keyEvent(@"2", 19, NO));
        printf("  typed 1 then 2                           -> %s\n", show(dp));
        sendKey(dp, arrow(NSUpArrowFunctionKey));
        printf("  then up (still on the month?)            -> %s\n", show(dp));
        [dp removeFromSuperview];

        dp = freshPicker(all);
        sendKey(dp, keyEvent(@"0", 29, NO));
        printf("  typed 0                                  -> %s\n", show(dp));
        [dp removeFromSuperview];

        dp = freshPicker(all);
        sendKey(dp, keyEvent(@"9", 25, NO));
        sendKey(dp, keyEvent(@"9", 25, NO));
        printf("  typed 9 then 9                           -> %s\n", show(dp));
        [dp removeFromSuperview];
      }

      printf("== wrapping at the top of a field\n");
      {
        NSDatePicker *dp = freshPicker(all);
        [dp setDateValue: [fmt dateFromString: @"2023-12-08 20:26:40"]];
        sendKey(dp, arrow(NSUpArrowFunctionKey));
        printf("  december, up on the month                -> %s\n", show(dp));
        [dp removeFromSuperview];

        dp = freshPicker(all);
        [dp setDateValue: [fmt dateFromString: @"2023-01-08 20:26:40"]];
        sendKey(dp, arrow(NSDownArrowFunctionKey));
        printf("  january, down on the month               -> %s\n", show(dp));
        [dp removeFromSuperview];

        dp = freshPicker(all);
        [dp setDateValue: [fmt dateFromString: @"2023-03-31 20:26:40"]];
        sendKey(dp, arrow(NSUpArrowFunctionKey));
        printf("  the 31st, up on the month                -> %s\n", show(dp));
        [dp removeFromSuperview];

        dp = freshPicker(all);
        [dp setDateValue: [fmt dateFromString: @"2023-03-08 23:26:40"]];
        sendKey(dp, arrow(NSRightArrowFunctionKey));
        sendKey(dp, arrow(NSRightArrowFunctionKey));
        sendKey(dp, arrow(NSRightArrowFunctionKey));
        sendKey(dp, arrow(NSUpArrowFunctionKey));
        printf("  23 hours, up on the hour                 -> %s\n", show(dp));
        [dp removeFromSuperview];
      }

      printf("== the arrow keys against the date limits\n");
      {
        NSDatePicker *dp = freshPicker(all);
        [dp setMaxDate: [fmt dateFromString: @"2023-03-20 00:00:00"]];
        sendKey(dp, arrow(NSUpArrowFunctionKey));
        printf("  up on the month with a max of the 20th   -> %s\n", show(dp));
        [dp removeFromSuperview];

        dp = freshPicker(all);
        [dp setMinDate: [fmt dateFromString: @"2023-03-01 00:00:00"]];
        sendKey(dp, arrow(NSDownArrowFunctionKey));
        printf("  down on the month with a min of the 1st  -> %s\n", show(dp));
        [dp removeFromSuperview];
      }

      printf("== target/action and the delegate\n");
      {
        Recorder *r = [[Recorder alloc] init];
        NSDatePicker *dp = freshPicker(all);

        [dp setTarget: r];
        [dp setAction: @selector(act:)];
        [dp setDelegate: r];
        actionCount = 0;
        [dp setDateValue: [fmt dateFromString: @"2023-05-08 20:26:40"]];
        printf("  actions after setDateValue:              %d (validate calls %d)\n",
               actionCount, r->validateCalls);
        sendKey(dp, arrow(NSUpArrowFunctionKey));
        printf("  after one up arrow: value %s actions %d validate %d proposed %s\n",
               show(dp), actionCount, r->validateCalls,
               r->lastProposed ? [[fmt stringFromDate: r->lastProposed] UTF8String]
                               : "(nil)");
        r->forced = [fmt dateFromString: @"1999-09-09 09:09:09"];
        sendKey(dp, arrow(NSUpArrowFunctionKey));
        printf("  delegate substitutes a date: value       -> %s\n", show(dp));
        [dp removeFromSuperview];
      }

      printf("== the calendar style and the keyboard\n");
      {
        NSDatePicker *dp = [[NSDatePicker alloc]
          initWithFrame: NSMakeRect(0, 0, 280, 150)];
        [dp setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US"]];
        [dp setTimeZone: [NSTimeZone timeZoneWithName: @"GMT"]];
        [dp setDatePickerStyle: NSDatePickerStyleClockAndCalendar];
        [dp setDateValue: base];
        [[win contentView] addSubview: dp];
        [win makeFirstResponder: dp];
        printf("  acceptsFirstResponder=%d firstResponder=%s\n",
               [dp acceptsFirstResponder],
               class_getName([[win firstResponder] class]));
        sendKey(dp, arrow(NSUpArrowFunctionKey));
        printf("  up arrow                                 -> %s\n", show(dp));
        sendKey(dp, arrow(NSRightArrowFunctionKey));
        printf("  right arrow                              -> %s\n", show(dp));
        [dp removeFromSuperview];
      }

      printf("== text field style and the keyboard\n");
      {
        NSDatePicker *dp = freshPicker(all);
        [dp setDatePickerStyle: NSDatePickerStyleTextField];
        sendKey(dp, arrow(NSUpArrowFunctionKey));
        printf("  up arrow                                 -> %s\n", show(dp));
        [dp removeFromSuperview];
      }

      fflush(stdout);

      printf("== mouse (watchdog armed)\n");
      alarm(25);
      {
        NSDatePicker *dp = freshPicker(NSDatePickerElementFlagYearMonthDay);
        NSRect f = [dp frame];
        NSPoint p = NSMakePoint(NSMinX(f) + 6, NSMidY(f));
        NSEvent *upEv = [NSEvent mouseEventWithType: NSEventTypeLeftMouseUp
                                           location: p
                                      modifierFlags: 0
                                          timestamp: 0
                                       windowNumber: [win windowNumber]
                                            context: nil
                                        eventNumber: 2
                                         clickCount: 1
                                           pressure: 0.0];
        NSEvent *downEv = [NSEvent mouseEventWithType: NSEventTypeLeftMouseDown
                                             location: p
                                        modifierFlags: 0
                                            timestamp: 0
                                         windowNumber: [win windowNumber]
                                              context: nil
                                          eventNumber: 1
                                           clickCount: 1
                                             pressure: 1.0];
        [NSApp postEvent: upEv atStart: NO];
        printf("  before the click: %s\n", show(dp));
        fflush(stdout);
        [dp mouseDown: downEv];
        printf("  after a click near the left edge: %s\n", show(dp));
        sendKey(dp, arrow(NSUpArrowFunctionKey));
        printf("  then up arrow: %s\n", show(dp));
        fflush(stdout);
      }
      printf("done\n");
    }
  return 0;
}
