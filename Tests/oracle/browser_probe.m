#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#include <stdio.h>

/* Dump the NSBrowserDelegate protocol as AppKit declares it, so the GNUstep
   header can be compared against the real list rather than a remembered one.
   Also dump the NSBrowser methods that go with the item based API. */

static void
dumpProtocol(const char *name)
{
  Protocol *p = objc_getProtocol(name);
  unsigned int count = 0;
  struct objc_method_description *list;
  unsigned int i;
  int req, inst;

  if (p == NULL)
    {
      printf("protocol %s NOT FOUND\n", name);
      return;
    }
  printf("=== %s ===\n", name);
  for (req = 1; req >= 0; req--)
    {
      for (inst = 1; inst >= 0; inst--)
	{
	  list = protocol_copyMethodDescriptionList(p, req ? YES : NO,
	    inst ? YES : NO, &count);
	  for (i = 0; i < count; i++)
	    {
	      printf("%s %s %s\n",
		req ? "required" : "optional",
		inst ? "-" : "+",
		sel_getName(list[i].name));
	    }
	  if (list != NULL)
	    free(list);
	}
    }
}

static void
dumpSelectors(Class c, const char *needle)
{
  unsigned int count = 0;
  Method *methods = class_copyMethodList(c, &count);
  unsigned int i;

  printf("=== %s methods matching \"%s\" ===\n", class_getName(c), needle);
  for (i = 0; i < count; i++)
    {
      const char *n = sel_getName(method_getName(methods[i]));

      if (strstr(n, needle) != NULL)
	printf("- %s\n", n);
    }
  if (methods != NULL)
    free(methods);
}

int main(void)
{
  @autoreleasepool
    {
      setbuf(stdout, NULL);
      dumpProtocol("NSBrowserDelegate");
      dumpSelectors([NSBrowser class], "tem");
      dumpSelectors([NSBrowser class], "olumn");
      printf("done\n");
    }
  return 0;
}
