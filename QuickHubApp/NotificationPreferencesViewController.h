//
//  NotificationPreferencesViewController.h
//  QuickHub
//
//  Created by Christophe Hamerling on 02/11/12.
//
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"
#import <Growl/GrowlApplicationBridge.h>

@interface NotificationPreferencesViewController : NSViewController<MASPreferencesViewController> {
    NSButton *switchEventNotificationButton;
    NSTextField *eventNotificationLabel;
    
    NSButton *switchApplicationNotificationButton;
    NSTextField *applicationNotificationLabel;
}

@property (assign) BOOL growl;
@property (assign) BOOL notificationCenter;

// Github Events
@property (assign) IBOutlet NSTextField *eventNotificationLabel;
@property (assign) IBOutlet NSButton *switchEventNotificationButton;
// Application notifications
@property (assign) IBOutlet NSTextField *applicationNotificationLabel;
@property (assign) IBOutlet NSButton *switchApplicationNotificationButton;

// Github Events
- (IBAction)switchEventNotification:(id)sender;
- (IBAction)toggleEvent:(id)sender;
// Application notifications
- (IBAction)switchApplicationNotification:(id)sender;
- (IBAction)toggleApplication:(id)sender;

@end
