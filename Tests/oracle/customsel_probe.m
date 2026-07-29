#import <Foundation/Foundation.h>

static void dump(NSPredicate *p, const char *name)
{
  NSError *error = nil;
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject: p
                                      requiringSecureCoding: NO
                                                      error: &error];
  NSDictionary *plist;
  NSArray *objects;
  NSUInteger i;

  printf("===== %s\n", name);
  if (data == nil)
    {
      printf("  archiving failed: %s\n", [[error description] UTF8String]);
      return;
    }
  plist = [NSPropertyListSerialization propertyListWithData: data
                                                    options: 0
                                                     format: NULL
                                                      error: NULL];
  objects = plist[@"$objects"];
  for (i = 0; i < [objects count]; i++)
    {
      id entry = objects[i];

      if ([entry isKindOfClass: [NSDictionary class]])
        {
          NSMutableString *out = [NSMutableString string];

          for (NSString *k in [[entry allKeys]
                 sortedArrayUsingSelector: @selector(compare:)])
            {
              [out appendFormat: @"%@=%@ ", k, entry[k]];
            }
          printf("  [%2lu] %s\n", (unsigned long)i, [out UTF8String]);
        }
      else
        {
          printf("  [%2lu] %s\n", (unsigned long)i,
                 [[entry description] UTF8String]);
        }
    }

  {
    NSPredicate *back = [NSKeyedUnarchiver unarchivedObjectOfClass:
      [NSPredicate class] fromData: data error: NULL];

    printf("  read back: %s\n", [[back description] UTF8String]);
  }
}

int main(int argc, const char **argv)
{
  @autoreleasepool
    {
      NSExpression *left = [NSExpression expressionForKeyPath: @"a"];
      NSExpression *right = [NSExpression expressionForConstantValue: @"b"];

      dump([NSComparisonPredicate predicateWithLeftExpression: left
                                              rightExpression: right
                                               customSelector:
                                                 @selector(isEqual:)],
           "custom selector isEqual:");

      dump([NSComparisonPredicate predicateWithLeftExpression: left
                                              rightExpression: right
                                                     modifier:
                                                       NSAnyPredicateModifier
                                                         type:
                                            NSEqualToPredicateOperatorType
                                                      options: 0],
           "ANY modifier");

      dump([NSPredicate predicateWithValue: YES], "true predicate");
      dump([NSPredicate predicateWithValue: NO], "false predicate");
    }
  return 0;
}
