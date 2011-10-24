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

@interface PreferencesWindowController : NSWindowController<NSWindowDelegate, NSTextFieldDelegate> {
    Preferences *preferences;
    NSTextField *emailField;
    NSTextField *passworrField;
    QuickHubAppAppDelegate* app;
    NSProgressIndicator *progressIndicator;
    NSTextField *connectionStatus;
    NSButton *signInButton;
}
@property (assign) IBOutlet NSButton *signInButton;
@property (assign) IBOutlet NSTextField *connectionStatus;
@property (assign) IBOutlet NSTextField *emailField;
@property (assign) IBOutlet NSTextField *passworrField;
@property (nonatomic, retain) QuickHubAppAppDelegate *app;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;

- (IBAction)signIn:(id)sender;
- (IBAction)about:(id)sender;

- (BOOL) checkIfUpdateNeeded;

@end
