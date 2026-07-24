#import <Cocoa/Cocoa.h>

int
main(int argc, const char *argv[])
{
  @autoreleasepool
    {
      NSCell *cell = [[NSCell alloc] initTextCell: @"hello"];
      NSRect frame = NSMakeRect(10, 20, 100, 40);

      NSText *fe = [cell fieldEditorForView: nil];
      printf("fieldEditorForView:nil -> %s\n", fe == nil ? "nil" : "non-nil");

      printf("wantsNotificationForMarkedText -> %s\n",
        [cell wantsNotificationForMarkedText] ? "YES" : "NO");

      NSRect mb = [cell focusRingMaskBoundsForFrame: frame inView: nil];
      printf("focusRingMaskBoundsForFrame: -> (%g %g %g %g) [frame is (10 20 100 40)]\n",
        mb.origin.x, mb.origin.y, mb.size.width, mb.size.height);

      NSRect ef = [cell expansionFrameWithFrame: frame inView: nil];
      printf("expansionFrameWithFrame: (fitting text) -> (%g %g %g %g)\n",
        ef.origin.x, ef.origin.y, ef.size.width, ef.size.height);
    }
  return 0;
}
