/* Apple oracle for the NSObjectController coverage test: the defaults
   (content, object class, editable, automaticallyPreparesContent), newObject,
   the content and selectedObjects round-trip, add/remove and canAdd/canRemove. */
#import <Cocoa/Cocoa.h>

int
main(int argc, const char **argv)
{
  @autoreleasepool
  {
    NSObjectController *oc = [[NSObjectController alloc] init];
    NSLog(@"OC init content=%@ objectClass=%@ editable=%d autoPrep=%d "
          @"selCount=%lu canAdd=%d canRemove=%d",
          [oc content] == nil ? @"nil" : @"set",
          NSStringFromClass([oc objectClass]), [oc isEditable],
          [oc automaticallyPreparesContent],
          (unsigned long)[[oc selectedObjects] count],
          [oc canAdd], [oc canRemove]);

    id newObj = [oc newObject];
    NSLog(@"OC newObject class=%@", NSStringFromClass([newObj class]));

    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [oc setContent: d];
    NSLog(@"OC afterSet contentSame=%d selCount=%lu sel0Same=%d canRemove=%d",
          [oc content] == d, (unsigned long)[[oc selectedObjects] count],
          [[oc selectedObjects] count] > 0
            && [[oc selectedObjects] objectAtIndex: 0] == d,
          [oc canRemove]);

    NSObjectController *oc2 = [[NSObjectController alloc] initWithContent: d];
    NSLog(@"OC initWithContent same=%d", [oc2 content] == d);

    [oc setEditable: NO];
    NSLog(@"OC notEditable canAdd=%d canRemove=%d", [oc canAdd], [oc canRemove]);

    NSObjectController *oc3 = [[NSObjectController alloc] init];
    id o = [NSMutableDictionary dictionary];
    [oc3 addObject: o];
    NSLog(@"OC addObject contentSame=%d", [oc3 content] == o);
    [oc3 removeObject: o];
    NSLog(@"OC removeObject content=%@", [oc3 content] == nil ? @"nil" : @"set");
  }
  return 0;
}
