#import <Cocoa/Cocoa.h>

static NSPredicateEditorRowTemplate *comparisonTemplate(void)
{
  return [[NSPredicateEditorRowTemplate alloc]
    initWithLeftExpressions: @[[NSExpression expressionForKeyPath: @"name"],
                               [NSExpression expressionForKeyPath: @"size"]]
rightExpressionAttributeType: NSStringAttributeType
                    modifier: NSDirectPredicateModifier
                   operators: @[@(NSEqualToPredicateOperatorType),
                                @(NSContainsPredicateOperatorType)]
                     options: 0];
}

static NSPredicateEditorRowTemplate *compoundTemplate(void)
{
  return [[NSPredicateEditorRowTemplate alloc]
    initWithCompoundTypes: @[@(NSAndPredicateType), @(NSOrPredicateType)]];
}

static void report(NSPredicateEditor *e, const char *label)
{
  printf("%s: rows=%ld predicate=%s\n", label, (long)[e numberOfRows],
         [[[e predicate] description] UTF8String]);
  for (NSInteger i = 0; i < [e numberOfRows]; i++)
    {
      NSArray *criteria = [e criteriaForRow: i];
      NSArray *values = [e displayValuesForRow: i];
      NSMutableString *classes = [NSMutableString string];

      for (id c in criteria)
        {
          [classes appendFormat: @"%@ ", NSStringFromClass([c class])];
        }
      printf("   row %ld type=%lu parent=%ld criteria=[%s] values=%lu",
             (long)i, (unsigned long)[e rowTypeForRow: i],
             (long)[e parentRowForRow: i], [classes UTF8String],
             (unsigned long)[values count]);
      for (id v in values)
        {
          printf(" %s", [NSStringFromClass([v class]) UTF8String]);
        }
      printf("\n      predicateForRow=%s\n",
             [[[e predicateForRow: i] description] UTF8String]);
    }
}

int main(int argc, const char **argv)
{
  @autoreleasepool
    {
      [NSApplication sharedApplication];

      NSPredicateEditor *e = [[NSPredicateEditor alloc]
        initWithFrame: NSMakeRect(0, 0, 500, 300)];

      printf("== defaults\n");
      printf("  rowTemplates    %s\n",
             [[[e rowTemplates] description] UTF8String]);
      printf("  numberOfRows    %ld\n", (long)[e numberOfRows]);
      printf("  nestingMode     %lu\n", (unsigned long)[e nestingMode]);
      printf("  rowHeight       %g\n", (double)[e rowHeight]);
      printf("  delegate        %s\n", [e delegate] ? "set" : "nil");
      printf("  objectValue     %s\n",
             [[[e objectValue] description] UTF8String]);
      printf("  predicate       %s\n", [[[e predicate] description] UTF8String]);

      NSArray *templates = @[compoundTemplate(), comparisonTemplate()];
      [e setRowTemplates: templates];
      printf("\n== after setRowTemplates: (compound first, then comparison)\n");
      printf("  rowTemplates count %lu\n",
             (unsigned long)[[e rowTemplates] count]);
      report(e, "  state");

      [e addRow: nil];
      report(e, "\nafter addRow");
      [e addRow: nil];
      report(e, "\nafter a second addRow");

      printf("\n== objectValue now: %s\n",
             [[[e objectValue] description] UTF8String]);

      /* Showing an existing predicate. */
      NSPredicate *p = [NSPredicate predicateWithFormat:
        @"name == 'x' AND size CONTAINS 'y'"];
      @try
        {
          [e setObjectValue: p];
          report(e, "\nafter setObjectValue: with a compound predicate");
        }
      @catch (NSException *ex)
        {
          printf("\nsetObjectValue: raised %s: %s\n", [[ex name] UTF8String],
                 [[ex reason] UTF8String]);
        }

      /* And whether a delegate is consulted at all. */
      printf("\ndelegate after all that: %s\n", [e delegate] ? "set" : "nil");
    }
  return 0;
}
