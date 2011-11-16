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

#import "Preferences.h"
#import "GrowlManager.h"
#import "AppController.h"
#import "MenuController.h"
#import "GitHubController.h"
#import "ASIHTTPRequest.h"

@interface QuickHubAppAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;
    
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    Preferences *preferences;
    
    GrowlManager *growlManager;
    AppController *appController;
    GitHubController *ghController;
    MenuController *menuController;
}

@property (nonatomic, retain) IBOutlet GrowlManager *growlManager;
@property (nonatomic, retain) IBOutlet AppController *appController;
@property (nonatomic, retain) IBOutlet GitHubController *ghController;
@property (nonatomic, retain) IBOutlet MenuController *menuController;

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

#pragma mark - GH

- (IBAction)saveAction:(id)sender;
- (IBAction)openGitHub:(id)sender;
- (IBAction)openIssues:(id)sender;
- (IBAction)openProjects:(id)sender;
- (IBAction)openOrganizations:(id)sender;
- (IBAction)openGists:(id)sender;
- (IBAction)openPulls:(id)sender;
- (IBAction)openURL:(id)sender;

- (IBAction)createGist:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)quit:(id)sender;

# pragma mark - GH Menu pressed actions
- (void) repoPressed:(id)sender;
- (void) organizationPressed:(id)sender;
- (void) issuePressed:(id)sender;
- (void) gistPressed:(id) sender;
- (void) pullPressed:(id) sender;
- (void) followerPressed:(id) sender;
- (void) followingPressed:(id) sender;

- (IBAction)helpPressed:(id)sender;


@end
