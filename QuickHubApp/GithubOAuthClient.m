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

#import "GithubOAuthClient.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
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
        
        // Use the default cache provided by ASIHTTPRequest
        [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
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
    [request setCachePolicy: ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setDelegate:self];
    [request startSynchronous];
    NSDictionary *result = [[request responseString] objectFromJSONString];
    return result;
}

- (NSDictionary*) loadIssues:(id) sender {
    //NSLog(@"Loading Issues...");
    
    // try to get my issues with ASIHTTP and JSONKIT...
    // FIXME : Add all param cf http://developer.github.com/v3/issues/#list-issues
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:@"issues"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setDelegate:self];
    [request startSynchronous];
    
    NSDictionary *result = [[request responseString] objectFromJSONString];

    return result;
}

- (NSDictionary*) loadGists:(id) sender {
    //NSLog(@"Loaging Gists...");
    // get gists
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:@"gists"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setDelegate:self];
    [request startSynchronous];
    
    NSDictionary *result = [[request responseString] objectFromJSONString];

    return result;
}

- (NSDictionary*) loadOrganizations:(id) sender {
    //NSLog(@"Loading Organizations...");
    
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:@"user/orgs"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setDelegate:self];
    [request startSynchronous];

    return [[request responseString] objectFromJSONString];
}

- (NSDictionary *)getReposForOrganization:(NSString *)name {
    //NSLog(@"Loading Repos for Organization %@...", name);

    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:[NSString stringWithFormat:@"orgs/%@/repos", name]]];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setDelegate:self];
    [request startSynchronous];
    
    return [[request responseString] objectFromJSONString];
}

- (NSDictionary*) loadRepos:(id) sender {
    //NSLog(@"Loading Repositories...");
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:@"user/repos"]];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setDelegate:self];
    [request startSynchronous];
    
    NSDictionary *result = [[request responseString] objectFromJSONString];

    return result;
}

- (NSDictionary*)loadPulls:(id)sender {
    //NSLog(@"Loading Pulls for repositories...");
    NSMutableSet *repos = [self getRepositories:nil];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *repoName in repos) {
        NSDictionary *pulls = [self getPullsForRepository:repoName];
        if (pulls != nil && [pulls valueForKey:@"url"]) {
            [dict setValue:pulls forKey:repoName];
        }
    }    
    return [dict autorelease];
}

- (NSMutableSet *)getRepositories:(id)sender {
    //NSLog(@"Getting Repositories...");
    NSMutableSet *result = [[NSMutableSet alloc]init];
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:@"user/repos"]];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setDelegate:self];
    [request startSynchronous];
    [self updateRemaining:request];
    
    NSDictionary* dict = [[request responseString] objectFromJSONString];
    
    for (NSArray *repo in dict) {
        [result addObject:[repo valueForKey:@"name"]];
    }  
    return [result autorelease];
}

- (NSDictionary *)getPullsForRepository:(NSString *)name {
    //NSLog(@"Get pulls for repository %@", name);
    NSString *userName = [[Preferences sharedInstance] login];
    
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:[NSString stringWithFormat:@"repos/%@/%@/pulls", userName, name]]];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    
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
    //NSLog(@"Loading Followers...");
    
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:@"user/followers"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setDelegate:self];
    [request startSynchronous];
    NSDictionary *result = [[request responseString] objectFromJSONString];

    return result;
}

- (NSDictionary *) loadFollowings:(id) sender {
    
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:@"user/following"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setDelegate:self];
    [request startSynchronous];
    NSDictionary *result = [[request responseString] objectFromJSONString];

    return result;
}

- (NSDictionary *) loadWatchedRepos:(id) sender {
    NSString *url = [NSString stringWithFormat:@"%@&per_page=100", [self getOAuthURL:@"user/watched"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setDelegate:self];
    [request startSynchronous];   
    NSDictionary *result = [[request responseString] objectFromJSONString];

    return result;
}

- (NSDictionary*) loadUserEvents:(id) sender {
    NSString *userName = [[Preferences sharedInstance] login];

    NSString *url = [NSString stringWithFormat:@"%@", [self getOAuthURL:[NSString stringWithFormat:@"users/%@/events", userName]]];
    NSLog(@"%@", url);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setDelegate:self];
    [request startSynchronous];   
    NSDictionary *result = [[request responseString] objectFromJSONString];

    return result;    
}

- (NSDictionary*) loadReceivedEvents:(id) sender {
    NSString *userName = [[Preferences sharedInstance] login];
    
    NSString *url = [NSString stringWithFormat:@"%@", [self getOAuthURL:[NSString stringWithFormat:@"users/%@/received_events", userName]]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setDelegate:self];
    [request startSynchronous];   
    NSDictionary *result = [[request responseString] objectFromJSONString];

    return result;
}

// Note : this is not available with oauth!
- (NSDictionary *) getAuthorizations:(id) sender {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:@"authorizations"]]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setDelegate:self];
    [request startSynchronous];   
    NSDictionary *result = [[request responseString] objectFromJSONString];

    return result;
}

#pragma mark - WRITE API Impl
- (NSDictionary*) createGist:(NSString*) content withDescription:(NSString*) description andFileName:(NSString *) fileName isPublic:(BOOL) pub {
    
    NSString *payload = [NSString stringWithFormat:@"{\"description\": \"%@\", \"public\": %@, \"files\":{\"%@\": { \"content\": %@ }}}", description, pub ? @"true" : @"false", fileName, [content JSONString]];
        
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self getOAuthURL:@"gists"]]];
    [request appendPostData:[payload dataUsingEncoding:NSUTF8StringEncoding]];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    
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

- (NSDictionary*) createRepository:(NSString*) name description:(NSString*)desc homepage:(NSString*) home wiki:(BOOL)wk issues:(BOOL)is downloads:(BOOL)dl isPrivate:(BOOL)privacy autoInit:(BOOL)init {
    NSDictionary *result = nil;
    
    NSString *payload = [NSString stringWithFormat:@"{\"name\": \"%@\", \"description\": \"%@\", \"homepage\": \"%@\", \"public\": %@, \"has_issues\": %@, \"has_wiki\": %@, \"has_downloads\": %@, \"auto_init\": %@}", name, desc, home, privacy ? @"false" : @"true", is ? @"true" : @"false", wk? @"true" : @"false", dl? @"true" : @"false", init? @"true" : @"false"];
        
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

- (NSDictionary*) createRepository:(NSString*) name forOrg:(NSString*)orgName description:(NSString*)desc homepage:(NSString*) home wiki:(BOOL)wk issues:(BOOL)is downloads:(BOOL)dl isPrivate:(BOOL)privacy autoInit:(BOOL)init{
    NSDictionary *result = nil;
    
    NSString *payload = [NSString stringWithFormat:@"{\"name\": \"%@\", \"description\": \"%@\", \"homepage\": \"%@\", \"public\": %@, \"has_issues\": %@, \"has_wiki\": %@, \"has_downloads\": %@, \"auto_init\": %@}", name, desc, home, privacy ? @"false" : @"true", is ? @"true" : @"false", wk? @"true" : @"false", dl? @"true" : @"false", init? @"true" : @"false"];
        
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
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    [self updateRemaining:request];
    
    NSError *error = [request error];
    if (!error) {
        int status = [request responseStatusCode];
        NSString *response = [request responseString];
        if (status == 200) {
            result = [response objectFromJSONString];
        } else {
        }
    } else {
    
    }
    return result;
}

- (BOOL) checkCredentials:(id) sender {
    //NSLog(@"Checking credentials...");
    
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
