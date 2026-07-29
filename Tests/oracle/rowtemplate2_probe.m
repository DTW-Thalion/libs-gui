#import <Cocoa/Cocoa.h>

static NSPredicateEditorRowTemplate *
templateFor(NSAttributeType type, NSArray *ops, NSUInteger options,
            NSComparisonPredicateModifier modifier)
{
  return [[NSPredicateEditorRowTemplate alloc]
           initWithLeftExpressions: @[[NSExpression expressionForKeyPath: @"a"]]
      rightExpressionAttributeType: type
                          modifier: modifier
                         operators: ops
                           options: options];
}

static void dumpViews(NSPredicateEditorRowTemplate *t, const char *label)
{
  printf("%s:\n", label);
  for (NSView *v in [t templateViews])
    {
      printf("   %s", [NSStringFromClass([v class]) UTF8String]);
      if ([v isKindOfClass: [NSPopUpButton class]])
        {
          printf(" titles=%s",
                 [[[(NSPopUpButton *)v itemTitles] description] UTF8String]);
        }
      else if ([v isKindOfClass: [NSTextField class]])
        {
          NSTextField *f = (NSTextField *)v;
          printf(" formatter=%s placeholder='%s'",
                 [NSStringFromClass([[f formatter] class]) UTF8String],
                 [[[f cell] placeholderString] UTF8String]);
        }
      printf("\n");
    }
}

int main(int argc, const char **argv)
{
  @autoreleasepool
    {
      [NSApplication sharedApplication];

      NSArray *allOps = @[@(NSLessThanPredicateOperatorType),
                          @(NSLessThanOrEqualToPredicateOperatorType),
                          @(NSGreaterThanPredicateOperatorType),
                          @(NSGreaterThanOrEqualToPredicateOperatorType),
                          @(NSEqualToPredicateOperatorType),
                          @(NSNotEqualToPredicateOperatorType),
                          @(NSMatchesPredicateOperatorType),
                          @(NSLikePredicateOperatorType),
                          @(NSBeginsWithPredicateOperatorType),
                          @(NSEndsWithPredicateOperatorType),
                          @(NSInPredicateOperatorType),
                          @(NSContainsPredicateOperatorType),
                          @(NSBetweenPredicateOperatorType)];

      NSPredicateEditorRowTemplate *t =
        templateFor(NSStringAttributeType, allOps, 0, NSDirectPredicateModifier);
      printf("== operator titles, in the order given\n");
      NSPopUpButton *opButton = [[t templateViews] objectAtIndex: 1];
      printf("   %s\n", [[[opButton itemTitles] description] UTF8String]);

      printf("\n== right hand view by attribute type\n");
      struct { NSAttributeType type; const char *name; } types[] = {
        {NSInteger16AttributeType, "Integer16"},
        {NSInteger32AttributeType, "Integer32"},
        {NSInteger64AttributeType, "Integer64"},
        {NSDecimalAttributeType, "Decimal"},
        {NSDoubleAttributeType, "Double"},
        {NSFloatAttributeType, "Float"},
        {NSStringAttributeType, "String"},
        {NSBooleanAttributeType, "Boolean"},
        {NSDateAttributeType, "Date"},
        {NSUndefinedAttributeType, "Undefined"},
      };
      for (unsigned i = 0; i < sizeof(types)/sizeof(types[0]); i++)
        {
          NSPredicateEditorRowTemplate *tt =
            templateFor(types[i].type, @[@(NSEqualToPredicateOperatorType)], 0,
                        NSDirectPredicateModifier);
          dumpViews(tt, types[i].name);
          printf("   predicate: %s\n",
                 [[[tt predicateWithSubpredicates: nil] description] UTF8String]);
        }

      printf("\n== modifier\n");
      NSPredicateEditorRowTemplate *anyT =
        templateFor(NSStringAttributeType, @[@(NSEqualToPredicateOperatorType)],
                    0, NSAnyPredicateModifier);
      printf("   modifier=%ld predicate=%s\n", (long)[anyT modifier],
             [[[anyT predicateWithSubpredicates: nil] description] UTF8String]);
      printf("   view count=%lu\n",
             (unsigned long)[[anyT templateViews] count]);

      printf("\n== match scores\n");
      NSPredicateEditorRowTemplate *m =
        [[NSPredicateEditorRowTemplate alloc]
          initWithLeftExpressions: @[[NSExpression expressionForKeyPath: @"name"]]
     rightExpressionAttributeType: NSStringAttributeType
                         modifier: NSDirectPredicateModifier
                        operators: @[@(NSEqualToPredicateOperatorType),
                                     @(NSContainsPredicateOperatorType)]
                          options: 0];
      NSArray *cases = @[@"name == 'x'", @"name CONTAINS 'x'",
                         @"name ==[c] 'x'", @"name BEGINSWITH 'x'",
                         @"other == 'x'", @"name == 3",
                         @"name == other"];
      for (NSString *format in cases)
        {
          NSPredicate *p = [NSPredicate predicateWithFormat: format];
          printf("   %-22s -> %f\n", [format UTF8String],
                 [m matchForPredicate: p]);
        }

      NSPredicateEditorRowTemplate *two =
        [[NSPredicateEditorRowTemplate alloc]
          initWithLeftExpressions: @[[NSExpression expressionForKeyPath: @"name"],
                                     [NSExpression expressionForKeyPath: @"title"]]
     rightExpressionAttributeType: NSStringAttributeType
                         modifier: NSDirectPredicateModifier
                        operators: @[@(NSEqualToPredicateOperatorType)]
                          options: 0];
      printf("   two left expressions, name == 'x' -> %f\n",
             [two matchForPredicate:
               [NSPredicate predicateWithFormat: @"name == 'x'"]]);

      NSPredicateEditorRowTemplate *ct =
        [[NSPredicateEditorRowTemplate alloc]
          initWithCompoundTypes: @[@(NSNotPredicateType)]];
      printf("   NOT template titles=%s\n",
             [[[(NSPopUpButton *)[[ct templateViews] objectAtIndex: 0] itemTitles]
                description] UTF8String]);
      printf("   NOT template predicate=%s\n",
             [[[ct predicateWithSubpredicates:
                 @[[NSPredicate predicateWithFormat: @"a == 1"]]] description]
               UTF8String]);
    }
  return 0;
}
