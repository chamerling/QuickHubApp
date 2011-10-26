//
//  QHConstants.h
//  QuickHubApp
//
//  Created by Christophe Hamerling on 26/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QHConstants : NSObject

#ifndef QH_Constants_h
#define QH_Constants_h

#define appsite     @"http://quickhubapp.com"
#define growllogo   @"QuickHubLogo-128.png"
#define notificatioName @"QuickHub";
#define eventDatePattern  @"yyyy-MM-dd"

#pragma mark - GITHUB Notification events
#define GITHUB_NOTIFICATION_REPOSITORIES_ADDED   @"Repository Added"
#define GITHUB_NOTIFICATION_REPOSITORIES_REMOVED @"Repository Removed"
#define GITHUB_NOTIFICATION_COMMITS_PUSHED @"New Push"
#define GITHUB_NOTIFICATION_WATCHERS_ADDED @"New Watchers Added"

#define GITHUB_NOTIFICATION_REPOS @"GetRepos"
#define GITHUB_NOTIFICATION_GISTS @"GetGists"
#define GITHUB_NOTIFICATION_ORGS @"GetOrgs"
#define GITHUB_NOTIFICATION_ISSUES @"GetIssues"
#define GITHUB_NOTIFICATION_PULLS @"GetPulls"

#define HTTP_NOTIFICATION_FAILURE @"GetIssues"

#define GENERIC_NOTIFICATION @"GenericListener"

#endif

@end
