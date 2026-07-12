/* Apple oracle for the NSTextView typing-attributes coverage test:
   defaults, typing attributes, font/colour, and the editable/selectable
   coupling. */
#import <Cocoa/Cocoa.h>

int main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    NSTextView *tv = [[NSTextView alloc] initWithFrame: NSMakeRect(0, 0, 200, 100)];
    printf("TV flags: editable=%d selectable=%d richText=%d fieldEditor=%d drawsBg=%d\n",
           [tv isEditable], [tv isSelectable], [tv isRichText],
           [tv isFieldEditor], [tv drawsBackground]);

    NSDictionary *ta = [tv typingAttributes];
    printf("TV default typingAttributes: hasFont=%d hasColor=%d hasPara=%d count=%lu\n",
           [ta objectForKey: NSFontAttributeName] != nil,
           [ta objectForKey: NSForegroundColorAttributeName] != nil,
           [ta objectForKey: NSParagraphStyleAttributeName] != nil,
           (unsigned long)[ta count]);

    [tv setString: @"hello"];
    printf("TV setString: string='%s' len=%lu\n",
           [[tv string] UTF8String], (unsigned long)[[tv string] length]);

    [tv setFont: [NSFont systemFontOfSize: 20]];
    printf("TV setFont 20: font.pt=%g typingFont.pt=%g\n",
           [[tv font] pointSize],
           [[[tv typingAttributes] objectForKey: NSFontAttributeName] pointSize]);

    [tv setTextColor: [NSColor redColor]];
    printf("TV setTextColor red: typingColor==red:%d\n",
           [[[tv typingAttributes] objectForKey: NSForegroundColorAttributeName]
             isEqual: [NSColor redColor]]);

    NSMutableDictionary *custom = [NSMutableDictionary dictionary];
    [custom setObject: [NSFont systemFontOfSize: 30] forKey: NSFontAttributeName];
    [tv setTypingAttributes: custom];
    printf("TV setTypingAttributes: font.pt=%g count=%lu\n",
           [[[tv typingAttributes] objectForKey: NSFontAttributeName] pointSize],
           (unsigned long)[[tv typingAttributes] count]);

    /* editable / selectable coupling. */
    NSTextView *c = [[NSTextView alloc] initWithFrame: NSMakeRect(0, 0, 200, 100)];
    [c setEditable: NO];
    printf("TV setEditable NO: editable=%d selectable=%d\n", [c isEditable], [c isSelectable]);
    [c setSelectable: NO];
    printf("TV setSelectable NO: editable=%d selectable=%d\n", [c isEditable], [c isSelectable]);
    [c setEditable: YES];
    printf("TV setEditable YES (while not selectable): editable=%d selectable=%d\n",
           [c isEditable], [c isSelectable]);

    printf("DONE\n");
  }
  return 0;
}
