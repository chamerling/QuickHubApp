//
//  GistCreateWindowController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 31/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GistCreateWindowController.h"

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
    [createButton setEnabled:NO];
    [progressIndicator setHidden:NO];
    [progressIndicator startAnimation:nil];
    // create the gist...
    NSString *description = [[descriptionField stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *theFileName = [[fileNameField stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL pub = [publicChoice state] == 1 ? TRUE : FALSE;
    NSString *content = [contentTextView string];
    
    if (ghController) {
        [ghController createGist:content withDescription:description andFileName:theFileName isPublic:pub];
    }
    [progressIndicator stopAnimation:nil];
    [progressIndicator setHidden:YES];
    [createButton setEnabled:YES];
}
@end
