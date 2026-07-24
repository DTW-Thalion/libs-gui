#import <Cocoa/Cocoa.h>

int
main(int argc, const char *argv[])
{
  @autoreleasepool
    {
      NSResponder *r = [[NSResponder alloc] init];
      NSResponder *other = [[NSResponder alloc] init];

      /* Which of these are actually implemented on a plain NSResponder? */
      printf("responds validateProposedFirstResponder:forEvent: -> %s\n",
        [r respondsToSelector: @selector(validateProposedFirstResponder:forEvent:)] ? "YES" : "NO");
      printf("responds supplementalTargetForAction:sender: -> %s\n",
        [r respondsToSelector: @selector(supplementalTargetForAction:sender:)] ? "YES" : "NO");
      printf("responds commitEditingAndReturnError: -> %s\n",
        [r respondsToSelector: @selector(commitEditingAndReturnError:)] ? "YES" : "NO");
      printf("responds encodeRestorableStateWithCoder: -> %s\n",
        [r respondsToSelector: @selector(encodeRestorableStateWithCoder:)] ? "YES" : "NO");
      printf("responds restoreStateWithCoder: -> %s\n",
        [r respondsToSelector: @selector(restoreStateWithCoder:)] ? "YES" : "NO");
      printf("responds invalidateRestorableState -> %s\n",
        [r respondsToSelector: @selector(invalidateRestorableState)] ? "YES" : "NO");

      /* Default return values. */
      BOOL v = [r validateProposedFirstResponder: other forEvent: nil];
      printf("validateProposedFirstResponder:forEvent: -> %s\n", v ? "YES" : "NO");

      id t = [r supplementalTargetForAction: @selector(copy:) sender: nil];
      printf("supplementalTargetForAction:sender: -> %s\n", t == nil ? "nil" : "non-nil");
    }
  return 0;
}
