#import <Cocoa/Cocoa.h>

static void describeViews(NSArray *views, const char *label)
{
  printf("  %s: count=%lu\n", label, (unsigned long)[views count]);
  for (NSView *v in views)
    {
      printf("     %s", [NSStringFromClass([v class]) UTF8String]);
      if ([v isKindOfClass: [NSPopUpButton class]])
        {
          NSPopUpButton *p = (NSPopUpButton *)v;
          printf("  items=%lu titles=%s selected=%s",
                 (unsigned long)[[p itemTitles] count],
                 [[[p itemTitles] description] UTF8String],
                 [[p titleOfSelectedItem] UTF8String]);
        }
      else if ([v isKindOfClass: [NSTextField class]])
        {
          printf("  stringValue='%s'", [[(NSTextField *)v stringValue] UTF8String]);
        }
      printf("\n");
    }
}

int main(int argc, const char **argv)
{
  @autoreleasepool
    {
      [NSApplication sharedApplication];

      /* 1. A default instance. */
      NSPredicateEditorRowTemplate *plain =
        [[NSPredicateEditorRowTemplate alloc] init];
      printf("== plain init\n");
      printf("  leftExpressions=%s rightExpressions=%s\n",
             [[[plain leftExpressions] description] UTF8String],
             [[[plain rightExpressions] description] UTF8String]);
      printf("  operators=%s modifier=%ld options=%lu attrType=%lu\n",
             [[[plain operators] description] UTF8String],
             (long)[plain modifier], (unsigned long)[plain options],
             (unsigned long)[plain rightExpressionAttributeType]);
      printf("  compoundTypes=%s\n",
             [[[plain compoundTypes] description] UTF8String]);
      @try { describeViews([plain templateViews], "templateViews"); }
      @catch (NSException *e) { printf("  templateViews raised %s\n", [[e name] UTF8String]); }

      /* 2. The string comparison template from the documentation. */
      NSArray *left = @[[NSExpression expressionForKeyPath: @"name"],
                        [NSExpression expressionForKeyPath: @"title"]];
      NSArray *ops = @[@(NSEqualToPredicateOperatorType),
                       @(NSContainsPredicateOperatorType)];
      NSPredicateEditorRowTemplate *t =
        [[NSPredicateEditorRowTemplate alloc]
          initWithLeftExpressions: left
     rightExpressionAttributeType: NSStringAttributeType
                         modifier: NSDirectPredicateModifier
                        operators: ops
                          options: NSCaseInsensitivePredicateOption];

      printf("\n== string template\n");
      printf("  leftExpressions=%s\n", [[[t leftExpressions] description] UTF8String]);
      printf("  rightExpressions=%s\n", [[[t rightExpressions] description] UTF8String]);
      printf("  attrType=%lu modifier=%ld options=%lu\n",
             (unsigned long)[t rightExpressionAttributeType],
             (long)[t modifier], (unsigned long)[t options]);
      describeViews([t templateViews], "templateViews");

      NSPredicate *built = [t predicateWithSubpredicates: nil];
      printf("  predicateWithSubpredicates:nil -> %s\n",
             [[built description] UTF8String]);
      if ([built isKindOfClass: [NSComparisonPredicate class]])
        {
          NSComparisonPredicate *c = (NSComparisonPredicate *)built;
          printf("     opType=%lu options=%lu modifier=%ld\n",
                 (unsigned long)[c predicateOperatorType],
                 (unsigned long)[c options], (long)[c comparisonPredicateModifier]);
        }

      /* 3. Matching. */
      NSPredicate *match = [NSPredicate predicateWithFormat: @"name CONTAINS[c] 'x'"];
      NSPredicate *other = [NSPredicate predicateWithFormat: @"other > 3"];
      NSPredicate *compound = [NSPredicate predicateWithFormat: @"name == 'a' AND title == 'b'"];
      printf("  match(name CONTAINS[c] 'x') = %f\n", [t matchForPredicate: match]);
      printf("  match(other > 3)            = %f\n", [t matchForPredicate: other]);
      printf("  match(compound)             = %f\n", [t matchForPredicate: compound]);
      printf("  match(nil)                  = %f\n", [t matchForPredicate: nil]);

      /* 4. setPredicate: then read the views back. */
      [t setPredicate: match];
      describeViews([t templateViews], "views after setPredicate");
      printf("  predicateWithSubpredicates:nil after set -> %s\n",
             [[[t predicateWithSubpredicates: nil] description] UTF8String]);

      /* 5. displayableSubpredicates. */
      printf("  displayableSubpredicates(comparison) = %s\n",
             [[[t displayableSubpredicatesOfPredicate: match] description] UTF8String]);
      printf("  displayableSubpredicates(compound)   = %s\n",
             [[[t displayableSubpredicatesOfPredicate: compound] description] UTF8String]);

      /* 6. A compound template. */
      NSPredicateEditorRowTemplate *ct =
        [[NSPredicateEditorRowTemplate alloc]
          initWithCompoundTypes: @[@(NSAndPredicateType), @(NSOrPredicateType)]];
      printf("\n== compound template\n");
      printf("  compoundTypes=%s leftExpressions=%s\n",
             [[[ct compoundTypes] description] UTF8String],
             [[[ct leftExpressions] description] UTF8String]);
      describeViews([ct templateViews], "templateViews");
      printf("  match(compound) = %f  match(comparison) = %f\n",
             [ct matchForPredicate: compound], [ct matchForPredicate: match]);
      printf("  displayableSubpredicates(compound) = %s\n",
             [[[ct displayableSubpredicatesOfPredicate: compound] description] UTF8String]);
      NSPredicate *sub1 = [NSPredicate predicateWithFormat: @"a == 1"];
      NSPredicate *sub2 = [NSPredicate predicateWithFormat: @"b == 2"];
      printf("  predicateWithSubpredicates:(a,b) = %s\n",
             [[[ct predicateWithSubpredicates: @[sub1, sub2]] description] UTF8String]);

      /* 7. Right expressions given explicitly. */
      NSPredicateEditorRowTemplate *rt =
        [[NSPredicateEditorRowTemplate alloc]
          initWithLeftExpressions: @[[NSExpression expressionForKeyPath: @"state"]]
                 rightExpressions: @[[NSExpression expressionForConstantValue: @"open"],
                                     [NSExpression expressionForConstantValue: @"shut"]]
                         modifier: NSDirectPredicateModifier
                        operators: @[@(NSEqualToPredicateOperatorType)]
                          options: 0];
      printf("\n== explicit right expressions\n");
      printf("  rightExpressions=%s attrType=%lu\n",
             [[[rt rightExpressions] description] UTF8String],
             (unsigned long)[rt rightExpressionAttributeType]);
      describeViews([rt templateViews], "templateViews");
      printf("  predicateWithSubpredicates:nil -> %s\n",
             [[[rt predicateWithSubpredicates: nil] description] UTF8String]);

      /* 8. Coding. */
      @try
        {
          NSData *d = [NSKeyedArchiver archivedDataWithRootObject: t
                                           requiringSecureCoding: NO
                                                           error: NULL];
          NSPredicateEditorRowTemplate *back =
            [NSKeyedUnarchiver unarchivedObjectOfClass:
              [NSPredicateEditorRowTemplate class] fromData: d error: NULL];
          printf("\n== coding: leftExpressions=%s operators=%s\n",
                 [[[back leftExpressions] description] UTF8String],
                 [[[back operators] description] UTF8String]);
        }
      @catch (NSException *e)
        {
          printf("\n== coding raised %s\n", [[e name] UTF8String]);
        }
    }
  return 0;
}
