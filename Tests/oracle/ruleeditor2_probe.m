#import <Cocoa/Cocoa.h>

/* A delegate that distinguishes the two row types the way a real one does:
   a compound row offers All/Any/None, a simple row offers key path, operator
   and a value field.
*/
@interface Delegate : NSObject <NSRuleEditorDelegate>
@end

@implementation Delegate

- (NSInteger) ruleEditor: (NSRuleEditor *)editor
numberOfChildrenForCriterion: (id)criterion
             withRowType: (NSRuleEditorRowType)rowType
{
  if (rowType == NSRuleEditorRowTypeCompound)
    {
      return criterion == nil ? 3 : 0;
    }
  if (criterion == nil)
    {
      return 1;
    }
  if ([criterion isEqual: @"name"])
    {
      return 1;
    }
  if ([criterion isEqual: @"is"])
    {
      return 1;
    }
  return 0;
}

- (id) ruleEditor: (NSRuleEditor *)editor
            child: (NSInteger)index
     forCriterion: (id)criterion
      withRowType: (NSRuleEditorRowType)rowType
{
  if (rowType == NSRuleEditorRowTypeCompound)
    {
      return @[@"All", @"Any", @"None"][index];
    }
  if (criterion == nil)
    {
      return @"name";
    }
  if ([criterion isEqual: @"name"])
    {
      return @"is";
    }
  return @"value";
}

- (id) ruleEditor: (NSRuleEditor *)editor
displayValueForCriterion: (id)criterion
            inRow: (NSInteger)row
{
  if ([criterion isEqual: @"value"])
    {
      NSTextField *f = [[NSTextField alloc] initWithFrame:
                          NSMakeRect(0, 0, 100, 22)];
      [f setStringValue: [NSString stringWithFormat: @"v%ld", (long)row]];
      return f;
    }
  return criterion;
}

- (NSDictionary *) ruleEditor: (NSRuleEditor *)editor
   predicatePartsForCriterion: (id)criterion
             withDisplayValue: (id)value
                        inRow: (NSInteger)row
{
  if ([criterion isEqual: @"All"])
    {
      return @{NSRuleEditorPredicateCompoundType: @(NSAndPredicateType)};
    }
  if ([criterion isEqual: @"Any"])
    {
      return @{NSRuleEditorPredicateCompoundType: @(NSOrPredicateType)};
    }
  if ([criterion isEqual: @"None"])
    {
      return @{NSRuleEditorPredicateCompoundType: @(NSNotPredicateType)};
    }
  if ([criterion isEqual: @"name"])
    {
      return @{NSRuleEditorPredicateLeftExpression:
                 [NSExpression expressionForKeyPath: @"name"]};
    }
  if ([criterion isEqual: @"is"])
    {
      return @{NSRuleEditorPredicateOperatorType:
                 @(NSEqualToPredicateOperatorType)};
    }
  return @{NSRuleEditorPredicateRightExpression:
             [NSExpression expressionForConstantValue: [value stringValue]]};
}

@end

static void report(NSRuleEditor *e, const char *label)
{
  printf("%s: rows=%ld predicate=%s\n", label, (long)[e numberOfRows],
         [[[e predicate] description] UTF8String]);
  for (NSInteger i = 0; i < [e numberOfRows]; i++)
    {
      printf("   row %ld type=%lu parent=%ld subrows=%s criteria=%s\n",
             (long)i, (unsigned long)[e rowTypeForRow: i],
             (long)[e parentRowForRow: i],
             [[[e subrowIndexesForRow: i] description] UTF8String],
             [[[e criteriaForRow: i] description] UTF8String]);
    }
}

int main(int argc, const char **argv)
{
  @autoreleasepool
    {
      [NSApplication sharedApplication];
      Delegate *d = [Delegate new];

      NSUInteger modes[] = {NSRuleEditorNestingModeSingle,
                            NSRuleEditorNestingModeList,
                            NSRuleEditorNestingModeCompound,
                            NSRuleEditorNestingModeSimple};
      const char *names[] = {"Single", "List", "Compound", "Simple"};

      for (unsigned m = 0; m < 4; m++)
        {
          NSRuleEditor *e = [[NSRuleEditor alloc]
            initWithFrame: NSMakeRect(0, 0, 400, 200)];
          [e setNestingMode: modes[m]];
          [e setDelegate: d];

          printf("\n===== nesting mode %s (%lu)\n", names[m],
                 (unsigned long)modes[m]);
          [e addRow: nil];
          report(e, "after first addRow");
          [e addRow: nil];
          report(e, "after second addRow");

          if (modes[m] == NSRuleEditorNestingModeCompound)
            {
              [e insertRowAtIndex: [e numberOfRows]
                         withType: NSRuleEditorRowTypeCompound
                    asSubrowOfRow: 0
                          animate: NO];
              report(e, "after inserting a compound subrow of 0");
            }
        }

      /* Setting criteria and display values directly. */
      NSRuleEditor *e = [[NSRuleEditor alloc]
        initWithFrame: NSMakeRect(0, 0, 400, 200)];
      [e setDelegate: d];
      [e addRow: nil];
      printf("\n===== setCriteria:andDisplayValues:forRowAtIndex:\n");
      printf("before: %s\n", [[[e predicate] description] UTF8String]);
      NSArray *criteria = [e criteriaForRow: [e numberOfRows] - 1];
      NSMutableArray *values = [[e displayValuesForRow: [e numberOfRows] - 1]
                                 mutableCopy];
      if ([values count] > 2 && [[values objectAtIndex: 2]
                                  respondsToSelector: @selector(setStringValue:)])
        {
          [[values objectAtIndex: 2] setStringValue: @"changed"];
        }
      [e setCriteria: criteria
    andDisplayValues: values
       forRowAtIndex: [e numberOfRows] - 1];
      printf("after:  %s\n", [[[e predicate] description] UTF8String]);

      /* Selection and removal. */
      [e selectRowIndexes: [NSIndexSet indexSetWithIndex: 0]
     byExtendingSelection: NO];
      printf("selected %s\n",
             [[[e selectedRowIndexes] description] UTF8String]);
      [e removeRowsAtIndexes: [NSIndexSet indexSetWithIndex: 0]
              includeSubrows: YES];
      printf("after removing row 0 with subrows: rows=%ld\n",
             (long)[e numberOfRows]);
    }
  return 0;
}
