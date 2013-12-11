// (The MIT License)
//
// Copyright (c) 2013 Christophe Hamerling <christophe.hamerling@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// 'Software'), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "GitHubController.h"
#import "NSData+Base64.h"
#import "QHConstants.h"
#import "Context.h"
#import "JSONKit.h"

@interface GitHubController (Private)
- (BOOL) checkResponseOK:(ASIHTTPRequest*) request;
- (NSMutableSet*) getRepositories:(id) sender;
- (NSDictionary*) getPullsForRepository:(NSString *)name;
- (void) updateRemaining:(ASIHTTPRequest*) request;
@end


@implementation GitHubController

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"Initializing GHController");
        preferences = [Preferences sharedInstance];
    }
    
    return self;
}

- (void)loadGHData:(id)sender {    
    [self loadIssues:nil];
    [self loadGists:nil];
    [self loadOrganizations:nil];
    [self loadRepos:nil];
    [self loadFollowers:nil];
    [self loadFollowings:nil];
    [self loadWatchedRepos:nil];
}

- (void)updateRemaining:(ASIHTTPRequest *)request {
    // TODO : put it in a HTTP wrapper
    if (request) {
        NSString *r = [[request responseHeaders] valueForKey:@"X-RateLimit-Remaining"];
        [[Context sharedInstance] setRemainingCalls:r];
    }
}

- (void) loadUser:(id) sender {
    NSLog(@"Load user...");
                
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/user?access_token=XXX"]];
    [request setDelegate:self];
    [request startSynchronous];
    [self updateRemaining:request];
        
    NSString *responseString = [request responseString];
    NSLog(@"Get the user request response : %@", responseString);
        //NSDictionary* dict = [[request responseString] objectFromJSONString];    
}

# pragma mark - Load things from github
- (void) loadIssues:(id) sender {
    NSLog(@"Loading Issues...");
    
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
    ASIHTTPRequest *gistRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/gists?per_page=50"]];
    [gistRequest addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [gistRequest setDidFinishSelector:@selector(gistFinished:)];
    [gistRequest setDidFailSelector:@selector(gistsFailed:)];
    [gistRequest setDelegate:self];
    [gistRequest startAsynchronous];
}

- (void) loadOrganizations:(id) sender {
    NSLog(@"Loading Organizations...");
    
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
    NSLog(@"Loading Repositories...");
    
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
    NSLog(@"Loading Pulls for repositories...");
    NSMutableSet *repos = [self getRepositories:nil];

    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    for (NSString *repoName in repos) {
        // get the pulls for this repository
        NSDictionary *pulls = [self getPullsForRepository:repoName];
        if (pulls != nil && [pulls valueForKey:@"url"]) {
            [dict setValue:pulls forKey:repoName];
        }
    }
    
    // FIXME : remove this just send back the dictionnay of pulls!
    // j'ai du faire ca tard la nuit!
    [[NSNotificationCenter defaultCenter] postNotificationName:GITHUB_NOTIFICATION_PULLS 
														object:dict 
													  userInfo:nil];           
    
}

- (NSMutableSet *)getRepositories:(id)sender {
    NSLog(@"Getting Repositories...");
    NSMutableSet *result = [[NSMutableSet alloc]init];
    
    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    ASIHTTPRequest *repositoriesRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/user/repos?per_page=100"]];
    [repositoriesRequest addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [repositoriesRequest setDidFailSelector:@selector(reposFailed:)];
    [repositoriesRequest setDelegate:self];
    [repositoriesRequest startSynchronous];
    [self updateRemaining:repositoriesRequest];
    
    NSDictionary* dict = [[repositoriesRequest responseString] objectFromJSONString];

    for (NSArray *repo in dict) {
        [result addObject:[repo valueForKey:@"name"]];
    }  
    return result;
}

- (NSDictionary *)getPullsForRepository:(NSString *)name {
    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    ASIHTTPRequest *repositoriesRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/pulls", username, name]]];
    [repositoriesRequest addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [repositoriesRequest setDelegate:self];
    [repositoriesRequest startSynchronous];
    [self updateRemaining:repositoriesRequest];
    int status = [repositoriesRequest responseStatusCode];
    NSString *response = [[repositoriesRequest responseString]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // an empty response is a JSON string like '[]' (without quotes)...
    if (status == 200 && [response length] > 2) {
        return [[repositoriesRequest responseString] objectFromJSONString];
    }
    return nil;
}

- (BOOL) checkCredentials:(id) sender {
    NSLog(@"Checking credentials...");
    
    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    if ([username length] == 0) {
        return NO;
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/user"]];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [request startSynchronous];
    [self updateRemaining:request];

    int status = [request responseStatusCode];
    return status == 200;
}

- (void) loadFollowers:(id) sender {
    NSLog(@"Loading Followers...");
    
    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/user/followers?per_page=100"]];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [request setDidFinishSelector:@selector(followersFinished:)];
    [request setDidFailSelector:@selector(httpFailed:)];
    [request setDelegate:self];
    [request startAsynchronous];    
}

- (void) loadFollowings:(id) sender {
    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/user/following?per_page=100"]];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [request setDidFinishSelector:@selector(followingsFinished:)];
    [request setDidFailSelector:@selector(httpFailed:)];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void) loadWatchedRepos:(id) sender {
    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/user/watched?per_page=100"]];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    [request setDidFinishSelector:@selector(watchedReposFinished:)];
    [request setDidFailSelector:@selector(httpFailed:)];
    [request setDelegate:self];
    [request startAsynchronous];    
}

# pragma mark - HTTP failures
- (void) issuesFailed:(ASIHTTPRequest*)request {
    NSLog(@"Error : %@", [request error]);
    NSString *error = @"Error getting issues";
    [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
														object:error 
													  userInfo:nil];   
}

- (void) gistsFailed:(ASIHTTPRequest*)request {
    NSLog(@"Error : %@", [request error]);
    NSString *error = @"Error getting gists";
    [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
														object:error 
													  userInfo:nil];   
}

- (void) organizationsFailed:(ASIHTTPRequest*)request {
    NSLog(@"Error : %@", [request error]);
    NSString *error = @"Error getting organizations";
    [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
														object:error 
													  userInfo:nil];   
}

- (void) reposFailed:(ASIHTTPRequest*)request {
    NSLog(@"Error : %@", [request error]);
    NSString *error = @"Error getting repositories";
    [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
														object:error 
													  userInfo:nil];   
}

- (void)pullFailed:(ASIHTTPRequest *)request {
    NSLog(@"Error : %@", [request error]);
    [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
														object:request 
													  userInfo:nil];       
}

- (void) httpFailed:(ASIHTTPRequest*)request {
    NSLog(@"Error : %@", [request error]);
    NSString *error = @"HTTP failure, can not get data";
    [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
														object:error 
													  userInfo:nil];           
}

#pragma mark - process HTTP responses

// does nothing but forward the responses to listeners...
// TODO : dispatch on error handlers after response decode and on good data handlers too...
- (void) issuesFinished:(ASIHTTPRequest*)request {
    NSLog(@"Issues Finished...");
    [self updateRemaining:request];
    // TODO
    BOOL error = NO;
    
    if (error) {
        
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:GITHUB_NOTIFICATION_ISSUES 
                                                            object:request 
                                                            userInfo:nil]; 
    }
}

- (void) gistFinished:(ASIHTTPRequest*)request {
    NSLog(@"Gists Finished...");
    [self updateRemaining:request];

    [[NSNotificationCenter defaultCenter] postNotificationName:GITHUB_NOTIFICATION_GISTS 
														object:request 
													  userInfo:nil];       
}

- (void) organizationsFinished:(ASIHTTPRequest*)request {
    NSLog(@"Organizations Finished...");
    [self updateRemaining:request];

    [[NSNotificationCenter defaultCenter] postNotificationName:GITHUB_NOTIFICATION_ORGS 
														object:request 
													  userInfo:nil];   
}

- (void) reposFinished:(ASIHTTPRequest*)request {
    NSLog(@"Repositories Finished...");
    [self updateRemaining:request];

    [[NSNotificationCenter defaultCenter] postNotificationName:GITHUB_NOTIFICATION_REPOS 
														object:request 
													  userInfo:nil];   
}

- (void)pullFinished:(ASIHTTPRequest *)request {
    NSLog(@"Pulls Finished...");
    [self updateRemaining:request];

    [[NSNotificationCenter defaultCenter] postNotificationName:GITHUB_NOTIFICATION_PULLS 
														object:request 
													  userInfo:nil]; 
}

- (void) followingsFinished:(ASIHTTPRequest*)request {
    NSLog(@"Followings Finished...");
    [self updateRemaining:request];

    [[NSNotificationCenter defaultCenter] postNotificationName:GITHUB_NOTIFICATION_FOLLOWINGS 
														object:request 
													  userInfo:nil];    
}

- (void) followersFinished:(ASIHTTPRequest*)request {
    NSLog(@"Followers Finished...");
    [self updateRemaining:request];

    [[NSNotificationCenter defaultCenter] postNotificationName:GITHUB_NOTIFICATION_FOLLOWERS
														object:request 
													  userInfo:nil]; 
}

- (void) watchedReposFinished:(ASIHTTPRequest*)request {
    NSLog(@"Watched Repos Finished...");
    [self updateRemaining:request];

    [[NSNotificationCenter defaultCenter] postNotificationName:GITHUB_NOTIFICATION_WATCHEDREPO
														object:request 
													  userInfo:nil]; 
}

# pragma mark - Write
- (NSString*) createGist:(NSString*) content withDescription:(NSString*) description andFileName:(NSString *) fileName isPublic:(BOOL) pub {
    NSString *gistId = nil;
    
    NSString *username = [preferences login];
    NSString *password = [preferences password];
        
    NSString *payload = [NSString stringWithFormat:@"{\"description\": \"%@\", \"public\": %@, \"files\":{\"%@\": { \"content\": %@ }}}", description, pub ? @"true" : @"false", fileName, [content JSONString]];
    
    NSLog(@"Outgoing Payload : %@", payload);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/gists"]];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    
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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GITHUB_NOTIFICATION_GIST_CREATED 
                                                            object:dict 
                                                          userInfo:nil];           
    } else {
        NSLog(@"Gist creation error %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
                                                            object:@"Failed to create Gist" 
                                                          userInfo:nil];           
    }
    return gistId;
}

- (NSString*) createRepository:(NSString*) name description:(NSString*)desc homepage:(NSString*) home wiki:(BOOL)wk issues:(BOOL)is downloads:(BOOL)dl isPrivate:(BOOL)privacy {
    NSString *location = nil;
    
    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    NSString *payload = [NSString stringWithFormat:@"{\"name\": \"%@\", \"description\": \"%@\", \"homepage\": \"%@\", \"public\": %@, \"has_issues\": %@, \"has_wiki\": %@, \"has_downloads\": %@}", name, desc, home, privacy ? @"false" : @"true", wk ? @"true" : @"false", is? @"true" : @"false", dl? @"true" : @"false"];
    
    NSLog(@"Outgoing Payload : %@", payload);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/user/repos"]];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
    
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
            [[NSNotificationCenter defaultCenter] postNotificationName:GITHUB_NOTIFICATION_REPO_CREATED 
                                                                object:nil 
                                                              userInfo:nil];     
        } else {
            NSLog(@"Repo creation error, bad return code %d", status);
            NSLog(@"Returned message is %@", response);
            [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
                                                                object:@"Failed to create repository" 
                                                              userInfo:nil]; 
        }
    } else {
        NSLog(@"Repo creation error %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
                                                            object:@"Failed to create repository" 
                                                          userInfo:nil];           
    }
    return location;
}

- (NSDictionary *) getGist:(NSString*)gistId {
    NSDictionary *result = nil;
    
    NSString *username = [preferences login];
    NSString *password = [preferences password];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/gists/%@", gistId]]];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]]];
        
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
            [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
                                                                object:@"Get gist failure" 
                                                              userInfo:nil]; 
        }
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_NOTIFICATION 
                                                            object:@"Get gist failure" 
                                                          userInfo:nil];           
    }
    return result;
}

- (void)dealloc
{
    // TODO
    [super dealloc];
}

@end
