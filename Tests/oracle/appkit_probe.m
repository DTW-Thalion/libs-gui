/* Apple oracle: what a nil label does.  Fred would rather the empty-string
   default were set in the initialiser than answered for in the getter.  That
   only covers the same ground if AppKit lets a label go back to nil.
   Apple-only. */
#import <Cocoa/Cocoa.h>
#include <stdio.h>

static const char *
show(NSString *s)
{
  if (s == nil)
    {
      return "nil";
    }
  if ([s length] == 0)
    {
      return "empty";
    }
  return [s UTF8String];
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    printf("== NSTabViewItem label ==\n");
    {
      NSTabViewItem *i = [[NSTabViewItem alloc] initWithIdentifier: @"id"];

      printf("DEFAULT  label=%s\n", show([i label]));
      [i setLabel: @"x"];
      printf("SET x    label=%s\n", show([i label]));
      [i setLabel: nil];
      printf("SET nil  label=%s\n", show([i label]));
    }

    printf("\n== NSToolbarItem label and paletteLabel ==\n");
    {
      NSToolbarItem *t = [[NSToolbarItem alloc] initWithItemIdentifier: @"id"];

      printf("DEFAULT  label=%s paletteLabel=%s\n",
             show([t label]), show([t paletteLabel]));
      [t setLabel: @"L"];
      [t setPaletteLabel: @"P"];
      printf("SET      label=%s paletteLabel=%s\n",
             show([t label]), show([t paletteLabel]));
      [t setLabel: nil];
      [t setPaletteLabel: nil];
      printf("SET nil  label=%s paletteLabel=%s\n",
             show([t label]), show([t paletteLabel]));
    }

    printf("\n== NSTabViewItem through an archive with no label ==\n");
    {
      /* The keyed decode path here calls setLabel: with whatever it decodes,
         so an archive with no label hands the setter a nil. */
      NSTabViewItem *i = [[NSTabViewItem alloc] initWithIdentifier: @"id"];
      NSData *d;
      NSTabViewItem *back;

      d = [NSKeyedArchiver archivedDataWithRootObject: i
                            requiringSecureCoding: NO
                                            error: NULL];
      if (d != nil)
        {
          back = [NSKeyedUnarchiver unarchivedObjectOfClass: [NSTabViewItem class]
                                                   fromData: d
                                                      error: NULL];
          printf("ARCHIVED label=%s\n", back == nil ? "(decode failed)"
                                                    : show([back label]));
        }
      else
        {
          printf("ARCHIVED (encode failed)\n");
        }
    }
  }
  return 0;
}
