/* Probe of real Apple AppKit behaviour for the coverage tests added in
   PRs #472-#475.  Compiled on a macOS Actions runner against -framework
   Cocoa to establish the correct contract, so GNUstep divergences can be
   classified as quirks vs bugs.
*/
#import <Cocoa/Cocoa.h>

int main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    /* ---- NSSecureTextFieldCell / NSSecureTextField ---- */
    NSSecureTextFieldCell *sc = [[NSSecureTextFieldCell alloc] init];
    printf("SEC cell default echosBullets = %d\n", [sc echosBullets]);

    NSSecureTextField *sf = [[NSSecureTextField alloc] initWithFrame: NSMakeRect(0,0,100,22)];
    printf("SEC field default echosBullets = %d\n", [sf echosBullets]);

    NSSecureTextFieldCell *cc = [[NSSecureTextFieldCell alloc] init];
    [cc setEchosBullets: NO];
    NSData *dc = [NSKeyedArchiver archivedDataWithRootObject: cc requiringSecureCoding: NO error: NULL];
    NSSecureTextFieldCell *cc2 = [NSKeyedUnarchiver unarchivedObjectOfClass: [NSSecureTextFieldCell class] fromData: dc error: NULL];
    printf("SEC cell archive(NO) -> echosBullets = %d\n", [cc2 echosBullets]);

    NSSecureTextField *ff = [[NSSecureTextField alloc] initWithFrame: NSMakeRect(0,0,100,22)];
    [ff setEchosBullets: NO];
    NSData *df = [NSKeyedArchiver archivedDataWithRootObject: ff requiringSecureCoding: NO error: NULL];
    NSSecureTextField *ff2 = [NSKeyedUnarchiver unarchivedObjectOfClass: [NSSecureTextField class] fromData: df error: NULL];
    printf("SEC field archive(NO) -> echosBullets = %d\n", [ff2 echosBullets]);

    @try {
      [NSSecureTextField setCellClass: [NSTextFieldCell class]];
      printf("SEC setCellClass: accepted (no exception)\n");
    } @catch (NSException *e) {
      printf("SEC setCellClass: raises %s\n", [[e name] UTF8String]);
    }

    /* ---- NSStepperCell ---- */
    NSStepperCell *s = [[NSStepperCell alloc] init];
    printf("STEP defaults: min=%g max=%g inc=%g wraps=%d autorep=%d value=%g align=%ld\n",
           [s minValue], [s maxValue], [s increment], [s valueWraps],
           [s autorepeat], [s doubleValue], (long)[s alignment]);

    NSStepperCell *sca = [[NSStepperCell alloc] init]; /* 0..59 */
    [sca setObjectValue: [NSNumber numberWithDouble: 100]];
    printf("STEP setObj 100 -> %g\n", [sca doubleValue]);
    [sca setObjectValue: [NSNumber numberWithDouble: -5]];
    printf("STEP setObj -5 -> %g\n", [sca doubleValue]);
    @try {
      [sca setObjectValue: [NSArray array]];
      printf("STEP setObj array -> %g\n", [sca doubleValue]);
    } @catch (NSException *e) { printf("STEP setObj array EXC %s\n", [[e name] UTF8String]); }
    @try {
      [sca setObjectValue: nil];
      printf("STEP setObj nil -> %g\n", [sca doubleValue]);
    } @catch (NSException *e) { printf("STEP setObj nil EXC %s\n", [[e name] UTF8String]); }

    NSStepperCell *smm = [[NSStepperCell alloc] init];
    [smm setMinValue: 50]; [smm setMaxValue: 10];
    [smm setObjectValue: [NSNumber numberWithDouble: 30]];
    printf("STEP min50/max10 setObj 30 -> %g\n", [smm doubleValue]);

    NSStepperCell *smc = [[NSStepperCell alloc] init];
    [smc setDoubleValue: 40]; [smc setMaxValue: 10];
    printf("STEP setDouble40 setMax10 -> %g\n", [smc doubleValue]);

    /* ---- NSFormCell ---- */
    NSFormCell *fc = [[NSFormCell alloc] init];
    printf("FORM default title='%s' titleAlign=%ld entryAlign=%ld writingDir=%ld editable=%d bezeled=%d\n",
           [[fc title] UTF8String], (long)[fc titleAlignment], (long)[fc alignment],
           (long)[fc titleBaseWritingDirection], [fc isEditable], [fc isBezeled]);

    [fc setTitleWidth: 123];
    printf("FORM manual titleWidth=%g titleWidth:(500)=%g\n",
           [fc titleWidth], [fc titleWidth: NSMakeSize(500,20)]);
    [fc setTitleWidth: -1];
    double nat = [fc titleWidth];
    printf("FORM auto titleWidth=%g titleWidth:(1)=%g titleWidth:(nat+1000)=%g\n",
           nat, [fc titleWidth: NSMakeSize(1,20)], [fc titleWidth: NSMakeSize(nat+1000,20)]);

    NSFormCell *fm = [[NSFormCell alloc] init];
    [fm setTitleWithMnemonic: @"&File"];
    printf("FORM setTitleWithMnemonic &File -> '%s'\n", [[fm title] UTF8String]);

    /* ---- NSPrintInfo ---- */
    NSPrintInfo *pi = [[NSPrintInfo alloc] initWithDictionary: [NSDictionary dictionary]];
    printf("PRINT default orient=%ld hpag=%ld vpag=%ld hc=%d vc=%d job='%s' paper='%s'\n",
           (long)[pi orientation], (long)[pi horizontalPagination], (long)[pi verticalPagination],
           [pi isHorizontallyCentered], [pi isVerticallyCentered],
           [[pi jobDisposition] UTF8String], [[pi paperName] UTF8String]);

    NSPrintInfo *pp = [[NSPrintInfo alloc] initWithDictionary: [NSDictionary dictionary]];
    [pp setPaperSize: NSMakeSize(800,400)];
    printf("PRINT setPaperSize 800x400 -> orient=%ld size=%s\n",
           (long)[pp orientation], [NSStringFromSize([pp paperSize]) UTF8String]);
    [pp setPaperSize: NSMakeSize(300,900)];
    printf("PRINT setPaperSize 300x900 -> orient=%ld\n", (long)[pp orientation]);

    NSPrintInfo *po = [[NSPrintInfo alloc] initWithDictionary: [NSDictionary dictionary]];
    [po setPaperSize: NSMakeSize(400,800)];
    [po setOrientation: NSPaperOrientationLandscape];
    printf("PRINT portrait 400x800 setOrientation landscape -> size=%s\n",
           [NSStringFromSize([po paperSize]) UTF8String]);

    printf("DONE\n");
  }
  return 0;
}
