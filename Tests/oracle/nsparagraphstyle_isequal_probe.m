#import <Cocoa/Cocoa.h>
#include <stdio.h>

/* Does AppKit's NSParagraphStyle isEqual: take textBlocks, textLists and the
   base writing direction into account?  GNUstep compares tabStops and
   textLists only, so styles differing only in their text blocks merge into
   one attribute run. */

static NSMutableParagraphStyle *
style(void)
{
  return [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
}

int main(void)
{
  @autoreleasepool
    {
      setbuf(stdout, NULL);

      NSTextBlock *b1 = [[NSTextBlock alloc] init];
      NSTextBlock *b2 = [[NSTextBlock alloc] init];
      NSTextList *l1 = [[NSTextList alloc] initWithMarkerFormat: @"{decimal}" options: 0];
      NSTextList *l2 = [[NSTextList alloc] initWithMarkerFormat: @"{box}" options: 0];
      NSMutableParagraphStyle *a, *b;

      a = style(); b = style();
      printf("identical defaults                    isEqual=%d\n", (int)[a isEqual: b]);

      a = style(); b = style();
      [a setTextBlocks: [NSArray arrayWithObject: b1]];
      [b setTextBlocks: [NSArray arrayWithObject: b2]];
      printf("differ only in textBlocks             isEqual=%d\n", (int)[a isEqual: b]);

      a = style(); b = style();
      [a setTextBlocks: [NSArray arrayWithObject: b1]];
      printf("one has textBlocks, other has none    isEqual=%d\n", (int)[a isEqual: b]);

      a = style(); b = style();
      [a setTextBlocks: [NSArray arrayWithObject: b1]];
      [b setTextBlocks: [NSArray arrayWithObject: b1]];
      printf("same textBlocks array contents        isEqual=%d\n", (int)[a isEqual: b]);

      a = style(); b = style();
      [a setTextLists: [NSArray arrayWithObject: l1]];
      [b setTextLists: [NSArray arrayWithObject: l2]];
      printf("differ only in textLists              isEqual=%d\n", (int)[a isEqual: b]);

      a = style(); b = style();
      [a setBaseWritingDirection: NSWritingDirectionRightToLeft];
      printf("differ only in baseWritingDirection   isEqual=%d\n", (int)[a isEqual: b]);

      a = style(); b = style();
      [a setHeaderLevel: 2];
      printf("differ only in headerLevel            isEqual=%d\n", (int)[a isEqual: b]);

      /* Does an attributed string coalesce two paragraphs whose styles differ
         only in their text blocks? */
      {
	NSMutableAttributedString *s
	  = [[NSMutableAttributedString alloc] init];
	NSMutableParagraphStyle *p1 = style();
	NSMutableParagraphStyle *p2 = style();
	NSRange eff;

	[p1 setTextBlocks: [NSArray arrayWithObject: b1]];
	[p2 setTextBlocks: [NSArray arrayWithObject: b2]];
	[s appendAttributedString: [[[NSAttributedString alloc]
	  initWithString: @"one\n" attributes:
	    [NSDictionary dictionaryWithObject: p1
	      forKey: NSParagraphStyleAttributeName]] autorelease]];
	[s appendAttributedString: [[[NSAttributedString alloc]
	  initWithString: @"two\n" attributes:
	    [NSDictionary dictionaryWithObject: p2
	      forKey: NSParagraphStyleAttributeName]] autorelease]];
	[s attribute: NSParagraphStyleAttributeName atIndex: 0
	  effectiveRange: &eff];
	printf("first run of a 8 char two block string %lu,%lu\n",
	  (unsigned long)eff.location, (unsigned long)eff.length);
      }

      printf("done\n");
    }
  return 0;
}
