#import <Cocoa/Cocoa.h>

/* A delegate offering: [key path] -> [is, is not] -> [a text field]
   so a row is three criteria deep.
*/
@interface Delegate : NSObject <NSRuleEditorDelegate>
{
@public
  NSMutableArray *log;
}
@end

@implementation Delegate

- (id) init
{
  if ((self = [super init]) != nil)
    {
      log = [NSMutableArray new];
    }
  return self;
}

- (NSInteger) ruleEditor: (NSRuleEditor *)editor
numberOfChildrenForCriterion: (id)criterion
             withRowType: (NSRuleEditorRowType)rowType
{
  [log addObject: [NSString stringWithFormat: @"count(%@,%ld)",
                     criterion ? criterion : @"root", (long)rowType]];
  if (criterion == nil)
    {
      return 2;			// two key paths
    }
  if ([criterion isEqual: @"name"] || [criterion isEqual: @"size"])
    {
      return 2;			// two operators
    }
  if ([criterion isEqual: @"is"] || [criterion isEqual: @"is not"])
    {
      return 1;			// the value field
    }
  return 0;
}

- (id) ruleEditor: (NSRuleEditor *)editor
            child: (NSInteger)index
     forCriterion: (id)criterion
      withRowType: (NSRuleEditorRowType)rowType
{
  [log addObject: [NSString stringWithFormat: @"child(%@,%ld)",
                     criterion ? criterion : @"root", (long)index]];
  if (criterion == nil)
    {
      return index == 0 ? @"name" : @"size";
    }
  if ([criterion isEqual: @"name"] || [criterion isEqual: @"size"])
    {
      return index == 0 ? @"is" : @"is not";
    }
  return @"value";
}

- (id) ruleEditor: (NSRuleEditor *)editor
displayValueForCriterion: (id)criterion
            inRow: (NSInteger)row
{
  [log addObject: [NSString stringWithFormat: @"display(%@)", criterion]];
  if ([criterion isEqual: @"value"])
    {
      NSTextField *f = [[NSTextField alloc] initWithFrame:
                          NSMakeRect(0, 0, 100, 22)];
      [f setStringValue: @"typed"];
      return f;
    }
  return criterion;
}

- (NSDictionary *) ruleEditor: (NSRuleEditor *)editor
   predicatePartsForCriterion: (id)criterion
             withDisplayValue: (id)value
                        inRow: (NSInteger)row
{
  [log addObject: [NSString stringWithFormat: @"parts(%@)", criterion]];
  if ([criterion isEqual: @"name"] || [criterion isEqual: @"size"])
    {
      return @{NSRuleEditorPredicateLeftExpression:
                 [NSExpression expressionForKeyPath: criterion]};
    }
  if ([criterion isEqual: @"is"])
    {
      return @{NSRuleEditorPredicateOperatorType:
                 @(NSEqualToPredicateOperatorType)};
    }
  if ([criterion isEqual: @"is not"])
    {
      return @{NSRuleEditorPredicateOperatorType:
                 @(NSNotEqualToPredicateOperatorType)};
    }
  return @{NSRuleEditorPredicateRightExpression:
             [NSExpression expressionForConstantValue: [value stringValue]]};
}

- (void) ruleEditorRowsDidChange: (NSNotification *)notification
{
  [log addObject: @"rowsDidChange"];
}

@end

int main(int argc, const char **argv)
{
  @autoreleasepool
    {
      [NSApplication sharedApplication];

      NSRuleEditor *editor = [[NSRuleEditor alloc]
        initWithFrame: NSMakeRect(0, 0, 400, 200)];

      printf("== defaults on a fresh editor\n");
      printf("  numberOfRows        %ld\n", (long)[editor numberOfRows]);
      printf("  nestingMode         %lu\n", (unsigned long)[editor nestingMode]);
      printf("  rowHeight           %g\n", (double)[editor rowHeight]);
      printf("  isEditable          %d\n", (int)[editor isEditable]);
      printf("  canRemoveAllRows    %d\n", (int)[editor canRemoveAllRows]);
      printf("  delegate            %s\n", [editor delegate] ? "set" : "nil");
      printf("  rowClass            %s\n",
             [NSStringFromClass([editor rowClass]) UTF8String]);
      printf("  criteriaKeyPath     %s\n", [[editor criteriaKeyPath] UTF8String]);
      printf("  displayValuesKeyPath %s\n",
             [[editor displayValuesKeyPath] UTF8String]);
      printf("  rowTypeKeyPath      %s\n", [[editor rowTypeKeyPath] UTF8String]);
      printf("  subrowsKeyPath      %s\n", [[editor subrowsKeyPath] UTF8String]);
      printf("  formattingDictionary %s\n",
             [[[editor formattingDictionary] description] UTF8String]);
      printf("  predicate           %s\n",
             [[[editor predicate] description] UTF8String]);
      printf("  selectedRowIndexes  %s\n",
             [[[editor selectedRowIndexes] description] UTF8String]);

      Delegate *d = [Delegate new];
      [editor setDelegate: d];
      printf("\n== after setting the delegate, before any row\n");
      printf("  numberOfRows %ld, calls so far: %s\n",
             (long)[editor numberOfRows], [[d->log description] UTF8String]);

      [d->log removeAllObjects];
      [editor addRow: nil];
      printf("\n== after -addRow:\n");
      printf("  numberOfRows        %ld\n", (long)[editor numberOfRows]);
      printf("  criteriaForRow:0    %s\n",
             [[[editor criteriaForRow: 0] description] UTF8String]);
      printf("  displayValuesForRow:0 count %lu\n",
             (unsigned long)[[editor displayValuesForRow: 0] count]);
      for (id v in [editor displayValuesForRow: 0])
        {
          printf("     %s\n", [NSStringFromClass([v class]) UTF8String]);
        }
      printf("  rowTypeForRow:0     %lu\n",
             (unsigned long)[editor rowTypeForRow: 0]);
      printf("  parentRowForRow:0   %ld\n", (long)[editor parentRowForRow: 0]);
      printf("  subrowIndexes:0     %s\n",
             [[[editor subrowIndexesForRow: 0] description] UTF8String]);
      printf("  predicate           %s\n",
             [[[editor predicate] description] UTF8String]);
      printf("  predicateForRow:0   %s\n",
             [[[editor predicateForRow: 0] description] UTF8String]);
      printf("  rowForDisplayValue  %ld\n",
             (long)[editor rowForDisplayValue:
                     [[editor displayValuesForRow: 0] objectAtIndex: 0]]);
      printf("  delegate calls: %s\n", [[d->log description] UTF8String]);

      /* A second row, and what the whole predicate becomes. */
      [d->log removeAllObjects];
      [editor addRow: nil];
      printf("\n== after a second -addRow:\n");
      printf("  numberOfRows %ld\n", (long)[editor numberOfRows]);
      printf("  predicate    %s\n", [[[editor predicate] description] UTF8String]);
      printf("  subviews     %lu\n", (unsigned long)[[editor subviews] count]);

      /* Nesting. */
      printf("\n== nesting\n");
      [editor setNestingMode: NSRuleEditorNestingModeCompound];
      printf("  set compound, nestingMode %lu, rows %ld\n",
             (unsigned long)[editor nestingMode], (long)[editor numberOfRows]);
      [editor insertRowAtIndex: 1
                      withType: NSRuleEditorRowTypeSimple
                 asSubrowOfRow: 0
                       animate: NO];
      printf("  after insert as subrow of 0: rows %ld\n",
             (long)[editor numberOfRows]);
      printf("  parentRowForRow:1 %ld subrowIndexes:0 %s\n",
             (long)[editor parentRowForRow: 1],
             [[[editor subrowIndexesForRow: 0] description] UTF8String]);
      printf("  rowTypeForRow:0 %lu\n", (unsigned long)[editor rowTypeForRow: 0]);
      printf("  predicate %s\n", [[[editor predicate] description] UTF8String]);

      /* Removing. */
      [editor removeRowAtIndex: 0];
      printf("\n== after removing row 0: rows %ld predicate %s\n",
             (long)[editor numberOfRows],
             [[[editor predicate] description] UTF8String]);

      printf("\n== notification name: %s\n",
             [NSRuleEditorRowsDidChangeNotification UTF8String]);
    }
  return 0;
}
