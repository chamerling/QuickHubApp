//
//  GitHubController.m
//  QuickHubApp
//
//  Created by Christophe Hamerling on 25/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GitHubController.h"
#import "NSData+Base64.h"

@interface GitHubController (Private)
- (BOOL) checkResponseOK:(ASIHTTPRequest*) request;
@end

@implementation GitHubController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        preferences = [Preferences sharedInstance];
    }
    
    return self;
}

- (void)loadGHData:(id)sender {    
    [self loadIssues:nil];
    [self loadGists:nil];
    [self loadOrganizations:nil];
    [self loadRepos:nil];
}

# pragma mark - Load things from github
- (void) loadIssues:(id) sender {
    NSLog(@"Loaging Issues...");
    
    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    // try to get my issues with ASIHTTP and JSONKIT...
    ASIHTTPRequest *issuesRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/issues?per_page=100"]];
    [issuesRequest addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [issuesRequest setDidFinishSelector:@selector(issuesFinished:)];
    [issuesRequest setDidFailSelector:@selector(issuesFailed:)];
    [issuesRequest setDelegate:self];
    [issuesRequest startAsynchronous];
}

- (void) loadGists:(id) sender {
    NSLog(@"Loaging Gists...");
    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    // get gists
    ASIHTTPRequest *gistRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/gists?per_page=100"]];
    [gistRequest addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [gistRequest setDidFinishSelector:@selector(gistFinished:)];
    [gistRequest setDidFailSelector:@selector(gistsFailed:)];
    [gistRequest setDelegate:self];
    [gistRequest startAsynchronous];
}

- (void) loadOrganizations:(id) sender {
    NSLog(@"Loaging Organizations...");
    
    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    ASIHTTPRequest *organizationsRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/user/orgs?per_page=100"]];
    [organizationsRequest addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [organizationsRequest setDidFinishSelector:@selector(organizationsFinished:)];
    [organizationsRequest setDidFailSelector:@selector(organizationsFailed:)];
    [organizationsRequest setDelegate:self];
    [organizationsRequest startAsynchronous];    
}

- (void) loadRepos:(id) sender {
    NSLog(@"Loaging Repositories...");
    
    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    ASIHTTPRequest *repositoriesRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/user/repos?per_page=100"]];
    [repositoriesRequest addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [repositoriesRequest setDidFinishSelector:@selector(reposFinished:)];
    [repositoriesRequest setDidFailSelector:@selector(reposFailed:)];
    [repositoriesRequest setDelegate:self];
    [repositoriesRequest startAsynchronous];
}

- (void)loadPulls:(id)sender {
    NSLog(@"TODO : Loaging Pulls for repository...");
    
    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/repos/:user/:repo/pulls?per_page=100"]];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [request setDidFinishSelector:@selector(pullFinished:)];
    [request setDidFailSelector:@selector(pullFailed:)];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (BOOL) checkCredentials:(id) sender {
    NSLog(@"Checking credentials...");
    
    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/user"]];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [request startSynchronous];
    int status = [request responseStatusCode];
    return status == 200;
}

# pragma mark - HTTP failures
- (void) issuesFailed:(ASIHTTPRequest*)request {
    NSLog(@"Error : %@", [request error]);
    
    // TODO : create an objct with failure context...
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HTTPFailed" 
														object:request 
													  userInfo:nil];   
}

- (void) gistsFailed:(ASIHTTPRequest*)request {
    NSLog(@"Error : %@", [request error]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HTTPFailed" 
														object:request 
													  userInfo:nil];   
}

- (void) organizationsFailed:(ASIHTTPRequest*)request {
    NSLog(@"Error : %@", [request error]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HTTPFailed" 
														object:request 
													  userInfo:nil];   
}

- (void) reposFailed:(ASIHTTPRequest*)request {
    NSLog(@"Error : %@", [request error]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HTTPFailed" 
														object:request 
													  userInfo:nil];   
}

- (void)pullFailed:(ASIHTTPRequest *)request {
    NSLog(@"Error : %@", [request error]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HTTPFailed" 
														object:request 
													  userInfo:nil];       
}

- (void) httpFailed:(ASIHTTPRequest*)request {
    NSLog(@"Error : %@", [request error]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HTTPFailed" 
														object:request 
													  userInfo:nil];           
}

#pragma mark - process HTTP responses

// does nothing but forward the responses to listeners...
// TODO : dispatch on error handlers after response decode and on good data handlers too...
- (void) issuesFinished:(ASIHTTPRequest*)request {
    NSLog(@"Issues Finished...");
    // TODO
    BOOL error = NO;
    
    if (error) {
        
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IssuesNotify" 
                                                            object:request 
                                                            userInfo:nil]; 
    }
}

- (void) gistFinished:(ASIHTTPRequest*)request {
    NSLog(@"Gists Finished...");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GistsNotify" 
														object:request 
													  userInfo:nil];       
}

- (void) organizationsFinished:(ASIHTTPRequest*)request {
    NSLog(@"Organizations Finished...");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OrgsNotify" 
														object:request 
													  userInfo:nil];   
}

- (void) reposFinished:(ASIHTTPRequest*)request {
    NSLog(@"Repositories Finished...");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReposNotify" 
														object:request 
													  userInfo:nil];       
}

- (void)pullFinished:(ASIHTTPRequest *)request {
    NSLog(@"Pulls Finished...");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PullsNotify" 
														object:request 
													  userInfo:nil];       
}

@end
