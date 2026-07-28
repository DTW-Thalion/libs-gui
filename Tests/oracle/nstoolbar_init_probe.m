#import <Cocoa/Cocoa.h>

static void dump(NSString *label, NSToolbar *tb)
{
  printf("%s\n", [label UTF8String]);
  printf("  toolbar               = %s\n", tb == nil ? "nil" : "non-nil");
  if (tb == nil)
    {
      return;
    }
  printf("  identifier            = '%s'\n", [[tb identifier] UTF8String]);
  printf("  isVisible             = %d\n", (int)[tb isVisible]);
  printf("  displayMode           = %d\n", (int)[tb displayMode]);
  printf("  sizeMode              = %d\n", (int)[tb sizeMode]);
  printf("  showsBaselineSeparator= %d\n", (int)[tb showsBaselineSeparator]);
  printf("  allowsUserCustomization=%d\n", (int)[tb allowsUserCustomization]);
  printf("  autosavesConfiguration =%d\n", (int)[tb autosavesConfiguration]);
  printf("  items count           = %d\n", (int)[[tb items] count]);
  printf("  delegate              = %s\n", [tb delegate] == nil ? "nil" : "non-nil");
}

int main(int argc, const char **argv)
{
  @autoreleasepool
    {
      [NSApplication sharedApplication];

      printf("NSToolbarDisplayModeDefault      = %d\n",
             (int)NSToolbarDisplayModeDefault);
      printf("NSToolbarDisplayModeIconAndLabel = %d\n",
             (int)NSToolbarDisplayModeIconAndLabel);
      printf("NSToolbarSizeModeDefault         = %d\n",
             (int)NSToolbarSizeModeDefault);
      printf("NSToolbarSizeModeRegular         = %d\n",
             (int)NSToolbarSizeModeRegular);
      printf("\n");

      dump(@"A. [[NSToolbar alloc] init]", [[NSToolbar alloc] init]);
      printf("\n");
      dump(@"B. [[NSToolbar alloc] initWithIdentifier: @\"\"]",
           [[NSToolbar alloc] initWithIdentifier: @""]);
      printf("\n");
      dump(@"C. [[NSToolbar alloc] initWithIdentifier: @\"tb269\"]",
           [[NSToolbar alloc] initWithIdentifier: @"tb269"]);
      printf("\n");

      /* Does a toolbar made with -init attach to a window and stay visible
         without an explicit -setVisible: YES? */
      NSWindow *win = [[NSWindow alloc]
        initWithContentRect: NSMakeRect(0, 0, 400, 300)
                  styleMask: NSWindowStyleMaskTitled
                    backing: NSBackingStoreBuffered
                      defer: NO];
      NSToolbar *tb = [[NSToolbar alloc] init];
      [win setToolbar: tb];
      printf("D. after -[NSWindow setToolbar:] with an -init toolbar\n");
      printf("  window toolbar == tb = %d\n", (int)([win toolbar] == tb));
      printf("  isVisible            = %d\n", (int)[tb isVisible]);

      /* Identity: are two -init toolbars distinct, and does the second one
         inherit config from the first (the 'toolbar model' path)? */
      NSToolbar *t1 = [[NSToolbar alloc] initWithIdentifier: @"shared269"];
      [t1 setDisplayMode: NSToolbarDisplayModeLabelOnly];
      [t1 setVisible: NO];
      NSToolbar *t2 = [[NSToolbar alloc] initWithIdentifier: @"shared269"];
      printf("\nE. second toolbar with the same identifier\n");
      printf("  t2 displayMode = %d (t1 set LabelOnly=%d)\n",
             (int)[t2 displayMode], (int)NSToolbarDisplayModeLabelOnly);
      printf("  t2 isVisible   = %d (t1 set NO)\n", (int)[t2 isVisible]);
    }
  return 0;
}
