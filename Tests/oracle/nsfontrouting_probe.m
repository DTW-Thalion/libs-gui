/* Oracle: where does -[NSApplication targetForAction: @selector(changeFont:)]
   resolve when a document window (with an NSTextView) is main and the font
   panel is key?  This is the routing rule NSFontManager -sendAction relies on. */
#import <Cocoa/Cocoa.h>

static const char *
clsName(id o)
{
  return o ? [NSStringFromClass([o class]) UTF8String] : "(nil)";
}

static void
report(const char *label)
{
  id target = [NSApp targetForAction: @selector(changeFont:)];
  printf("%-24s key=%s main=%s  target(changeFont:)=%s\n",
         label,
         clsName([NSApp keyWindow]),
         clsName([NSApp mainWindow]),
         clsName(target));
}

int
main(void)
{
  @autoreleasepool
    {
      [NSApplication sharedApplication];

      NSWindow *doc = [[NSWindow alloc]
        initWithContentRect: NSMakeRect(0, 0, 300, 300)
                  styleMask: NSWindowStyleMaskTitled | NSWindowStyleMaskResizable
                    backing: NSBackingStoreBuffered
                      defer: NO];
      NSTextView *tv = [[NSTextView alloc]
        initWithFrame: NSMakeRect(0, 0, 300, 300)];
      [doc setContentView: tv];
      [doc makeFirstResponder: tv];

      printf("NSTextView responds to changeFont: = %d\n",
             [tv respondsToSelector: @selector(changeFont:)]);

      report("before ordering");

      [doc makeKeyAndOrderFront: nil];
      [doc makeMainWindow];
      report("doc key+main");
      printf("  doc isKey=%d isMain=%d\n", [doc isKeyWindow], [doc isMainWindow]);

      NSFontPanel *fp = [[NSFontManager sharedFontManager] fontPanel: YES];
      printf("fontPanel canBecomeMain=%d canBecomeKey=%d worksWhenModal=%d\n",
             [fp canBecomeMainWindow], [fp canBecomeKeyWindow],
             [fp worksWhenModal]);

      [fp makeKeyAndOrderFront: nil];
      report("fontpanel shown");
      printf("  keyIsFontPanel=%d mainIsDoc=%d\n",
             ([NSApp keyWindow] == fp), ([NSApp mainWindow] == doc));

      [fp makeKeyWindow];
      report("fontpanel forced key");
      printf("  keyIsFontPanel=%d\n", ([NSApp keyWindow] == fp));
    }
  return 0;
}
