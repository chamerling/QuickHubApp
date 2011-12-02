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

@synthesize progressIndicator;
@synthesize location;
@synthesize avatar;
@synthesize firstName;
@synthesize lastName;
@synthesize company;
@synthesize accessButton;
@synthesize appController;
@synthesize menuController;

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
        [accessButton setTitle:@"Authorize"];
        [lastName setStringValue:@""];
        [location setStringValue:@""];
        [company setStringValue:@""];
    } else {
        [progressIndicator setHidden:NO];
        [progressIndicator startAnimation:nil];
        [accessButton setTitle:@"Revoke Access"];
        [NSThread detachNewThreadSelector:@selector(loadUserData:) toTarget:self withObject:nil];        
    }
}

- (void)loadUserData:(id)source {
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSDictionary *userData = [client loadUser:nil];
    [[Preferences sharedInstance]storeLogin:[userData valueForKey:@"login"] withPassword:@""];
    // Note : do not release anything in the GH client since it will crash all...
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:userData waitUntilDone:YES];
   [pool release];
}

- (void)updateUI:(NSDictionary*) userData {
    [lastName setStringValue:[NSString stringWithFormat:@"%@", [userData valueForKey:@"name"]]];
    [location setStringValue:[NSString stringWithFormat:@"%@", [userData valueForKey:@"location"]]];
    [company setStringValue:[NSString stringWithFormat:@"%@", [userData valueForKey:@"company"]]];
    
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [userData valueForKey:@"avatar_url"]]]];
    [image setSize:NSMakeSize(100,100)];
    [avatar setImage:image];
    [progressIndicator setHidden:YES];
    [progressIndicator stopAnimation:nil];
}

- (IBAction)accessAction:(id)sender {
    Preferences *pref = [Preferences sharedInstance];
    if (![pref oauthToken] || [[pref oauthToken]length] == 0) {
        [accessButton setTitle:@"Revoke Access"];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:oauthsite]];
    } else {
        
        // not available for now
        //NSDictionary* auths = [client getAuthorizations:nil];
        [pref storeToken:@""];
        [pref storeLogin:@"" withPassword:@""];
        [appController stopAll:nil];
        [menuController cleanMenus:nil];
        [menuController resetCache:nil];
        [lastName setStringValue:@""];
        [location setStringValue:@""];
        [company setStringValue:@""];
        [accessButton setTitle:@"Authorize"];
        NSImage *image = [NSImage imageNamed:@"qh.png"];
        [image setSize:NSMakeSize(100,100)];
        [avatar setImage:image];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:revokeurl]];
    }
    [[[super view]window]close];
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
    return NSLocalizedString(@"GitHub", @"Toolbar item name for the GitHub preference pane");
}

@end
