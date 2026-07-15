/* Apple oracle for the NSRulerMarker coverage test.  Probes the init defaults
   (markerLocation, imageOrigin, image, ruler, movable, removable,
   representedObject), the thicknessRequiredInRuler computation, the plain
   setter round-trips and the nil-argument exceptions.  Portable so the same
   file runs under GNUstep for an A/B. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    NSScrollView *sv =
        [[NSScrollView alloc] initWithFrame: NSMakeRect(0, 0, 200, 200)];
    NSRulerView *rv = [[NSRulerView alloc] initWithScrollView: sv
                                                  orientation: NSHorizontalRuler];
    NSImage *img = [[NSImage alloc] initWithSize: NSMakeSize(20, 16)];

    NSRulerMarker *m = [[NSRulerMarker alloc] initWithRulerView: rv
                                                 markerLocation: 100.0
                                                          image: img
                                                    imageOrigin: NSMakePoint(3, 4)];
    printf("INIT loc=%g imgOrigin=%gx%g imageSame=%d rulerSame=%d movable=%d removable=%d repObj=%s\n",
           [m markerLocation], [m imageOrigin].x, [m imageOrigin].y,
           [m image] == img, [m ruler] == rv, [m isMovable], [m isRemovable],
           [m representedObject] == nil ? "nil" : "set");
    printf("INIT thickness=%g\n", [m thicknessRequiredInRuler]);

    [m setMarkerLocation: 200.0];
    [m setImageOrigin: NSMakePoint(5, 6)];
    [m setMovable: NO];
    [m setRemovable: YES];
    [m setRepresentedObject: @"obj"];
    printf("SET loc=%g imgOrigin=%gx%g movable=%d removable=%d repObj=%s\n",
           [m markerLocation], [m imageOrigin].x, [m imageOrigin].y,
           [m isMovable], [m isRemovable],
           [m representedObject] == nil ? "nil"
             : [[[m representedObject] description] UTF8String]);

    @try
      {
        [[NSRulerMarker alloc] initWithRulerView: nil
                                  markerLocation: 0.0
                                           image: img
                                     imageOrigin: NSZeroPoint];
        printf("EXC nilRuler no-raise\n");
      }
    @catch (NSException *e)
      {
        printf("EXC nilRuler raised %s\n", [[e name] UTF8String]);
      }
    @try
      {
        [[NSRulerMarker alloc] initWithRulerView: rv
                                  markerLocation: 0.0
                                           image: nil
                                     imageOrigin: NSZeroPoint];
        printf("EXC nilImage no-raise\n");
      }
    @catch (NSException *e)
      {
        printf("EXC nilImage raised %s\n", [[e name] UTF8String]);
      }
  }
  return 0;
}
