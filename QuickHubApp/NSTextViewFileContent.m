// (The MIT License)
//
// Copyright (c) 2013 Christophe Hamerling <christophe.hamerling@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// 'Software'), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "NSTextViewFileContent.h"
#import "QHConstants.h"

@implementation NSTextViewFileContent

- (id)init
{
    self = [super init];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    }
    
    return self;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSLog(@"Perform drag operation");
    NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    for (NSString *item in draggedFilenames){
        // TODO : filter types
        CFStringRef fileExtension = (CFStringRef) [item pathExtension];
        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
        
        NSLog(@"Extension %@", fileExtension);
        BOOL validFormat = NO;
        // check UTI
        // http://developer.apple.com/library/mac/#documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html
        if (UTTypeConformsTo(fileUTI, kUTTypeImage)) NSLog(@"It's an image!");
        else if (UTTypeConformsTo(fileUTI, kUTTypeMovie)) NSLog(@"It's a movie!");
        else {
            // other types should work...
            validFormat = YES;
        }
        CFRelease(fileUTI);

        if (validFormat) {
            NSError *error;
            NSString *content = [[NSString alloc]
                                          initWithContentsOfFile:item
                                          encoding:NSUTF8StringEncoding
                             error:&error];
        
            if (content) {
                [self setString:content];
                // dispatch the file name in order to notify others that something happened with this file.
                // espacially, we want to update others fields with that data and set the cursor somewhere...
                [[NSNotificationCenter defaultCenter] postNotificationName:GIST_DND object:item userInfo:nil];
            }
        } else {
            NSLog(@"Invalid format");
            [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
                                                                object:@"Invalid file format" 
                                                              userInfo:nil];
        }
    }
    return YES;
}

@end
