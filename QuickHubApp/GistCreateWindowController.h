//
//  GistCreateWindowController.h
//  QuickHub
//
//  Created by Christophe Hamerling on 31/10/11.
//  Copyright 2011 christophehamerling.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GithubOAuthClient.h"

@interface GistCreateWindowController : NSWindowController {
    GithubOAuthClient *ghClient;
    
    IBOutlet NSTextField *descriptionField;
    IBOutlet NSTextField *fileNameField;
    IBOutlet NSTextView *contentTextView;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSButton *createButton;
    IBOutlet NSButtonCell *copyURLToPasteBoard;
}

@property (assign) GithubOAuthClient *ghClient;

#pragma mark - actions
- (IBAction)createGist:(id)sender;
- (IBAction)createPrivateGist:(id)sender;
- (IBAction)cleanFields:(id)sender;

@end
