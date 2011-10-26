//
//  AppController.h
//  QuickHubApp
//
//  Created by Christophe Hamerling on 25/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Preferences.h"
#import "ASIHTTPRequest.h"
#import "GitHubController.h"

@interface AppController : NSObject {
    
    Preferences *preferences;
    GitHubController *githubController;
    
    // update timers
    NSTimer* gistTimer;
    NSTimer* issueTimer;
    NSTimer* organizationTimer;
    NSTimer* repositoryTimer;
    
    // misc.
    BOOL githubPolling;
    
}

- (void) pollIssues:(id) sender;
- (void) pollGists:(id) sender;
- (void) pollOrgs:(id) sender;
- (void) pollRepos:(id) sender;
//- (void) pollPulls:(id) sender;

- (void) loadAll:(id)sender;
- (void) stopAll:(id)sender;

- (BOOL) checkInternetConnection;

@end
