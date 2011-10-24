//
//  QuickHubAppAppDelegate.h
//  QuickHubApp
//
//  Created by Christophe Hamerling on 10/10/11.
//  Copyright 2011 chamerling.org. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

#import "Preferences.h"
#import "ASIHTTPRequest.h"

@interface QuickHubAppAppDelegate : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate> {
    NSWindow *window;
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;
    
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    Preferences *preferences;
    
    // caches
    NSMutableSet* existingIssues;
    NSMutableSet* existingGists;
    NSMutableSet* existingRepos;
    
    // track first calls to avoid notifications
    BOOL firstGistCall;
    BOOL firstIssueCall;
    BOOL firstOrganizationCall;
    BOOL firstRepositoryCall;
    
    // update timers
    NSTimer* gistTimer;
    NSTimer* issueTimer;
    NSTimer* organizationTimer;
    NSTimer* repositoryTimer;
    
    // misc.
    BOOL githubPolling;
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic) BOOL githubPolling;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

#pragma mark - GH

- (void)loadGHData:(id)sender;

- (void)loadAll:(id)sender;
- (void)stopAll:(id)sender;
- (void)cleanMenus:(id)sender;

- (IBAction)saveAction:(id)sender;
- (IBAction)openGitHub:(id)sender;
- (IBAction)openIssues:(id)sender;
- (IBAction)openProjects:(id)sender;
- (IBAction)openOrganizations:(id)sender;
- (IBAction)openGists:(id)sender;
- (IBAction)createGist:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)quit:(id)sender;

# pragma mark - GH Menu pressed actions
- (void) repoPressed:(id)sender;
- (void) organizationPressed:(id)sender;
- (void) issuePressed:(id)sender;
- (void) gistPressed:(id) sender;

# pragma mark - GH HTTP processing
- (void) issuesFinished:(ASIHTTPRequest*)request;
- (void) gistFinished:(ASIHTTPRequest*)request;
- (void) organizationsFinished:(ASIHTTPRequest*)request;
- (void) reposFinished:(ASIHTTPRequest*)request;

- (void) issuesFailed:(ASIHTTPRequest*)request;
- (void) gistsFailed:(ASIHTTPRequest*)request;
- (void) organizationsFailed:(ASIHTTPRequest*)request;
- (void) reposFailed:(ASIHTTPRequest*)request;

- (void) httpFailed:(ASIHTTPRequest*)request;

# pragma mark - Load things from github
- (BOOL) checkCredentials:(id) sender;
- (void) loadIssues:(id) sender;
- (void) loadGists:(id) sender;
- (void) loadOrganizations:(id) sender;
- (void) loadRepos:(id) sender;

# pragma mark - menu management
- (void) deleteOldEntriesFromMenu:(NSMenu*)menu fromItemTitle:(NSString*)title;
- (IBAction)helpPressed:(id)sender;

@end
