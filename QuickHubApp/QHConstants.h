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
#define growllogo   @"growl.png"
#define notificatioName @"QuickHub";
#define eventDatePattern  @"yyyy-MM-dd"

#pragma mark - Configuration
#define QH_CONF_USER @"userID";
#define QH_CONF_PASSWORD @"password";
#define QH_CONF_STARTUP @"openAtStartup";

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
#define GITHUB_NOTIFICATION_FOLLOWINGS @"GetFollowings"
#define GITHUB_NOTIFICATION_FOLLOWERS @"GetFollowers"
#define GITHUB_NOTIFICATION_WATCHEDREPO @"GetWatchedRepos"

#define GITHUB_NOTIFICATION_ISSUE_ADDED @"IssueAdded"
#define GITHUB_NOTIFICATION_ISSUE_REMOVED @"IssueRemoved"

#define GITHUB_NOTIFICATION_GIST_ADDED @"GistAdded"
#define GITHUB_NOTIFICATION_GIST_REMOVED @"GistRemoved"
#define GITHUB_NOTIFICATION_GIST_CREATED @"GistCreated"

#define HTTP_NOTIFICATION_FAILURE @"HTTPFailure"

#define GENERIC_NOTIFICATION @"GenericListener"

#define GIST_DND @"GistDnd"

#define POLLING_START @"PollingStart"
#define POLLING_STOP @"PollingStop"


#endif

@end
