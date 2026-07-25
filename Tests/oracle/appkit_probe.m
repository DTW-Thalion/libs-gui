/* Apple oracle: NSMatrix vs NSForm defaults for autosizesCells and
   tabKeyTraversesCells. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

int main(void)
{
  @autoreleasepool {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    NSMatrix *m = [[NSMatrix alloc] initWithFrame: NSMakeRect(0, 0, 100, 100)];
    printf("NSMatrix initWithFrame: autosizesCells=%d tabKeyTraversesCells=%d\n",
      [m autosizesCells], [m tabKeyTraversesCells]);

    NSForm *f1 = [[NSForm alloc] initWithFrame: NSMakeRect(0, 0, 100, 100)];
    printf("NSForm initWithFrame: autosizesCells=%d tabKeyTraversesCells=%d\n",
      [f1 autosizesCells], [f1 tabKeyTraversesCells]);

    NSForm *f2 = [[NSForm alloc]
      initWithFrame: NSMakeRect(0, 0, 100, 100)
               mode: NSListModeMatrix
          cellClass: [NSFormCell class]
       numberOfRows: 2
    numberOfColumns: 1];
    printf("NSForm initWithFrame:mode:...: autosizesCells=%d tabKeyTraversesCells=%d\n",
      [f2 autosizesCells], [f2 tabKeyTraversesCells]);
  }
  return 0;
}
