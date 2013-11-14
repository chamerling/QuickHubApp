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

#import "EventsManager.h"
#import "Preferences.h"
#import "GrowlManager.h"
#import "QHConstants.h"

@interface EventsManager (Private)
- (void) notifyNewEvent:(NSDictionary *) event;
- (BOOL) notificationActive:(NSString *) eventType;
- (BOOL) isNotificationsActive;

- (NSDictionary *) getCommit:(NSDictionary *)event;
- (NSDictionary *) getCreate:(NSDictionary *)event;
- (NSDictionary *) getDelete:(NSDictionary *)event;
- (NSDictionary *) getDownload:(NSDictionary *)event;
- (NSDictionary *) getFollow:(NSDictionary *)event;
- (NSDictionary *) getFork:(NSDictionary *)event;
- (NSDictionary *) getGist:(NSDictionary *)event;
- (NSDictionary *) getGollum:(NSDictionary *)event;
- (NSDictionary *) getIssueComment:(NSDictionary *)event;
- (NSDictionary *) getIssue:(NSDictionary *)event;
- (NSDictionary *) getMember:(NSDictionary *)event;
- (NSDictionary *) getPublic:(NSDictionary *)event;
- (NSDictionary *) getPull:(NSDictionary *)event;
- (NSDictionary *) getPullReview:(NSDictionary *)event;
- (NSDictionary *) getPush:(NSDictionary *)event;
- (NSDictionary *) getTeam:(NSDictionary *)event;
- (NSDictionary *) getWatch:(NSDictionary *)event;

- (void) updateEventMenu:(NSDictionary *)event;

@end

@implementation EventsManager

@synthesize menuController;

- (id)init
{
    self = [super init];
    if (self) {
        events = [[NSMutableArray alloc] init];
        eventIds = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (void) addEventsFromDictionary:(NSDictionary *) dict {
    BOOL firstCall = ([events count] == 0);
    
    NSMutableDictionary *arrangedEvents = [[NSMutableDictionary alloc] init];

    NSMutableSet* justGet = [[[NSMutableSet alloc] init] autorelease];
    for (NSDictionary *event in dict) {
        [justGet addObject:[event valueForKey:@"id"]];
        [arrangedEvents setObject:event forKey:[event valueForKey:@"id"]];
    }
    
    // diff events with the already cached ones
    NSMutableSet* newEvents = [NSMutableSet setWithSet:justGet];
    [newEvents minusSet:eventIds];
    
    // cache new events
    for (id eventId in newEvents) {
        [eventIds addObject:eventId];
        [events addObject:[arrangedEvents objectForKey:eventId]];
    }
    
    // TODO : Check if there is something to create array from set
    NSMutableArray *newEventsArray = [NSMutableArray arrayWithCapacity:[newEvents count]];
    for (id eventId in newEvents) {
        [newEventsArray addObject:[arrangedEvents objectForKey:eventId]];
    }
    
    // create an array with the new events and order them by date...
    NSArray *sorted = [[NSMutableArray arrayWithArray:newEventsArray] sortedArrayUsingComparator:^(id a, id b) {
        NSString *first = [a objectForKey:@"created_at"];
        NSString *second = [b objectForKey:@"created_at"];
        return [[first lowercaseString] compare:[second lowercaseString]];
    }];
        
    for (id event in sorted) {
        [self updateEventMenu:event];
    }
    
    if ([sorted count] > 0 && [self isNotificationsActive]) {
        // send some notifications...
        
        int nbEvents = 10;
        if ([sorted count] >= nbEvents) {
            // limit the number of events per configuration...
            
            if (!firstCall) {
                [[GrowlManager get] notifyWithName:@"GitHub Event" desc:[NSString stringWithFormat:@"%d new events...", [newEvents count]] url:nil icon:nil];
            }
        } else {
            // loop...
            // TODO : need to order events by date with the "created_at" element
            for (id event in sorted) {
                [self notifyNewEvent:event];
            }
        }
    }
}

- (NSArray *) getEvents {
    return events;  
}

- (void) clearEvents {
    events = [[NSMutableArray alloc] init];
    eventIds = [[NSMutableSet alloc] init];
}

- (void) notifyNewEvent:(NSDictionary *) event {
        
    if (!event) {
        return;
    }
    
    NSString *type = [event valueForKey:@"type"];
    
    if (!type) {
        return;
    }
        
    if ([CommitCommentEvent isEqualToString:type]) {
        if (![self notificationActive:GHCommitCommentEvent]) {
            return;
        }
        
        NSDictionary *dict = [self getCommit:event];
        [[GrowlManager get] notifyWithName:@"GitHub" desc:[dict valueForKey:@"message"] url:[dict valueForKey:@"url"] iconName:@"octocat-128"];
        
    } else if ([CreateEvent isEqualToString:type]) {
        if (![self notificationActive:GHCreateEvent]) {
            return;
        }
                
        NSDictionary *dict = [self getCreate:event];
        [[GrowlManager get] notifyWithName:@"GitHub" desc:[dict valueForKey:@"message"] url:[dict valueForKey:@"url"] iconName:@"octocat-128"];
         
    } else if ([DeleteEvent isEqualToString:type]) {
        if (![self notificationActive:GHDeleteEvent]) {
            return;
        }
        
        NSDictionary *dict = [self getDelete:event];
        [[GrowlManager get] notifyWithName:@"GitHub" desc:[dict valueForKey:@"message"] url:nil iconName:@"octocat-128"];
        
    } else if ([DownloadEvent isEqualToString:type]) {
        if ([self notificationActive:GHDownloadEvent]) {
            return;
        }
        
        NSDictionary *dict = [self getDownload:event];
        [[GrowlManager get] notifyWithName:@"GitHub" desc:[dict valueForKey:@"message"] url:[dict valueForKey:@"url"] iconName:@"octocat-128"];

    } else if ([FollowEvent isEqualToString:type]) {
        
        if ([self notificationActive:GHFollowEvent]) {
            return;
        }
        
        NSDictionary *dict = [self getFollow:event];
        [[GrowlManager get] notifyWithName:@"GitHub" desc:[dict valueForKey:@"message"] url:[dict valueForKey:@"url"] iconName:@"octocat-128"];
        
    } else if ([ForkEvent isEqualToString:type]) {
        if ([self notificationActive:GHForkEvent]) {
            return;
        }
        
        NSDictionary *dict = [self getFork:event];
        [[GrowlManager get] notifyWithName:@"GitHub" desc:[dict valueForKey:@"message"] url:[dict valueForKey:@"url"] iconName:@"octocat-128"];
        
    } else if ([ForkApplyEvent isEqualToString:type]) {
        
        // tested but can not find when it happens
        // forked and merged, nothing...
        /*
        NSString *actorLogin = [[event valueForKey:@"actor"] valueForKey:@"login"];
        NSString *repository = [[event valueForKey:@"repo"] valueForKey:@"name"];
        NSString *message = [NSString stringWithFormat:@"%@ applied fork %@", actorLogin, repository];
        
        if ([self notificationActive:GHForkApplyEvent]) {
            [[GrowlManager get] notifyWithName:@"GitHub" desc:message url:nil iconName:@"octocat-128"];
        }
         */
        
    } else if ([GistEvent isEqualToString:type]) {
        
        if ([self notificationActive:GHGistEvent]) {
            return;
        }
        
        NSDictionary *dict = [self getGist:event];
        [[GrowlManager get] notifyWithName:@"GitHub" desc:[dict valueForKey:@"message"] url:[dict valueForKey:@"url"] iconName:@"octocat-128"];  
        
    } else if ([GollumEvent isEqualToString:type]) {
        
        if ([self notificationActive:GHGollumEvent]) {
            return;
        }
        
        NSDictionary *dict = [self getGollum:event];
        [[GrowlManager get] notifyWithName:@"GitHub" desc:[dict valueForKey:@"message"] url:[dict valueForKey:@"url"] iconName:@"octocat-128"];
        
    } else if ([IssueCommentEvent isEqualToString:type]) {
        
        if ([self notificationActive:GHIssueCommentEvent]) {
            return;
        }
        
        NSDictionary *dict = [self getIssueComment:event];
        [[GrowlManager get] notifyWithName:@"GitHub" desc:[dict valueForKey:@"message"] url:[dict valueForKey:@"url"] iconName:@"octocat-128"];
        
    } else if ([IssuesEvent isEqualToString:type]) {
        
        if ([self notificationActive:GHIssuesEvent]) {
            return;
        }
        
        NSDictionary *dict = [self getIssue:event];
        [[GrowlManager get] notifyWithName:@"GitHub" desc:[dict valueForKey:@"message"] url:[dict valueForKey:@"url"] iconName:@"octocat-128"];
        
    } else if ([MemberEvent isEqualToString:type]) {

    } else if ([PublicEvent isEqualToString:type]) {
        
    } else if ([PullRequestEvent isEqualToString:type]) {
        
        if ([self notificationActive:GHPullRequestEvent]) {
            return;
        }
        
        NSDictionary *dict = [self getPull:event];
        [[GrowlManager get] notifyWithName:@"GitHub" desc:[dict valueForKey:@"message"] url:[dict valueForKey:@"url"] iconName:@"octocat-128"];
            
    } else if ([PullRequestReviewCommentEvent isEqualToString:type]) {

    } else if ([PushEvent isEqualToString:type]) {
        
        if ([self notificationActive:GHPushEvent]) {
            return;
        }
        
        NSDictionary *dict = [self getPush:event];
        [[GrowlManager get] notifyWithName:@"GitHub" desc:[dict valueForKey:@"message"] url:[dict valueForKey:@"url"] iconName:@"octocat-128"];
        
    } else if ([TeamAddEvent isEqualToString:type]) {

    } else if ([WatchEvent isEqualToString:type]) {
        
        if ([self notificationActive:GHWatchEvent]) {
            return;
        }
        
        NSDictionary *dict = [self getWatch:event];
        [[GrowlManager get] notifyWithName:@"GitHub" desc:[dict valueForKey:@"message"] url:[dict valueForKey:@"url"] iconName:@"octocat-128"];
        
    } else {
        // NOP
    }
}

- (BOOL) notificationActive:(NSString *) eventType {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL result = YES;
    
    if ([defaults valueForKey:eventType]) {
        result = [defaults boolForKey:eventType];
    } else {
        // if not found, let's say that the notification is active...
        result = YES;
    }
    return result;
}

- (BOOL) isNotificationsActive {
    BOOL result = YES;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:GHEventActive]) {
        result = [defaults boolForKey:GHEventActive];
    } else {
        // if not found, let's say that the notification is active...
        result = YES;
    }
    return result;    
}

#pragma mark - Events transformation
- (NSDictionary *) getCommit:(NSDictionary *)event {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    NSString *actorLogin = [[event valueForKey:@"actor"] valueForKey:@"login"];
    NSString *repository = [[event valueForKey:@"repo"] valueForKey:@"name"];
    NSString *message = [NSString stringWithFormat:@"%@ commented commit on %@", actorLogin, repository];
    NSString *url = [[[event valueForKey:@"payload"] valueForKey:@"comment"] valueForKey:@"html_url"];
    
    NSString *details = nil;
    id line = [[[event valueForKey:@"payload"] valueForKey:@"comment"] valueForKey:@"line"];
    if (line == [NSNull null] || [@"<null>" isEqualToString:[line stringValue]]) {
        NSString *commitId = [[[[event valueForKey:@"payload"] valueForKey:@"comment"] valueForKey:@"commit_id"] substringToIndex:10];
         details = [NSString stringWithFormat:@"Comment on %@: %@", commitId, [[[event valueForKey:@"payload"] valueForKey:@"comment"] valueForKey:@"body"]];
    } else {
        details = [NSString stringWithFormat:@"Comment on L%@: %@", line, [[[event valueForKey:@"payload"] valueForKey:@"comment"] valueForKey:@"body"]];        
    }
    
    [dict setValue:message forKey:@"message"];
    [dict setValue:url forKey:@"url"];
    [dict setValue:details forKey:@"details"];
    
    return dict;
}

- (NSDictionary *) getCreate:(NSDictionary *)event{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        
    NSString *actorLogin = [[event valueForKey:@"actor"] valueForKey:@"login"];
    NSString *refType = [[event valueForKey:@"payload"] valueForKey:@"ref_type"];
    NSString *repository = [[event valueForKey:@"repo"] valueForKey:@"name"];
    
    // default format
    NSString *message = [NSString stringWithFormat:@"%@ created %@ %@", actorLogin, refType, repository];
    NSString *details = nil;
    NSString *url = [NSString stringWithFormat:@"https://github.com/%@", repository];
    
    if ([refType isEqualToString:@"repository"]) {
        message = [NSString stringWithFormat:@"%@ created %@ %@", actorLogin, refType, repository];
        details = [NSString stringWithFormat:@"New repository is at %@", repository];
        url = [NSString stringWithFormat:@"https://github.com/%@", repository];
        
    } else if ([refType isEqualToString:@"tag"]) {
        NSString *ref = [[event valueForKey:@"payload"] valueForKey:@"ref"];
        message = [NSString stringWithFormat:@"%@ created %@ %@ at %@", actorLogin, refType, ref, repository];
        url = [NSString stringWithFormat:@"https://github.com/%@/tree/%@", repository, ref];

    } else if ([refType isEqualToString:@"branch"]) {
        NSString *ref = [[event valueForKey:@"payload"] valueForKey:@"ref"];
        message = [NSString stringWithFormat:@"%@ created %@ %@ at %@", actorLogin, refType, ref, repository];
        url = [NSString stringWithFormat:@"https://github.com/%@/tree/%@", repository, ref];
        details = [NSString stringWithFormat:@"New branch is at %@/tree/%@", repository, ref];
    }
    
    [dict setValue:message forKey:@"message"];
    [dict setValue:details forKey:@"details"];
    [dict setValue:url forKey:@"url"];
    
    return dict;    
}

- (NSDictionary *) getDelete:(NSDictionary *)event{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    NSString *actorLogin = [[event valueForKey:@"actor"] valueForKey:@"login"];
    NSString *repo = [[event valueForKey:@"repo"] valueForKey:@"name"];
    NSString *refType = [[event valueForKey:@"payload"] valueForKey:@"ref_type"];
    NSString *ref = [[event valueForKey:@"payload"] valueForKey:@"ref"];
    NSString *message = [NSString stringWithFormat:@"%@ deleted %@ at %@", actorLogin, refType, ref];
    NSString *url = [NSString stringWithFormat:@"https://github.com/%@", repo];
    NSString *details = nil;
    
    if ([refType isEqualToString:@"branch"]) {
        details = [NSString stringWithFormat:@"Deleted %@ was at %@/tree/%@", refType, repo, ref];
        
    } else if ([refType isEqualToString:@"tag"]) {
        details = [NSString stringWithFormat:@"Deleted %@ was at %@/tree/%@", refType, repo, ref];
    } else if ([refType isEqualToString:@"repository"]) {
        details = @"...";
    }
    
    [dict setValue:message forKey:@"message"];
    [dict setValue:details forKey:@"details"];
    [dict setValue:url forKey:@"url"];
    
    return dict;
}

- (NSDictionary *) getDownload:(NSDictionary *)event{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    NSString *actorLogin = [[event valueForKey:@"actor"] valueForKey:@"login"];
    NSString *filename = [[[event valueForKey:@"payload"] valueForKey:@"download"] valueForKey:@"name"];
    NSString *repository = [[event valueForKey:@"repo"] valueForKey:@"name"];
    NSString *message = [NSString stringWithFormat:@"%@ uploaded %@ to %@", actorLogin, filename, repository];
    NSString *url = [NSString stringWithFormat:@"https://github.com/%@/downloads/", repository];
    
    [dict setValue:message forKey:@"message"];
    [dict setValue:url forKey:@"url"];
    
    return dict;
}

- (NSDictionary *) getFollow:(NSDictionary *)event{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    NSString *actorLogin = [[event valueForKey:@"actor"] valueForKey:@"login"];
    NSString *target = [[[event valueForKey:@"payload"] valueForKey:@"target"] valueForKey:@"login"];
    NSString *message = [NSString stringWithFormat:@"%@ started following %@", actorLogin, target];
    NSNumber *nbRepos = [[[event valueForKey:@"payload"] valueForKey:@"target"] valueForKey:@"public_repos"];
    NSNumber *nbFollowers = [[[event valueForKey:@"payload"] valueForKey:@"target"] valueForKey:@"followers"];
    NSString *details = [NSString stringWithFormat:@"%@ has %ld repositories and %ld followers", target, [nbRepos intValue], [nbFollowers intValue]];
    NSString *url = [NSString stringWithFormat:@"https://github.com/%@", target];
    
    [dict setValue:message forKey:@"message"];
    [dict setValue:details forKey:@"details"];
    [dict setValue:url forKey:@"url"];
    
    return dict;
}

- (NSDictionary *) getFork:(NSDictionary *)event{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        
    NSString *actorLogin = [[event valueForKey:@"actor"] valueForKey:@"login"];
    NSString *repository = [[event valueForKey:@"repo"] valueForKey:@"name"];
    NSString *message = [NSString stringWithFormat:@"%@ forked %@", actorLogin, repository]; 
    NSString *details = [NSString stringWithFormat:@"Forked repository is at %@", [[[event valueForKey:@"payload"] valueForKey:@"forkee"] valueForKey:@"name"]];
    NSString *url = [[[event valueForKey:@"payload"] valueForKey:@"forkee"] valueForKey:@"html_url"];
    
    [dict setValue:message forKey:@"message"];
    [dict setValue:details forKey:@"details"];
    [dict setValue:url forKey:@"url"];
    
    return dict;
}

- (NSDictionary *) getGist:(NSDictionary *)event{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    NSString *actorLogin = [[event valueForKey:@"actor"] valueForKey:@"login"];
    NSString *action = [[event valueForKey:@"payload"] valueForKey:@"action"];
    NSNumber *gistId = [[[event valueForKey:@"payload"] valueForKey:@"gist"] valueForKey:@"id"];
    NSString *message = [NSString stringWithFormat:@"%@ %@d gist %@", actorLogin, action, gistId];
    NSString *url = [[[event valueForKey:@"payload"] valueForKey:@"gist"] valueForKey:@"html_url"];
    
    [dict setValue:message forKey:@"message"];
    [dict setValue:url forKey:@"url"];
    
    return dict;
}

- (NSDictionary *) getGollum:(NSDictionary *)event{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    NSString *actorLogin = [[event valueForKey:@"actor"] valueForKey:@"login"];
    NSString *repository = [[event valueForKey:@"repo"] valueForKey:@"name"];
    NSArray *pages = [[event valueForKey:@"payload"] valueForKey:@"pages"];
    
    NSString *message = nil;
    NSString *url = nil;
    
    if ([pages count] > 1) {
        message = [NSString stringWithFormat:@"%@ modified %d pages in the %@ wiki", actorLogin, [pages count], repository];
        url = [NSString stringWithFormat:@"https://github.com/%@/wiki/", repository];
        
    } else {
        
        for (NSDictionary *page in pages) {
            NSString *pageName = [page valueForKey:@"page_name"];
            NSString *action = [page valueForKey:@"action"];
            message = [NSString stringWithFormat:@"%@ %@ the %@ wiki page %@", actorLogin, action, repository, pageName];
            url = [page valueForKey:@"html_url"];
        }
    }
    
    [dict setValue:message forKey:@"message"];
    [dict setValue:url forKey:@"url"];
    
    return dict;
}

- (NSDictionary *) getIssueComment:(NSDictionary *)event{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    NSString *actorLogin = [[event valueForKey:@"actor"] valueForKey:@"login"];
    NSString *action = [[event valueForKey:@"payload"] valueForKey:@"action"];
    NSNumber *issueId = [[[event valueForKey:@"payload"] valueForKey:@"issue"] valueForKey:@"number"];
    NSString *repository = [[event valueForKey:@"repo"] valueForKey:@"name"];
    NSString *message = [NSString stringWithFormat:@"%@ %@ comment on issue %@ on %@", actorLogin, action, issueId, repository];
    NSString *url = [[[event valueForKey:@"payload"] valueForKey:@"issue"] valueForKey:@"html_url"];
    NSString *details = [NSString stringWithFormat:@"%@", [[[event valueForKey:@"payload"] valueForKey:@"comment"] valueForKey:@"body"]];
    
    [dict setValue:message forKey:@"message"];
    [dict setValue:url forKey:@"url"];
    [dict setValue:details forKey:@"details"];
    
    return dict;
}

- (NSDictionary *) getIssue:(NSDictionary *)event{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    NSString *actorLogin = [[event valueForKey:@"actor"] valueForKey:@"login"];
    NSString *action = [[event valueForKey:@"payload"] valueForKey:@"action"];
    NSNumber *issueId = [[[event valueForKey:@"payload"] valueForKey:@"issue"] valueForKey:@"number"];
    NSString *repository = [[event valueForKey:@"repo"] valueForKey:@"name"];
    NSString *message = [NSString stringWithFormat:@"%@ %@ issue %@ on %@", actorLogin, action, issueId, repository];
    NSString *url = [[[event valueForKey:@"payload"] valueForKey:@"issue"] valueForKey:@"html_url"];
    NSString *details = [NSString stringWithFormat:@"%@", [[[event valueForKey:@"payload"] valueForKey:@"issue"] valueForKey:@"title"]];
    
    [dict setValue:message forKey:@"message"];
    [dict setValue:url forKey:@"url"];
    [dict setValue:details forKey:@"details"];
    
    return dict;
}

- (NSDictionary *) getMember:(NSDictionary *)event{
    return [NSMutableDictionary dictionary];
}

- (NSDictionary *) getPublic:(NSDictionary *)event{
    return [NSMutableDictionary dictionary];    
}

- (NSDictionary *) getPull:(NSDictionary *)event{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    NSString *actorLogin = [[event valueForKey:@"actor"] valueForKey:@"login"];
    NSString *action = [[event valueForKey:@"payload"] valueForKey:@"action"];
    NSNumber *pullrequestId = [[event valueForKey:@"payload"] valueForKey:@"number"];
    NSString *repository = [[event valueForKey:@"repo"] valueForKey:@"name"];
    NSString *message = [NSString stringWithFormat:@"%@ %@ on pull request %@ on %@", actorLogin, action, pullrequestId, repository];
    NSString *url = [[[event valueForKey:@"payload"] valueForKey:@"pull_request"] valueForKey:@"html_url"];
    
    NSString *details = [[[event valueForKey:@"payload"] valueForKey:@"pull_request"] valueForKey:@"title"];
    
    [dict setValue:message forKey:@"message"];
    [dict setValue:url forKey:@"url"];
    [dict setValue:details forKey:@"details"];
    
    return dict;    
}

- (NSDictionary *) getPullReview:(NSDictionary *)event{
    return [NSMutableDictionary dictionary];    
}

- (NSDictionary *) getPush:(NSDictionary *)event{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    NSString *actorLogin = [[event valueForKey:@"actor"] valueForKey:@"login"];
    NSNumber *branch = [[event valueForKey:@"payload"] valueForKey:@"ref"];
    NSString *repository = [[event valueForKey:@"repo"] valueForKey:@"name"];
    NSString *message = [NSString stringWithFormat:@"%@ pushed to %@ at %@", actorLogin, branch, repository];
    
    NSNumber *size = [[event valueForKey:@"payload"] valueForKey:@"size"];
    NSString *commit = @"commit";
    if ([size intValue] > 1) {
        commit = @"commits";
    }
    NSString *details = [NSString stringWithFormat:@"%@ new %@", size, commit];
    NSString *url = [NSString stringWithFormat:@"https://github.com/%@/commits/", repository];
    
    NSArray *commits = [[event valueForKey:@"payload"] valueForKey:@"commits"];
    if (commits && [commits count] == 1) {
        url = [NSString stringWithFormat:@"https://github.com/%@/commit/%@", repository, [[commits objectAtIndex:0] valueForKey:@"sha"]];
    }
    
    [dict setValue:message forKey:@"message"];
    [dict setValue:details forKey:@"details"];
    [dict setValue:url forKey:@"url"];
    
    return dict;    
}

- (NSDictionary *) getTeam:(NSDictionary *)event{
    return [NSMutableDictionary dictionary];    
}

- (NSDictionary *) getWatch:(NSDictionary *)event{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        
    NSString *actorLogin = [[event valueForKey:@"actor"] valueForKey:@"login"];
    NSString *action = [[event valueForKey:@"payload"] valueForKey:@"action"];
    NSString *repository = [[event valueForKey:@"repo"] valueForKey:@"name"];
    NSString *message = [NSString stringWithFormat:@"%@ %@ watching %@", actorLogin, action, repository];
    NSString *url = [NSString stringWithFormat:@"https://github.com/%@", repository];
    
    [dict setValue:message forKey:@"message"];
    [dict setValue:url forKey:@"url"];
    
    return dict;    
}

#pragma mark - menulet manipulation
- (void) updateEventMenu:(NSDictionary *) event {
    if (!event) {
        return;
    }
    
    NSString *type = [event valueForKey:@"type"];
    
    if (!type) {
        return;
    }
        
    if ([CommitCommentEvent isEqualToString:type]) {
        [menuController addEvent:[self getCommit:event] top:YES];
        
    } else if ([CreateEvent isEqualToString:type]) {
        
        [menuController addEvent:[self getCreate:event] top:YES];
        
    } else if ([DeleteEvent isEqualToString:type]) {
        
        [menuController addEvent:[self getDelete:event] top:YES];
        
    } else if ([DownloadEvent isEqualToString:type]) {
        
        [menuController addEvent:[self getDownload:event] top:YES];
        
    } else if ([FollowEvent isEqualToString:type]) {
        
        [menuController addEvent:[self getFollow:event] top:YES];
        
    } else if ([ForkEvent isEqualToString:type]) {
        
        [menuController addEvent:[self getFork:event] top:YES];
        
    } else if ([ForkApplyEvent isEqualToString:type]) {
        
    } else if ([GistEvent isEqualToString:type]) {
        
        [menuController addEvent:[self getGist:event] top:YES];
        
    } else if ([GollumEvent isEqualToString:type]) {
        
        [menuController addEvent:[self getGollum:event] top:YES];
        
    } else if ([IssueCommentEvent isEqualToString:type]) {
        
        [menuController addEvent:[self getIssueComment:event] top:YES];
        
    } else if ([IssuesEvent isEqualToString:type]) {
        
        [menuController addEvent: [self getIssue:event] top:YES];
        
    } else if ([MemberEvent isEqualToString:type]) {
        
    } else if ([PublicEvent isEqualToString:type]) {
        
    } else if ([PullRequestEvent isEqualToString:type]) {
        
        [menuController addEvent:[self getPull:event] top:YES];
        
    } else if ([PullRequestReviewCommentEvent isEqualToString:type]) {
        
    } else if ([PushEvent isEqualToString:type]) {
        
       [menuController addEvent:[self getPush:event] top:YES];
        
    } else if ([TeamAddEvent isEqualToString:type]) {
        
    } else if ([WatchEvent isEqualToString:type]) {
        
        [menuController addEvent:[self getWatch:event] top:YES];
        
    } else {
        // NOP
    }
}


- (void)dealloc {
    [super dealloc];
}

@end
