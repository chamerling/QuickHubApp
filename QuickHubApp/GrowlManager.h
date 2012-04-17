//
//  GrowlManager.h
//  QuickHubApp
//
//  Created by Christophe Hamerling on 25/10/11.
//  Copyright 2011 christophehamerling.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/GrowlApplicationBridge.h>

@interface GrowlManager : NSObject<GrowlApplicationBridgeDelegate>

- (void)notifyWithName:(NSString*)name desc:(NSString*)description context:(NSDictionary*)context;
- (void)notifyWithName:(NSString*)name desc:(NSString*)description url:(NSString *)urlToOpen icon:(NSURL *) iconURL;
- (void)notifyWithName:(NSString*)name desc:(NSString*)description url:(NSString *)urlToOpen iconName:(NSString *) iconName;

+ (GrowlManager *)get;

@end
