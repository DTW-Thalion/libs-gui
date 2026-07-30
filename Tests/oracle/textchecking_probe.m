/* Ground truth for libs-gui #76: what -[NSTextCheckingController ...] actually
   does to its client. The client logs every call it receives, so the call
   sequence each controller method produces is visible, along with the return
   values of validAnnotations and menuAtIndex:clickedOnSelection:effectiveRange:.
*/
#import <Cocoa/Cocoa.h>
#include <stdio.h>

static NSString * const kText = @"This sentance has a mispelled word in it.";

#define LOG(fmt, ...) do { printf("      client: " fmt "\n", ##__VA_ARGS__); \
                           fflush(stdout); } while (0)

@interface LoggingClient : NSObject <NSTextCheckingClient>
{
  NSMutableAttributedString *_store;
  NSRange _selected;
}
@end

@implementation LoggingClient

- (instancetype) init
{
  self = [super init];
  if (self != nil)
    {
      _store = [[NSMutableAttributedString alloc] initWithString: kText];
      _selected = NSMakeRange(5, 8);   /* "sentance" */
    }
  return self;
}

/* NSTextCheckingClient */

- (void) addAnnotations: (NSDictionary *)annotations range: (NSRange)range
{
  LOG("addAnnotations:%s range:{%lu,%lu}",
      [[[annotations allKeys] description] UTF8String],
      (unsigned long)range.location, (unsigned long)range.length);
}

- (NSAttributedString *) annotatedSubstringForProposedRange: (NSRange)range
                                                actualRange: (NSRangePointer)actualRange
{
  NSRange clamped = NSIntersectionRange(range,
                                        NSMakeRange(0, [_store length]));

  LOG("annotatedSubstringForProposedRange:{%lu,%lu} -> {%lu,%lu}",
      (unsigned long)range.location, (unsigned long)range.length,
      (unsigned long)clamped.location, (unsigned long)clamped.length);
  if (actualRange != NULL)
    {
      *actualRange = clamped;
    }
  return [_store attributedSubstringFromRange: clamped];
}

- (NSCandidateListTouchBarItem *) candidateListTouchBarItem
{
  LOG("candidateListTouchBarItem");
  return nil;
}

- (void) removeAnnotation: (NSAttributedStringKey)annotationName range: (NSRange)range
{
  LOG("removeAnnotation:%s range:{%lu,%lu}", [annotationName UTF8String],
      (unsigned long)range.location, (unsigned long)range.length);
}

- (void) replaceCharactersInRange: (NSRange)range
                withAnnotatedString: (NSAttributedString *)annotatedString
{
  LOG("replaceCharactersInRange:{%lu,%lu} withAnnotatedString:\"%s\"",
      (unsigned long)range.location, (unsigned long)range.length,
      [[annotatedString string] UTF8String]);
}

- (void) selectAndShowRange: (NSRange)range
{
  LOG("selectAndShowRange:{%lu,%lu}",
      (unsigned long)range.location, (unsigned long)range.length);
  _selected = range;
}

- (void) setAnnotations: (NSDictionary *)annotations range: (NSRange)range
{
  LOG("setAnnotations:%s range:{%lu,%lu}",
      [[[annotations allKeys] description] UTF8String],
      (unsigned long)range.location, (unsigned long)range.length);
}

- (NSView *) viewForRange: (NSRange)range
             firstRect: (NSRectPointer)firstRect
             actualRange: (NSRangePointer)actualRange
{
  LOG("viewForRange:{%lu,%lu}",
      (unsigned long)range.location, (unsigned long)range.length);
  return nil;
}

/* NSTextInputClient */

- (void) insertText: (id)string replacementRange: (NSRange)replacementRange
{
  LOG("insertText:\"%s\" replacementRange:{%lu,%lu}",
      [[string description] UTF8String],
      (unsigned long)replacementRange.location,
      (unsigned long)replacementRange.length);
}

- (void) doCommandBySelector: (SEL)selector
{
  LOG("doCommandBySelector:%s", sel_getName(selector));
}

- (void) setMarkedText: (id)string
         selectedRange: (NSRange)selectedRange
      replacementRange: (NSRange)replacementRange
{
  LOG("setMarkedText:");
}

- (void) unmarkText { LOG("unmarkText"); }

- (NSRange) selectedRange
{
  LOG("selectedRange -> {%lu,%lu}", (unsigned long)_selected.location,
      (unsigned long)_selected.length);
  return _selected;
}

- (NSRange) markedRange { return NSMakeRange(NSNotFound, 0); }
- (BOOL) hasMarkedText { return NO; }

- (NSAttributedString *) attributedSubstringForProposedRange: (NSRange)range
                                                 actualRange: (NSRangePointer)actualRange
{
  NSRange clamped = NSIntersectionRange(range,
                                        NSMakeRange(0, [_store length]));

  LOG("attributedSubstringForProposedRange:{%lu,%lu} -> {%lu,%lu}",
      (unsigned long)range.location, (unsigned long)range.length,
      (unsigned long)clamped.location, (unsigned long)clamped.length);
  if (actualRange != NULL)
    {
      *actualRange = clamped;
    }
  return [_store attributedSubstringFromRange: clamped];
}

- (NSArray *) validAttributesForMarkedText { return [NSArray array]; }

- (NSRect) firstRectForCharacterRange: (NSRange)range
                          actualRange: (NSRangePointer)actualRange
{
  LOG("firstRectForCharacterRange:{%lu,%lu}",
      (unsigned long)range.location, (unsigned long)range.length);
  if (actualRange != NULL)
    {
      *actualRange = range;
    }
  return NSMakeRect(0, 0, 10, 10);
}

- (NSUInteger) characterIndexForPoint: (NSPoint)point { return NSNotFound; }

/* NSTextInputTraits: the controller may ask about these before checking. */

#define TRAIT(getter, setter) \
- (NSTextInputTraitType) getter { LOG(#getter); return 0; } \
- (void) setter: (NSTextInputTraitType)t { }

TRAIT(autocorrectionType, setAutocorrectionType)
TRAIT(spellCheckingType, setSpellCheckingType)
TRAIT(grammarCheckingType, setGrammarCheckingType)
TRAIT(smartQuotesType, setSmartQuotesType)
TRAIT(smartDashesType, setSmartDashesType)
TRAIT(smartInsertDeleteType, setSmartInsertDeleteType)
TRAIT(textReplacementType, setTextReplacementType)
TRAIT(dataDetectionType, setDataDetectionType)
TRAIT(linkDetectionType, setLinkDetectionType)
TRAIT(textCompletionType, setTextCompletionType)

@end

/* -changeSpelling: takes the replacement from [[sender selectedCell] stringValue],
   the way the spelling panel hands one over. */
@interface MockSender : NSObject
{
  NSCell *_cell;
}
+ (instancetype) senderWithCorrection: (NSString *)correction;
- (NSCell *) selectedCell;
@end

@implementation MockSender

+ (instancetype) senderWithCorrection: (NSString *)correction
{
  MockSender *sender = [[[self alloc] init] autorelease];

  sender->_cell = [[NSCell alloc] initTextCell: correction];
  return sender;
}

- (NSCell *) selectedCell
{
  return _cell;
}

@end

static void
describeMenu(NSMenu *menu, int depth)
{
  NSInteger i;

  if (menu == nil)
    {
      printf("%*s(nil menu)\n", depth * 2, "");
      return;
    }
  printf("%*smenu \"%s\" with %ld items\n", depth * 2, "",
         [[menu title] UTF8String], (long)[menu numberOfItems]);
  for (i = 0; i < [menu numberOfItems]; i++)
    {
      NSMenuItem *item = [menu itemAtIndex: i];

      printf("%*s  [%ld] \"%s\" action=%s tag=%ld\n", depth * 2, "", (long)i,
             [[item title] UTF8String],
             [item action] ? sel_getName([item action]) : "(none)",
             (long)[item tag]);
      if ([item hasSubmenu])
        {
          describeMenu([item submenu], depth + 2);
        }
    }
  fflush(stdout);
}

int
main(void)
{
  @autoreleasepool
    {
      LoggingClient *client = [[LoggingClient alloc] init];
      NSTextCheckingController *c;
      NSRange effective;

      [NSApplication sharedApplication];

      c = [[NSTextCheckingController alloc] initWithClient: client];
      printf("=== after initWithClient: ===\n");
      printf("client is the object passed: %d\n", [c client] == client);
      printf("spellCheckerDocumentTag=%ld\n", (long)[c spellCheckerDocumentTag]);
      printf("uniqueSpellDocumentTag for reference=%ld\n",
             (long)[NSSpellChecker uniqueSpellDocumentTag]);

      printf("\n=== validAnnotations ===\n");
      {
        NSArray *annotations = [c validAnnotations];

        printf("count=%lu\n%s\n", (unsigned long)[annotations count],
               [[annotations description] UTF8String]);
      }

      printf("\n=== checkSpelling: ===\n");
      [c checkSpelling: nil];

      printf("\n=== checkTextInSelection: ===\n");
      [c checkTextInSelection: nil];

      printf("\n=== checkTextInDocument: ===\n");
      [c checkTextInDocument: nil];

      printf("\n=== checkTextInRange:types:options: (spelling only) ===\n");
      [c checkTextInRange: NSMakeRange(0, [kText length])
                    types: NSTextCheckingTypeSpelling
                  options: [NSDictionary dictionary]];

      printf("\n=== considerTextCheckingForRange: ===\n");
      [c considerTextCheckingForRange: NSMakeRange(0, 10)];

      printf("\n=== didChangeTextInRange: ===\n");
      [c didChangeTextInRange: NSMakeRange(0, 5)];

      printf("\n=== insertedTextInRange: ===\n");
      [c insertedTextInRange: NSMakeRange(0, 4)];

      printf("\n=== didChangeSelectedRange ===\n");
      [c didChangeSelectedRange];

      printf("\n=== updateCandidates ===\n");
      [c updateCandidates];

      printf("\n=== menuAtIndex:5 clickedOnSelection:YES ===\n");
      effective = NSMakeRange(NSNotFound, 0);
      describeMenu([c menuAtIndex: 5
               clickedOnSelection: YES
                   effectiveRange: &effective], 0);
      printf("effectiveRange={%lu,%lu}\n", (unsigned long)effective.location,
             (unsigned long)effective.length);

      printf("\n=== menuAtIndex:5 clickedOnSelection:NO ===\n");
      effective = NSMakeRange(NSNotFound, 0);
      describeMenu([c menuAtIndex: 5
               clickedOnSelection: NO
                   effectiveRange: &effective], 0);
      printf("effectiveRange={%lu,%lu}\n", (unsigned long)effective.location,
             (unsigned long)effective.length);

      printf("\n=== changeSpelling: from a sender whose selectedCell holds"
             " the correction ===\n");
      [c changeSpelling: [MockSender senderWithCorrection: @"sentence"]];

      printf("\n=== ignoreSpelling: ===\n");
      [c ignoreSpelling: nil];

      printf("\n=== invalidate, then a check ===\n");
      [c invalidate];
      [c checkSpelling: nil];
      printf("spellCheckerDocumentTag after invalidate=%ld\n",
             (long)[c spellCheckerDocumentTag]);

      printf("\ndone\n");
    }
  return 0;
}
