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
#import "GistCreateWindowController.h"
#import "RepoCreateWindowController.h"
#import "QHConstants.h"
#import "LocalPreferencesViewController.h"
#import "AccountPreferencesViewController.h"
#import "AboutPreferencesViewController.h"
#import "GistViewWindowController.h"
#import "UserPreferences.h"
#import "OrgRepoCreateWindowController.h"
#import "IssueCreateWindowController.h"

#import "MASPreferencesWindowController.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "NSData+Base64.h"
#import "Reachability.h"
#import "NSString+JavaAPI.h"

@implementation QuickHubAppAppDelegate

@synthesize window;
@synthesize growlManager;
@synthesize appController;
@synthesize ghClient;
@synthesize menuController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [NSApp setServicesProvider:self];    
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [statusItem setMenu:statusMenu];
    NSImage *statusImage = [NSImage imageNamed:@"QuickHubAppToolbar.png"];
    [statusImage setTemplate:YES];
    [statusItem setImage:statusImage];
    [statusItem setHighlightMode:YES];
    
    // register handler for protocol
    [self registerURLHandler:nil];
    
    preferences = [Preferences sharedInstance];
    
    Reachability *internetDonnection = [Reachability reachabilityForInternetConnection];
    if ([internetDonnection currentReachabilityStatus] == NotReachable) {
        //NSLog(@"Startup : Internet is not reachable");
    } else {
        if ([[preferences oauthToken]length] == 0 || ![ghClient checkCredentials:nil]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION object:@"Unable to connect, check preferences" userInfo:nil];
            
            [self openPreferences:nil];
          
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION object:[NSString stringWithFormat:@"Connecting to GitHub..."] userInfo:nil];   
            // TODO : To it in background thread...
            
            [appController loadAll:nil];    
        }
    }
}

#pragma mark - Custom URL handling
- (void)registerURLHandler:(id) sender
{
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    OSStatus httpResult = LSSetDefaultHandlerForURLScheme((CFStringRef)@"quickhubapp", (CFStringRef)bundleID);
    //NSLog(@"Result : %@", httpResult);
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(getUrl:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)getUrl:(NSAppleEventDescriptor *)event
{
	NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
	// Now you can parse the URL and perform whatever action is needed
    //NSLog(@"Got an URL %@", url);
    
    if (url) {
        NSURL *callbackURL = [NSURL URLWithString:url];
    
        if ([url startsWith:@"quickhubapp://oauth"]) {
            // for now we do not support N operations, so 'oauth' is the only one. Will need to add more...
            NSString *query = [callbackURL query];    
            //NSLog(@"query %@", query);
            
            if ([[[Preferences sharedInstance] oauthToken]length] > 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION object:[NSString stringWithFormat:@"Already Authorized..."] userInfo:nil];
                return;
            }
            
            NSArray *components = [query componentsSeparatedByString:@"&"];
            NSString *oauth = nil;
            for (NSString *component in components) {
                if ([component hasPrefix:@"access_token="]) {
                    oauth = [component substringFromIndex:[@"access_token=" length]];
                }
            }
            //NSLog(@"Save oauth '%@' !", oauth);
            [[Preferences sharedInstance]storeToken:oauth];
            // save the user, can be used in some payloads...
            NSDictionary *user = [ghClient loadUser:nil];
            if (!user) {
                [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION object:[NSString stringWithFormat:@"User not found!"] userInfo:nil];   
                [[Preferences sharedInstance]storeToken:@""];
                return;
            }
            
            [[Preferences sharedInstance]storeLogin:[user valueForKey:@"login"] withPassword:@""];
            
            // TODO : Must reinitialize all and start polling stuff with the new OAuth token
            [appController stopAll:nil];
            [menuController cleanMenus:nil];
            [menuController resetCache:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION object:[NSString stringWithFormat:@"Connected to GitHub!"] userInfo:nil];   

            [appController loadAll:nil];
        } else if ([url startsWith:@"quickhubapp://gist"]) {
            //NSLog(@"Create Gist action...");
        } else {
            // ?
        }
    }
}

#pragma mark - Xcode generated stuff

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
    [_preferencesWindowController release];
    [super dealloc];
}

#pragma mark - Public accessors

- (MASPreferencesWindowController *)preferencesWindowController
{
    if (_preferencesWindowController == nil)
    {
        AccountPreferencesViewController *accountViewController = [[AccountPreferencesViewController alloc] init];
    
        // TODO
        // NSViewController *localViewController = [[LocalPreferencesViewController alloc] init];
        AboutPreferencesViewController *aboutViewController = [[AboutPreferencesViewController alloc] init];
        
        UserPreferences *userPreferences = [[UserPreferences alloc] init];
        [userPreferences setAppController:appController];
        [userPreferences setMenuController:menuController];
        
        NSArray *controllers = [[NSArray alloc] initWithObjects:accountViewController, userPreferences, /*localViewController,*/ aboutViewController, nil];
        
        [accountViewController release];
        [aboutViewController release];
        [userPreferences release];
        //[localViewController release];
        
        NSString *title = NSLocalizedString(@"Preferences", @"Common title for Preferences window");
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:title];
        
        [_preferencesWindowController selectControllerAtIndex:0];
        [controllers release];
    } else {
        [_preferencesWindowController selectControllerAtIndex:0];        
    }
    return _preferencesWindowController;
}

#pragma mark - Github Actions

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
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://github.com/account/organizations"]];
}

- (IBAction)createGist:(id)sender {
    GistCreateWindowController *gistCreator = [[GistCreateWindowController alloc] initWithWindowNibName:@"GistCreateWindow"];
    [gistCreator setGhClient:ghClient];
    [gistCreator setMenuController:menuController];
    [NSApp activateIgnoringOtherApps: YES];
	[[gistCreator window] makeKeyWindow];
    [gistCreator showWindow:self];
}

- (IBAction)createRepository:(id)sender {
    RepoCreateWindowController *creator = [[RepoCreateWindowController alloc] initWithWindowNibName:@"RepoCreateWindow"];
    [creator setGhClient:ghClient];
    [creator setMenuController:menuController];
    [NSApp activateIgnoringOtherApps: YES];
	[[creator window] makeKeyWindow];
    [creator showWindow:self];
}

- (IBAction)createOrgRepository:(id)sender {
    id selectedItem = [sender representedObject];
    NSString *orgName = [NSString stringWithFormat:@"%@", selectedItem];
    OrgRepoCreateWindowController *creator = [[OrgRepoCreateWindowController alloc] initWithWindowNibName:@"OrgRepoCreateWindow"];
    [creator setOrganisationName:orgName];
    [creator setGhClient:ghClient];
    [creator setMenuController:menuController];
    [NSApp activateIgnoringOtherApps: YES];
	[[creator window] makeKeyWindow];
    [creator showWindow:self];
}

- (IBAction)createIssue:(id)sender {
    IssueCreateWindowController *creator = [[IssueCreateWindowController alloc] initWithWindowNibName:@"IssueCreateWindow"];
    [creator setGhClient:ghClient];
    [creator setMenuController:menuController];
    [NSApp activateIgnoringOtherApps: YES];
	[[creator window] makeKeyWindow];
    [creator showWindow:self];
}

- (IBAction)openGists:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://gist.github.com"]];
}

- (IBAction)openPulls:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/dashboard/pulls"]];
}

- (void)openURL:(id)sender {
    id selectedItem = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", selectedItem]]];
}

- (IBAction)openPreferences:(id)sender {
    [NSApp activateIgnoringOtherApps: YES];
    //[[preferencesWindowController window] makeKeyWindow];
    [self.preferencesWindowController showWindow:nil];
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
    NSArray *selectedItem = [sender representedObject];
    // TODO, if needed!
    BOOL showGistOnGitHub = YES;
    if (showGistOnGitHub) {
        NSString *url = [selectedItem valueForKey:@"html_url"];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    } else {
        GistViewWindowController* viewGist = [[GistViewWindowController alloc] initWithWindowNibName:@"GistViewWindow"];
        [viewGist setGist:selectedItem];
        [viewGist showWindow:self];
    }
}

- (void) pullPressed:(id)sender {
    id selectedItem = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", selectedItem]]];    
}

- (void) organizationPressed:(id) sender {
    id selectedItem = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/organizations/%@", selectedItem]]];
}

- (void) followerPressed:(id) sender {
    id selectedItem = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/%@", selectedItem]]];    
}

- (void) followingPressed:(id) sender {
    id selectedItem = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/%@", selectedItem]]];        
}

// Gist a text selection
- (void)gistTextSelectionService:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
    if (![[pboard types] containsObject:NSPasteboardTypeString]) {
		NSBeep();
        [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION object:[NSString stringWithFormat:@"Invalid selection, can not gist it!"] userInfo:nil];
		return;
	}
    
    NSString *pboardString = [pboard stringForType:NSPasteboardTypeString];

    GistCreateWindowController *gistCreator = [[GistCreateWindowController alloc] initWithWindowNibName:@"GistCreateWindow"];
    [gistCreator setGhClient:ghClient];
    [gistCreator setMenuController:menuController];
    [gistCreator setGistContent:pboardString];
    
    [NSApp activateIgnoringOtherApps: YES];
	[[gistCreator window] makeKeyWindow];
    [gistCreator showWindow:self];
}

// gist a file content
- (void)gistFileContentService:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {    
    // just get file here!
    if (![[pboard types] containsObject:NSFilenamesPboardType]) {
		NSBeep();
        [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION object:[NSString stringWithFormat:@"Selection is not a file, can not gist it!"] userInfo:nil];
		return;
	}
	
	NSString *path = [[pboard propertyListForType:NSFilenamesPboardType] objectAtIndex:0];
    NSURL *url = [NSURL URLWithString:path];
    CFStringRef folder = (CFStringRef) [url path];
    
    CFStringRef folderUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, folder, NULL);

    // FIXME : folder is not recognized here...
    if (UTTypeConformsTo(folderUTI, kUTTypeFolder)) {
        NSBeep();
        [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
                                                            object:@"Can not create a Gist from a folder!" 
                                                          userInfo:nil];
        return;
    }
    CFRelease(folderUTI);
    
    CFStringRef fileExtension = (CFStringRef) [path pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    
    BOOL validFormat = NO;
    // check UTI
    // http://developer.apple.com/library/mac/#documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html
    if (UTTypeConformsTo(fileUTI, kUTTypeImage)) NSLog(@"It's an image!");
    else if (UTTypeConformsTo(fileUTI, kUTTypeMovie)) NSLog(@"It's a movie!");
    else {
        // other types should work...
        validFormat = YES;
    }
    CFRelease(fileUTI);
    
    if (validFormat) {
        NSError *error;
        NSString *content = [[NSString alloc]
                             initWithContentsOfFile:path
                             encoding:NSUTF8StringEncoding
                             error:&error];
        
        if (content) {
            GistCreateWindowController *gistCreator = [[GistCreateWindowController alloc] initWithWindowNibName:@"GistCreateWindow"];
            [gistCreator setGhClient:ghClient];
            [gistCreator setMenuController:menuController];
            [gistCreator setGistContent:content];
            [gistCreator setGistFileName:[path lastPathComponent]];
            
            [NSApp activateIgnoringOtherApps: YES];
            [[gistCreator window] makeKeyWindow];
            [gistCreator showWindow:self];
        } else {
            // FIXME : This is because it is probably a folder...
            NSBeep();
            [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
                                                                object:@"Can not create a Gist from this file!" 
                                                              userInfo:nil];   
        }
    } else {
        NSBeep();
        [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
                                                            object:@"Can not create a Gist from this file!" 
                                                          userInfo:nil];
    }
}

@end
