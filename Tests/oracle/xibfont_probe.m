/* Ground truth for libs-gui #77: what font does a text field cell get from a
   XIB when the font element is <font key="font" usesAppearanceFont="YES"/>,
   which carries neither a name nor a metaFont?  Compared with the same cell
   written as metaFont="system", and with the standard font roles.
*/
#import <Cocoa/Cocoa.h>
#include <stdio.h>

static NSString * const kXib =
@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
@"<document type=\"com.apple.InterfaceBuilder3.Cocoa.XIB\" version=\"3.0\" toolsVersion=\"21507\" targetRuntime=\"MacOSX.Cocoa\" propertyAccessControl=\"none\" useAutolayout=\"YES\" customObjectInstantitationMethod=\"direct\">\n"
@"    <dependencies>\n"
@"        <deployment identifier=\"macosx\"/>\n"
@"        <plugIn identifier=\"com.apple.InterfaceBuilder.CocoaPlugin\" version=\"21507\"/>\n"
@"    </dependencies>\n"
@"    <objects>\n"
@"        <customObject id=\"-2\" userLabel=\"File's Owner\" customClass=\"NSApplication\"/>\n"
@"        <customObject id=\"-1\" userLabel=\"First Responder\" customClass=\"FirstResponder\"/>\n"
@"        <customObject id=\"-3\" userLabel=\"Application\" customClass=\"NSObject\"/>\n"
@"        <window title=\"Demo\" allowsToolTipsWhenApplicationIsInactive=\"NO\" autorecalculatesKeyViewLoop=\"NO\" releasedWhenClosed=\"NO\" animationBehavior=\"default\" id=\"QvC-M9-y7g\">\n"
@"            <windowStyleMask key=\"styleMask\" titled=\"YES\" closable=\"YES\"/>\n"
@"            <rect key=\"contentRect\" x=\"200\" y=\"200\" width=\"360\" height=\"160\"/>\n"
@"            <view key=\"contentView\" id=\"EiT-Mj-1SZ\">\n"
@"                <rect key=\"frame\" x=\"0.0\" y=\"0.0\" width=\"360\" height=\"160\"/>\n"
@"                <subviews>\n"
@"                    <textField horizontalHuggingPriority=\"251\" verticalHuggingPriority=\"750\" fixedFrame=\"YES\" translatesAutoresizingMaskIntoConstraints=\"NO\" id=\"appearance-1\">\n"
@"                        <rect key=\"frame\" x=\"18\" y=\"110\" width=\"320\" height=\"17\"/>\n"
@"                        <textFieldCell key=\"cell\" lineBreakMode=\"clipping\" title=\"APPEARANCE FONT LABEL\" id=\"appearance-1-cell\">\n"
@"                            <font key=\"font\" usesAppearanceFont=\"YES\"/>\n"
@"                        </textFieldCell>\n"
@"                    </textField>\n"
@"                    <textField horizontalHuggingPriority=\"251\" verticalHuggingPriority=\"750\" fixedFrame=\"YES\" translatesAutoresizingMaskIntoConstraints=\"NO\" id=\"meta-1\">\n"
@"                        <rect key=\"frame\" x=\"18\" y=\"80\" width=\"320\" height=\"17\"/>\n"
@"                        <textFieldCell key=\"cell\" lineBreakMode=\"clipping\" title=\"META SYSTEM LABEL\" id=\"meta-1-cell\">\n"
@"                            <font key=\"font\" metaFont=\"system\"/>\n"
@"                        </textFieldCell>\n"
@"                    </textField>\n"
@"                    <textField horizontalHuggingPriority=\"251\" verticalHuggingPriority=\"750\" fixedFrame=\"YES\" translatesAutoresizingMaskIntoConstraints=\"NO\" id=\"nofont-1\">\n"
@"                        <rect key=\"frame\" x=\"18\" y=\"50\" width=\"320\" height=\"17\"/>\n"
@"                        <textFieldCell key=\"cell\" lineBreakMode=\"clipping\" title=\"NO FONT ELEMENT AT ALL\" id=\"nofont-1-cell\"/>\n"
@"                    </textField>\n"
@"                </subviews>\n"
@"            </view>\n"
@"        </window>\n"
@"    </objects>\n"
@"</document>\n";

static void
reportFont(const char *label, NSFont *font)
{
  if (font == nil)
    {
      printf("%-26s nil\n", label);
      return;
    }
  printf("%-26s fontName=%s familyName=%s size=%.2f\n", label,
         [[font fontName] UTF8String],
         [[font familyName] UTF8String],
         (double)[font pointSize]);
  printf("%-26s advance('M')=%.2f  \"SCSI Speed Limit\" width=%.2f\n", "",
         (double)[font advancementForGlyph: 'M'].width,
         (double)[@"SCSI Speed Limit" sizeWithAttributes:
           [NSDictionary dictionaryWithObject: font
                                       forKey: NSFontAttributeName]].width);
}

static void
walk(NSView *view)
{
  NSEnumerator *e = [[view subviews] objectEnumerator];
  NSView *each;

  if ([view isKindOfClass: [NSTextField class]])
    {
      NSCell *cell = [(NSControl *)view cell];

      printf("\n--- text field \"%s\"\n", [[cell title] UTF8String]);
      reportFont("  cell font", [cell font]);
    }
  while ((each = [e nextObject]) != nil)
    {
      walk(each);
    }
}

int
main(void)
{
  @autoreleasepool
    {
      NSString *dir = @"/tmp/xibfont";
      NSString *xib = [dir stringByAppendingPathComponent: @"Probe.xib"];
      NSString *nib = [dir stringByAppendingPathComponent: @"Probe.nib"];
      NSError *error = nil;
      int rc;

      [NSApplication sharedApplication];

      printf("=== the standard font roles on this system ===\n");
      printf("systemFontSize=%.2f labelFontSize=%.2f smallSystemFontSize=%.2f\n",
             (double)[NSFont systemFontSize], (double)[NSFont labelFontSize],
             (double)[NSFont smallSystemFontSize]);
      reportFont("systemFont(systemFontSize)",
                 [NSFont systemFontOfSize: [NSFont systemFontSize]]);
      reportFont("labelFont(labelFontSize)",
                 [NSFont labelFontOfSize: [NSFont labelFontSize]]);
      reportFont("systemFontOfSize:0", [NSFont systemFontOfSize: 0]);
      reportFont("fontWithName:nil size:12", [NSFont fontWithName: nil size: 12]);
      reportFont("fontWithName:bogus size:12",
                 [NSFont fontWithName: @"NoSuchFaceHere" size: 12]);

      [[NSFileManager defaultManager] createDirectoryAtPath: dir
                               withIntermediateDirectories: YES
                                                attributes: nil
                                                     error: NULL];
      if (![kXib writeToFile: xib atomically: YES
                    encoding: NSUTF8StringEncoding error: &error])
        {
          printf("could not write the xib: %s\n",
                 [[error description] UTF8String]);
          return 1;
        }

      rc = system("/usr/bin/ibtool --errors --warnings --output-format "
                  "human-readable-text --compile /tmp/xibfont/Probe.nib "
                  "/tmp/xibfont/Probe.xib 2>&1");
      printf("\nibtool exit=%d\n", rc);
      fflush(stdout);

      if (![[NSFileManager defaultManager] fileExistsAtPath: nib])
        {
          printf("no compiled nib, cannot load\n");
          return 1;
        }

      {
        NSNib *loaded = [[NSNib alloc]
                          initWithContentsOfURL: [NSURL fileURLWithPath: nib]];
        NSArray *top = nil;
        BOOL ok = [loaded instantiateWithOwner: NSApp topLevelObjects: &top];

        printf("instantiated=%d topLevelObjects=%lu\n", ok,
               (unsigned long)[top count]);

        for (id object in top)
          {
            if ([object isKindOfClass: [NSWindow class]])
              {
                walk([(NSWindow *)object contentView]);
              }
          }
      }

      printf("\ndone\n");
    }
  return 0;
}
