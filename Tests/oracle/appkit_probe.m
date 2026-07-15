/* Apple oracle for NSLayoutAnchor.  Probes the class hierarchy, whether NSView
   vends anchors (leadingAnchor/widthAnchor/...), the constraints those anchors
   build (attribute, constant, relation, multiplier), and the behaviour of the
   base-class constraintEqualToAnchor:constant: (does it honour the constant?).
   Portable so the same file runs under GNUstep for an A/B. */
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

    printf("HIER dimIsAnchor=%d xIsAnchor=%d yIsAnchor=%d copying=%d coding=%d\n",
           [NSLayoutDimension isSubclassOfClass: [NSLayoutAnchor class]],
           [NSLayoutXAxisAnchor isSubclassOfClass: [NSLayoutAnchor class]],
           [NSLayoutYAxisAnchor isSubclassOfClass: [NSLayoutAnchor class]],
           [NSLayoutAnchor conformsToProtocol: @protocol(NSCopying)],
           [NSLayoutAnchor conformsToProtocol: @protocol(NSCoding)]);

    NSView *v = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 100, 100)];
    NSView *v2 = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 100, 100)];

    printf("VIEW leadingAnchor=%d widthAnchor=%d topAnchor=%d\n",
           [v respondsToSelector: @selector(leadingAnchor)],
           [v respondsToSelector: @selector(widthAnchor)],
           [v respondsToSelector: @selector(topAnchor)]);

    if ([v respondsToSelector: @selector(widthAnchor)])
      {
        NSLayoutConstraint *w = [[v widthAnchor] constraintEqualToConstant: 50];
        printf("WIDTH firstAttr=%ld secondItem=%s secondAttr=%ld const=%g rel=%ld mult=%g\n",
               (long)[w firstAttribute],
               [w secondItem] == nil ? "nil" : "set",
               (long)[w secondAttribute], [w constant], (long)[w relation],
               [w multiplier]);

        NSLayoutConstraint *lead =
            [[v leadingAnchor] constraintEqualToAnchor: [v2 leadingAnchor]
                                              constant: 8];
        printf("LEAD firstAttr=%ld secondAttr=%ld const=%g rel=%ld mult=%g\n",
               (long)[lead firstAttribute], (long)[lead secondAttribute],
               [lead constant], (long)[lead relation], [lead multiplier]);
      }

    /* Directly-instantiated base anchor: does the Equal+constant variant honour
       the constant?  (Apple discourages direct instantiation; guard it.) */
    NS_DURING
      {
        NSLayoutAnchor *a = [[NSLayoutAnchor alloc] init];
        NSLayoutConstraint *e = [a constraintEqualToAnchor: a constant: 10];
        NSLayoutConstraint *g =
            [a constraintGreaterThanOrEqualToAnchor: a constant: 10];
        printf("DIRECT equalConst=%g gteConst=%g\n", [e constant], [g constant]);
      }
    NS_HANDLER
      printf("DIRECT raised=%s\n", [[localException name] UTF8String]);
    NS_ENDHANDLER
  }
  return 0;
}
