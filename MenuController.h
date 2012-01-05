//
//  MenuController.h
//  QuickHubApp
//
// Used to manage the dynamic menu
//
//  Created by Christophe Hamerling on 25/10/11.
//  Copyright 2011 chamerling.org. All rights reserved.
//

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

@end
