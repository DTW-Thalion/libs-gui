#import <Foundation/Foundation.h>

int main(int argc, const char **argv)
{
  @autoreleasepool
    {
      NSExpression *keyA = [NSExpression expressionForKeyPath: @"name"];
      NSExpression *keyB = [NSExpression expressionForKeyPath: @"name"];
      NSExpression *keyC = [NSExpression expressionForKeyPath: @"other"];
      NSExpression *conA = [NSExpression expressionForConstantValue: @"x"];
      NSExpression *conB = [NSExpression expressionForConstantValue: @"x"];
      NSExpression *var  = [NSExpression expressionForVariable: @"v"];
      NSExpression *fun  = [NSExpression expressionForFunction: @"sum:"
                                                     arguments: @[keyA]];

      printf("== equality\n");
      printf("  keyPath == keyPath (same path)  : %d\n", (int)[keyA isEqual: keyB]);
      printf("  keyPath == keyPath (other path) : %d\n", (int)[keyA isEqual: keyC]);
      printf("  constant == constant            : %d\n", (int)[conA isEqual: conB]);
      printf("  keyPath == constant             : %d\n", (int)[keyA isEqual: conA]);
      printf("  hashes equal (same path)        : %d\n",
             (int)([keyA hash] == [keyB hash]));
      printf("  containsObject                  : %d\n",
             (int)[@[keyA] containsObject: keyB]);
      printf("  variable == variable            : %d\n",
             (int)[var isEqual: [NSExpression expressionForVariable: @"v"]]);
      printf("  function == function            : %d\n",
             (int)[fun isEqual: [NSExpression expressionForFunction: @"sum:"
                                                          arguments: @[keyB]]]);

      NSPredicate *p1 = [NSPredicate predicateWithFormat: @"name == 'x'"];
      NSPredicate *p2 = [NSPredicate predicateWithFormat: @"name == 'x'"];
      NSPredicate *p3 = [NSPredicate predicateWithFormat: @"name == 'y'"];
      NSPredicate *c1 = [NSPredicate predicateWithFormat: @"a == 1 AND b == 2"];
      NSPredicate *c2 = [NSPredicate predicateWithFormat: @"a == 1 AND b == 2"];
      printf("  comparison predicates equal     : %d\n", (int)[p1 isEqual: p2]);
      printf("  different predicates equal      : %d\n", (int)[p1 isEqual: p3]);
      printf("  compound predicates equal       : %d\n", (int)[c1 isEqual: c2]);

      printf("\n== archiving\n");
      NSArray *subjects = @[keyA, conA, var, fun, p1, c1];
      for (id subject in subjects)
        {
          @try
            {
              NSData *data =
                [NSKeyedArchiver archivedDataWithRootObject: subject
                                      requiringSecureCoding: NO
                                                      error: NULL];
              id back = [NSKeyedUnarchiver unarchivedObjectOfClasses:
                          [NSSet setWithObjects: [NSExpression class],
                                                 [NSPredicate class],
                                                 [NSString class],
                                                 [NSNumber class],
                                                 [NSArray class], nil]
                                                            fromData: data
                                                               error: NULL];
              printf("  %-28s %4lu bytes, back=%s equal=%d\n",
                     [[subject description] UTF8String],
                     (unsigned long)[data length],
                     [[back description] UTF8String],
                     (int)[subject isEqual: back]);
            }
          @catch (NSException *e)
            {
              printf("  %-28s raised %s\n", [[subject description] UTF8String],
                     [[e name] UTF8String]);
            }
        }

      /* The keys the archive actually holds, for a key path expression. */
      NSData *data = [NSKeyedArchiver archivedDataWithRootObject: keyA
                                          requiringSecureCoding: NO
                                                          error: NULL];
      id plist = [NSPropertyListSerialization propertyListWithData: data
                                                           options: 0
                                                            format: NULL
                                                             error: NULL];
      printf("\n== archive of a key path expression\n%s\n",
             [[plist description] UTF8String]);

      data = [NSKeyedArchiver archivedDataWithRootObject: p1
                                   requiringSecureCoding: NO
                                                   error: NULL];
      plist = [NSPropertyListSerialization propertyListWithData: data
                                                        options: 0
                                                         format: NULL
                                                          error: NULL];
      printf("\n== archive of a comparison predicate\n%s\n",
             [[plist description] UTF8String]);
    }
  return 0;
}
