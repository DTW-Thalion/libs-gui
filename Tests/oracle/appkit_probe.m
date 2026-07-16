/* Apple oracle: what NSAppearance writes into a keyed archive, and whether it
   survives the round trip.  Tells us which keys to use rather than inventing
   them.  Apple-only. */
#import <Cocoa/Cocoa.h>
#include <stdio.h>

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    NSAppearance *aqua = [NSAppearance appearanceNamed: NSAppearanceNameAqua];
    NSAppearance *vib = [NSAppearance appearanceNamed:
      NSAppearanceNameVibrantDark];
    NSError *err = nil;
    NSData *data;
    id plist;

    printf("== conformance ==\n");
    printf("CONFORMS NSCoding=%d NSSecureCoding=%d\n",
           [NSAppearance conformsToProtocol: @protocol(NSCoding)],
           [NSAppearance conformsToProtocol: @protocol(NSSecureCoding)]);

    printf("\n== archived aqua ==\n");
    data = [NSKeyedArchiver archivedDataWithRootObject: aqua
                                requiringSecureCoding: NO
                                                error: &err];
    if (data == nil)
      {
        printf("ARCHIVE FAILED: %s\n", [[err description] UTF8String]);
      }
    else
      {
        plist = [NSPropertyListSerialization propertyListWithData: data
                                                          options: 0
                                                           format: NULL
                                                            error: &err];
        printf("PLIST %s\n", [[plist description] UTF8String]);
      }

    printf("\n== round trip ==\n");
    if (data != nil)
      {
        NSAppearance *back = [NSKeyedUnarchiver
          unarchivedObjectOfClass: [NSAppearance class]
                         fromData: data
                            error: &err];

        printf("BACK nonnil=%d name=%s vibrancy=%d\n", back != nil,
               back == nil ? "-" : [[back name] UTF8String],
               back == nil ? -1 : [back allowsVibrancy]);
      }

    printf("\n== archived vibrant dark ==\n");
    data = [NSKeyedArchiver archivedDataWithRootObject: vib
                                requiringSecureCoding: NO
                                                error: &err];
    if (data != nil)
      {
        NSAppearance *back = [NSKeyedUnarchiver
          unarchivedObjectOfClass: [NSAppearance class]
                         fromData: data
                            error: &err];

        printf("BACK nonnil=%d name=%s vibrancy=%d\n", back != nil,
               back == nil ? "-" : [[back name] UTF8String],
               back == nil ? -1 : [back allowsVibrancy]);
      }
  }
  return 0;
}
