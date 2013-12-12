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

#import <Cocoa/Cocoa.h>

#import "Preferences.h"
#import "GrowlManager.h"
#import "AppController.h"
#import "MenuController.h"
#import "GithubOAuthClient.h"
#import "ASIHTTPRequest.h"
#import "MASPreferencesWindowController.h"

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
    GithubOAuthClient *ghClient;
    MenuController *menuController;
    
    // MAS based preferences window controller
    MASPreferencesWindowController *_preferencesWindowController;
}

// MAS based preferences window controller
@property (nonatomic, readonly) MASPreferencesWindowController *preferencesWindowController;

@property (nonatomic, retain) IBOutlet GrowlManager *growlManager;
@property (nonatomic, retain) IBOutlet AppController *appController;
@property (nonatomic, retain) IBOutlet GithubOAuthClient *ghClient;
@property (nonatomic, retain) IBOutlet MenuController *menuController;

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;


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
- (IBAction)createRepository:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)createIssue:(id)sender;

# pragma mark - GH Menu pressed actions
- (void) repoPressed:(id)sender;
- (void) organizationPressed:(id)sender;
- (void) issuePressed:(id)sender;
- (void) gistPressed:(id) sender;
- (void) pullPressed:(id) sender;
- (void) followerPressed:(id) sender;
- (void) followingPressed:(id) sender;
- (void) eventPressed:(id) sender;

- (void)getUrl:(NSAppleEventDescriptor *)event;
- (void) registerURLHandler:(id) sender;

- (void)gistFileContentService:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error;
- (void)gistTextSelectionService:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error;

@end
