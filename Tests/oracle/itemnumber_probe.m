#import <Cocoa/Cocoa.h>
#include <stdio.h>

/* AppKit ground truth for -itemNumberInTextList:atIndex:, in the shapes the
   GNUstep implementation makes decisions about: a flat list, a nested
   sublist, a location in a different list, and a location in no list. */

#define APPEND(S, TXT, STYLE) \
  [S appendAttributedString: [[[NSAttributedString alloc] initWithString: TXT \
    attributes: [NSDictionary dictionaryWithObject: STYLE \
      forKey: NSParagraphStyleAttributeName]] autorelease]]

int main(void)
{
  @autoreleasepool
    {
      setbuf(stdout, NULL);

      NSTextList *list1 = [[NSTextList alloc] initWithMarkerFormat: @"{decimal}" options: 0];
      NSTextList *list2 = [[NSTextList alloc] initWithMarkerFormat: @"{box}" options: 0];
      NSTextList *list3 = [[NSTextList alloc] initWithMarkerFormat: @"{box}" options: 0];

      NSMutableParagraphStyle *plain = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
      NSMutableParagraphStyle *s2 = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
      NSMutableParagraphStyle *s3 = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
      NSMutableParagraphStyle *s4 = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];

      [s2 setTextLists: [NSArray arrayWithObject: list1]];
      [s3 setTextLists: [NSArray arrayWithObjects: list1, list2, nil]];
      [s4 setTextLists: [NSArray arrayWithObject: list3]];

      /* Flat list of five items. */
      {
	NSMutableAttributedString *flat = [[NSMutableAttributedString alloc] init];
	NSUInteger starts[5];
	int i;

	for (i = 0; i < 5; i++)
	  {
	    starts[i] = [flat length];
	    APPEND(flat, @"item\n", s2);
	  }
	printf("flat list item numbers:");
	for (i = 0; i < 5; i++)
	  printf(" %ld", (long)[flat itemNumberInTextList: list1 atIndex: starts[i] + 1]);
	printf("\n");
	printf("flat, at the newline of item 3        %ld\n",
	  (long)[flat itemNumberInTextList: list1 atIndex: starts[2] + 4]);
	printf("flat, at index 0                      %ld\n",
	  (long)[flat itemNumberInTextList: list1 atIndex: 0]);
      }

      /* Nested: plain, list1, list1+list2, list1, list3, plain. */
      {
	NSMutableAttributedString *s = [[NSMutableAttributedString alloc] init];
	NSUInteger pos1, pos2, pos3, pos4, pos5, pos6;

	pos1 = [s length];  APPEND(s, @"before\n", plain);
	pos2 = [s length];  APPEND(s, @"list 1 a\n", s2);
	pos3 = [s length];  APPEND(s, @"sub item\n", s3);
	pos4 = [s length];  APPEND(s, @"list 1 b\n", s2);
	pos5 = [s length];  APPEND(s, @"other list\n", s4);
	pos6 = [s length];  APPEND(s, @"ending\n", plain);

	printf("positions %lu %lu %lu %lu %lu %lu\n",
	  (unsigned long)pos1, (unsigned long)pos2, (unsigned long)pos3,
	  (unsigned long)pos4, (unsigned long)pos5, (unsigned long)pos6);

	printf("list1 at its first paragraph          %ld\n",
	  (long)[s itemNumberInTextList: list1 atIndex: pos2 + 1]);
	printf("list1 at the nested paragraph         %ld\n",
	  (long)[s itemNumberInTextList: list1 atIndex: pos3 + 1]);
	printf("list1 after the nested paragraph      %ld\n",
	  (long)[s itemNumberInTextList: list1 atIndex: pos4 + 1]);
	printf("list2 at the nested paragraph         %ld\n",
	  (long)[s itemNumberInTextList: list2 atIndex: pos3 + 1]);
	printf("list1 at a paragraph in another list  %ld\n",
	  (long)[s itemNumberInTextList: list1 atIndex: pos5 + 1]);
	printf("list1 at a paragraph with no list     %ld\n",
	  (long)[s itemNumberInTextList: list1 atIndex: pos1 + 1]);
	printf("list3 at its own paragraph            %ld\n",
	  (long)[s itemNumberInTextList: list3 atIndex: pos5 + 1]);
      }

      printf("done\n");
    }
  return 0;
}
