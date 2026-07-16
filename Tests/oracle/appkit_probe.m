/* Apple oracle for NSTableCellView, NSAppearance and NSDataAsset.  Probes the
   enumeration values (NSTableViewRowSizeStyle and NSBackgroundStyle), the init
   defaults, the setter round-trips, what appearanceNamed: does with a real and
   a bogus name, and what a data asset with no asset catalog does.  Portable so
   the same file runs under GNUstep for an A/B. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

#define SECTION(NAME) \
  printf("\n== " NAME " ==\n"); \
  @try {

#define ENDSECTION \
  } @catch (NSException *e) { \
    printf("EXCEPTION %s: %s\n", [[e name] UTF8String], \
           [[e reason] UTF8String]); \
  }

static const char *
nilstr(id o)
{
  return o == nil ? "nil" : "set";
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    SECTION("enums")
    printf("ROWSIZE default=%ld custom=%ld small=%ld medium=%ld large=%ld\n",
           (long)NSTableViewRowSizeStyleDefault,
           (long)NSTableViewRowSizeStyleCustom,
           (long)NSTableViewRowSizeStyleSmall,
           (long)NSTableViewRowSizeStyleMedium,
           (long)NSTableViewRowSizeStyleLarge);
    printf("BGSTYLE normal=%ld emphasized=%ld raised=%ld lowered=%ld\n",
           (long)NSBackgroundStyleNormal,
           (long)NSBackgroundStyleEmphasized,
           (long)NSBackgroundStyleRaised,
           (long)NSBackgroundStyleLowered);
    ENDSECTION

    SECTION("NSTableCellView init")
    NSTableCellView *v = [[NSTableCellView alloc] initWithFrame:
      NSMakeRect(0, 0, 100, 20)];

    printf("INIT objectValue=%s imageView=%s textField=%s\n",
           nilstr([v objectValue]), nilstr([v imageView]),
           nilstr([v textField]));
    printf("INIT rowSizeStyle=%ld backgroundStyle=%ld\n",
           (long)[v rowSizeStyle], (long)[v backgroundStyle]);

    NSTableCellView *z = [[NSTableCellView alloc] init];
    printf("PLAININIT rowSizeStyle=%ld backgroundStyle=%ld frameW=%g\n",
           (long)[z rowSizeStyle], (long)[z backgroundStyle],
           (double)[z frame].size.width);
    ENDSECTION

    SECTION("NSTableCellView round trips")
    NSTableCellView *v = [[NSTableCellView alloc] initWithFrame:
      NSMakeRect(0, 0, 100, 20)];
    NSTextField *tf = [[NSTextField alloc] initWithFrame:
      NSMakeRect(0, 0, 50, 20)];
    NSImageView *iv = [[NSImageView alloc] initWithFrame:
      NSMakeRect(0, 0, 20, 20)];
    NSString *obj = @"value";

    [v setObjectValue: obj];
    [v setTextField: tf];
    [v setImageView: iv];
    [v setRowSizeStyle: NSTableViewRowSizeStyleMedium];
    [v setBackgroundStyle: NSBackgroundStyleEmphasized];
    printf("SET objectValueSame=%d textFieldSame=%d imageViewSame=%d\n",
           [v objectValue] == obj, [v textField] == tf, [v imageView] == iv);
    printf("SET rowSizeStyle=%ld backgroundStyle=%ld\n",
           (long)[v rowSizeStyle], (long)[v backgroundStyle]);
    ENDSECTION

    SECTION("NSAppearance named")
    NSAppearance *aqua = [NSAppearance appearanceNamed: NSAppearanceNameAqua];

    printf("AQUACONST value=%s\n", [NSAppearanceNameAqua UTF8String]);
    printf("AQUA nonnil=%d name=%s vibrancy=%d\n",
           aqua != nil, [[aqua name] UTF8String], [aqua allowsVibrancy]);

    NSAppearance *vib = [NSAppearance appearanceNamed:
      NSAppearanceNameVibrantLight];
    printf("VIBRANTLIGHT nonnil=%d name=%s vibrancy=%d\n",
           vib != nil, [[vib name] UTF8String], [vib allowsVibrancy]);

    NSAppearance *bogus = [NSAppearance appearanceNamed: @"NotAnAppearance"];
    printf("BOGUS result=%s name=%s\n", nilstr(bogus),
           bogus == nil ? "-" : [[bogus name] UTF8String]);
    ENDSECTION

    SECTION("NSAppearance current")
    NSAppearance *aqua = [NSAppearance appearanceNamed: NSAppearanceNameAqua];
    NSAppearance *before = [NSAppearance currentAppearance];

    printf("CURRENT beforeSet=%s\n", nilstr(before));
    [NSAppearance setCurrentAppearance: aqua];
    printf("CURRENT afterSet=%s same=%d\n",
           nilstr([NSAppearance currentAppearance]),
           [NSAppearance currentAppearance] == aqua);
    ENDSECTION

    SECTION("NSAppearance bestMatch")
    NSAppearance *aqua = [NSAppearance appearanceNamed: NSAppearanceNameAqua];
    NSArray *names = [NSArray arrayWithObjects: NSAppearanceNameAqua,
      NSAppearanceNameDarkAqua, nil];

    printf("BESTMATCH result=%s\n",
           [aqua bestMatchFromAppearancesWithNames: names] == nil ? "nil"
             : [[aqua bestMatchFromAppearancesWithNames: names] UTF8String]);
    ENDSECTION

    SECTION("NSDataAsset")
    NSDataAsset *a = [[NSDataAsset alloc] initWithName: @"NoSuchAsset"];

    printf("MISSING result=%s\n", nilstr(a));
    if (a != nil)
      {
        printf("MISSING name=%s data=%s typeIdentifier=%s\n",
               [[a name] UTF8String], nilstr([a data]),
               nilstr([a typeIdentifier]));
      }

    NSDataAsset *b = [[NSDataAsset alloc] initWithName: @"NoSuchAsset"
                                                bundle: [NSBundle mainBundle]];
    printf("MISSING-BUNDLE result=%s\n", nilstr(b));
    ENDSECTION
  }
  return 0;
}
