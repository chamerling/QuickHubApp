//
//  GrowlManager.h
//  QuickHubApp
//
//  Created by Christophe Hamerling on 25/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/GrowlApplicationBridge.h>

#define GITHUB_NOTIFICATION_REPOSITORIES_ADDED   @"Repository Added"
#define GITHUB_NOTIFICATION_REPOSITORIES_REMOVED @"Repository Removed"
#define GITHUB_NOTIFICATION_COMMITS_PUSHED @"New Push"
#define GITHUB_NOTIFICATION_WATCHERS_ADDED @"New Watchers Added"

@interface GrowlManager : NSObject<GrowlApplicationBridgeDelegate>

@end
