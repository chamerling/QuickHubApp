//
//  GistCreateWindowController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 31/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GistCreateWindowController.h"

@interface GistCreateWindowController (Private)
- (void) createGist:(NSString*) content withDescription:(NSString*) description andFileName:(NSString *) fileName isPublic:(BOOL) pub;
@end

@implementation GistCreateWindowController
@synthesize ghController;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
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
    if (ghController) {
        [ghController createGist:content withDescription:description andFileName:fileName isPublic:pub];
    }
    [progressIndicator stopAnimation:nil];
    [progressIndicator setHidden:YES];
    [createButton setEnabled:YES];
}
@end
