/* Apple oracle for NSTextTableBlock: the initialiser, the getters, what a copy
   keeps, and the method type encodings (this header says int where AppKit may
   say NSInteger).  Portable so the same file runs under GNUstep for an A/B. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#import <objc/runtime.h>
#include <stdio.h>

#define SECTION(NAME) \
  printf("\n== " NAME " ==\n"); \
  @try {

#define ENDSECTION \
  } @catch (NSException *e) { \
    printf("EXCEPTION %s: %s\n", [[e name] UTF8String], \
           [[e reason] UTF8String]); \
  }

static void
dumpEncoding(Class c, const char *name)
{
  SEL s = NSSelectorFromString([NSString stringWithUTF8String: name]);
  Method m = class_getInstanceMethod(c, s);

  if (m == NULL)
    {
      printf("  %-22s (absent)\n", name);
      return;
    }
  printf("  %-22s %s\n", name, method_getTypeEncoding(m));
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    SECTION("method type encodings")
    printf("(q = NSInteger/long, i = int)\n");
    dumpEncoding([NSTextTableBlock class], "startingRow");
    dumpEncoding([NSTextTableBlock class], "rowSpan");
    dumpEncoding([NSTextTableBlock class], "startingColumn");
    dumpEncoding([NSTextTableBlock class], "columnSpan");
    dumpEncoding([NSTextTableBlock class],
      "initWithTable:startingRow:rowSpan:startingColumn:columnSpan:");
    dumpEncoding([NSTextTable class], "numberOfColumns");
    dumpEncoding([NSTextTable class], "setNumberOfColumns:");
    ENDSECTION

    SECTION("NSTextTableBlock init")
    NSTextTable *table = [[NSTextTable alloc] init];
    NSTextTableBlock *b = [[NSTextTableBlock alloc] initWithTable: table
                                                      startingRow: 1
                                                          rowSpan: 2
                                                   startingColumn: 3
                                                       columnSpan: 4];

    printf("INIT nonnil=%d tableSame=%d\n", b != nil, [b table] == table);
    printf("INIT row=%ld rowSpan=%ld col=%ld colSpan=%ld\n",
           (long)[b startingRow], (long)[b rowSpan],
           (long)[b startingColumn], (long)[b columnSpan]);
    ENDSECTION

    SECTION("NSTextTableBlock inherits the text block defaults")
    NSTextTable *table = [[NSTextTable alloc] init];
    NSTextTableBlock *b = [[NSTextTableBlock alloc] initWithTable: table
                                                      startingRow: 0
                                                          rowSpan: 1
                                                   startingColumn: 0
                                                       columnSpan: 1];

    printf("INHERIT contentWidth=%g type=%ld backgroundColor=%s\n",
           (double)[b contentWidth], (long)[b contentWidthValueType],
           [b backgroundColor] == nil ? "nil" : "set");
    ENDSECTION

    SECTION("NSTextTableBlock copy")
    NSTextTable *table = [[NSTextTable alloc] init];
    NSTextTableBlock *b = [[NSTextTableBlock alloc] initWithTable: table
                                                      startingRow: 1
                                                          rowSpan: 2
                                                   startingColumn: 3
                                                       columnSpan: 4];
    NSTextTableBlock *copy;

    [b setContentWidth: 25.0 type: NSTextBlockAbsoluteValueType];
    copy = [b copy];
    printf("COPY nonnil=%d class=%s\n", copy != nil,
           [NSStringFromClass([copy class]) UTF8String]);
    printf("COPY tableSame=%d row=%ld rowSpan=%ld col=%ld colSpan=%ld\n",
           [copy table] == table, (long)[copy startingRow],
           (long)[copy rowSpan], (long)[copy startingColumn],
           (long)[copy columnSpan]);
    printf("COPY contentWidth=%g\n", (double)[copy contentWidth]);
    ENDSECTION

    SECTION("NSTextTable defaults")
    NSTextTable *table = [[NSTextTable alloc] init];

    printf("TABLE numberOfColumns=%ld collapsesBorders=%d hidesEmptyCells=%d\n",
           (long)[table numberOfColumns], [table collapsesBorders],
           [table hidesEmptyCells]);
    printf("TABLE layoutAlgorithm=%ld\n", (long)[table layoutAlgorithm]);
    ENDSECTION
  }
  return 0;
}
