//
//  IssueCreateWindowController.h
//  QuickHub
//
//  Created by Christophe Hamerling on 03/01/12.
//  Copyright 2012 christophehamerling.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GithubOAuthClient.h"
#import "MenuController.h"

@interface IssueCreateWindowController : NSWindowController {
    
    GithubOAuthClient *ghClient;
    MenuController *menuController;
    
    NSTextField *titleField;
    NSTextView *issueDetails;
    NSButton *assignToMe;
    NSButton *openWebPage;
    NSProgressIndicator *progress;
    NSButton *createButton;
    NSButton *cancelButton;
    NSPopUpButton *repositoryList;
}
@property (assign) IBOutlet NSPopUpButton *repositoryList;
@property (assign) IBOutlet NSButton *createButton;
@property (assign) IBOutlet NSButton *cancelButton;
@property (assign) IBOutlet NSTextField *titleField;
@property (assign) IBOutlet NSTextView *issueDetails;
@property (assign) IBOutlet NSButton *assignToMe;
@property (assign) IBOutlet NSButton *openWebPage;
@property (assign) IBOutlet NSProgressIndicator *progress;
@property (assign) GithubOAuthClient *ghClient;
@property (assign) MenuController *menuController;

- (IBAction)cancelAction:(id)sender;
- (IBAction)createAction:(id)sender;

@end
