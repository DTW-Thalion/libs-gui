/* The actual string values behind the NSAppearanceName constants. */
#import <Cocoa/Cocoa.h>

#define SHOW(c) printf("  %-52s = \"%s\"\n", #c, [(NSString *)c UTF8String])

int main(void)
{
  setbuf(stdout, NULL);
  @autoreleasepool
    {
      printf("== NSAppearanceName constant values ==\n");
      SHOW(NSAppearanceNameAqua);
      SHOW(NSAppearanceNameDarkAqua);
      SHOW(NSAppearanceNameVibrantLight);
      SHOW(NSAppearanceNameVibrantDark);
      SHOW(NSAppearanceNameAccessibilityHighContrastAqua);
      SHOW(NSAppearanceNameAccessibilityHighContrastDarkAqua);
      SHOW(NSAppearanceNameAccessibilityHighContrastVibrantLight);
      SHOW(NSAppearanceNameAccessibilityHighContrastVibrantDark);

      /* Whether an appearance can actually be looked up by its own name. */
      printf("== +appearanceNamed: round trip ==\n");
      NSArray *names = @[ NSAppearanceNameAqua,
                          NSAppearanceNameDarkAqua,
                          NSAppearanceNameAccessibilityHighContrastAqua,
                          NSAppearanceNameAccessibilityHighContrastDarkAqua ];
      for (NSString *n in names)
        {
          NSAppearance *a = [NSAppearance appearanceNamed: n];
          printf("  %-52s -> %s\n", [n UTF8String],
                 a ? [[a name] UTF8String] : "(nil)");
        }
      printf("== done ==\n");
    }
  return 0;
}
