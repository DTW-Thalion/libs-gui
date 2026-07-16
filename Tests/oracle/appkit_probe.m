/* Apple oracle for NSBrowserCell.  Probes init defaults (leaf, loaded,
   alternateImage), the leaf/loaded/alternateImage setters, set/reset (highlight
   + state), the +branchImage / +highlightedBranchImage class images, and
   whether -copy preserves leaf/loaded/alternateImage.  Portable so the same
   file runs under GNUstep for an A/B. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    NSBrowserCell *c = [[NSBrowserCell alloc] initTextCell: @"Item"];
    printf("INIT leaf=%d loaded=%d altImage=%s\n",
           [c isLeaf], [c isLoaded],
           [c alternateImage] == nil ? "nil" : "set");

    NSImage *img = [[NSImage alloc] initWithSize: NSMakeSize(8, 8)];
    [c setLeaf: YES];
    [c setLoaded: YES];
    [c setAlternateImage: img];
    printf("SET leaf=%d loaded=%d altImageSame=%d\n",
           [c isLeaf], [c isLoaded], [c alternateImage] == img);

    [c set];
    printf("AFTERSET highlighted=%d state=%ld\n",
           [c isHighlighted], (long)[c state]);
    [c reset];
    printf("AFTERRESET highlighted=%d state=%ld\n",
           [c isHighlighted], (long)[c state]);

    printf("BRANCH branchImage=%s highlightedBranchImage=%s\n",
           [NSBrowserCell branchImage] == nil ? "nil" : "set",
           [NSBrowserCell highlightedBranchImage] == nil ? "nil" : "set");

    NSBrowserCell *copy = [c copy];
    printf("COPY leaf=%d loaded=%d altImageSame=%d\n",
           [copy isLeaf], [copy isLoaded], [copy alternateImage] == img);
  }
  return 0;
}
