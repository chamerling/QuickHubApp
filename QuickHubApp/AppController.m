//
//  AppController.m
//  QuickHubApp
//
// The main controller of the application...
//
//  Created by Christophe Hamerling on 25/10/11.
//  Copyright 2011 chamerling.org. All rights reserved.
//

#import "AppController.h"
#import "NSData+Base64.h"
#import "ASIHTTPRequest.h"
#import "QHConstants.h"

@implementation AppController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        githubController = [[GitHubController alloc]init];
        
        
        //reachability
        // check for internet connection
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
        
        internetReachable = [[Reachability reachabilityForInternetConnection] retain];
        [internetReachable startNotifier];
    }
    return self;
}

- (void)awakeFromNib {
    // register listeners to start and stop polling...
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loadAll:)
                                                 name:POLLING_START
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(stopAll:)
                                                 name:POLLING_STOP
                                               object:nil];
    
    // load gists when a gist is created!
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(pollGists:)
                                                 name:GITHUB_NOTIFICATION_GIST_CREATED
                                               object:nil];

}

#pragma mark - Github Actions

- (void) loadAll:(id)sender {
    if (!githubPolling) {
        NSLog(@"Load all and start polling things");
        [githubController loadGHData:nil];
        
        gistTimer = [NSTimer scheduledTimerWithTimeInterval:100 target:self selector:@selector(pollGists:) userInfo:nil repeats:YES];
        repositoryTimer = [NSTimer scheduledTimerWithTimeInterval:130 target:self selector:@selector(pollRepos:) userInfo:nil repeats:YES];
        organizationTimer = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(pollOrgs:) userInfo:nil repeats:YES];
        issueTimer = [NSTimer scheduledTimerWithTimeInterval:125 target:self selector:@selector(pollIssues:) userInfo:nil repeats:YES];
        followTimer = [NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(pollFollow:) userInfo:nil repeats:YES];
        watchingTimer = [NSTimer scheduledTimerWithTimeInterval:1800 target:self selector:@selector(pollWatching:) userInfo:nil repeats:YES];

        // add the timer to the common run loop mode so that it does not freezes when the user clicks on menu
        // cf http://stackoverflow.com/questions/4622684/nsrunloop-freezes-with-nstimer-and-any-input
        [[NSRunLoop currentRunLoop] addTimer:gistTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:repositoryTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:organizationTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:issueTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:followTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:watchingTimer forMode:NSRunLoopCommonModes];
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
        [followTimer invalidate];
        [watchingTimer invalidate];
    }
    githubPolling = NO;
    NSLog(@"Stopped");
}

- (void)pollGists:(id) sender {
    if (githubPolling) {
        [githubController loadGists:nil];
    }
}

- (void)pollRepos:(id) sender {
    if (githubPolling) {
        [githubController loadRepos:nil];
    }
}

- (void)pollOrgs:(id) sender {
    if (githubPolling) {
        [githubController loadOrganizations:nil];
    }
}

- (void)pollIssues:(id) sender {
    if (githubPolling) {
        [githubController loadIssues:nil];
    }
}

- (void) pollFollow:(id) sender {
    if (githubPolling) {
        [githubController loadFollowers:nil];
        [githubController loadFollowings:nil];
    }
}

- (void) pollWatching:(id) sender {
    if (githubPolling) {
        [githubController loadWatchedRepos:nil];
    }  
}

#pragma mark - reachability
- (void) checkNetworkStatus:(NSNotification *)notice {
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InternetDown" object:nil];
            break;
            
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InternetUp" object:nil];
            break;
            
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InternetUp" object:nil];
            break;            
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
