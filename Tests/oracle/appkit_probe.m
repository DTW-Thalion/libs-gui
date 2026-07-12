/* Probe of real Apple AppKit behaviour for the coverage tests added in
   PRs #472-#475.  Compiled on a macOS Actions runner against -framework
   Cocoa to establish the correct contract, so GNUstep divergences can be
   classified as quirks vs bugs.  Each scenario is wrapped so one failure
   does not hide the rest.
*/
#import <Cocoa/Cocoa.h>

#define TRY(name, body) do { \
  @try { body } \
  @catch (NSException *e) { printf("%s: EXCEPTION %s (%s)\n", name, \
    [[e name] UTF8String], [[e reason] UTF8String]); } \
} while (0)

int main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    TRY("app", { [NSApplication sharedApplication]; });

    /* ---- NSSecureTextFieldCell / NSSecureTextField ---- */
    TRY("SEC cell default", {
      NSSecureTextFieldCell *c = [[NSSecureTextFieldCell alloc] init];
      printf("SEC cell default echosBullets = %d\n", [c echosBullets]);
    });
    TRY("SEC field default", {
      NSSecureTextField *f = [[NSSecureTextField alloc] initWithFrame: NSMakeRect(0,0,100,22)];
      printf("SEC field default echosBullets = %d\n", [f echosBullets]);
    });
    TRY("SEC cell archive NO", {
      NSSecureTextFieldCell *c = [[NSSecureTextFieldCell alloc] init];
      [c setEchosBullets: NO];
      NSData *d = [NSKeyedArchiver archivedDataWithRootObject: c requiringSecureCoding: NO error: NULL];
      NSSecureTextFieldCell *c2 = [NSKeyedUnarchiver unarchivedObjectOfClass: [NSSecureTextFieldCell class] fromData: d error: NULL];
      printf("SEC cell archive(NO) -> echosBullets = %d\n", [c2 echosBullets]);
    });
    TRY("SEC field archive NO", {
      NSSecureTextField *f = [[NSSecureTextField alloc] initWithFrame: NSMakeRect(0,0,100,22)];
      [f setEchosBullets: NO];
      NSData *d = [NSKeyedArchiver archivedDataWithRootObject: f requiringSecureCoding: NO error: NULL];
      NSSecureTextField *f2 = [NSKeyedUnarchiver unarchivedObjectOfClass: [NSSecureTextField class] fromData: d error: NULL];
      printf("SEC field archive(NO) -> echosBullets = %d\n", [f2 echosBullets]);
    });
    TRY("SEC setCellClass", {
      @try { [NSSecureTextField setCellClass: [NSTextFieldCell class]];
             printf("SEC setCellClass: accepted (no exception)\n"); }
      @catch (NSException *e) { printf("SEC setCellClass: raises %s\n", [[e name] UTF8String]); }
    });

    /* ---- NSStepperCell ---- */
    TRY("STEP defaults", {
      NSStepperCell *s = [[NSStepperCell alloc] init];
      printf("STEP defaults: min=%g max=%g inc=%g wraps=%d autorep=%d value=%g align=%ld\n",
             [s minValue], [s maxValue], [s increment], [s valueWraps],
             [s autorepeat], [s doubleValue], (long)[s alignment]);
    });
    TRY("STEP clamp", {
      NSStepperCell *s = [[NSStepperCell alloc] init]; /* 0..59 */
      [s setObjectValue: [NSNumber numberWithDouble: 100]];
      printf("STEP setObj 100 -> %g\n", [s doubleValue]);
      [s setObjectValue: [NSNumber numberWithDouble: -5]];
      printf("STEP setObj -5 -> %g\n", [s doubleValue]);
      [s setObjectValue: [NSArray array]];
      printf("STEP setObj array -> %g\n", [s doubleValue]);
      [s setObjectValue: nil];
      printf("STEP setObj nil -> %g\n", [s doubleValue]);
    });
    TRY("STEP min>max", {
      NSStepperCell *s = [[NSStepperCell alloc] init];
      [s setMinValue: 50]; [s setMaxValue: 10];
      [s setObjectValue: [NSNumber numberWithDouble: 30]];
      printf("STEP min50/max10 setObj 30 -> %g\n", [s doubleValue]);
    });
    TRY("STEP setMax clamp", {
      NSStepperCell *s = [[NSStepperCell alloc] init];
      [s setDoubleValue: 40]; [s setMaxValue: 10];
      printf("STEP setDouble40 setMax10 -> %g\n", [s doubleValue]);
    });

    /* ---- NSFormCell ---- */
    TRY("FORM defaults", {
      NSFormCell *fc = [[NSFormCell alloc] init];
      printf("FORM default title='%s' titleAlign=%ld entryAlign=%ld writingDir=%ld editable=%d bezeled=%d\n",
             [[fc title] UTF8String], (long)[fc titleAlignment], (long)[fc alignment],
             (long)[fc titleBaseWritingDirection], [fc isEditable], [fc isBezeled]);
    });
    TRY("FORM titleWidth", {
      NSFormCell *fc = [[NSFormCell alloc] init];
      [fc setTitleWidth: 123];
      printf("FORM manual titleWidth=%g titleWidth:(500)=%g\n",
             [fc titleWidth], [fc titleWidth: NSMakeSize(500,20)]);
      [fc setTitleWidth: -1];
      double nat = [fc titleWidth];
      printf("FORM auto titleWidth=%g titleWidth:(1)=%g titleWidth:(nat+1000)=%g\n",
             nat, [fc titleWidth: NSMakeSize(1,20)], [fc titleWidth: NSMakeSize(nat+1000,20)]);
    });
    TRY("FORM mnemonic", {
      NSFormCell *fc = [[NSFormCell alloc] init];
      [fc setTitleWithMnemonic: @"&File"];
      printf("FORM setTitleWithMnemonic &File -> '%s'\n", [[fc title] UTF8String]);
    });

    /* ---- NSPrintInfo ---- */
    TRY("PRINT defaults", {
      NSPrintInfo *pi = [[NSPrintInfo alloc] initWithDictionary: [NSDictionary dictionary]];
      printf("PRINT default orient=%ld hpag=%ld vpag=%ld hc=%d vc=%d job='%s' paper='%s'\n",
             (long)[pi orientation], (long)[pi horizontalPagination], (long)[pi verticalPagination],
             [pi isHorizontallyCentered], [pi isVerticallyCentered],
             [[pi jobDisposition] UTF8String], [[pi paperName] UTF8String]);
    });
    TRY("PRINT setPaperSize", {
      NSPrintInfo *pi = [[NSPrintInfo alloc] initWithDictionary: [NSDictionary dictionary]];
      [pi setPaperSize: NSMakeSize(800,400)];
      printf("PRINT setPaperSize 800x400 -> orient=%ld size=%s\n",
             (long)[pi orientation], [NSStringFromSize([pi paperSize]) UTF8String]);
      [pi setPaperSize: NSMakeSize(300,900)];
      printf("PRINT setPaperSize 300x900 -> orient=%ld\n", (long)[pi orientation]);
    });
    TRY("PRINT setOrientation swap", {
      NSPrintInfo *pi = [[NSPrintInfo alloc] initWithDictionary: [NSDictionary dictionary]];
      [pi setPaperSize: NSMakeSize(400,800)];
      [pi setOrientation: NSPaperOrientationLandscape];
      printf("PRINT portrait 400x800 setOrientation landscape -> size=%s\n",
             [NSStringFromSize([pi paperSize]) UTF8String]);
    });

    printf("DONE\n");
  }
  return 0;
}
