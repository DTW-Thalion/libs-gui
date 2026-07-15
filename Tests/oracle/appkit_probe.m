/* Apple oracle for the NSGlyphInfo coverage test.  Probes the character
   collection enum and the three factory methods (character identifier, CG
   glyph, glyph name) with their readonly accessors (characterIdentifier,
   characterCollection, baseString, glyphID, glyphName).  Portable so the same
   file runs under GNUstep for an A/B. */
#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#else
#import <AppKit/AppKit.h>
#endif
#include <stdio.h>

static const char *
s(NSString *v)
{
  return v == nil ? "nil" : (const char *)[v UTF8String];
}

int
main(int argc, const char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  @autoreleasepool
  {
    [NSApplication sharedApplication];

    printf("ENUM coll Identity=%d CNS1=%d GB1=%d Japan1=%d Japan2=%d Korea1=%d\n",
           (int)NSIdentityMappingCharacterCollection,
           (int)NSAdobeCNS1CharacterCollection,
           (int)NSAdobeGB1CharacterCollection,
           (int)NSAdobeJapan1CharacterCollection,
           (int)NSAdobeJapan2CharacterCollection,
           (int)NSAdobeKorea1CharacterCollection);

    NSGlyphInfo *g1 = [NSGlyphInfo
        glyphInfoWithCharacterIdentifier: 42
                              collection: NSAdobeJapan1CharacterCollection
                              baseString: @"X"];
    printf("CID nonnil=%d cid=%lu coll=%lu base=%s glyphName=%s\n",
           g1 != nil, (unsigned long)[g1 characterIdentifier],
           (unsigned long)[g1 characterCollection],
           s([g1 baseString]), s([g1 glyphName]));

    NSFont *font = [NSFont systemFontOfSize: 12];
    NSGlyphInfo *g2 = [NSGlyphInfo glyphInfoWithCGGlyph: 36
                                               forFont: font
                                            baseString: @"A"];
    printf("CGG nonnil=%d glyphID=%d base=%s\n",
           g2 != nil, (int)[g2 glyphID], s([g2 baseString]));

    NSGlyphInfo *g3 = [NSGlyphInfo glyphInfoWithGlyphName: @"A"
                                                 forFont: font
                                              baseString: @"A"];
    printf("NAME nonnil=%d glyphName=%s\n",
           g3 != nil, g3 == nil ? "(nil object)" : s([g3 glyphName]));
  }
  return 0;
}
