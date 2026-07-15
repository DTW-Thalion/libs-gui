/* Apple oracle for the NSPathControl coverage test.  Probes the NSPathStyle
   enum, the init defaults (pathStyle, URL, pathItems, allowedTypes,
   doubleAction, placeholderString, editable) and the pathStyle / URL /
   placeholderString setters.  Portable so the same file runs under GNUstep for
   an A/B. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

@interface NSPathControl (OracleCompat)
- (BOOL) isEditable;
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

    printf("ENUM style Standard=%d NavBar=%d PopUp=%d\n",
           (int)NSPathStyleStandard, (int)NSPathStyleNavigationBar,
           (int)NSPathStylePopUp);

    NSPathControl *pc =
        [[NSPathControl alloc] initWithFrame: NSMakeRect(0, 0, 200, 30)];
    printf("INIT pathStyle=%ld url=%s doubleAction=%s placeholder=%s allowedTypes=%s\n",
           (long)[pc pathStyle],
           [pc URL] == nil ? "nil" : "set",
           [pc doubleAction] == NULL ? "NULL" : "set",
           s([pc placeholderString]),
           [pc allowedTypes] == nil ? "nil" : "set");
    printf("INIT pathItems=%s\n",
           [pc pathItems] == nil ? "nil"
             : [[NSString stringWithFormat: @"count-%lu",
                          (unsigned long)[[pc pathItems] count]] UTF8String]);
    if ([pc respondsToSelector: @selector(isEditable)])
      printf("INIT editable=%d\n", [pc isEditable]);
    else
      printf("INIT editable=unavailable\n");

    [pc setPathStyle: NSPathStylePopUp];
    NSURL *url = [NSURL fileURLWithPath: @"/tmp/foo"];
    [pc setURL: url];
    [pc setPlaceholderString: @"pick a path"];
    printf("SET pathStyle=%ld urlEqual=%d placeholder=%s\n",
           (long)[pc pathStyle], [[pc URL] isEqual: url],
           s([pc placeholderString]));
  }
  return 0;
}
