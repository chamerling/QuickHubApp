//
//  MenuController.m
//  QuickHubApp
//
//  Created by Christophe Hamerling on 25/10/11.
//  Copyright 2011 chamerling.org. All rights reserved.
//

#import "MenuController.h"
#import "QHConstants.h"
#import <Cocoa/Cocoa.h>
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "NSData+Base64.h"

@interface MenuController (Private)
- (void)notifyGists:(NSNotification *)aNotification;
- (void)notifyRepos:(NSNotification *)aNotification;
- (void)notifyOrganizations:(NSNotification *)aNotification;
- (void)notifyIssues:(NSNotification *)aNotification;
- (void)notifyFollowings:(NSNotification *)aNotification;
- (void)notifyFollowers:(NSNotification *)aNotification;
- (void)notifyWatchedRepos:(NSNotification *)aNotification;

- (void) issuesFinished:(ASIHTTPRequest*)request;
- (void) gistFinished:(ASIHTTPRequest*)request;
- (void) organizationsFinished:(ASIHTTPRequest*)request;
- (void) reposFinished:(ASIHTTPRequest*)request;
- (void) pullFinished:(ASIHTTPRequest *)request;
- (void) followersFinished:(ASIHTTPRequest*)request;
- (void) followingsFinished:(ASIHTTPRequest *)request;
- (void) watchedReposFinished:(ASIHTTPRequest *)request;
@end

@implementation MenuController

@synthesize statusMenu;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        preferences = [Preferences sharedInstance];
        
        firstGistCall = YES;
        firstIssueCall = YES;
        firstOrganizationCall = YES;
        firstRepositoryCall = YES;
    }
    
    return self;
}

// register to notifications so that the menu can be updated when data is retrieved from github...
- (void) awakeFromNib {
    NSLog(@"Registering notifications listeners for the menu controller");
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyGists:)
												 name:GITHUB_NOTIFICATION_GISTS
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyIssues:)
												 name:GITHUB_NOTIFICATION_ISSUES
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyOrganizations:)
												 name:GITHUB_NOTIFICATION_ORGS
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyRepos:)
												 name:GITHUB_NOTIFICATION_REPOS
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyFollowers:)
												 name:GITHUB_NOTIFICATION_FOLLOWERS
											   object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyFollowings:)
												 name:GITHUB_NOTIFICATION_FOLLOWINGS
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyWatchedRepos:)
												 name:GITHUB_NOTIFICATION_WATCHEDREPO
											   object:nil];

}

- (void)cleanMenus:(id)sender {
    NSLog(@"Cleaning menus");
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
    
    menuItem = [statusMenu itemWithTitle:@"Watching"];
    menu = [menuItem submenu];
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];

    // Delete users
    menuItem = [statusMenu itemWithTitle:@"Users"];
    NSMenu *tmp = [menuItem submenu];
    NSMenuItem *followersItem = [tmp itemWithTitle:@"Followers"];
    menu = [followersItem submenu];
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    followersItem = [tmp itemWithTitle:@"Following"];
    menu = [followersItem submenu];
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    firstGistCall = YES;
    firstIssueCall = YES;
    firstOrganizationCall = YES;
    firstRepositoryCall = YES;
}

#pragma mark - selectors
- (void)notifyGists:(NSNotification *)aNotification {
    NSLog(@"Got a Notify Gists");
    ASIHTTPRequest *httpRequest = [aNotification object];
    [self gistFinished:httpRequest];
}

- (void)notifyRepos:(NSNotification *)aNotification {
    NSLog(@"Got a Notify Repos");
    ASIHTTPRequest *httpRequest = [aNotification object];
    [self reposFinished:httpRequest];
}

- (void)notifyOrganizations:(NSNotification *)aNotification {
    NSLog(@"Got a Notify Orgs");
    ASIHTTPRequest *httpRequest = [aNotification object];
    [self organizationsFinished:httpRequest];
}

- (void)notifyIssues:(NSNotification *)aNotification {
    NSLog(@"Got a Notify Issues");
    ASIHTTPRequest *httpRequest = [aNotification object];
    [self issuesFinished:httpRequest];
}

- (void)notifyFollowings:(NSNotification *)aNotification {
    NSLog(@"Got a Notify Followings");
    ASIHTTPRequest *httpRequest = [aNotification object];
    [self followingsFinished:httpRequest];
}

- (void)notifyFollowers:(NSNotification *)aNotification {
    NSLog(@"Got a Notify Followers");
    ASIHTTPRequest *httpRequest = [aNotification object];
    [self followersFinished:httpRequest];
}

- (void)notifyWatchedRepos:(NSNotification *)aNotification {
    NSLog(@"Got a Notify Watched Respos");
    ASIHTTPRequest *httpRequest = [aNotification object];
    [self watchedReposFinished:httpRequest];
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
    if ([removedIssues count] > 0 && !firstIssueCall) {
        // for now we do not cache the issue title, so we just say that we removed some...
        NSString *title = [NSString stringWithString:@"Yeah! One less issue!"];
        if ([removedIssues count] > 1) {
            title = [NSString stringWithFormat:@"OMG, %d less issues", [removedIssues count]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
                                                            object:title 
                                                          userInfo:nil];
    }
    
    NSMutableSet* addedIssues = [NSMutableSet setWithSet:justGetIssues];
    [addedIssues minusSet:existingIssues];
    
    if ([addedIssues count] > 0 && !firstIssueCall) {
        if ([addedIssues count] > 3) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
                                                                object:[NSString stringWithFormat:@"%d new issues...", [addedIssues count]] 
                                                              userInfo:nil];
        } else {
            for (NSString *key in addedIssues) {
                for (NSArray *issue in result) {
                    if ([issue valueForKey:@"number"] == key) {
                        NSString *title = [issue valueForKey:@"title"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:GITHUB_NOTIFICATION_ISSUE_ADDED 
                                                                            object:[NSString stringWithFormat:@"%@", title]                                                             userInfo:nil];                
                    }
                }
            }
        }
    }
    
    firstIssueCall = NO;
    BOOL clean = (addedIssues != 0 || removedIssues != 0);
    if (clean) {
        [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    }
    
    // clear the existing Issues
    existingIssues = [[NSMutableSet alloc]init]; 
    
    for (NSArray *issue in result) {
        [existingIssues addObject:[issue valueForKey:@"number"]];
        if (clean) {
            NSMenuItem *issueItem = [[NSMenuItem alloc] initWithTitle:[issue valueForKey:@"title"] action:@selector(issuePressed:) keyEquivalent:@""];
            [issueItem setRepresentedObject:[issue valueForKey:@"html_url"]];
            
            NSImage* iconImage = [NSImage imageNamed:@"bullet_yellow.png"];
            [iconImage setSize:NSMakeSize(16,16)];
            [issueItem setImage:iconImage];
            
            [issueItem autorelease];
            [menu addItem:issueItem];
        }
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
    if ([removed count] > 0 && !firstGistCall) {
        NSString *title = nil;
        if ([removed count] > 1) {
            title = [NSString stringWithFormat:@"OMG, %d less gists", [removed count]];
        } else {
            title = [NSString stringWithString:@"RIP gist #"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
                                                            object:title 
                                                          userInfo:nil];       
    }
    
    NSMutableSet* added = [NSMutableSet setWithSet:justGet];
    [added minusSet:existingGists];
    
    if ([added count] > 0 && !firstGistCall) {
        if ([added count] > 3) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
                                                                object:[NSString stringWithFormat:@"%d new gists!", [added count]] 
                                                              userInfo:nil];
        } else {
            for (NSString *key in added) {
                for (NSArray *issue in result) {
                    if ([[issue valueForKey:@"id"] isEqual:key]) {
                        NSString *title = nil;
                        NSString *description = [issue valueForKey:@"description"];
                        if (description == (id)[NSNull null] || description.length == 0) {
                            title = [NSString stringWithFormat:@"gist %@", [issue valueForKey:@"id"]];
                        } else {
                            title = [NSString stringWithFormat:@"gist %@ : %@", [issue valueForKey:@"id"], description];
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:GITHUB_NOTIFICATION_GIST_ADDED 
                                                                            object:[NSString stringWithFormat:@"%@", title]                                                             userInfo:nil];                
                    }
                }
            }
        }
    }
    
    firstGistCall = NO;
    
    BOOL clean = (added != 0 || added != 0); {
        [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    }
    
    // clear the existing Issues
    existingGists = [[NSMutableSet alloc]init]; 
    
    for (NSArray *gist in result) {
        // cache for next time...
        [existingGists addObject:[gist valueForKey:@"id"]];
        
        if (clean) {
            NSString *title = nil;
            NSString *description = [gist valueForKey:@"description"];
            if (description == (id)[NSNull null] || description.length == 0) {
                title = [NSString stringWithFormat:@"%@", [gist valueForKey:@"id"]];
            } else {
                title = [NSString stringWithFormat:@"%@ : %@", [gist valueForKey:@"id"], description];
            }
        
            NSMenuItem *gistItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(gistPressed:) keyEquivalent:@""];
            
            NSNumber *pub = [gist valueForKey:@"public"];
            NSImage* iconImage = nil;
            if ([pub boolValue]) {
                iconImage = [NSImage imageNamed: @"bullet_green.png"];
            } else {
                iconImage = [NSImage imageNamed: @"bullet_red.png"];
            }
            [iconImage setSize:NSMakeSize(16,16)];
            [gistItem setImage:iconImage];
            
            [gistItem setToolTip:[NSString stringWithFormat:@"Created at %@, %@ comment(s)", [gist valueForKey:@"created_at"], [gist valueForKey:@"comments"]]];
            [gistItem setRepresentedObject:[gist valueForKey:@"html_url"]];
            [gistItem autorelease];
            [menu addItem:gistItem];
        }
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
        //[organizationItem setToolTip: [NSString stringWithFormat:@"Created at %@", [org valueForKey:@"created_at"]]];
        [organizationItem setRepresentedObject:[org valueForKey:@"login"]];
        
        NSImage* iconImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[org valueForKey:@"avatar_url"]]];
        [iconImage setSize:NSMakeSize(16,16)];
        [organizationItem setImage:iconImage];
        
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
            //[organizationRepoItem setToolTip: @""];
            [organizationRepoItem setRepresentedObject:[repo valueForKey:@"html_url"]];
            
            NSNumber *priv = [repo valueForKey:@"private"];
            NSImage* iconImage = nil;
            if ([priv boolValue]) {
                iconImage = [NSImage imageNamed: @"bullet_red.png"];
            } else {
                iconImage = [NSImage imageNamed: @"bullet_green.png"];
            }
            [iconImage setSize:NSMakeSize(16,16)];
            [organizationRepoItem setImage:iconImage];
            
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
    if ([removed count] > 0 && !firstRepositoryCall) {
        NSString *title = nil;
        if ([removed count] > 1) {
            title = [NSString stringWithFormat:@"OMG, %d less repositories!?", [removed count]];
        } else {
            // TODO get the name from the set
            title = [NSString stringWithString:@"RIP little repository..."];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
                                                            object:title 
                                                          userInfo:nil];       
    }
    
    NSMutableSet* added = [NSMutableSet setWithSet:justGet];
    [added minusSet:existingRepos];
    if ([added count] > 0 && !firstRepositoryCall) {
        if ([added count] > 3) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
                                                                object:[NSString stringWithFormat:@"%d new repositories! Take coffee and code!", [added count]] 
                                                              userInfo:nil];
        } else {
            for (NSString *key in added) {
                for (NSArray *issue in result) {
                    if ([[issue valueForKey:@"name"] isEqual:key]) {
                        NSString *title = [issue valueForKey:@"name"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
                                                                            object:[NSString stringWithFormat:@"%@ is your new repository", title]                                                             userInfo:nil];                
                    }
                }
            }
        }
    }
    firstRepositoryCall = NO;
    BOOL clean = (added != 0 || added != 0);

    if (clean) {
        [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    }
    
    // clear the existing Issues
    existingRepos = [[NSMutableSet alloc]init]; 
    
    for (NSArray *repo in result) {
        // cache for next time
        [existingRepos addObject:[repo valueForKey:@"name"]];
        
        if (clean) {
            NSMenuItem *organizationItem = [[NSMenuItem alloc] initWithTitle:[repo valueForKey:@"name"] action:@selector(repoPressed:) keyEquivalent:@""];
            [organizationItem setToolTip: [NSString stringWithFormat:@"Description : %@, Forks: %@, Watchers: %@", [repo valueForKey:@"description"], [repo valueForKey:@"forks"], [repo valueForKey:@"watchers"]]];
            [organizationItem setRepresentedObject:[repo valueForKey:@"html_url"]];
            
            NSNumber *priv = [repo valueForKey:@"private"];
            NSImage* iconImage = nil;
            if ([priv boolValue]) {
                iconImage = [NSImage imageNamed: @"bullet_red.png"];
            } else {
                iconImage = [NSImage imageNamed: @"bullet_green.png"];
            }
            [iconImage setSize:NSMakeSize(16,16)];
            [organizationItem setImage:iconImage];
            
            [organizationItem setEnabled:YES];
            [organizationItem autorelease];
            [menu addItem:organizationItem];
        }
    }
}

- (void)pullFinished:(ASIHTTPRequest *)request {
    
}

- (void) followersFinished:(ASIHTTPRequest*)request {
    NSLog(@"Followers Finished...");
    
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Users"];
    NSMenu *tmp = [menuItem submenu];
    
    NSMenuItem *followersItem = [tmp itemWithTitle:@"Followers"];
    NSMenu *menu = [followersItem submenu];

    NSDictionary* result = [[request responseString] objectFromJSONString];
    
    // always delete...
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    for (NSArray *user in result) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[user valueForKey:@"login"] action:@selector(followerPressed:) keyEquivalent:@""];
        [item setRepresentedObject:[user valueForKey:@"login"]];
        NSImage* iconImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[user valueForKey:@"avatar_url"]]];
        [iconImage setSize:NSMakeSize(18,18)];
        [item setImage:iconImage];
        [item autorelease];
        [menu addItem:item];
    }    
}

- (void) followingsFinished:(ASIHTTPRequest *)request {
    NSLog(@"Following Finished...");
    
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Users"];
    NSMenu *tmp = [menuItem submenu];
    
    NSMenuItem *followingsItem = [tmp itemWithTitle:@"Following"];
    NSMenu *menu = [followingsItem submenu];
    
    NSDictionary* result = [[request responseString] objectFromJSONString];
    
    // always delete...
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    for (NSArray *user in result) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[user valueForKey:@"login"] action:@selector(followingPressed:) keyEquivalent:@""];
        [item setRepresentedObject:[user valueForKey:@"login"]];
        NSImage* iconImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[user valueForKey:@"avatar_url"]]];
        [iconImage setSize:NSMakeSize(16,16)];
        [item setImage:iconImage];
        [item setEnabled:YES];
        [item autorelease];
        [menu addItem:item];
    }    
}

- (void) watchedReposFinished:(ASIHTTPRequest *)request {
    NSLog(@"Following Finished...");
    
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Watching"];
    NSMenu *menu = [menuItem submenu];
    
    NSDictionary* result = [[request responseString] objectFromJSONString];
    
    // always delete...
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    for (NSArray *repo in result) {
        // get the owner
        NSArray *owner = [repo valueForKey:@"owner"];
        
        // do not display my own repositories...
        if (![[preferences login] isEqualToString:[owner valueForKey:@"login"]]) {
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@/%@", [owner valueForKey:@"login"], [repo valueForKey:@"name"]] action:@selector(openURL:) keyEquivalent:@""];
            [item setRepresentedObject:[repo valueForKey:@"html_url"]];
            [item setToolTip: [NSString stringWithFormat:@"Description : %@, Forks: %@, Watchers: %@", [repo valueForKey:@"description"], [repo valueForKey:@"forks"], [repo valueForKey:@"watchers"]]];

            NSNumber *priv = [repo valueForKey:@"private"];
            NSImage* iconImage = nil;
            if ([priv boolValue]) {
                iconImage = [NSImage imageNamed: @"bullet_red.png"];
            } else {
                iconImage = [NSImage imageNamed: @"bullet_green.png"];
            }
            [item setImage:iconImage];
            [item setEnabled:YES];
            [item autorelease];
            [menu addItem:item];
        }
    }    
}

# pragma mark - Actions on pressed menu items

- (IBAction) repoPressed:(id) sender {
    id selectedItem = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", selectedItem]]];
}

- (IBAction) issuePressed:(id) sender {
    id selectedItem = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", selectedItem]]];
}

- (IBAction) gistPressed:(id) sender {
    id selectedItem = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", selectedItem]]];
}

- (IBAction) pullPressed:(id)sender {
    id selectedItem = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", selectedItem]]];    
}

- (IBAction) organizationPressed:(id) sender {
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

- (IBAction)openFollowings:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/%@/following", [preferences login]]]];
}

- (IBAction)openFollowers:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/%@/followers", [preferences login]]]];
}

- (IBAction)openWatchedRepositories:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/%@/following", [preferences login]]]]; 
}

#pragma mark - item stuff
- (void) deleteOldEntriesFromMenu:(NSMenu*)menu fromItemTitle:(NSString*)title {
    NSLog(@"Delete entries from menu");
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

- (void) resetCache:(id)sender {
    firstGistCall = YES;
    firstIssueCall = YES;
    firstOrganizationCall = YES;
    firstRepositoryCall = YES;
    existingRepos = [[NSMutableSet alloc]init]; 
    existingGists = [[NSMutableSet alloc]init]; 
    existingIssues = [[NSMutableSet alloc]init]; 
}

@end
