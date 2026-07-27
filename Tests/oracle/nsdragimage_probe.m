#import <Cocoa/Cocoa.h>

static void dumpComponents(NSString *what, NSArray *comps)
{
  printf("%s: count=%lu\n", [what UTF8String], (unsigned long)[comps count]);
  NSUInteger i;
  for (i = 0; i < [comps count]; i++)
    {
      NSDraggingImageComponent *c = [comps objectAtIndex: i];
      NSRect f = [c frame];
      printf("  [%lu] class=%s key=%s contentsClass=%s frame={%g,%g,%g,%g}\n",
             (unsigned long)i,
             [NSStringFromClass([c class]) UTF8String],
             [[c key] UTF8String],
             [c contents] ? [NSStringFromClass([[c contents] class]) UTF8String] : "nil",
             f.origin.x, f.origin.y, f.size.width, f.size.height);
    }
}

int
main(int argc, const char *argv[])
{
  @autoreleasepool
    {
      [NSApplication sharedApplication];

      printf("=== NSDraggingImageComponent key constants ===\n");
      printf("IconKey='%s'  LabelKey='%s'\n",
             [NSDraggingImageComponentIconKey UTF8String],
             [NSDraggingImageComponentLabelKey UTF8String]);

      printf("\n=== fresh component via +draggingImageComponentWithKey: ===\n");
      NSDraggingImageComponent *c =
        [NSDraggingImageComponent
          draggingImageComponentWithKey: NSDraggingImageComponentIconKey];
      NSRect f = [c frame];
      printf("class=%s key=%s contents=%s frame={%g,%g,%g,%g}\n",
             [NSStringFromClass([c class]) UTF8String], [[c key] UTF8String],
             [c contents] ? "set" : "nil",
             f.origin.x, f.origin.y, f.size.width, f.size.height);

      printf("\n=== component via -initWithKey: (custom key) ===\n");
      NSDraggingImageComponent *c2 =
        [[NSDraggingImageComponent alloc] initWithKey: @"custom"];
      printf("key=%s\n", [[c2 key] UTF8String]);
      [c2 setFrame: NSMakeRect(1, 2, 3, 4)];
      f = [c2 frame];
      printf("after setFrame -> {%g,%g,%g,%g}\n",
             f.origin.x, f.origin.y, f.size.width, f.size.height);
      NSImage *img = [[NSImage alloc] initWithSize: NSMakeSize(10, 10)];
      [c2 setContents: img];
      printf("after setContents:image -> contents=%s\n",
             [c2 contents] ? [NSStringFromClass([[c2 contents] class]) UTF8String] : "nil");

      printf("\n=== NSView draggingImageComponents ===\n");
      NSView *v = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 50, 40)];
      dumpComponents(@"bare NSView(50x40)", [v draggingImageComponents]);

      printf("\n=== NSCollectionViewItem draggingImageComponents ===\n");
      NSCollectionViewItem *item = [[NSCollectionViewItem alloc] init];
      dumpComponents(@"item with NO view set", [item draggingImageComponents]);

      NSView *iv = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 80, 60)];
      [item setView: iv];
      dumpComponents(@"item with 80x60 view", [item draggingImageComponents]);
    }
  return 0;
}
