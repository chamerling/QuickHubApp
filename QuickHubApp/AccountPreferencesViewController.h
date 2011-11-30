//
//  AccountPreferencesViewController.h
//  QuickHub
//
//  Created by Christophe Hamerling on 24/11/11.
//  Copyright 2011 christophehamerling.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"

#import "AppController.h"
#import "GitHubController.h"
#import "MenuController.h"

@interface AccountPreferencesViewController : NSViewController<MASPreferencesViewController,NSWindowDelegate, NSTextFieldDelegate> {
    Preferences *preferences;
    NSTextField *emailField;
    NSTextField *passworrField;
    NSProgressIndicator *progressIndicator;
    NSTextField *connectionStatus;
    NSButton *signInButton;
    
    IBOutlet NSTextField *copyright;
    IBOutlet NSButton *openAtStartupButton;
    
    IBOutlet NSPopUpButton *pollingButton;
    IBOutlet NSPopUpButton *gistsButton;
    // controllers
    GitHubController *ghController;
    AppController *appController;
    MenuController *menuController;
    
}
@property (assign) IBOutlet NSButton *signInButton;
@property (assign) IBOutlet NSTextField *connectionStatus;
@property (assign) IBOutlet NSTextField *emailField;
@property (assign) IBOutlet NSTextField *passworrField;
@property (nonatomic, retain) GitHubController *ghController;
@property (nonatomic, retain) AppController *appController;
@property (nonatomic, retain) MenuController *menuController;

@property (assign) IBOutlet NSProgressIndicator *progressIndicator;

- (IBAction)signIn:(id)sender;
- (IBAction)openAtStartup:(id)sender;

- (BOOL) checkIfUpdateNeeded;
- (void)checkRemoteTask:(id) sender;

@end
