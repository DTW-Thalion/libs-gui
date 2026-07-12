/* Apple oracle for the NSTableColumn coverage test: defaults, width
   clamping, the resizable/resizing-mask relationship, and the title. */
#import <Cocoa/Cocoa.h>

int main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    NSTableColumn *c = [[NSTableColumn alloc] initWithIdentifier: @"col1"];
    printf("TC identifier='%s'\n", [[c identifier] UTF8String]);
    printf("TC defaults: width=%g minWidth=%g maxWidth=%g resizingMask=%lu\n",
           [c width], [c minWidth], [c maxWidth], (unsigned long)[c resizingMask]);
    printf("TC defaults: resizable=%d editable=%d hidden=%d\n",
           [c isResizable], [c isEditable], [c isHidden]);
    printf("TC defaults: headerCell=%s dataCell=%s\n",
           [NSStringFromClass([[c headerCell] class]) UTF8String],
           [NSStringFromClass([[c dataCell] class]) UTF8String]);

    /* Width clamping. */
    [c setMinWidth: 20];
    [c setMaxWidth: 200];
    [c setWidth: 50];
    printf("TC setWidth 50 -> %g\n", [c width]);
    [c setWidth: 5];
    printf("TC setWidth 5 (below min 20) -> %g\n", [c width]);
    [c setWidth: 500];
    printf("TC setWidth 500 (above max 200) -> %g\n", [c width]);

    /* setMinWidth / setMaxWidth push the width. */
    [c setWidth: 100];
    [c setMinWidth: 150];
    printf("TC width=100 then setMinWidth 150 -> width=%g\n", [c width]);
    [c setWidth: 180];
    [c setMaxWidth: 160];
    printf("TC width=180 then setMaxWidth 160 -> width=%g\n", [c width]);

    /* The resizable / resizing-mask relationship. */
    NSTableColumn *r = [[NSTableColumn alloc] initWithIdentifier: @"r"];
    [r setResizingMask: NSTableColumnNoResizing];
    printf("TC setResizingMask 0 -> isResizable=%d\n", [r isResizable]);
    [r setResizingMask: NSTableColumnUserResizingMask];
    printf("TC setResizingMask User -> isResizable=%d\n", [r isResizable]);
    NSTableColumn *r2 = [[NSTableColumn alloc] initWithIdentifier: @"r2"];
    [r2 setResizable: NO];
    printf("TC setResizable NO -> resizingMask=%lu isResizable=%d\n",
           (unsigned long)[r2 resizingMask], [r2 isResizable]);
    [r2 setResizable: YES];
    printf("TC setResizable YES -> resizingMask=%lu isResizable=%d\n",
           (unsigned long)[r2 resizingMask], [r2 isResizable]);

    /* Title convenience (goes through the header cell). */
    [c setTitle: @"Name"];
    printf("TC setTitle -> title='%s' headerCell.stringValue='%s'\n",
           [[c title] UTF8String], [[[c headerCell] stringValue] UTF8String]);

    /* Simple round-trips. */
    [c setEditable: NO];
    [c setHidden: YES];
    [c setIdentifier: @"other"];
    printf("TC roundtrip editable=%d hidden=%d identifier='%s'\n",
           [c isEditable], [c isHidden], [[c identifier] UTF8String]);

    printf("DONE\n");
  }
  return 0;
}
