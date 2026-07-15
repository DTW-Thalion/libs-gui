/* Apple oracle for the NSActionCell coverage test.  Probes init defaults
   (tag, target, action, controlView, enabled, bordered, bezeled), the
   tag/target/action setters, the bezel/border mutual exclusion, and
   setEnabled:.  Portable so the same file runs under GNUstep for an A/B. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

static const char *
sel(SEL v)
{
  return v == NULL ? "NULL" : (const char *)[NSStringFromSelector(v) UTF8String];
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    NSActionCell *c = [[NSActionCell alloc] init];

    printf("INIT tag=%ld target=%s action=%s cv=%s enabled=%d bordered=%d bezeled=%d\n",
           (long)[c tag],
           [c target] == nil ? "nil" : "set",
           sel([c action]),
           [c controlView] == nil ? "nil" : "set",
           [c isEnabled], [c isBordered], [c isBezeled]);

    /* tag / target / action setters. */
    [c setTag: 42];
    id t = [NSObject new];
    [c setTarget: t];
    [c setAction: @selector(fire:)];
    printf("SET tag=%ld targetSame=%d action=%s\n",
           (long)[c tag], [c target] == t, sel([c action]));

    /* Bezel/border mutual exclusion. */
    [c setBezeled: YES];
    printf("BEZEL setBezeledYES bezeled=%d bordered=%d\n",
           [c isBezeled], [c isBordered]);
    [c setBordered: YES];
    printf("BORDER setBorderedYES bezeled=%d bordered=%d\n",
           [c isBezeled], [c isBordered]);

    /* Enabled. */
    [c setEnabled: NO];
    printf("ENABLED setEnabledNO enabled=%d\n", [c isEnabled]);
  }
  return 0;
}
