#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSGeometry.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSTableView.h>
#import <AppKit/NSTableColumn.h>
#import <AppKit/NSImage.h>

int
main(int argc, const char **argv)
{
  CREATE_AUTORELEASE_POOL(arp);
  NSTableView *tv;
  NSTableColumn *col;
  NSImage *img;

  START_SET("NSTableView indicator image")

  NS_DURING
    {
      [NSApplication sharedApplication];
    }
  NS_HANDLER
    {
      if ([[localException name] isEqualToString: NSInternalInconsistencyException])
        SKIP("It looks like GNUstep backend is not yet installed")
    }
  NS_ENDHANDLER

  tv = AUTORELEASE([[NSTableView alloc]
    initWithFrame: NSMakeRect(0, 0, 200, 100)]);
  col = AUTORELEASE([[NSTableColumn alloc] initWithIdentifier: @"c"]);
  [tv addTableColumn: col];
  img = AUTORELEASE([[NSImage alloc] initWithSize: NSMakeSize(8, 8)]);

  /* Checked against AppKit: no indicator image is set by default; setting one
     stores it for that column (retained, not copied); setting nil clears it. */
  PASS([tv indicatorImageInTableColumn: col] == nil,
    "indicatorImageInTableColumn: is nil by default");

  [tv setIndicatorImage: img inTableColumn: col];
  PASS([tv indicatorImageInTableColumn: col] == img,
    "indicatorImageInTableColumn: returns the image set for the column");

  [tv setIndicatorImage: nil inTableColumn: col];
  PASS([tv indicatorImageInTableColumn: col] == nil,
    "setIndicatorImage: nil clears the indicator image");

  END_SET("NSTableView indicator image")

  DESTROY(arp);
  return 0;
}
