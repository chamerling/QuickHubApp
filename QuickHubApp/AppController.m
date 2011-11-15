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
        
        hostReach = [[Reachability reachabilityWithHostName: @"api.github.com"] retain];
        [hostReach startNotifier];

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
        
        // data is no more loaded on first call, the timers are initialized with a fire date which is close to the creation.
        //[githubController loadGHData:nil];

        gistTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(pollGists:) userInfo:nil repeats:YES];
        //[gistTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:0.1]];
        
        repositoryTimer = [NSTimer scheduledTimerWithTimeInterval:130 target:self selector:@selector(pollRepos:) userInfo:nil repeats:YES];
        //[repositoryTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:0.2]];

        organizationTimer = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(pollOrgs:) userInfo:nil repeats:YES];
        //[organizationTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:0.3]];

        issueTimer = [NSTimer scheduledTimerWithTimeInterval:125 target:self selector:@selector(pollIssues:) userInfo:nil repeats:YES];
        //[issueTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:0.4]];
        
        followTimer = [NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(pollFollow:) userInfo:nil repeats:YES];
        //[followTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:0.5]];
        
        watchingTimer = [NSTimer scheduledTimerWithTimeInterval:1800 target:self selector:@selector(pollWatching:) userInfo:nil repeats:YES];
        //[watchingTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:0.6]];

        // add the timer to the common run loop mode so that it does not freezes when the user clicks on menu
        // cf http://stackoverflow.com/questions/4622684/nsrunloop-freezes-with-nstimer-and-any-input
        [[NSRunLoop currentRunLoop] addTimer:gistTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:repositoryTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:organizationTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:issueTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:followTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:watchingTimer forMode:NSRunLoopCommonModes];
        
        githubPolling = YES;
        
        [gistTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:1]];
        [repositoryTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:2]];
        [organizationTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:3]];
        [issueTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:4]];
        [followTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:6]];
        [watchingTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:7]];

        
        // fire all now!
        
    } else {
        NSLog(@"Can not start all since we are already polling...");
    }
}

- (void) stopAll:(id)sender {
    NSLog(@"Stop polling all GH stuff...");
    if (githubPolling) {
        [gistTimer invalidate];
        [repositoryTimer invalidate];
        [organizationTimer invalidate];
        [issueTimer invalidate];
        [followTimer invalidate];
        [watchingTimer invalidate];
    }
    githubPolling = NO;
    NSLog(@"Stopped!");
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
    Reachability* reach = [notice object];
    
    if (reach == internetReachable) {
        NSLog(@"Internet reachablity changed!");
   
        NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
        switch (internetStatus)
    
        {
            case NotReachable:
            {
                NSLog(@"The internet is down.");
            
                // if already polling github, stop all background task
                [self stopAll:nil];
            
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
    } else if (reach == hostReach) {
        NSLog(@"Host reachablity changed!");
    
        NetworkStatus hostStatus = [hostReach currentReachabilityStatus];
        if (hostStatus == NotReachable) {
            NSLog(@"The host is not reachable");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HostDown" object:nil];

        } else {
            NSLog(@"The host is reachable");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HostUp" object:nil];
            [self loadAll:nil];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
