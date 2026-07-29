#import <Foundation/Foundation.h>

/* For each operator type, print the class name Apple writes for the operator
   object held under NSPredicateOperator, and the keys on it.
*/
static void dumpOperator(NSPredicateOperatorType type, const char *name)
{
  NSPredicate *p;
  NSData *data;
  NSDictionary *plist;
  NSArray *objects;

  p = [NSComparisonPredicate
    predicateWithLeftExpression: [NSExpression expressionForKeyPath: @"a"]
                rightExpression: [NSExpression expressionForConstantValue: @"b"]
                       modifier: NSDirectPredicateModifier
                           type: type
                        options: 0];

  data = [NSKeyedArchiver archivedDataWithRootObject: p
                               requiringSecureCoding: NO
                                               error: NULL];
  plist = [NSPropertyListSerialization propertyListWithData: data
                                                    options: 0
                                                     format: NULL
                                                      error: NULL];
  objects = plist[@"$objects"];

  for (id entry in objects)
    {
      if ([entry isKindOfClass: [NSDictionary class]]
        && entry[@"$classname"] != nil
        && [entry[@"$classes"] containsObject: @"NSPredicateOperator"])
        {
          printf("  %-34s -> %s\n", name,
                 [entry[@"$classname"] UTF8String]);
          return;
        }
    }
  printf("  %-34s -> (none found)\n", name);
}

int main(int argc, const char **argv)
{
  @autoreleasepool
    {
      printf("operator type -> class written\n");
      dumpOperator(NSLessThanPredicateOperatorType, "LessThan");
      dumpOperator(NSLessThanOrEqualToPredicateOperatorType, "LessThanOrEqualTo");
      dumpOperator(NSGreaterThanPredicateOperatorType, "GreaterThan");
      dumpOperator(NSGreaterThanOrEqualToPredicateOperatorType, "GreaterThanOrEqualTo");
      dumpOperator(NSEqualToPredicateOperatorType, "EqualTo");
      dumpOperator(NSNotEqualToPredicateOperatorType, "NotEqualTo");
      dumpOperator(NSMatchesPredicateOperatorType, "Matches");
      dumpOperator(NSLikePredicateOperatorType, "Like");
      dumpOperator(NSBeginsWithPredicateOperatorType, "BeginsWith");
      dumpOperator(NSEndsWithPredicateOperatorType, "EndsWith");
      dumpOperator(NSInPredicateOperatorType, "In");
      dumpOperator(NSContainsPredicateOperatorType, "Contains");
      dumpOperator(NSBetweenPredicateOperatorType, "Between");

      /* And what the operator object itself carries. */
      NSPredicate *p = [NSPredicate predicateWithFormat: @"a BEGINSWITH[cd] 'b'"];
      NSData *data = [NSKeyedArchiver archivedDataWithRootObject: p
                                          requiringSecureCoding: NO
                                                          error: NULL];
      NSDictionary *plist = [NSPropertyListSerialization
        propertyListWithData: data options: 0 format: NULL error: NULL];
      printf("\nbeginswith[cd] operator entries:\n");
      for (id entry in plist[@"$objects"])
        {
          if ([entry isKindOfClass: [NSDictionary class]]
            && entry[@"NSOperatorType"] != nil)
            {
              printf("  %s\n", [[entry description] UTF8String]);
            }
        }
    }
  return 0;
}
