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

#import <Foundation/Foundation.h>

@interface QHConstants : NSObject

#ifndef QH_Constants_h
#define QH_Constants_h

#define APP_PREFIX @"org.chamerling.quickhubapp"

#define appsite     @"http://quickhubapp.com"
#define oauthsite   @"https://github.com/login/oauth/authorize?client_id=c5a8828037f5233363fb&scope=user,gist"
#define revokeurl   @"https://github.com/account/connections/"

#define urlscheme   @"quickhubapp"

#define oauthservice @"oauth"
#define gistservice @"gist"

#define growllogo   @"octocat-128.png"
#define notificatioName @"QuickHub";
#define eventDatePattern  @"yyyy-MM-dd"

#pragma mark - Configuration

#define QH_CONF_USER @"userID";
#define QH_CONF_PASSWORD @"password";
#define QH_CONF_STARTUP @"openAtStartup";

#pragma mark - Notification choice

#define NOTIFICATION_OSX @"Notification_OSX"
#define NOTIFICATION_GROWL @"Notification_Growl"

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

#pragma mark - application notifications

#define QUICKHUB_NOTIFICATION_ACTIVE @"AppNotificationActive"
#define QUICKHUB_NOTIFICATION_REPOS @"AppNotificationRepos"
#define QUICKHUB_NOTIFICATION_GISTS @"AppNotificationGists"
#define QUICKHUB_NOTIFICATION_ORGS @"AppNotificationOrgs"
#define QUICKHUB_NOTIFICATION_ISSUES @"AppNotificationIssues"
#define QUICKHUB_NOTIFICATION_PULLS @"AppNotificationPulls"
#define QUICKHUB_NOTIFICATION_USERS @"AppNotificationUsers"
#define QUICKHUB_NOTIFICATION_FOLLOWINGS @"AppNotificationFollowings"
#define QUICKHUB_NOTIFICATION_FOLLOWERS @"AppNotificationFollowers"
#define QUICKHUB_NOTIFICATION_WATCHEDREPO @"AppNotificationWatchedRepos"
#define QUICKHUB_NOTIFICATION_NOTIFICATION @"AppNotificationNotifications"
#define QUICKHUB_NOTIFICATION_EVENTS @"AppNotificationEvents"

#pragma mark - activate notification preferences for the github events API

#define GITHUB_NOTIFICATION_REPOS_KEY @"GetReposNotifyStateKey"
#define GITHUB_NOTIFICATION_GISTS_KEY @"GetGistsNotifyStateKey"
#define GITHUB_NOTIFICATION_ORGS_KEY @"GetOrgsNotifyStateKey"
#define GITHUB_NOTIFICATION_ISSUES_KEY @"GetIssuesNotifyStateKey"
#define GITHUB_NOTIFICATION_PULLS_KEY @"GetPullsNotifyStateKey"
#define GITHUB_NOTIFICATION_FOLLOWINGS_KEY @"GetFollowingsNotifyStateKey"
#define GITHUB_NOTIFICATION_FOLLOWERS_KEY @"GetFollowersNotifyStateKey"
#define GITHUB_NOTIFICATION_WATCHEDREPO_KEY @"GetWatchedReposNotifyStateKey"

#define GITHUB_NOTIFICATION_ISSUE_ADDED_KEY @"IssueAddedNotifyStateKey"
#define GITHUB_NOTIFICATION_ISSUE_REMOVED_KEY @"IssueRemovedNotifyStateKey"

#define GITHUB_NOTIFICATION_GIST_ADDED_KEY @"GistAddedNotifyStateKey"
#define GITHUB_NOTIFICATION_GIST_REMOVED_KEY @"GistRemovedNotifyStateKey"
#define GITHUB_NOTIFICATION_GIST_CREATED_KEY @"GistCreatedNotifyStateKey"
#define GITHUB_NOTIFICATION_REPO_CREATED_KEY @"RepoCreatedNotifyStateKey"

#define HTTP_NOTIFICATION_FAILURE @"HTTPFailure"

#define GENERIC_NOTIFICATION @"GenericListener"

#define GIST_DND @"GistDnd"

#define POLLING_START @"PollingStart"
#define POLLING_STOP @"PollingStop"

#define NOTIFY_INTERNET_DOWN @"InternetIsDown"
#define NOTIFY_INTERNET_UP @"InternetIsUp"

#define HTTP_200 200;
#define HTTP_201 201;

#pragma mark - Preferences

#define PREF_SHOW_ACTIONS @"GHPreferencesShowActions"

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

#define GHEventActive @"GHEventActive"

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
