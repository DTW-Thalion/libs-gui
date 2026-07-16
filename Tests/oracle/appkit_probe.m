/* Apple oracle for NSLayoutGuide.  Probes init defaults, whether the guide
   vends anchors (and what attribute/item they carry), NSView's layout-guide
   support (addLayoutGuide:/layoutGuides and owningView wiring), and the
   identifier copy semantics.  Portable so the same file runs under GNUstep. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

static const char *
cls(id o)
{
  return o == nil ? "nil" : (const char *)[NSStringFromClass([o class]) UTF8String];
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    NSLayoutGuide *g = [[NSLayoutGuide alloc] init];
    NSRect f = [g frame];
    printf("INIT frameW=%g frameH=%g owningView=%s identifier=%s ambiguous=%d\n",
           f.size.width, f.size.height,
           [g owningView] == nil ? "nil" : "set",
           [g identifier] == nil ? "nil" : "set",
           [g hasAmbiguousLayout]);

    printf("ANCHORS leading=%s trailing=%s top=%s bottom=%s width=%s height=%s centerX=%s centerY=%s\n",
           cls([g leadingAnchor]), cls([g trailingAnchor]),
           cls([g topAnchor]), cls([g bottomAnchor]),
           cls([g widthAnchor]), cls([g heightAnchor]),
           cls([g centerXAnchor]), cls([g centerYAnchor]));

    if ([g widthAnchor] != nil)
      {
        NSLayoutConstraint *w = [[g widthAnchor] constraintEqualToConstant: 10];
        printf("WIDTHC firstItemIsGuide=%d firstAttr=%ld const=%g\n",
               [w firstItem] == g, (long)[w firstAttribute], [w constant]);
      }
    else
      printf("WIDTHC unavailable\n");

    NSView *v = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 100, 100)];
    printf("VIEW respAdd=%d respGuides=%d respRemove=%d\n",
           [v respondsToSelector: @selector(addLayoutGuide:)],
           [v respondsToSelector: @selector(layoutGuides)],
           [v respondsToSelector: @selector(removeLayoutGuide:)]);

    if ([v respondsToSelector: @selector(addLayoutGuide:)])
      {
        [v addLayoutGuide: g];
        printf("ADD owningViewIsV=%d inGuides=%d guideCount=%lu\n",
               [g owningView] == v,
               [[v layoutGuides] containsObject: g],
               (unsigned long)[[v layoutGuides] count]);
      }

    NSMutableString *ms = [NSMutableString stringWithString: @"id1"];
    [g setIdentifier: ms];
    [ms appendString: @"X"];
    printf("IDENT afterMutate=%s\n", [[g identifier] UTF8String]);
  }
  return 0;
}
