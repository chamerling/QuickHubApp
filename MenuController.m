//
//  MenuController.m
//  QuickHubApp
//
//  Created by Christophe Hamerling on 25/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuController.h"
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
- (void)pullFinished:(ASIHTTPRequest *)request;
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

// register to notifications so that the menu can be updated...
- (void) awakeFromNib {
    NSLog(@"Registering notifications listeners for the menu controller");
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyGists:)
												 name:@"GistsNotify"
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyIssues:)
												 name:@"IssuesNotify"
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyOrganizations:)
												 name:@"OrgsNotify"
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyRepos:)
												 name:@"ReposNotify"
											   object:nil];
}

#pragma mark - listeners
- (void)notifyGists:(NSNotification *)aNotification {
    NSLog(@"Got a Notify Gists");
    ASIHTTPRequest *httpRequest = [aNotification object];
    [self gistFinished:httpRequest];
}

- (void)notifyRepos:(NSNotification *)aNotification {
    NSLog(@"Got a Notify Repos");
    ASIHTTPRequest *httpRequest = [aNotification object];
    [self gistFinished:httpRequest];
    
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
    if ([removedIssues count] > 0) {
    }
    
    NSMutableSet* addedIssues = [NSMutableSet setWithSet:justGetIssues];
    [addedIssues minusSet:existingIssues];
    if ([addedIssues count] > 0 && !firstIssueCall) {
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

- (void)pullFinished:(ASIHTTPRequest *)request {
    
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

- (void) pullPressed:(id)sender {
    id selectedItem = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", selectedItem]]];    
}

- (void) organizationPressed:(id) sender {
    id selectedItem = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/organizations/%@", selectedItem]]];
}

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

@end
