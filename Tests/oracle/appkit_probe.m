/* Apple oracle for the NSPathComponentCell coverage test.  Probes the init
   defaults (image, URL, title, stringValue), whether setImage:/setURL: keep
   the same object, whether setURL: changes the title, and the setTitle:
   round-trip.  Portable so the same file runs under GNUstep for an A/B. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

static const char *
s(NSString *v)
{
  return v == nil ? "nil" : (const char *)[v UTF8String];
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    NSPathComponentCell *c = [[NSPathComponentCell alloc] init];
    printf("INIT image=%s url=%s title=[%s] stringValue=[%s]\n",
           [c image] == nil ? "nil" : "set",
           [c URL] == nil ? "nil" : "set",
           s([c title]), s([c stringValue]));

    NSImage *img = [[NSImage alloc] initWithSize: NSMakeSize(16, 16)];
    [c setImage: img];
    printf("IMG same=%d nonnil=%d\n", [c image] == img, [c image] != nil);

    NSURL *url = [NSURL fileURLWithPath: @"/tmp/foo"];
    [c setURL: url];
    printf("URL same=%d equal=%d title=[%s] stringValue=[%s]\n",
           [c URL] == url, [[c URL] isEqual: url], s([c title]), s([c stringValue]));

    [c setTitle: @"MyTitle"];
    printf("TITLE title=[%s]\n", s([c title]));
  }
  return 0;
}
