#import <Foundation/Foundation.h>

static void dumpKeys(NSPredicateOperatorType type, NSUInteger options,
                     NSComparisonPredicateModifier modifier, const char *name)
{
  NSPredicate *p = [NSComparisonPredicate
    predicateWithLeftExpression: [NSExpression expressionForKeyPath: @"a"]
                rightExpression: [NSExpression expressionForConstantValue: @"b"]
                       modifier: modifier
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
  printf("  %-26s %-32s %s\n", name, [className UTF8String],
         [keys UTF8String]);
}

int main(int argc, const char **argv)
{
  @autoreleasepool
    {
      NSUInteger cd = NSCaseInsensitivePredicateOption
        | NSDiacriticInsensitivePredicateOption;

      printf("case                       class                            keys\n");
      dumpKeys(NSMatchesPredicateOperatorType, cd,
               NSDirectPredicateModifier, "Matches[cd]");
      dumpKeys(NSLikePredicateOperatorType, cd,
               NSDirectPredicateModifier, "Like[cd]");
      dumpKeys(NSBeginsWithPredicateOperatorType, cd,
               NSDirectPredicateModifier, "BeginsWith[cd]");
      dumpKeys(NSEndsWithPredicateOperatorType,
               NSCaseInsensitivePredicateOption,
               NSDirectPredicateModifier, "EndsWith[c]");
      dumpKeys(NSInPredicateOperatorType, cd,
               NSDirectPredicateModifier, "In[cd]");
      dumpKeys(NSContainsPredicateOperatorType, cd,
               NSDirectPredicateModifier, "Contains[cd]");
      dumpKeys(NSBetweenPredicateOperatorType, cd,
               NSDirectPredicateModifier, "Between[cd]");
      dumpKeys(NSLessThanPredicateOperatorType, cd,
               NSAllPredicateModifier, "LessThan[cd] ALL");
    }
  return 0;
}
