/* Apple oracle for the NSMatrix grid-management coverage test:
   dimensions, add/insert/remove rows and columns, the cell class and
   prototype, cell size, getRow:column:ofCell:, and cellWithTag:. */
#import <Cocoa/Cocoa.h>

int main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    NSButtonCell *proto = [[NSButtonCell alloc] init];
    NSMatrix *m = [[NSMatrix alloc] initWithFrame: NSMakeRect(0, 0, 100, 100)
                                             mode: NSListModeMatrix
                                        prototype: proto
                                     numberOfRows: 2
                                  numberOfColumns: 3];
    printf("MX dims: rows=%ld cols=%ld\n",
           (long)[m numberOfRows], (long)[m numberOfColumns]);
    printf("MX prototype isButtonCell=%d cellClass=%s\n",
           [[m prototype] isKindOfClass: [NSButtonCell class]] ,
           [NSStringFromClass([m cellClass]) UTF8String]);
    printf("MX cellAtRow00 isButtonCell=%d\n",
           [[m cellAtRow: 0 column: 0] isKindOfClass: [NSButtonCell class]]);

    /* Add a row and a column. */
    [m addRow];
    [m addColumn];
    printf("MX after addRow/addColumn: rows=%ld cols=%ld\n",
           (long)[m numberOfRows], (long)[m numberOfColumns]);

    /* Insert / remove. */
    [m insertRow: 1];
    printf("MX after insertRow 1: rows=%ld\n", (long)[m numberOfRows]);
    [m removeRow: 0];
    printf("MX after removeRow 0: rows=%ld\n", (long)[m numberOfRows]);
    [m removeColumn: 0];
    printf("MX after removeColumn 0: cols=%ld\n", (long)[m numberOfColumns]);

    /* getRow:column:ofCell:. */
    NSCell *c12 = [m cellAtRow: 1 column: 2];
    NSInteger gr = -9, gc = -9;
    BOOL found = [m getRow: &gr column: &gc ofCell: c12];
    printf("MX getRow:column:ofCell: found=%d row=%ld col=%ld\n", found, (long)gr, (long)gc);

    /* Tag lookup. */
    [[m cellAtRow: 0 column: 0] setTag: 77];
    printf("MX cellWithTag 77==cell00:%d cellWithTag 99 nil:%d\n",
           [m cellWithTag: 77] == [m cellAtRow: 0 column: 0],
           [m cellWithTag: 99] == nil);

    /* Cell size round-trips. */
    [m setCellSize: NSMakeSize(40, 18)];
    printf("MX cellSize=%gx%g\n", [m cellSize].width, [m cellSize].height);

    /* Mode round-trips. */
    [m setMode: NSRadioModeMatrix];
    printf("MX mode=%ld (radio=%ld)\n", (long)[m mode], (long)NSRadioModeMatrix);

    /* putCell: replaces a cell. */
    NSButtonCell *repl = [[NSButtonCell alloc] init];
    [repl setTag: 555];
    [m putCell: repl atRow: 0 column: 0];
    printf("MX putCell: cell00.tag=%ld\n", (long)[[m cellAtRow: 0 column: 0] tag]);

    printf("DONE\n");
  }
  return 0;
}
