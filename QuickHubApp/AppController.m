//
//  AppController.m
//  QuickHubApp
//
// The main controller of the application...
//
//  Created by Christophe Hamerling on 25/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "NSData+Base64.h"

@interface AppController (Private)
    - (void)loadGists;
    - (void)loadRepos;
    - (void)loadOrgs;
    - (void)loadIssues;
@end

@implementation AppController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        githubController = [[GitHubController alloc]init];
    }
    
    return self;
}

- (void)awakeFromNib {
    // register listeners to start and stop polling...
    // TODO
    NSLog(@"TODO : register listeners to start and stop polling");
}

#pragma mark - Github Actions

- (void) loadAll:(id)sender {
    if (!githubPolling) {
        NSLog(@"Load all and start polling things");
        [githubController loadGHData:nil];
        
        gistTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(loadGists:) userInfo:nil repeats:YES];
        repositoryTimer = [NSTimer scheduledTimerWithTimeInterval:130 target:self selector:@selector(loadRepos:) userInfo:nil repeats:YES];
        organizationTimer = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(loadOrgs:) userInfo:nil repeats:YES];
        issueTimer = [NSTimer scheduledTimerWithTimeInterval:125 target:self selector:@selector(loadIssues:) userInfo:nil repeats:YES];
        
        // add the timer to the common run loop mode so that it does not freezes when the user clicks on menu
        // cf http://stackoverflow.com/questions/4622684/nsrunloop-freezes-with-nstimer-and-any-input
        [[NSRunLoop currentRunLoop] addTimer:gistTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:repositoryTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:organizationTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] addTimer:issueTimer forMode:NSRunLoopCommonModes];
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
    }
    githubPolling = NO;
}

- (void)loadGists {
    [githubController loadGists:nil];
}

- (void)loadRepos {
    [githubController loadRepos:nil];
}

- (void)loadOrgs {
    [githubController loadOrganizations:nil];
}

- (void)loadIssues {
    [githubController loadIssues:nil];
}

#pragma mark - misc
- (BOOL)checkInternetConnection {
    NSHost *host = [NSHost hostWithName:@"www.google.fr"];
    NSLog(@"%@", host);
    return YES;
}

@end
