/* Apple oracle: what NSTokenFieldCell writes into a keyed archive, so the keys
   here can be the ones AppKit uses rather than invented.  Apple-only. */
#import <Cocoa/Cocoa.h>
#include <stdio.h>

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    NSTokenFieldCell *cell = [[NSTokenFieldCell alloc] initTextCell: @"token"];
    NSError *err = nil;
    NSData *data;
    id plist;

    [cell setTokenStyle: NSTokenStyleRounded];
    [cell setCompletionDelay: 2.5];
    [cell setTokenizingCharacterSet:
      [NSCharacterSet characterSetWithCharactersInString: @";"]];

    data = [NSKeyedArchiver archivedDataWithRootObject: cell
                                requiringSecureCoding: NO
                                                error: &err];
    if (data == nil)
      {
        printf("ARCHIVE FAILED: %s\n", [[err description] UTF8String]);
      }
    else
      {
        plist = [NSPropertyListSerialization propertyListWithData: data
                                                          options: 0
                                                           format: NULL
                                                            error: &err];
        /* Only the keys matter here, not the whole cell graph. */
        printf("== keys mentioning token/completion/delay ==\n");
        NSString *desc = [plist description];
        NSArray *lines = [desc componentsSeparatedByString: @"\n"];
        NSUInteger i;

        for (i = 0; i < [lines count]; i++)
          {
            NSString *l = [lines objectAtIndex: i];

            if ([l rangeOfString: @"oken"].location != NSNotFound
              || [l rangeOfString: @"ompletion"].location != NSNotFound
              || [l rangeOfString: @"elay"].location != NSNotFound)
              {
                printf("%s\n", [l UTF8String]);
              }
          }

        NSTokenFieldCell *back = [NSKeyedUnarchiver
          unarchivedObjectOfClass: [NSTokenFieldCell class]
                         fromData: data
                            error: &err];

        printf("\n== round trip ==\n");
        printf("BACK nonnil=%d tokenStyle=%ld completionDelay=%g set=%s\n",
               back != nil, (long)[back tokenStyle],
               (double)[back completionDelay],
               [back tokenizingCharacterSet] == nil ? "nil" : "set");
        if ([back tokenizingCharacterSet] != nil)
          {
            printf("BACK hasSemi=%d hasComma=%d\n",
                   [[back tokenizingCharacterSet] characterIsMember: ';'],
                   [[back tokenizingCharacterSet] characterIsMember: ',']);
          }
      }
  }
  return 0;
}
