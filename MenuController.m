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
#import "OrgRepoCreateWindowController.h"
#import "RepositoryDetailsViewController.h"
#import "UserDetailsViewController.h"
#import "EventMenuItemController.h"
#import "EventMenuItemView.h"

@interface MenuController (Private) 
- (NSMenu*) getIssuesMenu;
- (NSMenu*) getOrgsMenu;
- (NSMenu*) getReposMenu;
- (NSMenu*) getFollowingMenu;
- (NSMenu*) getFollowersMenu;
- (NSMenu*) getPullsMenu;
- (NSMenu*) getGistsMenu;
- (NSMenu*) getWatchingMenu;
- (NSMenu*) getReposOrgMenu:(NSString*) orgName;
- (NSMenuItem*) createMenuItemForOrgRepo:(NSDictionary*) repository;

- (void) addItemOnMainUIThread:(NSMenuItem *)item to:(NSMenu*)menu;
- (void) addItemOnMainUIThread:(NSMenuItem *)item to:(NSMenu*)menu at:(NSInteger)index;
- (void) addTopItemOnMainUIThread:(NSMenuItem *)item to:(NSMenu*)menu;

- (void) addItem:(NSMenuItem *)item to:(NSMenu*)menu top:(Boolean)top;

- (void) addItemAt:(NSDictionary *)dict;
- (void) addItem:(NSDictionary *)dict;
- (void) addTopItem:(NSDictionary *)dict;

- (void) deleteItemWithName:(NSString*)name fromMenu:(NSMenu*)menu;

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
    //NSLog(@"Registering notifications listeners for the menu controller");
     
    // register to internet connection changes so that we can update the first entry...
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyInternet:)
												 name:NOTIFY_INTERNET_UP
											   object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyInternet:)
												 name:NOTIFY_INTERNET_DOWN
											   object:nil];


}

- (void)cleanMenus:(id)sender {
    //NSLog(@"Cleaning menus");
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
    
    menuItem = [statusMenu itemWithTitle:@"Pull Requests"];
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
    
    [eventsMenu removeAllItems];
    
    firstGistCall = YES;
    firstIssueCall = YES;
    firstOrganizationCall = YES;
    firstRepositoryCall = YES;
}

#pragma mark - selectors
- (void)notifyInternet:(NSNotification *)aNotification {
    //NSLog(@"Internet statius change on menu");
    NSString *name = [aNotification name];
    if ([name compare:NOTIFY_INTERNET_UP] == NSOrderedSame) {
        [internetItem setTitle:@"Open GitHub..."];
        [internetItem setEnabled:TRUE];
    } else {
        [internetItem setTitle:@"No Internet connection"];
        [internetItem setEnabled:FALSE];
    }
}

#pragma mark - process HTTP responses
- (void) issuesFinished:(NSDictionary *)result {
    //NSLog(@"Issues Finished...");
    
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Issues"];
    NSMenu *menu = [menuItem submenu];
    
    //NSDictionary* result = [[request responseString] objectFromJSONString];
    
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
    BOOL clean = ([addedIssues count] != 0 || [removedIssues count] != 0);
    if (clean) {
        // TODO : Remove just the right ones...
        [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    }
    
    // clear the existing Issues
    existingIssues = [[NSMutableSet alloc]init]; 
    
    for (NSDictionary *issue in result) {
        [existingIssues addObject:[issue valueForKey:@"number"]];
        if (clean) {
            [self addIssue:issue top:NO];
        }
    }
    
    if (!result || [result count] == 0) {
        // default menu item
        [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
        NSMenuItem *defaultItem = [[NSMenuItem alloc] initWithTitle:@"No issues" action:nil keyEquivalent:@""];
        [defaultItem autorelease];
        //[menu addItem:defaultItem];
        [self addItem:defaultItem to:menu top:FALSE];
    }
}

- (void) gistFinished:(NSDictionary *)result {
    //NSLog(@"Gists Finished...");
    
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Gists"];
    NSMenu *menu = [menuItem submenu];
        
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
            title = [NSString stringWithFormat:@"OMG, %d fewer gists", [removed count]];
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
    BOOL clean = ([added count] != 0 || [removed count] != 0);
    // FIXME : Clean should not always be called if there is no response in the dictionary
    if (clean) {
        [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
        // TODO : delete only the removed... need to put gist ids as menu items ids
    }
    
    // clear the existing Issues
    existingGists = [[NSMutableSet alloc]init]; 
    
    for (NSDictionary *gist in result) {
        // cache for next time...
        [existingGists addObject:[gist valueForKey:@"id"]];
        
        if (clean) {
            [self addGist:gist top:NO];
        }
    }
    
    if (!result || [result count] == 0) {
        // delete all so that we do not add gists indefinitely...
        [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
        // default menu item
        NSMenuItem *defaultItem = [[NSMenuItem alloc] initWithTitle:@"No gists" action:nil keyEquivalent:@""];
        [defaultItem autorelease];
        //[menu addItem:defaultItem];
        [self addItem:defaultItem to:menu top:FALSE];
    }
}

//dict = [orgname -> [repos->[dict], [org->[dict]]]]
- (void) organizationsFinished:(NSDictionary *)result {
    //NSLog(@"Organizations Finished...");
    
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Organizations"];
    NSMenu *menu = [menuItem submenu];
    
    // delete all...
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    // order
    NSArray *orderedOrgs = [[NSMutableArray arrayWithArray:[result allKeys]] sortedArrayUsingComparator:^(id a, id b) {
        NSString *first = (NSString*)a;
        NSString *second = (NSString*)b;
        return [[first lowercaseString] compare:[second lowercaseString]];
    }];
    
    for (NSString *orgName in orderedOrgs) {
        NSDictionary *entry = [result valueForKey:orgName];
        NSDictionary *org = [entry valueForKey:@"org"];
        
        NSMenuItem *organizationItem = [[NSMenuItem alloc] initWithTitle:[org valueForKey:@"login"] action:@selector(organizationPressed:) keyEquivalent:@""];
        [organizationItem setRepresentedObject:[org valueForKey:@"login"]];
        
        NSImage* iconImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[org valueForKey:@"avatar_url"]]];
        [iconImage setSize:NSMakeSize(16,16)];
        [organizationItem setImage:iconImage];
        
        [organizationItem setEnabled:YES];
        [organizationItem autorelease];
        [menu addItem:organizationItem];
        //[self addItem:organizationItem to:menu top:FALSE];

        NSDictionary* repos = [entry valueForKey:@"repos"];
        
        NSMenu* repositoriesMenu = [[NSMenu alloc] init];
        
        // create the top items
        NSMenuItem *openItem = [[NSMenuItem alloc] initWithTitle:@"Open..." action:@selector(organizationPressed:) keyEquivalent:@""];
        [openItem setRepresentedObject:[org valueForKey:@"login"]];
        [openItem autorelease];
        [repositoriesMenu addItem:openItem];
        //[self addItem:openItem to:repositoriesMenu top:FALSE];
        
        NSMenuItem *createItem = [[NSMenuItem alloc] initWithTitle:@"Create Repository..." action:@selector(createOrgRepository:) keyEquivalent:@""];
        [createItem setRepresentedObject:[org valueForKey:@"login"]];
        [createItem autorelease];
        [repositoriesMenu addItem:createItem];
        //[self addItem:createItem to:repositoriesMenu top:FALSE];
        
        NSMenuItem *separator = [NSMenuItem separatorItem];
        [separator setTitle:@"deletelimit"];
        [repositoriesMenu addItem:separator];
        //[self addItem:separator to:repositoriesMenu top:FALSE];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSDictionary *repo in repos) {
            [array addObject:repo];
        }
        NSArray *sorted = [[NSMutableArray arrayWithArray:array] sortedArrayUsingComparator:^(id a, id b) {
            NSString *first = [a objectForKey:@"name"];
            NSString *second = [b objectForKey:@"name"];
            return [[first lowercaseString] compare:[second lowercaseString]];
        }];
        
        if (sorted.count == 0) {
            NSMenuItem *defaultItem = [[NSMenuItem alloc] initWithTitle:@"No repository" action:nil keyEquivalent:@""];
            [defaultItem autorelease];
            [repositoriesMenu addItem:defaultItem];
        } else {
            // HERE
            for (NSDictionary *repo in sorted) {
                NSMenuItem *organizationRepoItem = [[NSMenuItem alloc] initWithTitle:[repo valueForKey:@"name"] action:@selector(repoPressed:) keyEquivalent:@""];

                [organizationRepoItem setRepresentedObject:[repo valueForKey:@"html_url"]];
                
                NSNumber *priv = [repo valueForKey:@"private"];
                NSImage* iconImage = nil;
                
                NSNumber *forked = [repo valueForKey:@"fork"];
                if ([forked boolValue]) {
                    // TODO, set a specific icon
                    iconImage = [NSImage imageNamed: @"fork.png"];
                } else {
                    if ([priv boolValue]) {
                        iconImage = [NSImage imageNamed: @"bullet_red.png"];
                    } else {
                        iconImage = [NSImage imageNamed: @"bullet_green.png"];
                    }
                }
                [iconImage setSize:NSMakeSize(16,16)];
                [organizationRepoItem setImage:iconImage];
                
                [organizationRepoItem setEnabled:YES];
                [organizationRepoItem autorelease];
                
                // ID CARD
                RepositoryDetailsViewController *details = [[RepositoryDetailsViewController alloc] initWithNibName:@"RepositoryDetailsViewController" bundle:nil];
                [details setRepositoryData:repo];
                
                NSMenuItem *popoverMenuItem = [[NSMenuItem alloc] init];
                [popoverMenuItem setView:[details view]];
                [popoverMenuItem autorelease];
                
                NSMenu *foomenu = [[NSMenu alloc] init];    
                [foomenu addItem:popoverMenuItem];
                [organizationRepoItem setSubmenu:foomenu];
                
                [repositoriesMenu addItem:organizationRepoItem];
            }
        }
        [organizationItem setSubmenu:repositoriesMenu]; 
    }
    
    if (!result || [result count] == 0) {
        // default menu item
        [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
        NSMenuItem *defaultItem = [[NSMenuItem alloc] initWithTitle:@"No organizations" action:nil keyEquivalent:@""];
        [defaultItem autorelease];
        [menu addItem:defaultItem];
        //[self addItem:defaultItem to:menu top:FALSE];
    }
    
}

- (void) reposFinished:(NSDictionary *)result {
    //NSLog(@"Repositories update...");
    
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Repositories"];
    NSMenu *menu = [menuItem submenu];
    
    // process added and removed issues
    NSMutableSet* justGet = [[NSMutableSet alloc] init];
    for (NSArray *repo in result) {
        [justGet addObject:[repo valueForKey:@"name"]];
    }
    
    NSMutableSet* removed = [NSMutableSet setWithSet:existingRepos];
    [removed minusSet:justGet];
    if ([removed count] > 0 && !firstRepositoryCall) {
        for (NSString *repo in removed) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
                object:[NSString stringWithFormat:@"RIP repository '%@'", repo] userInfo:nil];
        }
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
                                                                            object:[NSString stringWithFormat:@"New repository '%@'", title]                                                             userInfo:nil];                
                    }
                }
            }
        }
    }
    
    firstRepositoryCall = NO;
    BOOL clean = ([added count] != 0 || [removed count] != 0);
    if (clean) {
        [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    }
    
    // clear the existing repos
    existingRepos = [[NSMutableSet alloc]init]; 
    
    // create an array from the JKArray in order to be able to sort it...
    // to be removed and updated the day JSONKit is no more used
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *repo in result) {
        [array addObject:repo];
    }
    NSArray *sorted = [[NSMutableArray arrayWithArray:array] sortedArrayUsingComparator:^(id a, id b) {
        NSString *first = [a objectForKey:@"name"];
        NSString *second = [b objectForKey:@"name"];
        return [[first lowercaseString] compare:[second lowercaseString]];
    }];
    
    for (NSDictionary *repo in sorted) {
        [existingRepos addObject:[repo valueForKey:@"name"]];                
        if (clean) {
            [self addRepo:repo top:NO];
        }
    }
    
    if (!result || [result count] == 0) {
        // default menu item
        [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
        NSMenuItem *defaultItem = [[NSMenuItem alloc] initWithTitle:@"No repositories" action:nil keyEquivalent:@""];
        [defaultItem autorelease];
        [self addItem:defaultItem to:menu top:FALSE];
    }
}

/*
 * TODO :
 * The input dictionary is composed:
 * - key is the repo name
 * - value is a dictionary
 *   - key = 'repository', value NSDictionary of the repository
 *   - key = 'pulls', value NSDictionary of the pulls
 */
- (void)pullsFinished:(NSDictionary *)dictionary {
    
    //NSLog(@"Pulls finished...");
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Pull Requests"];
    NSMenu *menu = [menuItem submenu];
    
    // TODO : create the notifications on add and delete
    
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    NSArray *keys = [dictionary allKeys];
    for (NSString *key in keys) {
        //NSLog(@"Processing pulls for repo '%@'", key);
        NSDictionary *pulls = [dictionary valueForKey:key];
        
        // create a menu entry for the current repository
        NSMenuItem *item = [[NSMenuItem alloc]initWithTitle:[NSString stringWithFormat:@"%@/%@", [preferences login], key] action:@selector(openURL:) keyEquivalent:@""];
        [item setRepresentedObject:[NSString stringWithFormat:@"https://github.com/%@/%@/pulls", [preferences login], key]];
        
        NSImage* iconImage = [NSImage imageNamed:@"bullet_yellow.png"];
        [iconImage setSize:NSMakeSize(16,16)];
        [item setImage:iconImage];
        
        [item autorelease];
        [menu addItem:item];
        //[self addItem:item to:menu top:FALSE];

        // add submenus and item for each pull
        NSMenu* pullsMenu = [[NSMenu alloc] init];
        for (NSArray *pull in pulls) {
            NSMenuItem *pullItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"#%@ - %@", [pull valueForKey:@"number"], [pull valueForKey:@"title"]] action:@selector(openURL:) keyEquivalent:@""];
            
            [pullItem setRepresentedObject:[pull valueForKey:@"html_url"]];
            [pullItem setToolTip:[NSString stringWithFormat:@"Created at %@", [pull valueForKey:@"created_at"]]];
            
            [pullItem autorelease];
            [pullsMenu addItem:pullItem];
            //[self addItem:pullItem to:pullsMenu top:FALSE];

        }
        [item setSubmenu:pullsMenu];
    }
    if (!keys || [keys count] == 0) {
        // default menu item
        [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];

        NSMenuItem *defaultItem = [[NSMenuItem alloc] initWithTitle:@"No pull requests" action:nil keyEquivalent:@""];
        [defaultItem autorelease];
        [menu addItem:defaultItem];
        //[self addItem:defaultItem to:menu top:FALSE];
    }
    
}

- (void) followersFinished:(NSDictionary *)result {
    //NSLog(@"Followers Finished...");
    
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Users"];
    NSMenu *tmp = [menuItem submenu];
    
    NSMenuItem *followersItem = [tmp itemWithTitle:@"Followers"];
    NSMenu *menu = [followersItem submenu];
    
    // always delete...
    // FIXME = just add or delete the diff...
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    // order the list by name
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *user in result) {
        [array addObject:user];
    }
    NSArray *sorted = [[NSMutableArray arrayWithArray:array] sortedArrayUsingComparator:^(id a, id b) {
        NSString *first = [a objectForKey:@"login"];
        NSString *second = [b objectForKey:@"login"];
        return [[first lowercaseString] compare:[second lowercaseString]];
    }];
    
    for (NSDictionary *user in sorted) {
        [self addFollower:user];
    }
    
    if (!result || [result count] == 0) {
        // default menu item
        [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
        NSMenuItem *defaultItem = [[NSMenuItem alloc] initWithTitle:@"No followers" action:nil keyEquivalent:@""];
        [defaultItem autorelease];
        //[menu addItem:defaultItem];
        [self addItem:defaultItem to:menu top:FALSE];
    }  
}

- (void) followingsFinished:(NSDictionary *)result {
    //NSLog(@"Following Finished...");
    
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Users"];
    NSMenu *tmp = [menuItem submenu];
    
    NSMenuItem *followingsItem = [tmp itemWithTitle:@"Following"];
    NSMenu *menu = [followingsItem submenu];
        
    // always delete...
    // FIXME = just add or delete the diff
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    // order the list by name
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *user in result) {
        [array addObject:user];
    }
    NSArray *sorted = [[NSMutableArray arrayWithArray:array] sortedArrayUsingComparator:^(id a, id b) {
        NSString *first = [a objectForKey:@"login"];
        NSString *second = [b objectForKey:@"login"];
        return [[first lowercaseString] compare:[second lowercaseString]];
    }];
    
    for (NSDictionary *user in sorted) {
        [self addFollowing:user];
    }
    
    if (!result || [result count] == 0) {
        // default menu item
        [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
        NSMenuItem *defaultItem = [[NSMenuItem alloc] initWithTitle:@"Nobody" action:nil keyEquivalent:@""];
        [defaultItem autorelease];
        //[menu addItem:defaultItem];
        [self addItem:defaultItem to:menu top:FALSE];
    }
}

- (void) watchedReposFinished:(NSDictionary *)result {
    //NSLog(@"Watched repos update...");
    
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Watching"];
    NSMenu *menu = [menuItem submenu];
        
    // always delete...
    // FIXME : just delete or add the diff
    [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *user in result) {
        [array addObject:user];
    }
    NSArray *sorted = [[NSMutableArray arrayWithArray:array] sortedArrayUsingComparator:^(id a, id b) {
        NSArray *ownerA = [a valueForKey:@"owner"];
        NSArray *ownerB = [b valueForKey:@"owner"];
        NSString *first = [NSString stringWithFormat:@"%@/%@", [ownerA valueForKey:@"login"], [a valueForKey:@"name"]];
        NSString *second = [NSString stringWithFormat:@"%@/%@", [ownerB valueForKey:@"login"], [b valueForKey:@"name"]];
        return [[first lowercaseString] compare:[second lowercaseString]];
    }];
    
    for (NSDictionary *repo in sorted) {
        // get the owner
        NSArray *owner = [repo valueForKey:@"owner"];
        
        // do not display my own repositories...
        if (![[preferences login] isEqualToString:[owner valueForKey:@"login"]]) {
            [self addWatched:repo];
        }
    }
    
    if (!result || [result count] == 0) {
        // default menu item
        [self deleteOldEntriesFromMenu:menu fromItemTitle:@"deletelimit"];
        NSMenuItem *defaultItem = [[NSMenuItem alloc] initWithTitle:@"Nothing to watch" action:nil keyEquivalent:@""];
        [defaultItem autorelease];
        //[menu addItem:defaultItem];
        [self addItem:defaultItem to:menu top:FALSE];
    }
}

#pragma mark - atomic
- (void) addIssue:(NSDictionary *)issue top:(BOOL)top {
    NSMenu *menu = [self getIssuesMenu];
    
    // get the repository name from the API url such as
    // 'https://api.github.com/repos/Jug-Montpellier/play-Jug/2' or 'https://api.github.com/repos/chamerling/JugApp/issues/1'
    
    NSString *apiURL = [issue valueForKey:@"url"];    
    NSString *repoName = [NSString stringWithString:[apiURL substringFromIndex:([[NSString stringWithString:@"https://api.github.com/repos/"] length])]];    
    if ([repoName rangeOfString:[NSString stringWithFormat:@"%@/", [[Preferences sharedInstance] login]]].length > 0) {
        repoName = [NSString stringWithString:[repoName substringFromIndex:([[NSString stringWithFormat:@"%@/", [[Preferences sharedInstance] login]] length])]];
        repoName = [repoName substringToIndex:[repoName rangeOfString:@"/issues"].location];
    } else {
        repoName = [repoName substringToIndex:[repoName rangeOfString:@"/issues"].location];
    }
    
    NSString *title = [NSString stringWithFormat:@"[%@] %@", repoName, [issue valueForKey:@"title"]];
    
    NSMenuItem *issueItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(issuePressed:) keyEquivalent:@""];
    [issueItem setRepresentedObject:[issue valueForKey:@"html_url"]];
    [issueItem setToolTip:[NSString stringWithFormat:@"Repository %@, State is %@, Created at %@", repoName, [issue valueForKey:@"state"], [issue valueForKey:@"created_at"]]];
    
    NSImage* iconImage = nil;
    NSDictionary *user = [issue valueForKey:@"user"];
    if (user && [user valueForKey:@"avatar_url"]) {
        iconImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[user valueForKey:@"avatar_url"]]];
    } else {
        iconImage = [NSImage imageNamed:@"bullet_yellow.png"];
    }

    [iconImage setSize:NSMakeSize(16,16)];
    [issueItem setImage:iconImage];
    [issueItem autorelease];
    
    [self addItem:issueItem to:menu top:top];
}

- (void) addGist:(NSDictionary *)gist top:(BOOL)top {
    NSMenu *menu = [self getGistsMenu];
    
    NSString *title = nil;
    NSString *description = [gist valueForKey:@"description"];
    if (description == (id)[NSNull null] || description.length == 0) {
        title = [NSString stringWithFormat:@"[%@]", [gist valueForKey:@"id"]];
    } else {
        title = [NSString stringWithFormat:@"[%@] %@", [gist valueForKey:@"id"], description];
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
    [gistItem setRepresentedObject:gist];
    [gistItem autorelease];
    
    [self addItem:gistItem to:menu top:top];
}

- (void) addOrg:(NSDictionary *)org {
    //NSMenu *menu = [self getOrgsMenu];

}

- (void) addRepo:(NSDictionary *)repo top:(BOOL)top{
    NSMenu *menu = [self getReposMenu];
    
    NSNumber *forked = [repo valueForKey:@"fork"];
    
    NSMenuItem *organizationItem = [[NSMenuItem alloc] initWithTitle:[repo valueForKey:@"name"] action:@selector(repoPressed:) keyEquivalent:@""];
    
    [organizationItem setRepresentedObject:[repo valueForKey:@"html_url"]];
    
    NSNumber *priv = [repo valueForKey:@"private"];
    NSImage* iconImage = nil;
    
    if ([forked boolValue]) {
        // TODO, set a specific icon
        iconImage = [NSImage imageNamed: @"fork.png"];
        
    } else {
        
        if ([priv boolValue]) {
            iconImage = [NSImage imageNamed: @"bullet_red.png"];
        } else {
            iconImage = [NSImage imageNamed: @"bullet_green.png"];
        }
    }
    
    [iconImage setSize:NSMakeSize(16,16)];
    [organizationItem setImage:iconImage];
    
    [organizationItem setEnabled:YES];
    [organizationItem autorelease];
    
    // ID CARD
    RepositoryDetailsViewController *details = [[RepositoryDetailsViewController alloc] initWithNibName:@"RepositoryDetailsViewController" bundle:nil];
    [details setRepositoryData:repo];
    
    NSMenuItem *popoverMenuItem = [[NSMenuItem alloc] init];
    [popoverMenuItem setView:[details view]];
    [popoverMenuItem autorelease];
    
    NSMenu *foomenu = [[NSMenu alloc] init];    
    [foomenu addItem:popoverMenuItem];
    [organizationItem setSubmenu:foomenu];
    
    [self addItem:organizationItem to:menu top:top];

}

- (void) addOrgRepo:(NSString *)orgName withRepo:(NSDictionary *)repo top:(BOOL)top {
    NSMenu *menu = [self getReposOrgMenu:orgName];
    if (menu) {
        NSMenuItem *repoItem = [self createMenuItemForOrgRepo:repo];
        [self addItem:repoItem to:menu top:top];

    } else {
        //NSLog(@"Repo menu not found");
    }
}

- (void) addFollower:(NSDictionary *)user {
    NSMenu *menu = [self getFollowersMenu];
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[user valueForKey:@"login"] action:@selector(followerPressed:) keyEquivalent:@""];
    [item setRepresentedObject:[user valueForKey:@"login"]];
    NSImage* iconImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[user valueForKey:@"avatar_url"]]];
    [iconImage setSize:NSMakeSize(18,18)];
    [item setImage:iconImage];
    [item autorelease];
    
    // ID CARD
    /*
    UserDetailsViewController *details = [[UserDetailsViewController alloc] initWithNibName:@"UserDetailsViewController" bundle:nil];
    [details setUserData:user];
    
    NSMenuItem *popoverMenuItem = [[NSMenuItem alloc] init];
    [popoverMenuItem setView:[details view]];
    [popoverMenuItem autorelease];
    
    NSMenu *foomenu = [[NSMenu alloc] init];    
    [foomenu addItem:popoverMenuItem];
    [item setSubmenu:foomenu];
    */
    
    [self addItem:item to:menu top:FALSE];
}

- (void) addFollowing:(NSDictionary *)user {
    NSMenu *menu = [self getFollowingMenu];
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[user valueForKey:@"login"] action:@selector(followingPressed:) keyEquivalent:@""];
    [item setRepresentedObject:[user valueForKey:@"login"]];
    NSImage* iconImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[user valueForKey:@"avatar_url"]]];
    [iconImage setSize:NSMakeSize(16,16)];
    [item setImage:iconImage];
    [item setEnabled:YES];
    [item autorelease];
    
    // ID CARD
    /*
    UserDetailsViewController *details = [[UserDetailsViewController alloc] initWithNibName:@"UserDetailsViewController" bundle:nil];
    [details setUserData:user];
    
    NSMenuItem *popoverMenuItem = [[NSMenuItem alloc] init];
    [popoverMenuItem setView:[details view]];
    [popoverMenuItem autorelease];
    
    NSMenu *foomenu = [[NSMenu alloc] init];    
    [foomenu addItem:popoverMenuItem];
    [item setSubmenu:foomenu];
     */

    [self addItem:item to:menu top:FALSE];
}

- (void) addWatched:(NSDictionary *)repo {
    NSMenu *menu = [self getWatchingMenu];
    
    NSArray *owner = [repo valueForKey:@"owner"];
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@/%@", [owner valueForKey:@"login"], [repo valueForKey:@"name"]] action:@selector(openURL:) keyEquivalent:@""];
    [item setRepresentedObject:[repo valueForKey:@"html_url"]];
    
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
    
    // ID Card
    RepositoryDetailsViewController *details = [[RepositoryDetailsViewController alloc] initWithNibName:@"RepositoryDetailsViewController" bundle:nil];
    [details setRepositoryData:repo];
    
    NSMenuItem *popoverMenuItem = [[NSMenuItem alloc] init];
    [popoverMenuItem setView:[details view]];
    [popoverMenuItem autorelease];
    
    NSMenu *foomenu = [[NSMenu alloc] init];    
    [foomenu addItem:popoverMenuItem];
    [item setSubmenu:foomenu];
    
    [self addItem:item to:menu top:FALSE];
}

- (void) addEvent:(NSDictionary *)event top:(BOOL)top {
    /*NSMenuItem *eventItem = [[NSMenuItem alloc] initWithTitle:[event valueForKey:@"message"] action:@selector(eventPressed:) keyEquivalent:@""];
    
    [eventItem setRepresentedObject:[event valueForKey:@"url"]];
    [eventItem setEnabled:YES];
    [eventItem autorelease];
    */
    
  
    NSMenuItem *eventItem = [[NSMenuItem alloc] initWithTitle:[event valueForKey:@"message"] action:@selector(eventPressed:) keyEquivalent:@""];
    EventMenuItemController *controller = [[EventMenuItemController alloc] initWithNibName:@"EventMenuItemController" bundle:nil];
    [controller setEvent:event];
    [eventItem setView:[controller view]];
    
    [eventItem setAction:@selector(eventPressed:)];
    [eventItem setTarget:self];
    [eventItem setRepresentedObject:[event valueForKey:@"url"]];
    [eventItem setEnabled:YES];
    [eventItem setState:NSMixedState];
    [eventItem autorelease];
    

    NSInteger eventMenuSize = 20;
    if ([eventsMenu numberOfItems] >= eventMenuSize) {
        [eventsMenu removeItemAtIndex:eventMenuSize - 1];
    }
        
    [self addItem:eventItem to:eventsMenu top:top];    
}

- (void) addPull:(NSDictionary *)pull {
    //NSMenu *menu = [self getPullsMenu];

}

# pragma mark - Actions on pressed menu items

- (void) openPull:(id)sender {
    id selectedItem = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", selectedItem]]];    
}

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
    NSString *url = [selectedItem valueForKey:@"html_url"];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
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

- (void) eventPressed:(id) sender {
    NSLog(@"Event pressed");
    id selectedItem = [sender representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", selectedItem]]];            
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
    // NSLog(@"Delete entries from menu %@", [menu title]);
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

- (void) deleteItemWithName:(NSString*)name fromMenu:(NSMenu*)menu {
    NSMenuItem *item = [menu itemWithTitle:name];
    if (item) {
        [menu removeItem:item];
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

#pragma mark - private

- (NSMenuItem*) createMenuItemForOrgRepo:(NSDictionary*) repo {
    
    NSMenuItem *organizationRepoItem = [[NSMenuItem alloc] initWithTitle:[repo valueForKey:@"name"] action:@selector(repoPressed:) keyEquivalent:@""];
    [organizationRepoItem setToolTip: [NSString stringWithFormat:@"Description : %@, Forks: %@, Watchers: %@", [repo valueForKey:@"description"], [repo valueForKey:@"forks"], [repo valueForKey:@"watchers"]]];
    
    //[organizationRepoItem setToolTip: @""];
    [organizationRepoItem setRepresentedObject:[repo valueForKey:@"html_url"]];
    
    NSNumber *priv = [repo valueForKey:@"private"];
    NSImage* iconImage = nil;
    
    NSNumber *forked = [repo valueForKey:@"fork"];
    if ([forked boolValue]) {
        // TODO, set a specific icon
        iconImage = [NSImage imageNamed: @"fork.png"];
    } else {
        if ([priv boolValue]) {
            iconImage = [NSImage imageNamed: @"bullet_red.png"];
        } else {
            iconImage = [NSImage imageNamed: @"bullet_green.png"];
        }
    }
    [iconImage setSize:NSMakeSize(16,16)];
    [organizationRepoItem setImage:iconImage];
    
    [organizationRepoItem setEnabled:YES];
    [organizationRepoItem autorelease];
    
    // ID Card
    /*
    RepositoryDetailsViewController *details = [[RepositoryDetailsViewController alloc] initWithNibName:@"RepositoryDetailsViewController" bundle:nil];
    [details setRepositoryData:repo];
    
    NSMenuItem *popoverMenuItem = [[NSMenuItem alloc] init];
    [popoverMenuItem setView:[details view]];
    [popoverMenuItem autorelease];
    
    NSMenu *foomenu = [[NSMenu alloc] init];    
    [foomenu addItem:popoverMenuItem];
    [organizationRepoItem setSubmenu:foomenu];
     */
    
    return organizationRepoItem;
}

- (NSMenu*) getIssuesMenu {
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Issues"];
    return [menuItem submenu];
}

- (NSMenu*) getOrgsMenu {
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Organizations"];
    return [menuItem submenu];
}

- (NSMenu*) getReposOrgMenu:(NSString*) orgName {
    NSMenu* orgs = [self getOrgsMenu];
    NSMenuItem *menuItem = [orgs itemWithTitle:orgName];
    return [menuItem submenu];
}

- (NSMenu*) getReposMenu {
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Repositories"];
    return [menuItem submenu];
   
}

- (NSMenu*) getFollowingMenu {
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Users"];
    NSMenu *tmp = [menuItem submenu];
    NSMenuItem *followersItem = [tmp itemWithTitle:@"Following"];
    return [followersItem submenu];
}

- (NSMenu*) getFollowersMenu {
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Users"];
    NSMenu *tmp = [menuItem submenu];
    NSMenuItem *followersItem = [tmp itemWithTitle:@"Followers"];
    return [followersItem submenu];
}

- (NSMenu*) getPullsMenu {
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Pull Requests"];
    return [menuItem submenu];
}

- (NSMenu*) getGistsMenu {
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Gists"];
    return [menuItem submenu];
}


- (NSMenu*) getWatchingMenu {
    NSMenuItem *menuItem = [statusMenu itemWithTitle:@"Watching"];
    return [menuItem submenu];
}

#pragma mark - UI update

// initial method to be called by the ones which want to update the menus
- (void) addItem:(NSMenuItem *)item to:(NSMenu*)menu top:(Boolean)top {
    if (top) {
        //NSInteger deleteItemLimit = [menu indexOfItemWithTitle:@"deletelimit"];
        //[self addItemOnMainUIThread:item to:menu at:(deleteItemLimit + 1)];
        [self addTopItemOnMainUIThread:item to:menu];
    } else {
        [self addItemOnMainUIThread:item to:menu];
    }
}

// will add in the main thread
- (void) addItemOnMainUIThread:(NSMenuItem *)item to:(NSMenu*)menu {
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:item, menu, nil] forKeys:[NSArray arrayWithObjects:@"item", @"menu", nil]];
    [self performSelectorOnMainThread:@selector(addItem:) withObject:dict waitUntilDone:NO];
}

- (void) addTopItemOnMainUIThread:(NSMenuItem *)item to:(NSMenu*)menu {
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:item, menu, nil] forKeys:[NSArray arrayWithObjects:@"item", @"menu", nil]];
    [self performSelectorOnMainThread:@selector(addTopItem:) withObject:dict waitUntilDone:NO];
}

// will add in the main thread
- (void) addItemOnMainUIThread:(NSMenuItem *)item to:(NSMenu*)menu at:(NSInteger)index {
    NSDictionary *dict = nil;
    
    NSString *string = [NSString stringWithFormat:@"%d", index];
    NSLog(@"String %@", string);
        
    if (index && index >=0) {
        dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:item, menu, string, nil] forKeys:[NSArray arrayWithObjects:@"item", @"menu", "index", nil]];
    } else {
    }
    
    [self performSelectorOnMainThread:@selector(addItemAt:) withObject:dict waitUntilDone:NO];
}

// do it in the main thread
- (void) addItem:(NSDictionary *)dict {
    NSMenu *menu = [dict valueForKey:@"menu"];
    NSMenuItem *item = [dict valueForKey:@"item"];
    
    if (menu && item) {
        [menu addItem:item];
    }
}

// do it in the main thread!
- (void) addItemAt:(NSDictionary *)dict {
    NSMenu *menu = [dict valueForKey:@"menu"];
    NSMenuItem *item = [dict valueForKey:@"item"];
    NSString *index = [dict valueForKey:@"index"];
    
    if (menu && item && index) {
        [menu insertItem:item atIndex:[index doubleValue]];
    }
}

- (void) addTopItem:(NSDictionary *)dict {
    NSMenu *menu = [dict valueForKey:@"menu"];
    NSMenuItem *item = [dict valueForKey:@"item"];
    
    if (menu && item) {
        NSInteger deleteItemLimit = [menu indexOfItemWithTitle:@"deletelimit"];
        [menu insertItem:item atIndex:(deleteItemLimit + 1)];
    }
}

@end
