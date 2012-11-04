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
    
}

@property (assign) BOOL growl;
@property (assign) BOOL notificationCenter;

@end
