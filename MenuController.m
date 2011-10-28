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

- (void) issuesFinished:(ASIHTTPRequest*)request;
- (void) gistFinished:(ASIHTTPRequest*)request;
- (void) organizationsFinished:(ASIHTTPRequest*)request;
- (void) reposFinished:(ASIHTTPRequest*)request;
- (void) pullFinished:(ASIHTTPRequest *)request;
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
}

- (void)cleanMenus:(id)sender {
    NSLog(@"Cleaning menu");
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
            [organizationItem setToolTip: @""];
            [organizationItem setRepresentedObject:[repo valueForKey:@"html_url"]];
            [organizationItem setEnabled:YES];
            [organizationItem autorelease];
            [menu addItem:organizationItem];
        }
    }
}

- (void)pullFinished:(ASIHTTPRequest *)request {
    
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
