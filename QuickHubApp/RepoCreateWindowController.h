//
//  RepoCreateWindowController.h
//  QuickHub
//
//  Created by Christophe Hamerling on 24/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GitHubController.h"

@interface RepoCreateWindowController : NSWindowController {
    // injected
    GitHubController *ghController;
    
    // local
    IBOutlet NSTextField *nameField;
    IBOutlet NSTextField *descriptionField;
    IBOutlet NSTextField *homePageField;
    IBOutlet NSButton *issuesBox;
    IBOutlet NSButton *downloadBox;
    IBOutlet NSButton *wikiBox;
    IBOutlet NSButton *privateBox;
    IBOutlet NSProgressIndicator *progress;
    IBOutlet NSButton *createButton;
    IBOutlet NSButton *cancelButton;
}

- (IBAction)createAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@property (assign) GitHubController *ghController;

@end
