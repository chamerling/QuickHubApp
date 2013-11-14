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

#import <Foundation/Foundation.h>
#import "Preferences.h"
#import "ASIHTTPRequest.h"

@interface GitHubController : NSObject {
    Preferences *preferences;
}

# pragma mark - GH HTTP processing
- (void) issuesFinished:(ASIHTTPRequest*)request;
- (void) gistFinished:(ASIHTTPRequest*)request;
- (void) organizationsFinished:(ASIHTTPRequest*)request;
- (void) reposFinished:(ASIHTTPRequest*)request;
- (void) pullFinished:(ASIHTTPRequest*)request;
- (void) followingsFinished:(ASIHTTPRequest*)request;
- (void) followersFinished:(ASIHTTPRequest*)request;
- (void) watchedReposFinished:(ASIHTTPRequest*)request;

- (void) issuesFailed:(ASIHTTPRequest*)request;
- (void) gistsFailed:(ASIHTTPRequest*)request;
- (void) organizationsFailed:(ASIHTTPRequest*)request;
- (void) reposFailed:(ASIHTTPRequest*)request;
- (void) pullFailed:(ASIHTTPRequest*)request;

- (void) httpFailed:(ASIHTTPRequest*)request;

# pragma mark - Load things from github
- (BOOL) checkCredentials:(id) sender;
- (void) loadGHData:(id)sender;
- (void) loadIssues:(id) sender;
- (void) loadGists:(id) sender;
- (void) loadOrganizations:(id) sender;
- (void) loadRepos:(id) sender;
- (void) loadPulls:(id) sender;
- (void) loadFollowers:(id) sender;
- (void) loadFollowings:(id) sender;
- (void) loadWatchedRepos:(id) sender;

- (void) loadUser:(id) sender;

# pragma mark - Write API
- (NSString*) createGist:(NSString*) content withDescription:(NSString*) title andFileName:(NSString *) fileName isPublic:(BOOL) pub;

- (NSString*) createRepository:(NSString*) name description:(NSString*)desc homepage:(NSString*) home wiki:(BOOL)wk issues:(BOOL)is downloads:(BOOL)dl isPrivate:(BOOL)privacy;

- (NSDictionary *) getGist:(NSString*)gistId;

@end
