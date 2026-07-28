#import <Cocoa/Cocoa.h>
#include <stdio.h>

/* When a value binding has no continuous option, does AppKit push the typed
   text to the bound object when the field editor stops editing, or only when
   the control sends its action?  libs-gui pushes it only from -sendAction:to:. */

@interface Recorder : NSObject
{
  NSString *text;
}
@property (retain) NSString *text;
@end

@implementation Recorder
@synthesize text;
@end

static void
report(const char *what, Recorder *r)
{
  printf("%-46s model=%s\n", what, r.text ? [r.text UTF8String] : "(nil)");
}

int main(void)
{
  @autoreleasepool
    {
      setbuf(stdout, NULL);
      [NSApplication sharedApplication];

      NSWindow *win = [[NSWindow alloc]
	initWithContentRect: NSMakeRect(0, 0, 200, 60)
		  styleMask: NSWindowStyleMaskTitled
		    backing: NSBackingStoreBuffered
		      defer: NO];
      NSTextField *field = [[NSTextField alloc]
	initWithFrame: NSMakeRect(10, 10, 180, 22)];
      Recorder *model = [[Recorder alloc] init];
      NSText *editor;

      [[win contentView] addSubview: field];
      model.text = @"start";
      [field bind: NSValueBinding toObject: model
	withKeyPath: @"text" options: nil];
      printf("after bind, field shows %s\n", [[field stringValue] UTF8String]);

      [win makeKeyAndOrderFront: nil];
      [win makeFirstResponder: field];
      editor = [field currentEditor];
      printf("field editor %s\n", editor ? "present" : "MISSING");
      if (editor == nil)
	{
	  printf("cannot simulate typing\n");
	  return 1;
	}

      [editor setString: @"typed"];
      [(NSTextView *)editor didChangeText];
      report("plain binding, mid edit", model);

      [win makeFirstResponder: nil];
      report("plain binding, after end editing", model);

      /* And the same with the continuous option, for comparison. */
      Recorder *model2 = [[Recorder alloc] init];
      NSTextField *field2 = [[NSTextField alloc]
	initWithFrame: NSMakeRect(10, 34, 180, 22)];

      [[win contentView] addSubview: field2];
      model2.text = @"start";
      [field2 bind: NSValueBinding toObject: model2
	 withKeyPath: @"text"
	     options: [NSDictionary dictionaryWithObject: @YES
	       forKey: NSContinuouslyUpdatesValueBindingOption]];
      [win makeFirstResponder: field2];
      editor = [field2 currentEditor];
      if (editor != nil)
	{
	  [editor setString: @"typed too"];
	  [(NSTextView *)editor didChangeText];
	  report("continuous binding, mid edit", model2);
	  [win makeFirstResponder: nil];
	  report("continuous binding, after end editing", model2);
	}
      else
	{
	  printf("second field editor MISSING\n");
	}

      printf("done\n");
    }
  return 0;
}
