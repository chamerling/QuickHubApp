//
//  GistCreateWindowController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 31/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GistCreateWindowController.h"
#import "QHConstants.h"

@interface GistCreateWindowController (Private)
- (void) createGist:(NSString*) content withDescription:(NSString*) description andFileName:(NSString *) fileName isPublic:(BOOL) pub;
- (void) fileHasBeenDnD:(NSNotification *)aNotification;
@end

@implementation GistCreateWindowController

@synthesize ghClient;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // listen for events
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(fileHasBeenDnD:)
                                                     name:GIST_DND
                                                   object:nil];

    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)createGist:(id)sender {
    // create the gist...
    NSString *description = [[descriptionField stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *theFileName = [[fileNameField stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *content = [contentTextView string];
    
    if (!theFileName || !content || ([theFileName length] == 0) || ([content length] == 0)) {
        NSBeep();
    } else {
        [self createGist:content withDescription:description andFileName:theFileName isPublic:TRUE];
    }
}

- (IBAction)createPrivateGist:(id)sender {
    // create the gist...
    NSString *description = [[descriptionField stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *theFileName = [[fileNameField stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *content = [contentTextView string];
    
    if (!theFileName || !content || ([theFileName length] == 0) || ([content length] == 0)) {
        NSBeep();
    } else {
        [self createGist:content withDescription:description andFileName:theFileName isPublic:FALSE];
    }
}

- (IBAction)cleanFields:(id)sender {
    [fileNameField setStringValue:@""];
    [descriptionField setStringValue:@""];
    [contentTextView setString:@""];
}

- (void) createGist:(NSString*) content withDescription:(NSString*) description andFileName:(NSString *) fileName isPublic:(BOOL) pub {
    [createButton setEnabled:NO];
    [progressIndicator setHidden:NO];
    [progressIndicator startAnimation:nil];
    NSString *gistURL = nil;
    if (ghClient) {
        gistURL = [ghClient createGist:content withDescription:description andFileName:fileName isPublic:pub];
    }
    [progressIndicator stopAnimation:nil];
    [progressIndicator setHidden:YES];
    [createButton setEnabled:YES];
    if ([copyURLToPasteBoard state] == 1) {
        NSString *finalURL = [NSString stringWithFormat:@"https://gist.github.com/%@", gistURL];
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        [pasteboard writeObjects:[NSArray arrayWithObject:finalURL]];
    }
}

- (void)fileHasBeenDnD:(NSNotification *)aNotification {
    // get the notification content which should be the file name with full path
    NSString *fileName = [aNotification object];
    [fileNameField setStringValue:[fileName lastPathComponent]];
    
    // focus
    [descriptionField selectText:self];
    [[descriptionField currentEditor] setSelectedRange:NSMakeRange([[fileNameField stringValue]length], 0)];
}

@end
