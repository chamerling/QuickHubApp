//
//  QuickHubAppAppDelegate.m
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

#import "QuickHubAppAppDelegate.h"

#import "PreferencesWindowController.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "NSData+Base64.h"

@implementation QuickHubAppAppDelegate

@synthesize window;
@synthesize githubPolling;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [statusItem setMenu:statusMenu];
    NSImage *statusImage = [NSImage imageNamed:@"QuickHubAppToolbar.png"];
    [statusImage setTemplate:YES];
    [statusItem setImage:statusImage];
    [statusItem setHighlightMode:YES];
    
    existingIssues = [[NSMutableSet alloc]init];
    existingGists = [[NSMutableSet alloc]init];
    
    firstGistCall = YES;
    firstIssueCall = YES;
    firstOrganizationCall = YES;
    firstRepositoryCall = YES;
    
    githubPolling = NO;
    
    [GrowlApplicationBridge setGrowlDelegate:self];
    
    preferences = [Preferences sharedInstance];
    if ([[preferences login]length] == 0 || ![self checkCredentials:nil]) {
        [GrowlApplicationBridge notifyWithTitle:@"QuickHub Failure" description:[NSString stringWithFormat:@"Bad credentials or not connected"] notificationName:@"QuickHub" iconData: nil priority:1 isSticky:NO clickContext:@"openPreferences"];
    } else {
        [self loadAll:nil];    
    }
}

/**
    Returns the directory the application uses to store the Core Data store file. This code uses a directory named "QuickHubApp" in the user's Library directory.
 */
- (NSURL *)applicationFilesDirectory {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"QuickHubApp"];
}

/**
    Creates if necessary and returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"QuickHubApp" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
    Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
        
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"QuickHubApp.storedata"];
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        [__persistentStoreCoordinator release], __persistentStoreCoordinator = nil;
        return nil;
    }

    return __persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}

/**
    Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/**
    Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction)saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    // Save changes in the application's managed object context before the application terminates.

    if (!__managedObjectContext) {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (void)dealloc
{
    [__managedObjectContext release];
    [__persistentStoreCoordinator release];
    [__managedObjectModel release];
    [statusMenu release];
    [statusItem release];
    [preferences release];
    [existingGists release];
    [existingIssues release];
    [existingRepos release];
    
    [gistTimer release];
    [issueTimer release];
    [organizationTimer release];
    [repositoryTimer release];
    [super dealloc];
}

#pragma mark - Github Actions

- (void) loadAll:(id)sender {
    if (!githubPolling) {
        NSLog(@"Load all and start polling things");
        [self loadGHData:nil];
        
        gistTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(loadGists:) userInfo:nil repeats:YES];
        repositoryTimer = [NSTimer scheduledTimerWithTimeInterval:130 target:self selector:@selector(loadRepos:) userInfo:nil repeats:YES];
        organizationTimer = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(loadOrganizations:) userInfo:nil repeats:YES];
        issueTimer = [NSTimer scheduledTimerWithTimeInterval:125 target:self selector:@selector(loadIssues:) userInfo:nil repeats:YES];
        
        // add the timer to the common run loop mode so that it does not freezes when the user clicks on menu
        // cf http://stackoverflow.com/questions/4622684/nsrunloop-freezes-with-nstimer-and-any-input
        [[NSRunLoop currentRunLoop] addTimer:gistTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:repositoryTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:organizationTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:issueTimer forMode:NSRunLoopCommonModes];
        githubPolling = YES;
    } else {
        NSLog(@"Can not start all since we are already polling...");
    }
}

- (void) stopAll:(id)sender {
    NSLog(@"Stop all...");
    if (githubPolling) {
        [gistTimer invalidate];
        [repositoryTimer invalidate];
        [organizationTimer invalidate];
        [issueTimer invalidate];
    }
    githubPolling = NO;
}

- (void)cleanMenus:(id)sender {
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Issues"];
    NSMenu *menu = [menuItem submenu];
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    menuItem = [statusMenu itemWithTitle:@"Gists"];
    menu = [menuItem submenu];
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    menuItem = [statusMenu itemWithTitle:@"Organizations"];
    menu = [menuItem submenu];
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    menuItem = [statusMenu itemWithTitle:@"Repositories"];
    menu = [menuItem submenu];
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    firstGistCall = YES;
    firstIssueCall = YES;
    firstOrganizationCall = YES;
    firstRepositoryCall = YES;
}

- (void)loadGHData:(id)sender {    
    [self loadIssues:nil];
    [self loadGists:nil];
    [self loadOrganizations:nil];
    [self loadRepos:nil];
}

- (IBAction)openGitHub:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://github.com"]];
}

- (IBAction)openIssues:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/dashboard/issues/"]];
}

- (IBAction)openProjects:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/%@/", [preferences login]]]];
}

- (IBAction)openOrganizations:(id)sender {
}

- (IBAction)createGist:(id)sender {
    [GrowlApplicationBridge notifyWithTitle:@"QuickHub - Gists" description:@"Coming soon!" 
                           notificationName:@"QuickHub" iconData:[NSData dataWithContentsOfFile:@"GHApp_icon.png"] priority:0 isSticky:NO clickContext:nil];}

- (IBAction)openGists:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://gist.github.com"]];
}

- (IBAction)openPreferences:(id)sender {
    PreferencesWindowController *preferencesWindow = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
    [preferencesWindow setApp:self];
    [preferencesWindow showWindow:self];
}

- (IBAction)quit:(id)sender {
    [NSApp terminate: nil];
}

# pragma mark - Actions on pressed menu items

- (void) repoPressed:(id) sender {
    id selectedItem = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", selectedItem]]];
}

- (void) issuePressed:(id) sender {
    id selectedItem = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", selectedItem]]];
}

- (void) gistPressed:(id) sender {
    id selectedItem = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", selectedItem]]];
}

- (void) organizationPressed:(id) sender {
    id selectedItem = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/organizations/%@", selectedItem]]];
}

- (void) httpFailed:(ASIHTTPRequest*)request {
    NSLog(@"HTTP FAILURE : %@", [request error]);
    [GrowlApplicationBridge notifyWithTitle:@"QuickHub" description:[NSString stringWithFormat:@"Error while fetching data"] notificationName:@"QuickHub" iconData: nil priority:1 isSticky:NO clickContext:nil];
}

# pragma mark - Load things from github
- (void) loadIssues:(id) sender {
    NSLog(@"Loaging Issues...");

    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    // try to get my issues with ASIHTTP and JSONKIT...
    ASIHTTPRequest *issuesRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/issues?per_page=100"]];
    [issuesRequest addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [issuesRequest setDidFinishSelector:@selector(issuesFinished:)];
    [issuesRequest setDidFailSelector:@selector(issuesFailed:)];
    [issuesRequest setDelegate:self];
    [issuesRequest startAsynchronous];
}

- (void) loadGists:(id) sender {
    NSLog(@"Loaging Gists...");
    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    // get gists
    ASIHTTPRequest *gistRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/gists?per_page=100"]];
    [gistRequest addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [gistRequest setDidFinishSelector:@selector(gistFinished:)];
    [gistRequest setDidFailSelector:@selector(gistsFailed:)];
    [gistRequest setDelegate:self];
    [gistRequest startAsynchronous];
}

- (void) loadOrganizations:(id) sender {
    NSLog(@"Loaging Organizations...");

    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    ASIHTTPRequest *organizationsRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/user/orgs?per_page=100"]];
    [organizationsRequest addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [organizationsRequest setDidFinishSelector:@selector(organizationsFinished:)];
    [organizationsRequest setDidFailSelector:@selector(organizationsFailed:)];
    [organizationsRequest setDelegate:self];
    [organizationsRequest startAsynchronous];    
}

- (void) loadRepos:(id) sender {
    NSLog(@"Loaging Repositories...");

    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    ASIHTTPRequest *repositoriesRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/user/repos?per_page=100"]];
    [repositoriesRequest addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [repositoriesRequest setDidFinishSelector:@selector(reposFinished:)];
    [repositoriesRequest setDidFailSelector:@selector(reposFailed:)];
    [repositoriesRequest setDelegate:self];
    [repositoriesRequest startAsynchronous];
}

- (BOOL)checkCredentials:(id)sender {
    NSLog(@"Checking credentials...");

    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/user"]];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [request startSynchronous];
    int status = [request responseStatusCode];
    return status == 200;
}

# pragma mark - HTTP failures
- (void) issuesFailed:(ASIHTTPRequest*)request {
    NSLog(@"Error : %@", [request error]);
    [GrowlApplicationBridge notifyWithTitle:@"QuickHub Failure" description:[NSString stringWithFormat:@"Error while getting issues data"] notificationName:@"QuickHub" iconData: nil priority:1 isSticky:NO clickContext:nil];
}

- (void) gistsFailed:(ASIHTTPRequest*)request {
    NSLog(@"Error : %@", [request error]);
    [GrowlApplicationBridge notifyWithTitle:@"QuickHub Failure" description:[NSString stringWithFormat:@"Error while getting gists"] notificationName:@"QuickHub" iconData: nil priority:1 isSticky:NO clickContext:nil];
}

- (void) organizationsFailed:(ASIHTTPRequest*)request {
    NSLog(@"Error : %@", [request error]);
    [GrowlApplicationBridge notifyWithTitle:@"QuickHub Failure" description:[NSString stringWithFormat:@"Error while getting organizations"] notificationName:@"QuickHub" iconData: nil priority:1 isSticky:NO clickContext:nil];
}

- (void) reposFailed:(ASIHTTPRequest*)request {
    NSLog(@"Error : %@", [request error]);
    [GrowlApplicationBridge notifyWithTitle:@"QuickHub Failure" description:[NSString stringWithFormat:@"Error while getting repositories"] notificationName:@"QuickHub" iconData: nil priority:1 isSticky:NO clickContext:nil];
}

#pragma mark - process HTTP responses

- (void) issuesFinished:(ASIHTTPRequest*)request {
    NSLog(@"Issues Finished...");
    
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Issues"];
    NSMenu *menu = [menuItem submenu];
    
    NSDictionary* result = [[request responseString] objectFromJSONString];
    
    // process added and removed issues
    NSMutableSet* justGetIssues = [[NSMutableSet alloc] init];
    for (NSArray *issue in result) {
        [justGetIssues addObject:[issue valueForKey:@"number"]];
    }
    
    NSMutableSet* removedIssues = [NSMutableSet setWithSet:existingIssues];
    [removedIssues minusSet:justGetIssues];
    if ([removedIssues count] > 0) {
        [GrowlApplicationBridge notifyWithTitle:@"QuickHub" description:[NSString stringWithFormat:@"%@ less issues",[removedIssues count]] notificationName:@"QuickHub" iconData: nil priority:1 isSticky:NO clickContext:nil];
    }
    
    NSMutableSet* addedIssues = [NSMutableSet setWithSet:justGetIssues];
    [addedIssues minusSet:existingIssues];
    if ([addedIssues count] > 0 && !firstIssueCall) {
        [GrowlApplicationBridge notifyWithTitle:@"QuickHub" description:[NSString stringWithFormat:@"%d more issues",[addedIssues count]] notificationName:@"QuickHub" iconData: nil priority:1 isSticky:NO clickContext:nil];
    }
    firstIssueCall = NO;
        
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    // clear the existing Issues
    existingIssues = [[NSMutableSet alloc]init]; 
    
    for (NSArray *issue in result) {
        [existingIssues addObject:[issue valueForKey:@"number"]];
        NSMenuItem *issueItem = [[NSMenuItem alloc] initWithTitle:[issue valueForKey:@"title"] action:@selector(issuePressed:) keyEquivalent:@""];
        [issueItem setRepresentedObject:[issue valueForKey:@"html_url"]];
        [issueItem autorelease];
        [menu addItem:issueItem];
    }
}

- (void) gistFinished:(ASIHTTPRequest*)request {
    NSLog(@"Gists Finished...");

    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Gists"];
    NSMenu *menu = [menuItem submenu];
    
    NSDictionary* result = [[request responseString] objectFromJSONString];
    
    // process added and removed issues
    NSMutableSet* justGet = [[NSMutableSet alloc] init];
    for (NSArray *issue in result) {
        [justGet addObject:[issue valueForKey:@"id"]];
    }
    
    NSMutableSet* removed = [NSMutableSet setWithSet:existingGists];
    [removed minusSet:justGet];
    if ([removed count] > 0) {
        
    }
    
    NSMutableSet* added = [NSMutableSet setWithSet:justGet];
    [added minusSet:existingGists];
    if ([added count] > 0 && !firstGistCall) {
        [GrowlApplicationBridge notifyWithTitle:@"QuickHub" description:[NSString stringWithFormat:@"%d new Gists",[added count]] notificationName:@"QuickHub" iconData: nil priority:1 isSticky:NO clickContext:nil];
    }
    firstGistCall = NO;
    
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    // clear the existing Issues
    existingGists = [[NSMutableSet alloc]init]; 
    
    for (NSArray *gist in result) {
        // cache for next time...
        [existingGists addObject:[gist valueForKey:@"id"]];

        NSString *title = nil;
        NSString *description = [gist valueForKey:@"description"];
        if (description == (id)[NSNull null] || description.length == 0) {
            title = [NSString stringWithFormat:@"gist %@", [gist valueForKey:@"id"]];
        } else {
            title = [NSString stringWithFormat:@"gist %@ : %@", [gist valueForKey:@"id"], description];
        }
        
        NSMenuItem *gistItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(gistPressed:) keyEquivalent:@""];
        
        [gistItem setRepresentedObject:[gist valueForKey:@"html_url"]];
        [gistItem autorelease];
        [menu addItem:gistItem];
    }
}

- (void) organizationsFinished:(ASIHTTPRequest*)request {
    NSLog(@"Organizations Finished...");

    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Organizations"];
    NSMenu *menu = [menuItem submenu];
    NSDictionary* result = [[request responseString] objectFromJSONString];
    
    // clean if called N times...
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    for (NSArray *org in result) {
        
        NSMenuItem *organizationItem = [[NSMenuItem alloc] initWithTitle:[org valueForKey:@"login"] action:@selector(organizationPressed:) keyEquivalent:@""];
        [organizationItem setToolTip: @""];
        [organizationItem setRepresentedObject:[org valueForKey:@"login"]];
        [organizationItem setEnabled:YES];
        [organizationItem autorelease];
        [menu addItem:organizationItem];
        
        // let's get the repositories for all organization...
        ASIHTTPRequest *repositoriesRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/orgs/%@/repos", [org valueForKey:@"login"]]]];
        [repositoriesRequest addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", [preferences login], [preferences password]] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
        [repositoriesRequest setDelegate:self];
        [repositoriesRequest startSynchronous];
        
        NSDictionary* repos = [[repositoriesRequest responseString] objectFromJSONString];
        
        NSMenu* repositoriesMenu = [[NSMenu alloc] init];
        for (NSArray *repo in repos) {
            NSMenuItem *organizationRepoItem = [[NSMenuItem alloc] initWithTitle:[repo valueForKey:@"name"] action:@selector(repoPressed:) keyEquivalent:@""];
            [organizationRepoItem setToolTip: @""];
            [organizationRepoItem setRepresentedObject:[repo valueForKey:@"html_url"]];
            [organizationRepoItem setEnabled:YES];
            [organizationRepoItem autorelease];
            [repositoriesMenu addItem:organizationRepoItem];
            
        }
        [organizationItem setSubmenu:repositoriesMenu]; 
    }
}

- (void) reposFinished:(ASIHTTPRequest*)request {
    NSLog(@"Repositories Finished...");

    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Repositories"];
    NSMenu *menu = [menuItem submenu];
    NSDictionary* result = [[request responseString] objectFromJSONString];
    
    // process added and removed issues
    NSMutableSet* justGet = [[NSMutableSet alloc] init];
    for (NSArray *repo in result) {
        [justGet addObject:[repo valueForKey:@"name"]];
    }
    
    NSMutableSet* removed = [NSMutableSet setWithSet:existingRepos];
    [removed minusSet:justGet];
    if ([removed count] > 0) {
        
    }
    
    NSMutableSet* added = [NSMutableSet setWithSet:justGet];
    [added minusSet:existingGists];
    if ([added count] > 0 && !firstRepositoryCall) {
        [GrowlApplicationBridge notifyWithTitle:@"QuickHub" description:[NSString stringWithFormat:@"%d new repositories",[added count]] notificationName:@"QuickHub" iconData: nil priority:1 isSticky:NO clickContext:nil];
    }
    firstGistCall = NO;
    
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    // clear the existing Issues
    existingRepos = [[NSMutableSet alloc]init]; 
        
    for (NSArray *repo in result) {
        // cache for next time
        [existingRepos addObject:[repo valueForKey:@"name"]];

        NSMenuItem *organizationItem = [[NSMenuItem alloc] initWithTitle:[repo valueForKey:@"name"] action:@selector(repoPressed:) keyEquivalent:@""];
        [organizationItem setToolTip: @""];
        [organizationItem setRepresentedObject:[repo valueForKey:@"html_url"]];
        [organizationItem setEnabled:YES];
        [organizationItem autorelease];
        [menu addItem:organizationItem];
    }
}

#pragma mark - Growl stuff

- (NSDictionary *)registrationDictionaryForGrowl {
    NSArray *notifications = [NSArray arrayWithObject: @"QuickHub"];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          notifications, GROWL_NOTIFICATIONS_ALL,
                          notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
    return dict;
}

# pragma mark - UI management

- (void) deleteOldEntriesFromMenu:(NSMenu*)menu fromItemTitle:(NSString*)title {
    // remove all the menu items
    NSInteger deleteItemLimit = [menu indexOfItemWithTitle:title];
    if (deleteItemLimit > 0) {
        NSInteger deleteNb = [menu numberOfItems];
        for (NSInteger i = deleteItemLimit + 1; i < deleteNb; i++) {
            // delete all the items at the deleteItemLimit +1 since deleting shift items...
            [menu removeItemAtIndex:deleteItemLimit + 1];
        }
    }
}

- (IBAction)helpPressed:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://chamerling.github.com/QuickHubApp/"]];
}


@end
