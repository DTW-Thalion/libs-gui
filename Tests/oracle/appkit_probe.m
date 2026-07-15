/* Apple oracle for the NSPathControlItem coverage test.  Probes init defaults
   (URL, title, attributedTitle, image), whether the class responds to the
   setters GNUstep adds, and setter round-trips where present.  Portable so the
   same file runs under GNUstep for an A/B. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

@interface NSPathControlItem (OracleCompat)
- (void) setURL: (NSURL *)url;
- (void) setTitle: (NSString *)title;
- (void) setAttributedTitle: (NSAttributedString *)s;
- (void) setImage: (NSImage *)image;
@end

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

    NSPathControlItem *it = [[NSPathControlItem alloc] init];

    printf("INIT url=%s title=%s attrTitle=%s image=%s\n",
           [it URL] == nil ? "nil" : "set",
           s([it title]),
           [it attributedTitle] == nil ? "nil" : "set",
           [it image] == nil ? "nil" : "set");

    printf("RESP setURL=%d setTitle=%d setAttributedTitle=%d setImage=%d\n",
           [it respondsToSelector: @selector(setURL:)],
           [it respondsToSelector: @selector(setTitle:)],
           [it respondsToSelector: @selector(setAttributedTitle:)],
           [it respondsToSelector: @selector(setImage:)]);

    if ([it respondsToSelector: @selector(setURL:)])
      {
        NSURL *u = [NSURL fileURLWithPath: @"/tmp/foo"];
        [it setURL: u];
        printf("SET url urlEqual=%d\n", [[it URL] isEqual: u]);
      }

    if ([it respondsToSelector: @selector(setTitle:)])
      {
        [it setTitle: @"hello"];
        printf("SET title title=%s attrTitleString=%s\n",
               s([it title]), s([[it attributedTitle] string]));
      }

    if ([it respondsToSelector: @selector(setAttributedTitle:)])
      {
        NSAttributedString *a =
            [[NSAttributedString alloc] initWithString: @"world"];
        [it setAttributedTitle: a];
        printf("SET attrTitle title=%s attrTitleString=%s\n",
               s([it title]), s([[it attributedTitle] string]));
      }
  }
  return 0;
}
