//
//  GithubOAuthClient.m
//  QuickHub
//
//  Created by Christophe Hamerling on 01/12/11.
//  Copyright 2011 christophehamerling.com. All rights reserved.
//

#import "GithubOAuthClient.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "Preferences.h"
#import "Context.h"

@interface GithubOAuthClient (Private)
- (BOOL) checkResponseOK:(ASIHTTPRequest*) request;
- (void) updateRemaining:(ASIHTTPRequest*) request;
@end

@implementation GithubOAuthClient

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)updateRemaining:(ASIHTTPRequest *)request {
    // TODO : put it in a HTTP wrapper
    if (request) {
        NSString *r = [[request responseHeaders] valueForKey:@"X-RateLimit-Remaining"];
        [[Context sharedInstance] setRemainingCalls:r];
    }
}

- (NSString *)getOAuthURL:(NSString *)path {
    NSString *result = nil;
    if (path) {
        result = [NSString stringWithFormat:@"https://api.github.com/%@?access_token=%@", path, [[Preferences sharedInstance] oauthToken]];
    }
    NSLog(@"URL to call = '%@'", result);
    return result;
}

#pragma mark - READ API Impl

- (NSDictionary*) loadGHData:(id)sender {
    // TODO
    return nil;    
}

- (NSDictionary*) loadUser:(id) sender {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:@"user"]]];
    [request setDelegate:self];
    [request startSynchronous];
    NSDictionary *result = [[request responseString] objectFromJSONString];
    // DO not release the request, it cause failures on the threads...
    //[request release];
    return result;
}

- (NSDictionary*) loadIssues:(id) sender {
    NSLog(@"Loading Issues...");
    
    // try to get my issues with ASIHTTP and JSONKIT...
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:@"issues"]]];
    [request setDelegate:self];
    [request startSynchronous];
    NSDictionary *result = [[request responseString] objectFromJSONString];
    // DO not release the request, it cause failures on the threads...
    //[request release];
    return result;
}

- (NSDictionary*) loadGists:(id) sender {
    NSLog(@"Loaging Gists...");
    // get gists
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:@"gists"]]];
    [request setDelegate:self];
    [request startSynchronous];
    
    NSDictionary *result = [[request responseString] objectFromJSONString];
    // DO not release the request, it cause failures on the threads...
    //[request release];
    return result;
}

- (NSDictionary*) loadOrganizations:(id) sender {
    NSLog(@"Loading Organizations...");
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:@"user/orgs"]]];
    [request setDelegate:self];
    [request startSynchronous];
    NSDictionary *result = [[request responseString] objectFromJSONString];
    // DO not release the request, it cause failures on the threads...
    //[request release];
    return result;
}

- (NSDictionary *)getReposForOrganization:(NSString *)name {
    NSLog(@"Loading Repos for Organization %@...", name);

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:[NSString stringWithFormat:@"orgs/%@/repos", name]]]];
    [request setDelegate:self];
    [request startSynchronous];
    
    return [[request responseString] objectFromJSONString];
}

- (NSDictionary*) loadRepos:(id) sender {
    NSLog(@"Loading Repositories...");
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:@"user/repos"]]];
    [request setDelegate:self];
    [request startSynchronous];
    NSDictionary *result = [[request responseString] objectFromJSONString];
    // DO not release the request, it cause failures on the threads...
    //[request release];
    return result;
}

- (NSDictionary*)loadPulls:(id)sender {
    NSLog(@"Loading Pulls for repositories...");
    NSMutableSet *repos = [self getRepositories:nil];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    for (NSString *repoName in repos) {
        NSDictionary *pulls = [self getPullsForRepository:repoName];
        if (pulls != nil && [pulls valueForKey:@"url"]) {
            [dict setValue:pulls forKey:repoName];
        }
    }
    
    return dict;   
}

- (NSMutableSet *)getRepositories:(id)sender {
    NSLog(@"Getting Repositories...");
    NSMutableSet *result = [[NSMutableSet alloc]init];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:@"user/repos"]]];    
    [request setDelegate:self];
    [request startSynchronous];
    [self updateRemaining:request];
    
    NSDictionary* dict = [[request responseString] objectFromJSONString];
    
    for (NSArray *repo in dict) {
        [result addObject:[repo valueForKey:@"name"]];
    }  
    return result;
}

- (NSDictionary *)getPullsForRepository:(NSString *)name {
    NSLog(@"Get pulls for repository %@", name);
    NSString *userName = [[Preferences sharedInstance] login];    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:[NSString stringWithFormat:@"repos/%@/%@/pulls", userName, name]]]];
    [request startSynchronous];
    [self updateRemaining:request];
    int status = [request responseStatusCode];
    NSString *response = [[request responseString]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // an empty response is a JSON string like '[]' (without quotes)...
    if (status == 200 && [response length] > 2) {
        return [[request responseString] objectFromJSONString];
    }
    return nil;
}

- (NSDictionary *) loadFollowers:(id) sender {
    NSLog(@"Loading Followers...");
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:@"user/followers"]]];
    [request setDelegate:self];
    [request startSynchronous];
    NSDictionary *result = [[request responseString] objectFromJSONString];
    // DO not release the request, it cause failures on the threads...
    //[request release];
    return result;
}

- (NSDictionary *) loadFollowings:(id) sender {
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:@"user/following"]]];
    [request setDelegate:self];
    [request startSynchronous];
    NSDictionary *result = [[request responseString] objectFromJSONString];
    // DO not release the request, it cause failures on the threads...
    //[request release];
    return result;
}

- (NSDictionary *) loadWatchedRepos:(id) sender {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:@"user/watched"]]];
    [request setDelegate:self];
    [request startSynchronous];   
    NSDictionary *result = [[request responseString] objectFromJSONString];
    // DO not release the request, it cause failures on the threads...
    //[request release];
    return result;
}

#pragma mark - WRITE API Impl
# pragma mark - Write
- (NSString*) createGist:(NSString*) content withDescription:(NSString*) description andFileName:(NSString *) fileName isPublic:(BOOL) pub {
    NSString *gistId = nil;
    
    NSString *payload = [NSString stringWithFormat:@"{\"description\": \"%@\", \"public\": %@, \"files\":{\"%@\": { \"content\": %@ }}}", description, pub ? @"true" : @"false", fileName, [content JSONString]];
    
    NSLog(@"Outgoing Payload : %@", payload);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:@"gists"]]];
    [request appendPostData:[payload dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    [self updateRemaining:request];
    
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSLog(@"Gist creation result %@", response);
        
        NSDictionary* result = [response objectFromJSONString];
        gistId = [result objectForKey:@"id"];
        NSString *gistURL = [result objectForKey:@"html_url"];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:gistId, gistURL, nil] forKeys:[NSArray arrayWithObjects:@"id", @"url", nil]];
        
    } else {
        NSLog(@"Gist creation error %@", error);
    }
    return gistId;
}

- (NSString*) createRepository:(NSString*) name description:(NSString*)desc homepage:(NSString*) home wiki:(BOOL)wk issues:(BOOL)is downloads:(BOOL)dl isPrivate:(BOOL)privacy {
    NSString *location = nil;
    
    NSString *payload = [NSString stringWithFormat:@"{\"name\": \"%@\", \"description\": \"%@\", \"homepage\": \"%@\", \"public\": %@, \"has_issues\": %@, \"has_wiki\": %@, \"has_downloads\": %@}", name, desc, home, privacy ? @"false" : @"true", wk ? @"true" : @"false", is? @"true" : @"false", dl? @"true" : @"false"];
    
    NSLog(@"Outgoing Payload : %@", payload);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:@"user/repos"]]];
    [request appendPostData:[payload dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    [self updateRemaining:request];
    
    NSError *error = [request error];
    if (!error) {
        int status = [request responseStatusCode];
        NSString *response = [request responseString];
        if (status == 201) {
            NSLog(@"Repo creation result %@", response);
            NSDictionary* result = [response objectFromJSONString];
            location = [result objectForKey:@"html_url"];
        } else {
            NSLog(@"Repo creation error, bad return code %d", status);
            NSLog(@"Returned message is %@", response);
        }
    } else {
        NSLog(@"Repo creation error %@", error);
    }
    return location;
}

- (NSDictionary *) getGist:(NSString*)gistId {
    NSDictionary *result = nil;
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:[NSString stringWithFormat:@"gists/%@", gistId]]]];
    [request startSynchronous];
    [self updateRemaining:request];
    
    NSError *error = [request error];
    if (!error) {
        int status = [request responseStatusCode];
        NSString *response = [request responseString];
        if (status == 200) {
            NSLog(@"Get gist result %@", response);
            result = [response objectFromJSONString];
        } else {
        }
    } else {
    
    }
    return result;
}

- (BOOL) checkCredentials:(id) sender {
    NSLog(@"Checking credentials...");
    
    Preferences *preferences = [Preferences sharedInstance];
    NSString *oauth = [preferences oauthToken];
    
    if (!oauth || [oauth length] == 0) {
        return NO;
    }
    
    NSDictionary *dictionary = [self loadUser:nil];
    if (dictionary) {
        NSString *login = [dictionary valueForKey:@"login"];
        if ([login length] == 0) {
            return NO;
        }
    }
    
    return YES;
}


@end
