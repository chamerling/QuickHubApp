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
#import "Preferences.h"

@interface MenuController : NSObject {
    IBOutlet NSMenu *statusMenu;
    
    // caches
    NSMutableSet* existingIssues;
    NSMutableSet* existingGists;
    NSMutableSet* existingRepos;
    
    // track first calls to avoid notifications
    BOOL firstGistCall;
    BOOL firstIssueCall;
    BOOL firstOrganizationCall;
    BOOL firstRepositoryCall;
    
    Preferences *preferences;
    NSMenuItem *followingPressed;
    
    IBOutlet NSMenuItem *internetItem;
    
    IBOutlet NSMenuItem *eventsMenuItem;
    IBOutlet NSMenu *eventsMenu;
    IBOutlet NSMenuItem *eventsSeparatorItem;
}

@property (nonatomic, retain) IBOutlet NSMenu *statusMenu;

- (IBAction)openFollowings:(id)sender;
- (IBAction)openFollowers:(id)sender;
- (IBAction)openWatchedRepositories:(id)sender;

# pragma mark - GH Menu pressed actions
- (IBAction) repoPressed:(id)sender;
- (IBAction) organizationPressed:(id)sender;
- (IBAction) issuePressed:(id)sender;
- (IBAction) gistPressed:(id) sender;
- (IBAction) pullPressed:(id) sender;
- (void) followerPressed:(id) sender;
- (void) followingPressed:(id) sender;
- (void) eventPressed:(id) sender;

#pragma mark - UI management
- (void) deleteOldEntriesFromMenu:(NSMenu*)menu fromItemTitle:(NSString*)title;
- (void) resetCache:(id) sender;
- (void) cleanMenus:(id) sender;

#pragma mark - updates
- (void) issuesFinished:(NSDictionary *)request;
- (void) gistFinished:(NSDictionary *)request;
- (void) organizationsFinished:(NSDictionary *)request;
- (void) reposFinished:(NSDictionary *)request;
- (void) followersFinished:(NSDictionary *)request;
- (void) followingsFinished:(NSDictionary *)request;
- (void) watchedReposFinished:(NSDictionary *)request;
- (void) pullsFinished:(NSDictionary *)dictionary;

#pragma mark - atomic
- (void) addIssue:(NSDictionary *)issue top:(BOOL)top;
- (void) addGist:(NSDictionary *)gist top:(BOOL)top;
- (void) addOrg:(NSDictionary *)org;
- (void) addRepo:(NSDictionary *)repo top:(BOOL)top;
- (void) addOrgRepo:(NSString *)orgName withRepo:(NSDictionary *)repo top:(BOOL)top;
- (void) addFollower:(NSDictionary *)follower;
- (void) addFollowing:(NSDictionary *)following;
- (void) addWatched:(NSDictionary *)watched;
- (void) addPull:(NSDictionary *)pull;

- (void) addEvent:(NSDictionary *)event top:(BOOL)top;

@end
