#import <Foundation/Foundation.h>

static void dumpKeys(NSPredicateOperatorType type, NSUInteger options,
                     const char *name)
{
  NSPredicate *p = [NSComparisonPredicate
    predicateWithLeftExpression: [NSExpression expressionForKeyPath: @"a"]
                rightExpression: [NSExpression expressionForConstantValue: @"b"]
                       modifier: NSDirectPredicateModifier
                           type: type
                        options: options];
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject: p
                                      requiringSecureCoding: NO
                                                      error: NULL];
  NSDictionary *plist = [NSPropertyListSerialization
    propertyListWithData: data options: 0 format: NULL error: NULL];
  NSArray *objects = plist[@"$objects"];

  NSMutableString *keys = [NSMutableString string];
  NSString *className = @"?";

  for (id entry in objects)
    {
      if (![entry isKindOfClass: [NSDictionary class]])
        {
          continue;
        }
      if (entry[@"NSOperatorType"] != nil)
        {
          for (NSString *k in [[entry allKeys]
                 sortedArrayUsingSelector: @selector(compare:)])
            {
              if (![k isEqual: @"$class"])
                {
                  [keys appendFormat: @"%@=%@ ", k, entry[k]];
                }
            }
        }
      if ([entry[@"$classes"] containsObject: @"NSPredicateOperator"])
        {
          className = entry[@"$classname"];
        }
    }
  printf("  %-22s %-32s %s\n", name, [className UTF8String],
         [keys UTF8String]);
}

int main(int argc, const char **argv)
{
  @autoreleasepool
    {
      printf("case                   class                            keys\n");
      dumpKeys(NSLessThanPredicateOperatorType, 0, "LessThan");
      dumpKeys(NSEqualToPredicateOperatorType, 0, "EqualTo");
      dumpKeys(NSEqualToPredicateOperatorType, NSCaseInsensitivePredicateOption,
               "EqualTo[c]");
      dumpKeys(NSNotEqualToPredicateOperatorType, 0, "NotEqualTo");
      dumpKeys(NSMatchesPredicateOperatorType, 0, "Matches");
      dumpKeys(NSLikePredicateOperatorType, 0, "Like");
      dumpKeys(NSBeginsWithPredicateOperatorType, 0, "BeginsWith");
      dumpKeys(NSEndsWithPredicateOperatorType, 0, "EndsWith");
      dumpKeys(NSInPredicateOperatorType, 0, "In");
      dumpKeys(NSContainsPredicateOperatorType, 0, "Contains");
      dumpKeys(NSBetweenPredicateOperatorType, 0, "Between");
      dumpKeys(NSEqualToPredicateOperatorType, 0, "EqualTo again");
    }
  return 0;
}
