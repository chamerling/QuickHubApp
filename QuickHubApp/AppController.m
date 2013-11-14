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

#import "AppController.h"
#import "NSData+Base64.h"
#import "ASIHTTPRequest.h"
#import "QHConstants.h"
#import "Context.h"

@interface AppController (Private)
- (void) updateGistUI:(NSDictionary *) dictionary;
- (void) updateReposUI:(NSDictionary *) dictionary;
- (void) updateOrgsUI:(NSDictionary *) dictionary;
- (void) updateIssuesUI:(NSDictionary *) dictionary;
- (void) updatePullsUI:(NSDictionary *) dictionary;
- (void) updateWatchingUI:(NSDictionary *) dictionary;
- (void) updateFollowersUI:(NSDictionary *) dictionary;
- (void) updateFollowingUI:(NSDictionary *) dictionary;
- (void) doLoadAll:(id) sender;
@end

@implementation AppController

- (id)init
{
    self = [super init];
    if (self) {
        githubController = [[GithubOAuthClient alloc]init];

        //reachability
        // check for internet connection
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
        
        internetReachable = [[Reachability reachabilityForInternetConnection] retain];
        [internetReachable startNotifier];
        
        hostReach = [[Reachability reachabilityWithHostName: @"api.github.com"] retain];
        [hostReach startNotifier];
    }
    return self;
}

- (void)awakeFromNib {
    eventsManager = [[EventsManager alloc] init];
    [eventsManager setMenuController:menuController];
    
    // register listeners to start and stop polling...
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loadAll:)
                                                 name:POLLING_START
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(stopAll:)
                                                 name:POLLING_STOP
                                               object:nil];
    
    // load gists when a gist is created!
    // FIXME : Chck that this is not used
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(pollGists:)
                                                 name:GITHUB_NOTIFICATION_GIST_CREATED
                                               object:nil];

    // load repos when a repo is created!
    // FIXME : check that this is not used since we add them by hand
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(pollRepos:)
                                                 name:GITHUB_NOTIFICATION_REPO_CREATED
                                               object:nil];
    
    
}

#pragma mark - Github Actions

- (void) loadAll:(id)sender {
    if (!githubPolling) {
        Preferences *preferences = [Preferences sharedInstance];
        if ([[preferences oauthToken]length] == 0 || ![githubController checkCredentials:nil]) {
            return;
        }
        
        [self performSelectorInBackground:@selector(doLoadAll:) withObject:nil];        

    } else {
        //NSLog(@"Can not start all since we are already polling...");
    }
}

- (void) doLoadAll:(id) sender {
    //NSLog(@"Load all and start polling things");
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
    
    gistTimer = [NSTimer scheduledTimerWithTimeInterval:240 target:self selector:@selector(pollGists:) userInfo:nil repeats:YES];
    
    repositoryTimer = [NSTimer scheduledTimerWithTimeInterval:310 target:self selector:@selector(pollRepos:) userInfo:nil repeats:YES];
    
    organizationTimer = [NSTimer scheduledTimerWithTimeInterval:603 target:self selector:@selector(pollOrgs:) userInfo:nil repeats:YES];
    
    issueTimer = [NSTimer scheduledTimerWithTimeInterval:145 target:self selector:@selector(pollIssues:) userInfo:nil repeats:YES];
    
    followTimer = [NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(pollFollow:) userInfo:nil repeats:YES];
    
    watchingTimer = [NSTimer scheduledTimerWithTimeInterval:1802 target:self selector:@selector(pollWatching:) userInfo:nil repeats:YES];
    
    pullTimer = [NSTimer scheduledTimerWithTimeInterval:701 target:self selector:@selector(pollPulls:) userInfo:nil repeats:YES];
    
    eventTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(pollEvents:) userInfo:nil repeats:YES];
    
    // add the timer to the common run loop mode so that it does not freezes when the user clicks on menu
    // cf http://stackoverflow.com/questions/4622684/nsrunloop-freezes-with-nstimer-and-any-input
    [[NSRunLoop currentRunLoop] addTimer:gistTimer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] addTimer:repositoryTimer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] addTimer:organizationTimer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] addTimer:issueTimer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] addTimer:followTimer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] addTimer:watchingTimer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] addTimer:pullTimer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] addTimer:eventTimer forMode:NSRunLoopCommonModes];
    
    githubPolling = YES;
    
    [repositoryTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:1]];
    [gistTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:2]];
    [organizationTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:3]];
    [issueTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:4]];
    [followTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:6]];
    [watchingTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:7]];
    [pullTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:10]];
    [eventTimer setFireDate: [NSDate dateWithTimeIntervalSinceNow:5]];
    
    [runLoop run];
    [pool release];
}

- (void) stopAll:(id)sender {
    if (githubPolling) {
        [gistTimer invalidate];
        [repositoryTimer invalidate];
        [organizationTimer invalidate];
        [issueTimer invalidate];
        [followTimer invalidate];
        [watchingTimer invalidate];
        [pullTimer invalidate];
        [eventTimer invalidate];
    }
    githubPolling = NO;
    
    // FIXME : how to kill the background thread? Is it garbaged when there is nothing more in the run loop?
    //NSLog(@"Stopped!");
}

- (void) cleanCache:(id)sender {
    [eventsManager clearEvents];
}

- (void)pollGists:(id) sender {
    if (githubPolling) {
        NSDictionary *dictionary = [githubController loadGists:nil];
        if (dictionary) {
            //[self performSelectorOnMainThread:@selector(updateGistUI:) withObject:dictionary waitUntilDone:NO];
            [menuController gistFinished:dictionary];  
        }
    }
}

- (void)pollRepos:(id) sender {
    if (githubPolling) {
        NSSet *repositories = [githubController getRepositories:nil];
        [[Context sharedInstance]setRepositories:repositories];
        
        NSDictionary *dictionary = [githubController loadRepos:nil];
        if (dictionary) {
            //[self performSelectorOnMainThread:@selector(updateReposUI:) withObject:dictionary waitUntilDone:NO];
            [menuController reposFinished:dictionary];  
        }
    }
}

- (void)pollOrgs:(id) sender {
    if (githubPolling) {
        NSDictionary *dictionary = [githubController loadOrganizations:nil];
        // get all repository for each organization
        if (dictionary) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];

            for (NSArray *org in dictionary) {
                NSMutableDictionary *orgDictionary = [[NSMutableDictionary alloc]init];
                NSDictionary *repoDictionary = [githubController getReposForOrganization:[org valueForKey:@"login"]];
                [orgDictionary setValue:repoDictionary forKey:@"repos"];
                [orgDictionary setValue:org forKey:@"org"];
                [dict setValue:orgDictionary forKey:[org valueForKey:@"login"]];
            }
            //dict = [orgname -> [repos->[dict], [org->[dict]]]]
            
            //[self performSelectorOnMainThread:@selector(updateOrgsUI:) withObject:dict waitUntilDone:NO];
            [menuController organizationsFinished:dict];  
        }
    }
}

- (void)pollIssues:(id) sender {
    if (githubPolling) {
        NSDictionary *dictionary = [githubController loadIssues:nil];
        if (dictionary) {
            //[self performSelectorOnMainThread:@selector(updateIssuesUI:) withObject:dictionary waitUntilDone:NO];
            [menuController issuesFinished:dictionary];  
        }
    }
}

- (void) pollFollow:(id) sender {
    if (githubPolling) {
        NSDictionary *dictionary = [githubController loadFollowers:nil];
        NSDictionary *dictionary2 = [githubController loadFollowings:nil];
        if (dictionary) {
            //[self performSelectorOnMainThread:@selector(updateFollowersUI:) withObject:dictionary waitUntilDone:NO];
            [menuController followersFinished:dictionary];  
        }
        if (dictionary2) {
            //[self performSelectorOnMainThread:@selector(updateFollowingUI:) withObject:dictionary2 waitUntilDone:NO];
            [menuController followingsFinished:dictionary2];  
        }
    }
}

- (void) pollWatching:(id) sender {
    if (githubPolling) {
        NSDictionary *dictionary = [githubController loadWatchedRepos:nil];
        if (dictionary) {
            //[self performSelectorOnMainThread:@selector(updateWatchingUI:) withObject:dictionary waitUntilDone:NO];
            [menuController watchedReposFinished:dictionary];  
        }
    }  
}

- (void) pollPulls:(id) sender {
    if (githubPolling) {
        NSDictionary *dictionary = [githubController loadPulls:nil];
        if (dictionary) {
            //[self performSelectorOnMainThread:@selector(updatePullsUI:) withObject:dictionary waitUntilDone:NO];
            [menuController pullsFinished:dictionary];  
        }
    }  
}

- (void) pollEvents:(id) sender {
    if (githubPolling) {
        NSDictionary *dictionary = [githubController loadReceivedEvents:nil];
        if (dictionary) {
            [eventsManager addEventsFromDictionary:dictionary];
        }
    }      
}

- (void) updateGistUI:(NSDictionary *) dictionary
{
    [menuController gistFinished:dictionary];  
}

- (void) updateReposUI:(NSDictionary *) dictionary {
    [menuController reposFinished:dictionary];  
}

- (void) updateOrgsUI:(NSDictionary *) dictionary {
    [menuController organizationsFinished:dictionary];  
}

- (void) updateIssuesUI:(NSDictionary *) dictionary {
    [menuController issuesFinished:dictionary];  
}

- (void) updatePullsUI:(NSDictionary *) dictionary {
    [menuController pullsFinished:dictionary];  
}

- (void) updateWatchingUI:(NSDictionary *) dictionary {
    [menuController watchedReposFinished:dictionary];  
}

- (void) updateFollowersUI:(NSDictionary *) dictionary {
    [menuController followersFinished:dictionary];  
}

- (void) updateFollowingUI:(NSDictionary *) dictionary {
    [menuController followingsFinished:dictionary];  
}

#pragma mark - reachability
- (void) checkNetworkStatus:(NSNotification *)notice {
    Reachability* reach = [notice object];
    
    if (reach == internetReachable) {
        //NSLog(@"Internet reachablity changed!");
   
        NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
        switch (internetStatus)
    
        {
            case NotReachable:
            {
                //NSLog(@"The internet is down.");
            
                // if already polling github, stop all background task
                [self stopAll:nil];
            
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_INTERNET_DOWN object:nil];
                break;
            
            }
            case ReachableViaWiFi:
            {
                //NSLog(@"The internet is working via WIFI.");
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_INTERNET_UP object:nil];
                break;
            }
            case ReachableViaWWAN:
            {
                //NSLog(@"The internet is working via WWAN.");
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_INTERNET_UP object:nil];
                break;            
            }
        }
    } else if (reach == hostReach) {
        //NSLog(@"Host reachablity changed!");
    
        NetworkStatus hostStatus = [hostReach currentReachabilityStatus];
        if (hostStatus == NotReachable) {
            //NSLog(@"The host is not reachable");
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_INTERNET_DOWN object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HostDown" object:nil];

        } else {
            //NSLog(@"The host is reachable");
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_INTERNET_UP object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HostUp" object:nil];
            [self loadAll:nil];
        }
    }
}

- (void)dealloc {
    [eventsManager release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
