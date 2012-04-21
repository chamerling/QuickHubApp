//
//  AccountPreferencesViewController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 24/11/11.
//  Copyright 2011 christophehamerling.com. All rights reserved.
//

#import "AccountPreferencesViewController.h"
#import "NSWorkspaceHelper.h"
#import "QHConstants.h"

@implementation AccountPreferencesViewController
@synthesize showActionsButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)init
{
    return [super initWithNibName:@"AccountPreferencesViewController" bundle:nil];
}

- (void)viewWillAppear {

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL openAtLogin = [defaults boolForKey:@"openAtLogin"];
    NSInteger state = 0;
    if (openAtLogin) {
        state = 1;
    }
    [openAtStartupButton setState:state];
    
    BOOL showPref = [defaults boolForKey:PREF_SHOW_ACTIONS];
    [showActionsButton setState:showPref ? 1 : 0];
}

# pragma mark - Actions
- (IBAction)openAtStartup:(id)sender {
    
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

- (IBAction)showActions:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[sender state] forKey:PREF_SHOW_ACTIONS];
    [defaults synchronize];
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
    return NSLocalizedString(@"General", @"Toolbar item name for the Account preference pane");
}

@end
