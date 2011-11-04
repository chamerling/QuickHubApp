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

@end
