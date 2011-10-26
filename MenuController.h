//
//  MenuController.h
//  QuickHubApp
//
// Used to manage the dynamic menu
//
//  Created by Christophe Hamerling on 25/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
}

@property (nonatomic, retain) IBOutlet NSMenu *statusMenu;

# pragma mark - GH Menu pressed actions
- (void) repoPressed:(id)sender;
- (void) organizationPressed:(id)sender;
- (void) issuePressed:(id)sender;
- (void) gistPressed:(id) sender;
- (void) pullPressed:(id) sender;

#pragma mark - UI management
- (void) deleteOldEntriesFromMenu:(NSMenu*)menu fromItemTitle:(NSString*)title;

@end
