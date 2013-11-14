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

#import "ASIHTTPRequest.h"
#import "Reachability.h"

#import "Preferences.h"
#import "GithubOAuthClient.h"
#import "MenuController.h"
#import "EventsManager.h"

@class Reachability;
@interface AppController : NSObject {
    
    GithubOAuthClient *githubController;
    EventsManager *eventsManager;
    IBOutlet MenuController *menuController;
    
    // update timers
    NSTimer* gistTimer;
    NSTimer* issueTimer;
    NSTimer* organizationTimer;
    NSTimer* repositoryTimer;
    NSTimer* followTimer;
    NSTimer* watchingTimer;
    NSTimer* pullTimer;
    NSTimer* eventTimer;
    
    // misc.
    BOOL githubPolling;
    
    // Reachability
    Reachability* hostReach;
    Reachability* internetReachable;
    
}

- (void) pollIssues:(id) sender;
- (void) pollGists:(id) sender;
- (void) pollOrgs:(id) sender;
- (void) pollRepos:(id) sender;
- (void) pollFollow:(id) sender;
- (void) pollWatching:(id) sender;
- (void) pollPulls:(id) sender;
- (void) pollEvents:(id) sender;

//- (void) pollPulls:(id) sender;

- (void) loadAll:(id)sender;
- (void) stopAll:(id)sender;
- (void) cleanCache:(id)sender;

- (void) checkNetworkStatus:(NSNotification *)notice;

@end
