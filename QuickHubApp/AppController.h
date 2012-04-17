//
//  AppController.h
//  QuickHubApp
//
//  Created by Christophe Hamerling on 25/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequest.h"
#import "Reachability.h"

#import "Preferences.h"
#import "GithubOAuthClient.h"
#import "MenuController.h"
#import "EventsManager.h"

@class Reachability;
@interface AppController : NSObject {
    
    GithubOAuthClient *githubController;
    EventsManager *eventsManager;
    IBOutlet MenuController *menuController;
    
    // update timers
    NSTimer* gistTimer;
    NSTimer* issueTimer;
    NSTimer* organizationTimer;
    NSTimer* repositoryTimer;
    NSTimer* followTimer;
    NSTimer* watchingTimer;
    NSTimer* pullTimer;
    NSTimer* eventTimer;
    
    // misc.
    BOOL githubPolling;
    
    // Reachability
    Reachability* hostReach;
    Reachability* internetReachable;
    
}

- (void) pollIssues:(id) sender;
- (void) pollGists:(id) sender;
- (void) pollOrgs:(id) sender;
- (void) pollRepos:(id) sender;
- (void) pollFollow:(id) sender;
- (void) pollWatching:(id) sender;
- (void) pollPulls:(id) sender;
- (void) pollEvents:(id) sender;

//- (void) pollPulls:(id) sender;

- (void) loadAll:(id)sender;
- (void) stopAll:(id)sender;

- (void) checkNetworkStatus:(NSNotification *)notice;

@end
