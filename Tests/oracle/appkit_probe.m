/* Apple oracle for the NSTextAttachment coverage test: the default
   attachment cell, the file wrapper round-trip, and the attachment cell
   round-trip with its back reference. */
#import <Cocoa/Cocoa.h>

int
main(int argc, const char **argv)
{
  @autoreleasepool
  {
    NSTextAttachment *a = [[NSTextAttachment alloc] initWithFileWrapper: nil];
    NSLog(@"TA initNil fileWrapper=%@ cell=%@",
          [a fileWrapper] == nil ? @"nil" : @"set",
          [a attachmentCell] == nil ? @"nil" : NSStringFromClass([(id)[a attachmentCell] class]));

    NSData *data = [@"hello" dataUsingEncoding: NSUTF8StringEncoding];
    NSFileWrapper *fw = [[NSFileWrapper alloc] initRegularFileWithContents: data];
    NSTextAttachment *b = [[NSTextAttachment alloc] initWithFileWrapper: fw];
    NSLog(@"TA initFW fileWrapperSame=%d cell=%@",
          [b fileWrapper] == fw,
          [b attachmentCell] == nil ? @"nil" : NSStringFromClass([(id)[b attachmentCell] class]));

    NSTextAttachment *c = [[NSTextAttachment alloc] init];
    [c setFileWrapper: fw];
    NSLog(@"TA setFW same=%d", [c fileWrapper] == fw);

    NSTextAttachmentCell *cell = [[NSTextAttachmentCell alloc] init];
    [c setAttachmentCell: cell];
    NSLog(@"TA setCell same=%d cellAttachmentSame=%d",
          [c attachmentCell] == cell, [cell attachment] == c);
  }
  return 0;
}
