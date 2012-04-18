//
//  EventPreferencesViewController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 17/04/12.
//  Copyright 2012 christophehamerling.com. All rights reserved.
//

#import "EventPreferencesViewController.h"
#import "Preferences.h"

@implementation EventPreferencesViewController

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
    return [super initWithNibName:@"EventPreferencesViewController" bundle:nil];
}

- (IBAction)toggleEvent:(id)sender {
    // persist modification when checkbox state is modified
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults synchronize];    
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"EventPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:@"notification-128"];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Notifications", @"Toolbar item name for the Events preference pane");
}

@end
