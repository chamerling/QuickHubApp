//
//  PreferencesWindowController.h
//  QuickHubApp
//
//  Created by Christophe Hamerling on 10/10/11.
//  Copyright 2011 chamerling.org. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Cocoa/Cocoa.h>

#import "Preferences.h"
#import "QuickHubAppAppDelegate.h"
#import "MenuController.h"

@interface PreferencesWindowController : NSWindowController<NSWindowDelegate, NSTextFieldDelegate> {
    Preferences *preferences;
    NSTextField *emailField;
    NSTextField *passworrField;
    NSProgressIndicator *progressIndicator;
    NSTextField *connectionStatus;
    NSButton *signInButton;
    IBOutlet NSTextField *Version;
    
    IBOutlet NSButton *openAtStartupButton;
    
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
- (IBAction)about:(id)sender;
- (IBAction)openAtStartup:(id)sender;

- (BOOL) checkIfUpdateNeeded;
- (void)checkRemoteTask:(id) sender;

@end
