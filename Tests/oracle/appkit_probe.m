/* Apple oracle for the NSBrowser configuration coverage test: the many
   selection/column/title flag defaults, the path separator, and the
   numeric configuration. */
#import <Cocoa/Cocoa.h>

int main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    NSBrowser *b = [[NSBrowser alloc] initWithFrame: NSMakeRect(0, 0, 300, 200)];

    printf("BR flags: branch=%d empty=%d multi=%d reuses=%d takesTitle=%d\n",
           [b allowsBranchSelection], [b allowsEmptySelection],
           [b allowsMultipleSelection], [b reusesColumns],
           [b takesTitleFromPreviousColumn]);
    printf("BR flags: separates=%d titled=%d hScroller=%d arrowKeys=%d\n",
           [b separatesColumns], [b isTitled], [b hasHorizontalScroller],
           [b sendsActionOnArrowKeys]);
    printf("BR flags: prefersAllColResize=%d\n", [b prefersAllColumnUserResizing]);
    printf("BR pathSeparator='%s' minColWidth=%g maxVisibleCols=%ld colResizeType=%ld\n",
           [[b pathSeparator] UTF8String], [b minColumnWidth],
           (long)[b maxVisibleColumns], (long)[b columnResizingType]);
    printf("BR cellPrototype class=%s\n",
           [NSStringFromClass([[b cellPrototype] class]) UTF8String]);

    /* Round-trips. */
    [b setAllowsMultipleSelection: YES];
    [b setAllowsEmptySelection: YES];
    [b setSeparatesColumns: NO];
    [b setTitled: NO];
    [b setPathSeparator: @":"];
    [b setMinColumnWidth: 120.0];
    [b setMaxVisibleColumns: 4];
    [b setColumnResizingType: NSBrowserUserColumnResizing];
    printf("BR roundtrip: multi=%d empty=%d separates=%d titled=%d sep='%s' minW=%g maxCols=%ld resize=%ld\n",
           [b allowsMultipleSelection], [b allowsEmptySelection],
           [b separatesColumns], [b isTitled], [[b pathSeparator] UTF8String],
           [b minColumnWidth], (long)[b maxVisibleColumns], (long)[b columnResizingType]);

    printf("DONE\n");
  }
  return 0;
}
