//
//  PreferencesWindowController.m
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

#import <Growl/Growl.h>
#import "NSWorkspaceHelper.h"

#import "PreferencesWindowController.h"

@interface PreferencesWindowController (Private)
- (void) taskDidTerminate:(NSNotification *)notification;
- (void) updateUI:(id)sender;
@end

@implementation PreferencesWindowController

@synthesize signInButton;
@synthesize connectionStatus;
@synthesize emailField;
@synthesize passworrField;
@synthesize ghController;
@synthesize menuController;
@synthesize appController;
@synthesize progressIndicator;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        NSLog(@"Init preferences window");
        preferences = [Preferences sharedInstance];
    }
    return self;
}

- (void) windowWillLoad {
}

- (void)windowDidLoad
{
    [super windowDidLoad];
  
    [[self window]setDelegate:self];
}

- (void)showWindow:(id)sender {
    NSLog(@"Show Preferences Window");
    [[self window] center];
    [[self window] setLevel:10000];

    [progressIndicator setHidden:YES];

    [emailField setStringValue:[preferences login]];
    [emailField setDelegate:self];
    
    [passworrField setStringValue:[preferences password]];
    [passworrField setDelegate:self];
    
    // set quickhub preferences from the configuration
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL openAtLogin = [defaults boolForKey:@"openAtLogin"];
    NSInteger state = 0;
    if (openAtLogin) {
        state = 1;
    }
    [openAtStartupButton setState:state];
    
    [Version setStringValue:[NSString stringWithFormat:@"Version %@", (NSString *)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey)]];
    
    // do it in a separate process so that we do not freeze the window
    [self performSelectorInBackground:@selector(checkRemoteTask:) withObject:nil];    
}

- (void) windowWillClose:(NSNotification *)notification {
    //[self signIn:nil];
}

# pragma mark - Actions
- (IBAction)signIn:(id)sender {
    if ([self checkIfUpdateNeeded]) {
        [preferences storeLogin:[emailField stringValue] withPassword:[passworrField stringValue]];
        [progressIndicator setHidden:NO];
        [connectionStatus setStringValue:@"Checking credentials..."];
        [progressIndicator startAnimation:nil];
        BOOL credentials = [ghController checkCredentials:nil];
        [progressIndicator stopAnimation:nil];
        [progressIndicator setHidden:YES];
        if (credentials) {
            // need to reset all data so that we do not display bad stuff...
            [connectionStatus setStringValue:[NSString stringWithFormat:@"Connected as %@", [preferences login]]];
            [signInButton setEnabled:NO];
            [appController stopAll:nil];
            [menuController cleanMenus:nil];
            [menuController resetCache:nil];
            [appController loadAll:nil];
            [self close];
        } else {
            [connectionStatus setStringValue:@"Bad credentials!"];
            [appController stopAll:nil];
            [menuController cleanMenus:nil];
        }
    }
}

- (IBAction)about:(id)sender {
}

- (IBAction)openAtStartup:(id)sender {
    NSLog(@"Open at startup called");
    
    // get the current state and save to workspace to open at startup...
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	NSBundle *bundle = [NSBundle mainBundle];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL shouldRegisterForLogin = [sender state];
	if (shouldRegisterForLogin) {
		[workspace registerLoginLaunchBundle:bundle];
		[defaults setBool:YES forKey:@"openAtLogin"];
	} else {
		[workspace unregisterLoginLaunchBundle:bundle];
		[defaults setBool:NO forKey:@"openAtLogin"];
	}
}

- (BOOL) checkIfUpdateNeeded {
    BOOL result = NO;
    NSString* oldLogin = [preferences login];
    NSString* oldPassword = [preferences password];
    NSComparisonResult loginCompare = [oldLogin compare:[emailField stringValue]];
    NSComparisonResult pwdCompare = [oldPassword compare:[passworrField stringValue]];
    
    if (loginCompare != NSOrderedSame || pwdCompare != NSOrderedSame) {
        result = YES;
    }
    return result;
}

- (void)checkRemoteTask:(id) sender {
    
    BOOL internetAvailable = YES;
    if (internetAvailable) {
        BOOL connected = [ghController checkCredentials:nil];
        if (connected) {
            [connectionStatus setStringValue:[NSString stringWithFormat:@"Connected as %@", [preferences login]]];
            [signInButton setEnabled:NO];
        } else {
            [connectionStatus setStringValue:@"Bad credentials!"];
        }
    } else {
        [signInButton setEnabled:NO];
        [connectionStatus setStringValue:@"No Internet connection!"];        
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskDidTerminate:)
                                                 name:NSTaskDidTerminateNotification
                                               object:nil];
}

- (void) taskDidTerminate:(NSNotification *)notification {
    // Call updateUI method on main thread to update the user interface
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}

# pragma mark - text fields delegate
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    [signInButton setEnabled:YES];
    return YES;
}

@end
