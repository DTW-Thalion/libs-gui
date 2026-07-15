/* Apple oracle for the NSLayoutConstraint coverage test.  Probes the relation
   / attribute / priority enums, the constraintWithItem:... factory and its
   readonly accessors, the default priority and active state, the priority and
   active setters, and (guarded, since GNUstep may not have them) setConstant:,
   identifier/setIdentifier: and shouldBeArchived.  Portable so the same file
   runs under GNUstep for an A/B. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

/* Declared so the file compiles where GNUstep lacks these; respondsToSelector:
   is what actually reports availability. */
@interface NSLayoutConstraint (OracleCompat)
- (void) setConstant: (CGFloat)c;
- (NSString *) identifier;
- (void) setIdentifier: (NSString *)s;
- (BOOL) shouldBeArchived;
@end

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

    printf("HAS setConstant=%d identifier=%d shouldBeArchived=%d\n",
           [c respondsToSelector: @selector(setConstant:)],
           [c respondsToSelector: @selector(identifier)],
           [c respondsToSelector: @selector(shouldBeArchived)]);
    if ([c respondsToSelector: @selector(identifier)])
      printf("ID default=%s\n",
             [c identifier] == nil ? "nil" : [[c identifier] UTF8String]);
    if ([c respondsToSelector: @selector(shouldBeArchived)])
      printf("ARCH default=%d\n", [c shouldBeArchived]);

    [c setPriority: NSLayoutPriorityDefaultHigh];
    printf("SET prio=%g\n", (double)[c priority]);
    if ([c respondsToSelector: @selector(setConstant:)])
      {
        [c setConstant: 42.0];
        printf("SET const=%g\n", [c constant]);
      }

    [c setActive: NO];
    printf("ACTIVE afterNO=%d\n", [c isActive]);
    [c setActive: YES];
    printf("ACTIVE afterYES=%d\n", [c isActive]);
  }
  return 0;
}
