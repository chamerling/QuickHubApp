//
//  AccountPreferencesViewController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 24/11/11.
//  Copyright 2011 christophehamerling.com. All rights reserved.
//

#import "AccountPreferencesViewController.h"
#import "NSWorkspaceHelper.h"

@implementation AccountPreferencesViewController

@synthesize signInButton;
@synthesize connectionStatus;
@synthesize emailField;
@synthesize passworrField;
@synthesize ghController;
@synthesize menuController;
@synthesize appController;
@synthesize progressIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        preferences = [Preferences sharedInstance];
    }
    
    return self;
}

- (id)init
{
    return [super initWithNibName:@"AccountPreferencesViewController" bundle:nil];
}

- (void)viewWillAppear {

    preferences = [Preferences sharedInstance];

    [progressIndicator setHidden:YES];
    
    if ([[preferences login]length] > 0) {
        [emailField setStringValue:[preferences login]];
    }
    [emailField setDelegate:self];
    
    if ([[preferences password]length] > 0) {
        [passworrField setStringValue:[preferences password]];
    }
    [passworrField setDelegate:self];
    
    // set quickhub preferences from the configuration
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL openAtLogin = [defaults boolForKey:@"openAtLogin"];
    NSInteger state = 0;
    if (openAtLogin) {
        state = 1;
    }
    [openAtStartupButton setState:state];
    
    // do it in a separate process so that we do not freeze the window
    [self performSelectorInBackground:@selector(checkRemoteTask:) withObject:nil];  
}

# pragma mark - Actions
- (IBAction)signIn:(id)sender {
    preferences = [Preferences sharedInstance];

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
        } else {
            [connectionStatus setStringValue:@"Bad credentials!"];
            [appController stopAll:nil];
            [menuController cleanMenus:nil];
            [menuController resetCache:nil];
        }
    }
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
    return YES;
    /*
     BOOL result = NO;
     NSString* oldLogin = [preferences login];
     NSString* oldPassword = [preferences password];
     
     if (!oldLogin) {
     oldLogin = [NSString stringWithString:@""];
     }
     if (!oldPassword) {
     oldPassword = [NSString stringWithString:@""];
     }
     
     NSComparisonResult loginCompare = [oldLogin compare:[emailField stringValue]];
     NSComparisonResult pwdCompare = [oldPassword compare:[passworrField stringValue]];
     
     if (loginCompare != NSOrderedSame || pwdCompare != NSOrderedSame) {
     result = YES;
     }
     return result;
     */
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

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"AccountPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameAdvanced];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Account", @"Toolbar item name for the Account preference pane");
}

@end
