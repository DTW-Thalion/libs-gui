/* Apple oracle for the NSLayoutConstraint coverage test.  Probes the relation
   / attribute / priority enums, the constraintWithItem:... factory and its
   readonly accessors, the default priority and active state, the constant /
   priority / active / identifier setters and shouldBeArchived.  Portable so
   the same file runs under GNUstep for an A/B. */
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

    NSView *v1 = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 100, 100)];
    NSView *v2 = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 40, 40)];
    [v1 addSubview: v2];

    printf("ENUM rel LE=%d Eq=%d GE=%d\n",
           (int)NSLayoutRelationLessThanOrEqual,
           (int)NSLayoutRelationEqual, (int)NSLayoutRelationGreaterThanOrEqual);
    printf("ENUM attr NotAn=%d Left=%d Width=%d Height=%d CenterX=%d\n",
           (int)NSLayoutAttributeNotAnAttribute, (int)NSLayoutAttributeLeft,
           (int)NSLayoutAttributeWidth, (int)NSLayoutAttributeHeight,
           (int)NSLayoutAttributeCenterX);
    printf("ENUM prio Required=%g High=%g Low=%g\n",
           (double)NSLayoutPriorityRequired, (double)NSLayoutPriorityDefaultHigh,
           (double)NSLayoutPriorityDefaultLow);

    NSLayoutConstraint *c =
        [NSLayoutConstraint constraintWithItem: v1
                                     attribute: NSLayoutAttributeWidth
                                     relatedBy: NSLayoutRelationEqual
                                        toItem: v2
                                     attribute: NSLayoutAttributeWidth
                                    multiplier: 2.0
                                      constant: 5.0];
    printf("FACT first=%d firstAttr=%ld rel=%ld second=%d secondAttr=%ld mult=%g const=%g prio=%g active=%d\n",
           [c firstItem] == v1, (long)[c firstAttribute], (long)[c relation],
           [c secondItem] == v2, (long)[c secondAttribute],
           [c multiplier], [c constant], (double)[c priority], [c isActive]);

    if ([c respondsToSelector: @selector(identifier)])
      printf("ID default=%s\n",
             [c identifier] == nil ? "nil" : [[c identifier] UTF8String]);
    else
      printf("ID default=unavailable\n");
    if ([c respondsToSelector: @selector(shouldBeArchived)])
      printf("ARCH default=%d\n", [c shouldBeArchived]);
    else
      printf("ARCH default=unavailable\n");

    [c setConstant: 42.0];
    [c setPriority: NSLayoutPriorityDefaultHigh];
    if ([c respondsToSelector: @selector(setIdentifier:)])
      [c setIdentifier: @"myC"];
    printf("SET const=%g prio=%g id=%s\n",
           [c constant], (double)[c priority],
           [c respondsToSelector: @selector(identifier)]
             && [c identifier] != nil ? [[c identifier] UTF8String] : "nil");

    [c setActive: NO];
    printf("ACTIVE afterNO=%d\n", [c isActive]);
    [c setActive: YES];
    printf("ACTIVE afterYES=%d\n", [c isActive]);
  }
  return 0;
}
