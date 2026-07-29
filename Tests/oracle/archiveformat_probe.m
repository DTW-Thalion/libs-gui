#import <Foundation/Foundation.h>

/* Print the $objects table of a keyed archive with each entry numbered, so
   the shape of what Apple writes can be read off directly.
*/
static void dumpArchive(id object, const char *label)
{
  NSData *data;
  NSDictionary *plist;
  NSArray *objects;
  NSUInteger i;

  printf("\n===== %s : %s\n", label, [[object description] UTF8String]);

  data = [NSKeyedArchiver archivedDataWithRootObject: object
                               requiringSecureCoding: NO
                                               error: NULL];
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
          NSMutableString *line = [NSMutableString string];

          for (NSString *key in [[entry allKeys]
                 sortedArrayUsingSelector: @selector(compare:)])
            {
              id value = entry[key];

              if ([value isKindOfClass: [NSNumber class]]
                || [value isKindOfClass: [NSString class]])
                {
                  [line appendFormat: @"%@=%@ ", key, value];
                }
              else if ([value isKindOfClass: [NSArray class]])
                {
                  [line appendFormat: @"%@=%@ ", key, value];
                }
              else
                {
                  /* A reference to another entry. */
                  [line appendFormat: @"%@=->%@ ", key, value];
                }
            }
          printf("  [%2lu] %s\n", (unsigned long)i, [line UTF8String]);
        }
      else
        {
          printf("  [%2lu] %s\n", (unsigned long)i,
                 [[entry description] UTF8String]);
        }
    }
}

int main(int argc, const char **argv)
{
  @autoreleasepool
    {
      dumpArchive([NSExpression expressionForConstantValue: @"hello"],
                  "constant string");
      dumpArchive([NSExpression expressionForConstantValue: @(42)],
                  "constant number");
      dumpArchive([NSExpression expressionForEvaluatedObject],
                  "evaluated object");
      dumpArchive([NSExpression expressionForVariable: @"v"], "variable");
      dumpArchive([NSExpression expressionForKeyPath: @"a.b"], "key path");
      dumpArchive([NSExpression expressionForFunction: @"sum:"
                                            arguments:
                     @[[NSExpression expressionForKeyPath: @"n"]]],
                  "function");
      dumpArchive([NSExpression expressionForAggregate:
                     @[[NSExpression expressionForConstantValue: @1],
                       [NSExpression expressionForConstantValue: @2]]],
                  "aggregate");
      dumpArchive([NSPredicate predicateWithFormat: @"name == 'x'"],
                  "comparison predicate");
      dumpArchive([NSPredicate predicateWithFormat: @"name ==[cd] 'x'"],
                  "comparison predicate with options");
      dumpArchive([NSPredicate predicateWithFormat: @"ANY list == 'x'"],
                  "comparison predicate with a modifier");
      dumpArchive([NSPredicate predicateWithFormat: @"a == 1 AND b == 2"],
                  "and predicate");
      dumpArchive([NSPredicate predicateWithFormat: @"NOT (a == 1)"],
                  "not predicate");
      dumpArchive([NSPredicate predicateWithValue: YES], "true predicate");
    }
  return 0;
}
