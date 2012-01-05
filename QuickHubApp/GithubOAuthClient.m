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
    //NSLog(@"URL to call = '%@'", result);
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
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:@"issues"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
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
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:@"gists"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setDelegate:self];
    [request startSynchronous];
    
    NSDictionary *result = [[request responseString] objectFromJSONString];
    // DO not release the request, it cause failures on the threads...
    //[request release];
    return result;
}

- (NSDictionary*) loadOrganizations:(id) sender {
    NSLog(@"Loading Organizations...");
    
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:@"user/orgs"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setDelegate:self];
    [request startSynchronous];
    NSDictionary *result = [[request responseString] objectFromJSONString];
    // DO not release the request, it cause failures on the threads...
    //[request release];
    return result;
}

- (NSDictionary *)getReposForOrganization:(NSString *)name {
    NSLog(@"Loading Repos for Organization %@...", name);

    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:[NSString stringWithFormat:@"orgs/%@/repos", name]]];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setDelegate:self];
    [request startSynchronous];
    
    return [[request responseString] objectFromJSONString];
}

- (NSDictionary*) loadRepos:(id) sender {
    NSLog(@"Loading Repositories...");
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:@"user/repos"]];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
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
    NSLog(@"Got pulls!");
    
    return dict;   
}

- (NSMutableSet *)getRepositories:(id)sender {
    NSLog(@"Getting Repositories...");
    NSMutableSet *result = [[NSMutableSet alloc]init];
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:@"user/repos"]];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];    
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
    //NSLog(@"Get pulls for repository %@", name);
    NSString *userName = [[Preferences sharedInstance] login];
    
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:[NSString stringWithFormat:@"repos/%@/%@/pulls", userName, name]]];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
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
    
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:@"user/followers"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setDelegate:self];
    [request startSynchronous];
    NSDictionary *result = [[request responseString] objectFromJSONString];
    // DO not release the request, it cause failures on the threads...
    //[request release];
    return result;
}

- (NSDictionary *) loadFollowings:(id) sender {
    
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:@"user/following"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setDelegate:self];
    [request startSynchronous];
    NSDictionary *result = [[request responseString] objectFromJSONString];
    // DO not release the request, it cause failures on the threads...
    //[request release];
    return result;
}

- (NSDictionary *) loadWatchedRepos:(id) sender {
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:@"user/watched"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setDelegate:self];
    [request startSynchronous];   
    NSDictionary *result = [[request responseString] objectFromJSONString];
    // DO not release the request, it cause failures on the threads...
    //[request release];
    return result;
}

// Note : this is not available with oauth!
- (NSDictionary *) getAuthorizations:(id) sender {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:@"authorizations"]]];
    [request setDelegate:self];
    [request startSynchronous];   
    NSDictionary *result = [[request responseString] objectFromJSONString];
    // DO not release the request, it cause failures on the threads...
    //[request release];
    return result;
}

#pragma mark - WRITE API Impl
- (NSDictionary*) createGist:(NSString*) content withDescription:(NSString*) description andFileName:(NSString *) fileName isPublic:(BOOL) pub {
    
    NSString *payload = [NSString stringWithFormat:@"{\"description\": \"%@\", \"public\": %@, \"files\":{\"%@\": { \"content\": %@ }}}", description, pub ? @"true" : @"false", fileName, [content JSONString]];
    
    NSLog(@"Outgoing Payload : %@", payload);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:@"gists"]]];
    [request appendPostData:[payload dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    [self updateRemaining:request];
    
    NSError *error = [request error];
    if (!error && [request responseStatusCode] == 201) {
        NSString *response = [request responseString];
        return [response objectFromJSONString];        
    } else {
        NSLog(@"Gist creation error %@", error);
    }
    return nil;
}

- (NSDictionary *) createIssue:(NSString *) repository user:(NSString *)user title:(NSString *)title boby:(NSString *)body assignee:(NSString*)assignee milestone:(NSString *) milestone labels:(NSSet*)labels {
    
    NSDictionary *result = nil;
    NSString *payload = nil;
    if (assignee) {
        payload = [NSString stringWithFormat:@"{\"title\": %@, \"body\": %@, \"assignee\": \"%@\"}", [title JSONString], [body JSONString], assignee];    
    } else {
        payload = [NSString stringWithFormat:@"{\"title\": %@, \"body\": %@}", [title JSONString], [body JSONString]];
    }
        
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:[NSString stringWithFormat:@"repos/%@/%@/issues", user, repository]]]];
    [request appendPostData:[payload dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    [self updateRemaining:request];
    
    NSError *error = [request error];
    if (!error) {
        int status = [request responseStatusCode];
        NSString *response = [request responseString];
        if (status == 201) {
            result = [response objectFromJSONString];
        } else {
            NSLog(@"Issue creation error, bad return code %d", status);
        }
    } else {
        NSLog(@"Issue creation error %@", error);
    }
    return result;
}

- (NSDictionary*) createRepository:(NSString*) name description:(NSString*)desc homepage:(NSString*) home wiki:(BOOL)wk issues:(BOOL)is downloads:(BOOL)dl isPrivate:(BOOL)privacy {
    NSDictionary *result = nil;
    
    NSString *payload = [NSString stringWithFormat:@"{\"name\": \"%@\", \"description\": \"%@\", \"homepage\": \"%@\", \"public\": %@, \"has_issues\": %@, \"has_wiki\": %@, \"has_downloads\": %@}", name, desc, home, privacy ? @"false" : @"true", is ? @"true" : @"false", wk? @"true" : @"false", dl? @"true" : @"false"];
        
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:@"user/repos"]]];
    [request appendPostData:[payload dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    [self updateRemaining:request];
    
    NSError *error = [request error];
    if (!error) {
        int status = [request responseStatusCode];
        NSString *response = [request responseString];
        if (status == 201) {
            result = [response objectFromJSONString];
        } else {
            NSLog(@"Repo creation error, bad return code %d", status);
        }
    } else {
        NSLog(@"Repo creation error %@", error);
    }
    return result;
}

- (NSDictionary*) createRepository:(NSString*) name forOrg:(NSString*)orgName description:(NSString*)desc homepage:(NSString*) home wiki:(BOOL)wk issues:(BOOL)is downloads:(BOOL)dl isPrivate:(BOOL)privacy {
    NSDictionary *result = nil;
    
    NSString *payload = [NSString stringWithFormat:@"{\"name\": \"%@\", \"description\": \"%@\", \"homepage\": \"%@\", \"public\": %@, \"has_issues\": %@, \"has_wiki\": %@, \"has_downloads\": %@}", name, desc, home, privacy ? @"false" : @"true", is ? @"true" : @"false", wk? @"true" : @"false", dl? @"true" : @"false"];
        
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:[NSString stringWithFormat:@"orgs/%@/repos", orgName]]]];
    [request appendPostData:[payload dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    [self updateRemaining:request];
    
    NSError *error = [request error];
    if (!error) {
        int status = [request responseStatusCode];
        NSString *response = [request responseString];
        if (status == 201) {
            result = [response objectFromJSONString];
        } else {
            NSLog(@"Repo creation error, bad return code %d", status);
        }
    } else {
        NSLog(@"Repo creation error %@", error);
    }
    return result;
}

#pragma mark - delete
// Note : this is not available with oauth!
- (BOOL)deleteAuth:(NSString *)authId {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:[NSString stringWithFormat:@"authorizations/%@", authId]]]];
    [request setRequestMethod:@"DELETE"];
    [request startSynchronous];
    
    return ([request responseStatusCode] == 204);

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
