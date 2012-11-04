//
//  NotificationPreferencesViewController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 02/11/12.
//
//

#import "NotificationPreferencesViewController.h"
#import "GrowlManager.h"

@interface NotificationPreferencesViewController ()

@end

@implementation NotificationPreferencesViewController

@synthesize growl;
@synthesize notificationCenter;

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
    growl = [[GrowlManager get] growlAvailable:nil];
    notificationCenter = [[GrowlManager get] notificationCenterAvailable:nil];
    return [super initWithNibName:@"NotificationPreferencesViewController" bundle:nil];
}

#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"NotificationPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:@"octocat-128"];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Notification", @"Toolbar item name for the Notification preference pane");
}

@end
