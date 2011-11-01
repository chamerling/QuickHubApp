//
//  GrowlManager.h
//  QuickHubApp
//
//  Created by Christophe Hamerling on 25/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/GrowlApplicationBridge.h>

@interface GrowlManager : NSObject<GrowlApplicationBridgeDelegate>

- (void)notifyWithName:(NSString*)name desc:(NSString*)description context:(NSDictionary*)context;

@end
