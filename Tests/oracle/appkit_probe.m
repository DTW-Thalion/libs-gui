/* Apple oracle for the NSPathCell coverage test.  Probes init defaults
   (pathStyle, backgroundColor, placeholder, allowedTypes, URL, doubleAction,
   pathComponentCells), the +pathComponentCellClass class method, and the
   pathStyle / backgroundColor / placeholderString / allowedTypes / doubleAction
   setters.  Portable so the same file runs under GNUstep for an A/B. */
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

    printf("ENUM Standard=%d NavBar=%d PopUp=%d\n",
           (int)NSPathStyleStandard, (int)NSPathStyleNavigationBar,
           (int)NSPathStylePopUp);

    printf("CLASS pathComponentCellClass=%s\n",
           [NSStringFromClass([NSPathCell pathComponentCellClass]) UTF8String]);

    NSPathCell *pc = [[NSPathCell alloc] init];

    printf("INIT pathStyle=%ld bg=%s placeholder=%s allowedTypes=%s url=%s "
           "doubleAction=%s\n",
           (long)[pc pathStyle],
           [pc backgroundColor] == nil ? "nil" : "set",
           s([pc placeholderString]),
           [pc allowedTypes] == nil ? "nil" : "set",
           [pc URL] == nil ? "nil" : "set",
           sel([pc doubleAction]));
    printf("INIT pcc=%s\n",
           [pc pathComponentCells] == nil ? "nil"
             : [[NSString stringWithFormat: @"count-%lu",
                          (unsigned long)[[pc pathComponentCells] count]] UTF8String]);

    /* Setters. */
    [pc setPathStyle: NSPathStylePopUp];

    NSColor *col = [NSColor redColor];
    [pc setBackgroundColor: col];

    [pc setPlaceholderString: @"choose"];

    NSArray *types = [NSArray arrayWithObject: @"txt"];
    [pc setAllowedTypes: types];

    [pc setDoubleAction: @selector(doubleClick:)];

    printf("SET pathStyle=%ld bgEqual=%d placeholder=%s allowedTypesEqual=%d "
           "doubleAction=%s\n",
           (long)[pc pathStyle],
           [[pc backgroundColor] isEqual: col],
           s([pc placeholderString]),
           [[pc allowedTypes] isEqual: types],
           sel([pc doubleAction]));
  }
  return 0;
}
