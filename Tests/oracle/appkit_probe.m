/* Apple oracle: what do the NSButton convenience constructors configure?
   Portable (compiles under GNUstep too, but the point is the Apple values). */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

@interface Tgt : NSObject @end
@implementation Tgt - (void) go: (id)s {} @end

static void dump(const char *name, NSButton *b, Tgt *t)
{
  printf("%-14s title='%s' bordered=%d bezel=%ld img=%d state=%ld tgt=%d act='%s'\n",
    name, [[b title] UTF8String], [b isBordered], (long)[b bezelStyle],
    [b image] != nil, (long)[b state], [b target] == t,
    b.action ? sel_getName(b.action) : "(nil)");
}

int main(void)
{
  @autoreleasepool {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];
    Tgt *t = [Tgt new];
    NSImage *img = [NSImage imageNamed: NSImageNameInfo];
    dump("button/title", [NSButton buttonWithTitle: @"Go" target: t action: @selector(go:)], t);
    dump("button/img",   [NSButton buttonWithImage: img target: t action: @selector(go:)], t);
    dump("button/t+i",   [NSButton buttonWithTitle: @"Go" image: img target: t action: @selector(go:)], t);
    dump("checkbox",     [NSButton checkboxWithTitle: @"Chk" target: t action: @selector(go:)], t);
    dump("radio",        [NSButton radioButtonWithTitle: @"Rad" target: t action: @selector(go:)], t);
  }
  return 0;
}
