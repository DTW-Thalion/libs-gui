#import <Cocoa/Cocoa.h>

static const char *B(BOOL v) { return v ? "YES" : "NO"; }

static void dump(NSString *label, NSStackView *sv)
{
  printf("%-28s arranged=%lu subviews=%lu\n", [label UTF8String],
         (unsigned long)[[sv arrangedSubviews] count],
         (unsigned long)[[sv subviews] count]);
}

int
main(int argc, const char *argv[])
{
  @autoreleasepool
    {
      [NSApplication sharedApplication];

      NSStackView *sv = [[NSStackView alloc]
        initWithFrame: NSMakeRect(0, 0, 200, 200)];
      dump(@"fresh", sv);

      NSView *a = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 20, 20)];
      NSView *b = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 20, 20)];
      NSView *c = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 20, 20)];

      [sv addArrangedSubview: a];
      dump(@"after add a", sv);
      printf("  a in arranged=%s subviews=%s  a.translatesAMIC=%s\n",
             B([[sv arrangedSubviews] containsObject: a]),
             B([[sv subviews] containsObject: a]),
             B([a translatesAutoresizingMaskIntoConstraints]));

      [sv addArrangedSubview: b];
      [sv insertArrangedSubview: c atIndex: 0];
      printf("order arranged: ");
      for (NSView *v in [sv arrangedSubviews])
        printf("%s ", v == a ? "a" : v == b ? "b" : v == c ? "c" : "?");
      printf("\norder subviews: ");
      for (NSView *v in [sv subviews])
        printf("%s ", v == a ? "a" : v == b ? "b" : v == c ? "c" : "?");
      printf("\n");

      // duplicate add
      [sv addArrangedSubview: a];
      dump(@"after re-add a", sv);

      // removeArrangedSubview keeps it as a subview?
      [sv removeArrangedSubview: a];
      printf("after removeArranged a: arranged contains a=%s subviews contains a=%s\n",
             B([[sv arrangedSubviews] containsObject: a]),
             B([[sv subviews] containsObject: a]));
      dump(@"after removeArranged a", sv);

      // plain addSubview: does it join arrangedSubviews?
      NSView *d = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 20, 20)];
      [sv addSubview: d];
      printf("after plain addSubview d: d in arranged=%s subviews=%s\n",
             B([[sv arrangedSubviews] containsObject: d]),
             B([[sv subviews] containsObject: d]));

      // removeFromSuperview of an arranged view prunes arrangedSubviews?
      [b removeFromSuperview];
      printf("after b removeFromSuperview: b in arranged=%s subviews=%s\n",
             B([[sv arrangedSubviews] containsObject: b]),
             B([[sv subviews] containsObject: b]));
    }
  return 0;
}
