//
//  NSTextViewFileContent.m
//  QuickHub
//
//  Created by Christophe Hamerling on 14/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
