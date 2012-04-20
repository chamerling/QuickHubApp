//
//  EventPreferencesViewController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 17/04/12.
//  Copyright 2012 christophehamerling.com. All rights reserved.
//

#import "EventPreferencesViewController.h"
#import "Preferences.h"
#import "QHConstants.h"

@implementation EventPreferencesViewController
@synthesize notificationLabel;
@synthesize switchNotificationButton;

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

- (void)viewWillAppear {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL result = YES;
    
    if ([defaults valueForKey:GHEventActive]) {
        result = [defaults boolForKey:GHEventActive];
    } else {
        // if not found, let's say that the notification is active...
        result = YES;
    }
            
    if (result) {
        [switchNotificationButton setTitle:@"Turn Off"];
        [notificationLabel setStringValue:@"Notifications are active."];
    } else {
        [switchNotificationButton setTitle:@"Turn On"];    
        [notificationLabel setStringValue:@"Notifications are inactive."];
    }
}

- (IBAction)switchNotification:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL result = YES;
    
    if ([defaults valueForKey:GHEventActive]) {
        result = [defaults boolForKey:GHEventActive];
    } else {
        // if not found, let's say that the notification is active...
        result = YES;
    }
        
    [defaults setBool:!result forKey:GHEventActive];
    
    if (result) {
        [switchNotificationButton setTitle:@"Turn On"];
        [notificationLabel setStringValue:@"Notifications are inactive."];
    } else {
        [switchNotificationButton setTitle:@"Turn Off"];    
        [notificationLabel setStringValue:@"Notifications are active."];
    }
    [defaults synchronize];
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
