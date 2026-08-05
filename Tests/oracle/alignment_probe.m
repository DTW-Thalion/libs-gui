#import <Cocoa/Cocoa.h>

int
main(int argc, const char *argv[])
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSMutableParagraphStyle *style;
  NSTextField *field;

  printf("NSTextAlignmentLeft=%ld Center=%ld Right=%ld Justified=%ld Natural=%ld\n",
         (long)NSTextAlignmentLeft, (long)NSTextAlignmentCenter,
         (long)NSTextAlignmentRight, (long)NSTextAlignmentJustified,
         (long)NSTextAlignmentNatural);

  style = [[NSMutableParagraphStyle alloc] init];
  printf("a new paragraph style has alignment %ld\n",
         (long)[style alignment]);
  [style setAlignment: NSTextAlignmentRight];
  printf("after setAlignment: NSTextAlignmentRight it reads %ld\n",
         (long)[style alignment]);

  field = [[NSTextField alloc] initWithFrame: NSMakeRect(0, 0, 100, 20)];
  [field setAlignment: NSTextAlignmentCenter];
  printf("a text field set to centre reads %ld, its cell %ld\n",
         (long)[field alignment], (long)[[field cell] alignment]);

  printf("NSNormalWindowLevel=%ld NSFloatingWindowLevel=%ld "
         "NSSubmenuWindowLevel=%ld NSTornOffMenuWindowLevel=%ld\n",
         (long)NSNormalWindowLevel, (long)NSFloatingWindowLevel,
         (long)NSSubmenuWindowLevel, (long)NSTornOffMenuWindowLevel);
  printf("NSMainMenuWindowLevel=%ld NSStatusWindowLevel=%ld "
         "NSModalPanelWindowLevel=%ld NSPopUpMenuWindowLevel=%ld "
         "NSScreenSaverWindowLevel=%ld\n",
         (long)NSMainMenuWindowLevel, (long)NSStatusWindowLevel,
         (long)NSModalPanelWindowLevel, (long)NSPopUpMenuWindowLevel,
         (long)NSScreenSaverWindowLevel);

  printf("NSTabViewControllerTabStyleSegmentedControlOnTop=%ld "
         "OnBottom=%ld Toolbar=%ld Unspecified=%ld\n",
         (long)NSTabViewControllerTabStyleSegmentedControlOnTop,
         (long)NSTabViewControllerTabStyleSegmentedControlOnBottom,
         (long)NSTabViewControllerTabStyleToolbar,
         (long)NSTabViewControllerTabStyleUnspecified);

  fflush(stdout);
  [pool release];
  return 0;
}
