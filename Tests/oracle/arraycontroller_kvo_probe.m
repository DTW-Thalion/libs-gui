#import <Cocoa/Cocoa.h>

@interface Task : NSObject
@property (copy) NSString *name;
@end

@implementation Task
@end

@interface Obs : NSObject
{
@public
  int count;
}
@end

@implementation Obs
- (void) observeValueForKeyPath: (NSString *)keyPath
                       ofObject: (id)object
                         change: (NSDictionary *)change
                        context: (void *)context
{
  count++;
  printf("   notified keyPath=%s ofObject=%s change=%s\n",
         [keyPath UTF8String], [NSStringFromClass([object class]) UTF8String],
         [[change description] UTF8String]);
}
@end

int main(int argc, const char **argv)
{
  @autoreleasepool
    {
      NSMutableArray *tasks = [NSMutableArray array];
      NSArrayController *controller;
      Obs *o1 = [Obs new];
      Obs *o2 = [Obs new];
      Task *t;

      for (int i = 0; i < 2; i++)
        {
          Task *task = [Task new];
          task.name = [NSString stringWithFormat: @"task %d", i];
          [tasks addObject: task];
        }
      t = tasks[0];

      controller = [[NSArrayController alloc] initWithContent: tasks];
      printf("arrangedObjects class = %s\n",
             [NSStringFromClass([[controller arrangedObjects] class]) UTF8String]);

      [controller addObserver: o1
                   forKeyPath: @"arrangedObjects.name"
                      options: NSKeyValueObservingOptionNew
                      context: NULL];

      printf("--- changing an element property\n");
      t.name = @"edited";
      printf("keypath observer count = %d\n", o1->count);

      /* Registering directly on the proxy, the way GNUstep's proxy supports. */
      @try
        {
          [[controller arrangedObjects] addObserver: o2
                                         forKeyPath: @"name"
                                            options: NSKeyValueObservingOptionNew
                                            context: NULL];
          printf("direct add on proxy: accepted\n");
          t.name = @"edited twice";
          printf("direct proxy observer count = %d\n", o2->count);
        }
      @catch (NSException *e)
        {
          printf("direct add on proxy raised %s: %s\n",
                 [[e name] UTF8String], [[e reason] UTF8String]);
        }

      /* And a plain array in the middle of a key path. */
      @try
        {
          NSMutableDictionary *holder = [NSMutableDictionary dictionary];
          holder[@"list"] = tasks;
          [holder addObserver: o2
                   forKeyPath: @"list.name"
                      options: NSKeyValueObservingOptionNew
                      context: NULL];
          printf("plain array keypath: accepted\n");
        }
      @catch (NSException *e)
        {
          printf("plain array keypath raised %s: %s\n",
                 [[e name] UTF8String], [[e reason] UTF8String]);
        }
    }
  return 0;
}
