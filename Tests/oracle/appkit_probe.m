/* Apple oracle for NSPageController's delegate flow.  Installs a delegate that
   records every call AppKit makes, in order, so the implementation follows what
   AppKit actually does rather than a reading of the protocol.  Also pins the
   remaining range corners.  Apple-only. */
#import <Cocoa/Cocoa.h>
#include <stdio.h>

static NSMutableArray *calls = nil;

@interface Recorder : NSObject <NSPageControllerDelegate>
@end

@implementation Recorder

- (NSPageControllerObjectIdentifier) pageController: (NSPageController *)pc
                                identifierForObject: (id)object
{
  [calls addObject: [NSString stringWithFormat: @"identifierForObject:%@",
    object]];
  return [NSString stringWithFormat: @"id-%@", object];
}

- (NSViewController *) pageController: (NSPageController *)pc
          viewControllerForIdentifier: (NSPageControllerObjectIdentifier)ident
{
  NSViewController *vc = [[NSViewController alloc] init];

  [calls addObject: [NSString stringWithFormat: @"viewControllerForIdentifier:%@",
    ident]];
  [vc setView: [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 10, 10)]];
  return vc;
}

- (void) pageController: (NSPageController *)pc
  prepareViewController: (NSViewController *)vc
             withObject: (id)object
{
  [calls addObject: [NSString stringWithFormat: @"prepare:withObject:%@",
    object]];
}

- (void) pageController: (NSPageController *)pc
  didTransitionToObject: (id)object
{
  [calls addObject: [NSString stringWithFormat: @"didTransitionToObject:%@ (%@)",
    object, NSStringFromClass([object class])]];
}

- (NSRect) pageController: (NSPageController *)pc frameForObject: (id)object
{
  [calls addObject: [NSString stringWithFormat: @"frameForObject:%@ (%@)",
    object, NSStringFromClass([object class])]];
  return NSMakeRect(0, 0, 50, 50);
}

- (void) pageControllerWillStartLiveTransition: (NSPageController *)pc
{
  [calls addObject: @"willStartLiveTransition"];
}

- (void) pageControllerDidEndLiveTransition: (NSPageController *)pc
{
  [calls addObject: @"didEndLiveTransition"];
}
@end

static void
dumpCalls(const char *tag)
{
  NSUInteger i;

  printf("%s calls=%lu\n", tag, (unsigned long)[calls count]);
  for (i = 0; i < [calls count]; i++)
    {
      printf("   %lu. %s\n", (unsigned long)i + 1,
             [[calls objectAtIndex: i] UTF8String]);
    }
  [calls removeAllObjects];
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];
    calls = [[NSMutableArray alloc] init];

    printf("== what AppKit calls on setSelectedIndex: ==\n");
    {
      NSPageController *p = [[NSPageController alloc] init];
      Recorder *r = [[Recorder alloc] init];

      [p setDelegate: r];
      [p setArrangedObjects: [NSArray arrayWithObjects: @"a", @"b", @"c", nil]];
      dumpCalls("AFTER-setArrangedObjects");

      [p setSelectedIndex: 2];
      dumpCalls("AFTER-setSelectedIndex:2");
      printf("   -> selectedIndex=%ld selectedViewController=%s\n",
             (long)[p selectedIndex],
             [p selectedViewController] == nil ? "nil"
               : [NSStringFromClass([[p selectedViewController] class]) UTF8String]);
    }

    printf("\n== navigateForwardToObject: ==\n");
    {
      NSPageController *p = [[NSPageController alloc] init];
      Recorder *r = [[Recorder alloc] init];

      [p setDelegate: r];
      [p setArrangedObjects: [NSArray arrayWithObjects: @"a", @"b", nil]];
      [calls removeAllObjects];
      [p navigateForwardToObject: @"b"];
      dumpCalls("AFTER-navigateForwardToObject:b");
      printf("   -> selectedIndex=%ld arrangedCount=%lu\n",
             (long)[p selectedIndex],
             (unsigned long)[[p arrangedObjects] count]);
    }

    printf("\n== range corners ==\n");
    {
      NSPageController *p = [[NSPageController alloc] init];

      @try { [p setSelectedIndex: 5];
        printf("EMPTY-idx5 ok selectedIndex=%ld\n", (long)[p selectedIndex]); }
      @catch (NSException *e) { printf("EMPTY-idx5 raised %s\n",
        [[e name] UTF8String]); }
    }
    {
      NSPageController *p = [[NSPageController alloc] init];

      @try { [p setSelectedIndex: -1];
        printf("EMPTY-idxneg1 ok selectedIndex=%ld\n", (long)[p selectedIndex]); }
      @catch (NSException *e) { printf("EMPTY-idxneg1 raised %s\n",
        [[e name] UTF8String]); }
    }
    {
      NSPageController *p = [[NSPageController alloc] init];

      [p setArrangedObjects: [NSArray arrayWithObjects: @"a", @"b", @"c", nil]];
      @try { [p setSelectedIndex: 3];
        printf("THREE-idx3 ok selectedIndex=%ld\n", (long)[p selectedIndex]); }
      @catch (NSException *e) { printf("THREE-idx3 raised %s\n",
        [[e name] UTF8String]); }
    }
    {
      NSPageController *p = [[NSPageController alloc] init];

      [p setArrangedObjects: [NSArray arrayWithObjects: @"a", @"b", @"c", nil]];
      @try { [p setSelectedIndex: -1];
        printf("THREE-idxneg1 ok selectedIndex=%ld\n", (long)[p selectedIndex]); }
      @catch (NSException *e) { printf("THREE-idxneg1 raised %s\n",
        [[e name] UTF8String]); }
    }

    printf("\n== no delegate, with objects ==\n");
    {
      NSPageController *p = [[NSPageController alloc] init];

      [p setArrangedObjects: [NSArray arrayWithObjects: @"a", @"b", nil]];
      [p setSelectedIndex: 1];
      printf("NODELEGATE selectedIndex=%ld selectedViewController=%s view=%s\n",
             (long)[p selectedIndex],
             [p selectedViewController] == nil ? "nil" : "set",
             [p view] == nil ? "nil" : "set");
    }
  }
  return 0;
}
