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

@interface GithubOAuthClient : NSObject

#pragma mark - OAuth
- (NSString *)getOAuthURL:(NSString *)path;

#pragma mark - Read API

- (BOOL) checkCredentials:(id) sender;

- (NSDictionary*) loadUser:(id) sender;

- (NSDictionary*) loadGHData:(id)sender;
- (NSDictionary*) loadIssues:(id) sender;
- (NSDictionary*) loadGists:(id) sender;
- (NSDictionary*) loadOrganizations:(id) sender;
- (NSDictionary*) loadRepos:(id) sender;
- (NSDictionary*) loadPulls:(id) sender;
- (NSDictionary*) loadFollowers:(id) sender;
- (NSDictionary*) loadFollowings:(id) sender;
- (NSDictionary*) loadWatchedRepos:(id) sender;
- (NSDictionary*) loadUserEvents:(id) sender;
- (NSDictionary*) loadReceivedEvents:(id) sender;
- (NSDictionary *) getAuthorizations:(id) sender;

# pragma mark - Write API
- (NSDictionary*) createGist:(NSString*) content withDescription:(NSString*) title andFileName:(NSString *) fileName isPublic:(BOOL) pub;

- (NSDictionary*) createRepository:(NSString*) name description:(NSString*)desc homepage:(NSString*) home wiki:(BOOL)wk issues:(BOOL)is downloads:(BOOL)dl isPrivate:(BOOL)privacy autoInit:(BOOL)init;

- (NSDictionary*) createRepository:(NSString*) name forOrg:(NSString*)orgName description:(NSString*)desc homepage:(NSString*) home wiki:(BOOL)wk issues:(BOOL)is downloads:(BOOL)dl isPrivate:(BOOL)privacy autoInit:(BOOL)init;

- (NSDictionary *) createIssue:(NSString *) repository user:(NSString *)user title:(NSString *)title boby:(NSString *)body assignee:(NSString*)assignee milestone:(NSString *) milestone labels:(NSSet*)labels;

- (NSDictionary *) getGist:(NSString*)gistId;

- (NSDictionary *)getPullsForRepository:(NSString *)name;

- (NSDictionary *)getReposForOrganization:(NSString *)name;

- (NSDictionary *)getReposForOrganization:(NSString *)name;

- (NSMutableSet *)getRepositories:(id)sender;

# pragma mark - delete API
- (BOOL) deleteAuth:(NSString *) authId;

@end
