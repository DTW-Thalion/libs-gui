#import <Cocoa/Cocoa.h>
#include <stdio.h>

/* AppKit ground truth for -rangeOfTextBlock:atIndex: and
   -rangeOfTextTable:atIndex: with adjacent paragraphs carrying different
   blocks, mirroring the layout of the existing rangeOfTextList test. */

static void
show(const char *what, NSRange r)
{
  if (r.location == NSNotFound)
    printf("%-46s NSNotFound,%lu\n", what, (unsigned long)r.length);
  else
    printf("%-46s %lu,%lu\n", what,
      (unsigned long)r.location, (unsigned long)r.length);
}

int main(void)
{
  @autoreleasepool
    {
      setbuf(stdout, NULL);

      NSTextTable *table1 = [[NSTextTable alloc] init];
      NSTextTable *table2 = [[NSTextTable alloc] init];

      NSTextBlock *block1 = [[NSTextBlock alloc] init];
      NSTextBlock *block2 = [[NSTextBlock alloc] init];
      NSTextBlock *block3 = [[NSTextBlock alloc] init];

      NSTextTableBlock *cell1 = [[NSTextTableBlock alloc]
	initWithTable: table1 startingRow: 0 rowSpan: 1
	startingColumn: 0 columnSpan: 1];
      NSTextTableBlock *cell2 = [[NSTextTableBlock alloc]
	initWithTable: table1 startingRow: 1 rowSpan: 1
	startingColumn: 0 columnSpan: 1];
      NSTextTableBlock *cell3 = [[NSTextTableBlock alloc]
	initWithTable: table2 startingRow: 0 rowSpan: 1
	startingColumn: 0 columnSpan: 1];

      NSMutableParagraphStyle *plain = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
      NSMutableParagraphStyle *s2 = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
      NSMutableParagraphStyle *s3 = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
      NSMutableParagraphStyle *s4 = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];

      [s2 setTextBlocks: [NSArray arrayWithObject: block1]];
      [s3 setTextBlocks: [NSArray arrayWithObjects: block1, block2, nil]];
      [s4 setTextBlocks: [NSArray arrayWithObject: block3]];

      NSMutableAttributedString *storage
	= [[NSMutableAttributedString alloc] init];
      NSUInteger pos1, pos2, pos3, pos4, pos5, pos6;

#define APPEND(TXT, STYLE) \
      [storage appendAttributedString: \
	[[[NSAttributedString alloc] initWithString: TXT \
	  attributes: [NSDictionary dictionaryWithObject: STYLE \
	    forKey: NSParagraphStyleAttributeName]] autorelease]]

      pos1 = [storage length];  APPEND(@"before\n", plain);
      pos2 = [storage length];  APPEND(@"block 1\n", s2);
      pos3 = [storage length];  APPEND(@"nested\n", s3);
      pos4 = [storage length];  APPEND(@"block 1\n", s2);
      pos5 = [storage length];  APPEND(@"block 3\n", s4);
      pos6 = [storage length];  APPEND(@"ending\n", plain);

      printf("positions %lu %lu %lu %lu %lu %lu len %lu\n",
	(unsigned long)pos1, (unsigned long)pos2, (unsigned long)pos3,
	(unsigned long)pos4, (unsigned long)pos5, (unsigned long)pos6,
	(unsigned long)[storage length]);

      show("block2 at nested", [storage rangeOfTextBlock: block2 atIndex: pos3 + 1]);
      show("block1 at nested", [storage rangeOfTextBlock: block1 atIndex: pos3 + 1]);
      show("block1 at its own paragraph", [storage rangeOfTextBlock: block1 atIndex: pos2 + 1]);
      show("block3 (adjacent) at its paragraph", [storage rangeOfTextBlock: block3 atIndex: pos5 + 1]);
      show("block1 at block3 paragraph", [storage rangeOfTextBlock: block1 atIndex: pos5]);
      show("block1 at plain paragraph", [storage rangeOfTextBlock: block1 atIndex: pos1]);

      /* Same layout again, with table cells instead of plain blocks. */
      NSMutableParagraphStyle *t2 = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
      NSMutableParagraphStyle *t3 = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
      NSMutableParagraphStyle *t4 = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];

      [t2 setTextBlocks: [NSArray arrayWithObject: cell1]];
      [t3 setTextBlocks: [NSArray arrayWithObject: cell2]];
      [t4 setTextBlocks: [NSArray arrayWithObject: cell3]];

      NSMutableAttributedString *ts
	= [[NSMutableAttributedString alloc] init];
      NSUInteger q1, q2, q3, q4, q5;

      q1 = [ts length];
      [ts appendAttributedString: [[[NSAttributedString alloc] initWithString: @"before\n"
	attributes: [NSDictionary dictionaryWithObject: plain forKey: NSParagraphStyleAttributeName]] autorelease]];
      q2 = [ts length];
      [ts appendAttributedString: [[[NSAttributedString alloc] initWithString: @"cell 1\n"
	attributes: [NSDictionary dictionaryWithObject: t2 forKey: NSParagraphStyleAttributeName]] autorelease]];
      q3 = [ts length];
      [ts appendAttributedString: [[[NSAttributedString alloc] initWithString: @"cell 2\n"
	attributes: [NSDictionary dictionaryWithObject: t3 forKey: NSParagraphStyleAttributeName]] autorelease]];
      q4 = [ts length];
      [ts appendAttributedString: [[[NSAttributedString alloc] initWithString: @"other table\n"
	attributes: [NSDictionary dictionaryWithObject: t4 forKey: NSParagraphStyleAttributeName]] autorelease]];
      q5 = [ts length];
      [ts appendAttributedString: [[[NSAttributedString alloc] initWithString: @"ending\n"
	attributes: [NSDictionary dictionaryWithObject: plain forKey: NSParagraphStyleAttributeName]] autorelease]];

      printf("table positions %lu %lu %lu %lu %lu len %lu\n",
	(unsigned long)q1, (unsigned long)q2, (unsigned long)q3,
	(unsigned long)q4, (unsigned long)q5, (unsigned long)[ts length]);

      show("table1 at cell 1", [ts rangeOfTextTable: table1 atIndex: q2 + 1]);
      show("table1 at cell 2", [ts rangeOfTextTable: table1 atIndex: q3 + 1]);
      show("table2 (adjacent) at its cell", [ts rangeOfTextTable: table2 atIndex: q4 + 1]);
      show("table1 at table2 cell", [ts rangeOfTextTable: table1 atIndex: q4]);
      show("table1 at plain paragraph", [ts rangeOfTextTable: table1 atIndex: q1]);

      printf("done\n");
    }
  return 0;
}
