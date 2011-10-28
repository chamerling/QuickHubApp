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

- (void)cleanMenus:(id)sender;

# pragma mark - GH Menu pressed actions
- (IBAction) repoPressed:(id)sender;
- (IBAction) organizationPressed:(id)sender;
- (IBAction) issuePressed:(id)sender;
- (IBAction) gistPressed:(id) sender;
- (IBAction) pullPressed:(id) sender;

#pragma mark - UI management
- (void) deleteOldEntriesFromMenu:(NSMenu*)menu fromItemTitle:(NSString*)title;
- (void) resetCache:(id) sender;

@end
