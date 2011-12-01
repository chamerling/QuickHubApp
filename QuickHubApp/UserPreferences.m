//
//  UserPreferences.m
//  QuickHub
//
//  Created by Christophe Hamerling on 01/12/11.
//  Copyright 2011 christophehamerling.com. All rights reserved.
//

#import "UserPreferences.h"
#import "Preferences.h"
#import "QHConstants.h"

@interface UserPreferences (Private)
- (void) loadUserData:(id)source;
@end

@implementation UserPreferences

@synthesize avatar;
@synthesize firstName;
@synthesize lastName;
@synthesize accessButton;

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
    return [super initWithNibName:@"UserPreferences" bundle:nil];
}

- (void)viewWillAppear {
    Preferences *pref = [Preferences sharedInstance];
    if (![pref oauthToken] || [[pref oauthToken]length] == 0) {
        [accessButton setStringValue:@""];
        [accessButton setTitle:@"Authorize QuickHub"];
    } else {
        [accessButton setTitle:@"Revoke Access"];
        [NSThread detachNewThreadSelector:@selector(loadUserData:) toTarget:self withObject:nil];        
    }
}

- (void)loadUserData:(id)source {
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSDictionary *userData = [client loadUser:nil];
    // Note : do not release anything in the GH client since it will crash all...
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:userData waitUntilDone:YES];
   [pool release];
}

- (void)updateUI:(NSDictionary*) userData {
    [lastName setStringValue:[NSString stringWithFormat:@"%@", [userData valueForKey:@"name"]]];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [userData valueForKey:@"avatar_url"]]]];
    [image setSize:NSMakeSize(100,100)];
    [avatar setImage:image];
}

- (IBAction)accessAction:(id)sender {
    Preferences *pref = [Preferences sharedInstance];
    if (![pref oauthToken] || [[pref oauthToken]length] == 0) {
        // access
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:oauthsite]];
        // close the current window...
    } else {
        // revoke
        [pref storeToken:@""];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:revokeurl]];
    }
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"UserPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameUser];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"User", @"Toolbar item name for the User preference pane");
}

@end
