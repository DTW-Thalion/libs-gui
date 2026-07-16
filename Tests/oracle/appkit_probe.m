/* Apple oracle, pass 3 for NSAppearance.  Pins the whole base-appearance
   mapping that bestMatchFromAppearancesWithNames: falls back to, for every
   named appearance, plus what -name reports for the high contrast ones.
   Apple-only. */
#import <Cocoa/Cocoa.h>
#include <stdio.h>

static void
dumpBest(NSString *ofName, NSArray *names, const char *listTag)
{
  NSAppearance *a = [NSAppearance appearanceNamed: ofName];
  NSString *best = [a bestMatchFromAppearancesWithNames: names];

  printf("  %-30s of %-22s -> %s\n", [[a name] UTF8String], listTag,
         best == nil ? "nil" : [best UTF8String]);
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    NSArray *all = [NSArray arrayWithObjects:
      NSAppearanceNameAqua,
      NSAppearanceNameDarkAqua,
      NSAppearanceNameVibrantLight,
      NSAppearanceNameVibrantDark,
      NSAppearanceNameAccessibilityHighContrastAqua,
      NSAppearanceNameAccessibilityHighContrastDarkAqua,
      NSAppearanceNameAccessibilityHighContrastVibrantLight,
      NSAppearanceNameAccessibilityHighContrastVibrantDark,
      nil];
    NSArray *aquaDark = [NSArray arrayWithObjects: NSAppearanceNameAqua,
      NSAppearanceNameDarkAqua, nil];
    NSUInteger i;

    printf("== what -name reports for each constant ==\n");
    for (i = 0; i < [all count]; i++)
      {
        NSString *n = [all objectAtIndex: i];
        NSAppearance *a = [NSAppearance appearanceNamed: n];

        printf("  constant=%-52s name=%s\n", [n UTF8String],
               [[a name] UTF8String]);
      }

    printf("\n== base appearance: each name against [aqua, darkAqua] ==\n");
    for (i = 0; i < [all count]; i++)
      {
        dumpBest([all objectAtIndex: i], aquaDark, "[aqua,darkAqua]");
      }

    printf("\n== against [aqua] only ==\n");
    for (i = 0; i < [all count]; i++)
      {
        dumpBest([all objectAtIndex: i], [NSArray arrayWithObject:
          NSAppearanceNameAqua], "[aqua]");
      }

    printf("\n== against [darkAqua] only ==\n");
    for (i = 0; i < [all count]; i++)
      {
        dumpBest([all objectAtIndex: i], [NSArray arrayWithObject:
          NSAppearanceNameDarkAqua], "[darkAqua]");
      }

    printf("\n== cross vibrant ==\n");
    dumpBest(NSAppearanceNameVibrantLight, [NSArray arrayWithObject:
      NSAppearanceNameVibrantDark], "[vibrantDark]");
    dumpBest(NSAppearanceNameVibrantDark, [NSArray arrayWithObject:
      NSAppearanceNameVibrantLight], "[vibrantLight]");
    dumpBest(NSAppearanceNameAqua, [NSArray arrayWithObject:
      NSAppearanceNameAqua], "[aqua]");
  }
  return 0;
}
