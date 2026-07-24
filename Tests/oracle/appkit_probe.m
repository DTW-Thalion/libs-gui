/* Apple oracle: dump the public Objective-C method surface of every class that
   AppKit vends, so it can be diffed against GNUstep's libgnustep-gui.  For each
   AppKit class we print its instance methods (prefix i) and class methods
   (prefix c), skipping private selectors (those beginning with '_').  Portable:
   under GNUstep it dumps libgnustep-gui instead, so the same file produces both
   sides of the diff. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#import <objc/runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef __APPLE__
#define WANT_IMAGE "AppKit.framework"
#else
#define WANT_IMAGE "libgnustep-gui"
#endif

static int cmp(const void *a, const void *b)
{
  return strcmp(*(const char *const *)a, *(const char *const *)b);
}

static void dumpMethods(Class cls, char kind)
{
  unsigned int n = 0, i;
  Method *ms = class_copyMethodList(cls, &n);
  const char **names = malloc(sizeof(char *) * (n ? n : 1));
  unsigned int cnt = 0;
  for (i = 0; i < n; i++)
    {
      const char *sel = sel_getName(method_getName(ms[i]));
      if (sel[0] == '_') continue;
      names[cnt++] = sel;
    }
  qsort(names, cnt, sizeof(char *), cmp);
  for (i = 0; i < cnt; i++)
    printf("%c %s\n", kind, names[i]);
  free(names);
  if (ms) free(ms);
}

int
main(void)
{
  unsigned int n = 0, i;
  Class *classes = objc_copyClassList(&n);
  const char **names = malloc(sizeof(char *) * n);
  unsigned int cnt = 0;
  for (i = 0; i < n; i++)
    {
      const char *img = class_getImageName(classes[i]);
      const char *nm = class_getName(classes[i]);
      if (img == NULL || strstr(img, WANT_IMAGE) == NULL) continue;
      if (nm[0] == '_') continue;
      names[cnt++] = nm;
    }
  qsort(names, cnt, sizeof(char *), cmp);
  printf("### classes=%u image=%s\n", cnt, WANT_IMAGE);
  for (i = 0; i < cnt; i++)
    {
      Class cls = objc_getClass(names[i]);
      printf("@@ %s : %s\n", names[i],
             class_getSuperclass(cls) ? class_getName(class_getSuperclass(cls)) : "(root)");
      dumpMethods(cls, 'i');
      dumpMethods(object_getClass(cls), 'c');
    }
  free(names);
  if (classes) free(classes);
  return 0;
}
