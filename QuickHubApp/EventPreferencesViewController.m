// (The MIT License)
//
// Copyright (c) 2013 Christophe Hamerling <christophe.hamerling@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// 'Software'), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
