/* Apple oracle: NSCell focusRingMaskBoundsForFrame: with a real view, and for
   a cell that belongs to a control. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

static void dumpRing(const char *label, NSCell *c, NSRect f, NSView *v)
{
  NSRect r = [c focusRingMaskBoundsForFrame: f inView: v];
  printf("%s focusRingMaskBounds = (%g,%g,%g,%g)\n",
    label, r.origin.x, r.origin.y, r.size.width, r.size.height);
}

int main(void)
{
  @autoreleasepool {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    NSRect f = NSMakeRect(10, 20, 30, 40);
    NSView *view = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 200, 200)];

    NSCell *cell = [[NSCell alloc] initTextCell: @"x"];
    dumpRing("plain-cell nil-view", cell, f, nil);
    dumpRing("plain-cell real-view", cell, f, view);

    NSButton *button = [[NSButton alloc] initWithFrame: NSMakeRect(0, 0, 30, 40)];
    dumpRing("button-cell", [button cell], f, button);

    NSTextField *tf = [[NSTextField alloc] initWithFrame: NSMakeRect(0, 0, 30, 40)];
    dumpRing("textfield-cell", [tf cell], f, tf);
  }
  return 0;
}
