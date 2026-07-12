/* Apple oracle for the NSStepper coverage test: the cell class, the value
   defaults exposed through the control, and the delegation of the setters
   to the cell. */
#import <Cocoa/Cocoa.h>

int main(void)
{
  @autoreleasepool
  {
    setvbuf(stdout, NULL, _IONBF, 0);
    [NSApplication sharedApplication];

    printf("STP cellClass=%s\n", [NSStringFromClass([NSStepper cellClass]) UTF8String]);

    NSStepper *s = [[NSStepper alloc] initWithFrame: NSMakeRect(0, 0, 20, 30)];
    printf("STP cell isStepperCell=%d\n", [[s cell] isKindOfClass: [NSStepperCell class]]);
    printf("STP defaults: min=%g max=%g inc=%g wraps=%d autorep=%d\n",
           [s minValue], [s maxValue], [s increment], [s valueWraps], [s autorepeat]);

    /* Delegation: setting on the control reflects on its cell. */
    [s setMaxValue: 20];
    [s setMinValue: 5];
    [s setIncrement: 2];
    [s setValueWraps: NO];
    [s setAutorepeat: NO];
    printf("STP after setters control: max=%g min=%g inc=%g wraps=%d autorep=%d\n",
           [s maxValue], [s minValue], [s increment], [s valueWraps], [s autorepeat]);
    printf("STP after setters cell:    max=%g min=%g inc=%g wraps=%d autorep=%d\n",
           [[s cell] maxValue], [[s cell] minValue], [[s cell] increment],
           [[s cell] valueWraps], [[s cell] autorepeat]);

    /* Value through the control (clamped by the cell). */
    [s setIntValue: 10];
    printf("STP setIntValue 10 -> %d (min5 max20)\n", [s intValue]);
    [s setIntValue: 100];
    printf("STP setIntValue 100 -> %d (clamps to max)\n", [s intValue]);

    printf("DONE\n");
  }
  return 0;
}
