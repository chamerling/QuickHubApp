//
//  GrowlManager.h
//  QuickHubApp
//
//  Created by Christophe Hamerling on 25/10/11.
//  Copyright 2011 christophehamerling.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/GrowlApplicationBridge.h>

@interface GrowlManager : NSObject<GrowlApplicationBridgeDelegate, NSUserNotificationCenterDelegate>

- (void)notifyWithName:(NSString*)name desc:(NSString*)description context:(NSDictionary*)context;
- (void)notifyWithName:(NSString*)name desc:(NSString*)description url:(NSString *)urlToOpen icon:(NSURL *) iconURL;
- (void)notifyWithName:(NSString*)name desc:(NSString*)description url:(NSString *)urlToOpen iconName:(NSString *) iconName;

// growl can be enabled but not available (not installed or not running)
- (BOOL) growlEnabled:(id) sender;
- (BOOL) growlAvailable:(id) sender;

// notification center is available
- (BOOL) notificationCenterEnabled:(id) sender;
- (BOOL) notificationCenterAvailable:(id) sender;

// All notifications status
- (BOOL) notificationsEnabled:(id) sender;

+ (GrowlManager *)get;

@end
