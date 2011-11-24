//
//  RepoCreateWindowController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 24/11/11.
//  Copyright 2011 christophehamerling.com All rights reserved.
//

#import "RepoCreateWindowController.h"

@implementation RepoCreateWindowController

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

- (IBAction)createAction:(id)sender {

    NSString *name = [[nameField stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *description = [[descriptionField stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *url = [[homePageField stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL wiki = ([wikiBox state] == 1) ? TRUE : FALSE;
    BOOL issues = ([issuesBox state] == 1) ? TRUE : FALSE;
    BOOL downloads = ([downloadBox state] == 1) ? TRUE : FALSE;
    BOOL isPrivate = ([privateBox state] == 1) ? TRUE : FALSE;
    
    if (!name || [name length] == 0) {
        NSBeep();
    } else {
        [createButton setEnabled:FALSE];
        [cancelButton setEnabled:FALSE];
        [progress setHidden:FALSE];
        [progress startAnimation:nil];
        
        NSString *repoAPIURL = [ghController createRepository:name description:description homepage:url wiki:wiki issues:issues downloads:downloads isPrivate:isPrivate];
        
        NSLog(@"Repo created and URL is %@", repoAPIURL);
        
        [progress stopAnimation:nil];
        [progress setHidden:TRUE];
        [createButton setEnabled:TRUE];
        [cancelButton setEnabled:TRUE];
        
        // TODO : catch an exception
        if (repoAPIURL && [repoAPIURL length] > 0) {
            // TODO : reload all the repositories
            
        } else {
            NSLog(@"Creation problem, URL is nil");
        }
        
        [[self window] close];
    }

}

- (IBAction)cancelAction:(id)sender {
    [[self window] close];
}

@end
