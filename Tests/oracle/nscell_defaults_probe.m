#import <Cocoa/Cocoa.h>

int
main(int argc, const char *argv[])
{
  @autoreleasepool
    {
      NSCell *cell = [[NSCell alloc] initTextCell: @"hello"];
      NSRect frame = NSMakeRect(10, 20, 100, 40);
      NSView *view = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 300, 300)];

      NSRect mbNil = [cell focusRingMaskBoundsForFrame: frame inView: nil];
      printf("focusRingMaskBoundsForFrame: view=nil -> (%g %g %g %g)\n",
        mbNil.origin.x, mbNil.origin.y, mbNil.size.width, mbNil.size.height);
      NSRect mb = [cell focusRingMaskBoundsForFrame: frame inView: view];
      printf("focusRingMaskBoundsForFrame: view=real -> (%g %g %g %g) [frame is (10 20 100 40)]\n",
        mb.origin.x, mb.origin.y, mb.size.width, mb.size.height);

      NSRect ef = [cell expansionFrameWithFrame: frame inView: view];
      printf("expansionFrameWithFrame: fitting text view=real -> (%g %g %g %g)\n",
        ef.origin.x, ef.origin.y, ef.size.width, ef.size.height);

      NSCell *big = [[NSCell alloc] initTextCell:
        @"a very long string that will certainly not fit inside a narrow cell"];
      NSRect narrow = NSMakeRect(10, 20, 40, 20);
      NSRect ef2 = [big expansionFrameWithFrame: narrow inView: view];
      printf("expansionFrameWithFrame: clipped text view=real -> (%g %g %g %g) [narrow is (10 20 40 20)]\n",
        ef2.origin.x, ef2.origin.y, ef2.size.width, ef2.size.height);
    }
  return 0;
}
