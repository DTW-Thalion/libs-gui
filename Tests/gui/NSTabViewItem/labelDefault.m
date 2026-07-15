/* A default NSTabViewItem label is the empty string, as AppKit does.  The
 * label starts out empty rather than reading back empty: an item told to have
 * no label has none, as in AppKit.
 */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSString.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSTabViewItem.h>

int main()
{
  CREATE_AUTORELEASE_POOL(arp);
  NSTabViewItem *item;

  START_SET("NSTabViewItem labelDefault")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  item = AUTORELEASE([[NSTabViewItem alloc] initWithIdentifier: @"l"]);
  pass([[item label] isEqualToString: @""],
       "default label is the empty string");

  item = AUTORELEASE([[NSTabViewItem alloc] init]);
  pass([[item label] isEqualToString: @""],
       "an item made with init has the empty label too");

  [item setLabel: @"x"];
  pass([[item label] isEqualToString: @"x"], "the label round-trips");

  [item setLabel: nil];
  pass([item label] == nil, "an item told to have no label has none");

  END_SET("NSTabViewItem labelDefault")

  DESTROY(arp);
  return 0;
}
