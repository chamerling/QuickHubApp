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

#define APP_PREFIX @"org.chamerling.quickhubapp"

#define appsite     @"http://quickhubapp.com"
#define oauthsite   @"http://quickhubapp.com/oauth.html"
#define revokeurl   @"https://github.com/account/connections/"

#define urlscheme   @"quickhubapp"

#define oauthservice @"oauth"
#define gistservice @"gist"

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
#define GITHUB_NOTIFICATION_REPO_CREATED @"RepoCreated"

#define HTTP_NOTIFICATION_FAILURE @"HTTPFailure"

#define GENERIC_NOTIFICATION @"GenericListener"

#define GIST_DND @"GistDnd"

#define POLLING_START @"PollingStart"
#define POLLING_STOP @"PollingStop"

#define NOTIFY_INTERNET_DOWN @"InternetIsDown"
#define NOTIFY_INTERNET_UP @"InternetIsUp"

#define HTTP_200 200;
#define HTTP_201 201;

#pragma mark - Events

#define CommitCommentEvent @"CommitCommentEvent"
#define CreateEvent @"CreateEvent"
#define DeleteEvent @"DeleteEvent"
#define DownloadEvent @"DownloadEvent"
#define FollowEvent @"FollowEvent"
#define ForkEvent @"ForkEvent"
#define ForkApplyEvent @"ForkApplyEvent"
#define GistEvent @"GistEvent"
#define GollumEvent @"GollumEvent"
#define IssueCommentEvent @"IssueCommentEvent"
#define IssuesEvent @"IssuesEvent"
#define MemberEvent @"MemberEvent"
#define PublicEvent @"PublicEvent"
#define PullRequestEvent @"PullRequestEvent"
#define PullRequestReviewCommentEvent @"PullRequestReviewCommentEvent"
#define PushEvent @"PushEvent"
#define TeamAddEvent @"TeamAddEvent"
#define WatchEvent @"WatchEvent"

#define GHCommitCommentEvent @"GHCommitCommentEvent"
#define GHCreateEvent @"GHCreateEvent"
#define GHDeleteEvent @"GHDeleteEvent"
#define GHDownloadEvent @"GHDownloadEvent"
#define GHFollowEvent @"GHFollowEvent"
#define GHForkEvent @"GHForkEvent"
#define GHForkApplyEvent @"GHForkApplyEvent"
#define GHGistEvent @"GHGistEvent"
#define GHGollumEvent @"GHGollumEvent"
#define GHIssueCommentEvent @"GHIssueCommentEvent"
#define GHIssuesEvent @"GHIssuesEvent"
#define GHMemberEvent @"GHMemberEvent"
#define GHPublicEvent @"GHPublicEvent"
#define GHPullRequestEvent @"GHPullRequestEvent"
#define GHPullRequestReviewCommentEvent @"GHPullRequestReviewCommentEvent"
#define GHPushEvent @"GHPushEvent"
#define GHTeamAddEvent @"GHTeamAddEvent"
#define GHWatchEvent @"GHWatchEvent"

#endif

@end
