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
        
        gistTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(pollGists:) userInfo:nil repeats:YES];
        repositoryTimer = [NSTimer scheduledTimerWithTimeInterval:130 target:self selector:@selector(pollRepos:) userInfo:nil repeats:YES];
        organizationTimer = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(pollOrgs:) userInfo:nil repeats:YES];
        issueTimer = [NSTimer scheduledTimerWithTimeInterval:125 target:self selector:@selector(pollIssues:) userInfo:nil repeats:YES];
        
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

- (void)pollGists:(id) sender {
    [githubController loadGists:nil];
}

- (void)pollRepos:(id) sender {
    [githubController loadRepos:nil];
}

- (void)pollOrgs:(id) sender {
    [githubController loadOrganizations:nil];
}

- (void)pollIssues:(id) sender {
    [githubController loadIssues:nil];
}

#pragma mark - misc
- (BOOL)checkInternetConnection {
    NSHost *host = [NSHost hostWithName:@"www.google.fr"];
    NSLog(@"%@", host);
    return YES;
}

@end
