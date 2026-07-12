/* Apple oracle for the NSTextFieldCell coverage test: defaults and the
   placeholder string/attributed gating. */
#import <Cocoa/Cocoa.h>

int main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    NSTextFieldCell *c = [[NSTextFieldCell alloc] initTextCell: @""];
    printf("TFC default drawsBackground=%d\n", [c drawsBackground]);
    printf("TFC default bezelStyle=%ld (square=%ld rounded=%ld)\n",
           (long)[c bezelStyle], (long)NSTextFieldSquareBezel, (long)NSTextFieldRoundedBezel);
    printf("TFC default textColor==textColor:%d ==controlText:%d nil:%d\n",
           [c textColor] == [NSColor textColor],
           [c textColor] == [NSColor controlTextColor],
           [c textColor] == nil);
    printf("TFC default bgColor==textBackground:%d ==control:%d nil:%d\n",
           [c backgroundColor] == [NSColor textBackgroundColor],
           [c backgroundColor] == [NSColor controlColor],
           [c backgroundColor] == nil);
    printf("TFC default placeholderString nil:%d placeholderAttr nil:%d\n",
           [c placeholderString] == nil, [c placeholderAttributedString] == nil);

    /* Placeholder gating. */
    NSTextFieldCell *p = [[NSTextFieldCell alloc] initTextCell: @""];
    [p setPlaceholderString: @"type here"];
    printf("TFC after setPlaceholderString: string='%s' attr nil:%d\n",
           [[p placeholderString] UTF8String], [p placeholderAttributedString] == nil);
    NSAttributedString *as = [[NSAttributedString alloc] initWithString: @"attr ph"];
    [p setPlaceholderAttributedString: as];
    printf("TFC after setPlaceholderAttr: string nil:%d attr.string='%s'\n",
           [p placeholderString] == nil, [[[p placeholderAttributedString] string] UTF8String]);

    /* Setters round-trip. */
    NSTextFieldCell *s = [[NSTextFieldCell alloc] initTextCell: @""];
    [s setDrawsBackground: YES];
    [s setBezelStyle: NSTextFieldRoundedBezel];
    [s setTextColor: [NSColor redColor]];
    [s setBackgroundColor: [NSColor blueColor]];
    printf("TFC roundtrip draws=%d bezel=%ld text==red:%d bg==blue:%d\n",
           [s drawsBackground], (long)[s bezelStyle],
           [s textColor] == [NSColor redColor], [s backgroundColor] == [NSColor blueColor]);

    /* String value is stored. */
    [s setStringValue: @"hello"];
    printf("TFC stringValue='%s' editable=%d\n", [[s stringValue] UTF8String], [s isEditable]);

    printf("DONE\n");
  }
  return 0;
}
