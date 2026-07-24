/* Apple oracle: NSButton click/state semantics per button type.
   Portable so the same file runs under GNUstep for an A/B comparison.
   Question: does -performClick: (and -setNextState) change the state of a
   momentary button, and how does it differ from a toggle/checkbox/radio? */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

@interface Ctr : NSObject { @public int hits; } @end
@implementation Ctr - (void) act: (id)s { hits++; } @end

static void
probe(const char *name, NSInteger type, BOOL setType)
{
  Ctr *t = [Ctr new];
  NSButton *b = [[NSButton alloc] initWithFrame: NSMakeRect(0, 0, 80, 24)];
  if (setType)
    [b setButtonType: (NSButtonType)type];
  [b setTarget: t];
  [b setAction: @selector(act:)];
  NSInteger s0 = [b state];
  [b performClick: nil];
  NSInteger s1 = [b state];
  [b performClick: nil];
  NSInteger s2 = [b state];
  printf("%-22s initial=%ld  performClick->%ld  again->%ld  hits=%d\n",
         name, (long)s0, (long)s1, (long)s2, t->hits);
}

int
main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    printf("== NSButton performClick state by type ==\n");
    probe("default(no setType)", 0, NO);
    probe("MomentaryLight", NSMomentaryLightButton, YES);
    probe("MomentaryPushIn", NSMomentaryPushInButton, YES);
    probe("MomentaryChange", NSMomentaryChangeButton, YES);
    probe("PushOnPushOff", NSPushOnPushOffButton, YES);
    probe("OnOff", NSOnOffButton, YES);
    probe("Toggle", NSToggleButton, YES);
    probe("Switch(checkbox)", NSSwitchButton, YES);
    probe("Radio", NSRadioButton, YES);

    printf("\n== setNextState by type (start Off) ==\n");
    struct { const char *n; NSInteger t; } types[] = {
      {"MomentaryPushIn", NSMomentaryPushInButton},
      {"Toggle", NSToggleButton},
      {"Switch(checkbox)", NSSwitchButton},
    };
    for (int i = 0; i < 3; i++)
      {
        NSButton *b = [[NSButton alloc] initWithFrame: NSMakeRect(0, 0, 80, 24)];
        [b setButtonType: (NSButtonType)types[i].t];
        [b setState: NSOffState];
        [b setNextState];
        printf("%-22s setNextState(Off)->%ld\n", types[i].n, (long)[b state]);
      }
  }
  return 0;
}
