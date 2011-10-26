//
//  GrowlManager.m
//  QuickHubApp
//
// Register to the notification center and react on notifications : display growl stuff
//
//  Created by Christophe Hamerling on 25/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GrowlManager.h"
#import "QHConstants.h"

@interface GrowlManager (Private)
- (void)notifyWithNewCommits:(NSNotification *)aNotification;
- (void)notifyWithRepositoriesAdditions:(NSNotification *)aNotification;
- (void)notifyWithRepositoriesRemovals:(NSNotification *)aNotification;
- (void)notifyWithNewPush:(NSNotification *)aNotification;
- (void)notifyWithWatchersAdded:(NSNotification *)aNotification;
- (void)notifyWithGistsAdded:(NSNotification *)aNotification;
- (void)notifyWithGistsRemoved:(NSNotification *)aNotification;
- (void)notifyWithOrgsAdded:(NSNotification *)aNotification;
- (void)notifyWithOrgsDeleted:(NSNotification *)aNotification;
- (void)notifyWithIssueAdded:(NSNotification *)aNotification;
- (void)notifyWithIssueDeleted:(NSNotification *)aNotification;
- (void)genericListener:(NSNotification *)aNotification;
@end

@implementation GrowlManager

- (void) awakeFromNib {
    NSLog(@"Registering notification listeners for growl");
    [GrowlApplicationBridge setGrowlDelegate:self];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyWithRepositoriesAdditions:)
												 name:GITHUB_NOTIFICATION_REPOSITORIES_ADDED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyWithRepositoriesRemovals:)
												 name:GITHUB_NOTIFICATION_REPOSITORIES_REMOVED
											   object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(genericListener:)
                                                 name:GENERIC_NOTIFICATION
                                               object:nil];
}

- (void)notifyWithNewCommits:(NSNotification *)aNotification {
    
}

- (void)notifyWithNewPush:(NSNotification *)aNotification {
    
}

-(void)notifyWithRepositoriesAdditions:(NSNotification *)aNotification {
    
}

- (void)notifyWithRepositoriesRemovals:(NSNotification *)aNotification {
    
}

- (void)notifyWithWatchersAdded:(NSNotification *)aNotification {
    
}

- (void)notifyWithGistsAdded:(NSNotification *)aNotification {
    NSString *gistName = @"";//[aNotification object];
    [self notifyWithName:@"QuickHub" desc:[NSString stringWithFormat:@"Gist '%@' added", gistName]];
}

- (void)notifyWithGistsRemoved:(NSNotification *)aNotification {
    NSString *gistName = @"";//[aNotification object];
    [self notifyWithName:@"QuickHub" desc:[NSString stringWithFormat:@"Gist '%@' removed", gistName]];
}

- (void)notifyWithOrgsAdded:(NSNotification *)aNotification {
    NSString *orgName = @"";//[aNotification object];
    [self notifyWithName:@"QuickHub" desc:[NSString stringWithFormat:@"Orgnization '%@' added", orgName]];
}

- (void)notifyWithOrgsDeleted:(NSNotification *)aNotification {
    [self notifyWithName:@"QuickHub" desc:@"Organization deleted!"];
}

- (void)notifyWithIssueAdded:(NSNotification *)aNotification {
    [self notifyWithName:@"QuickHub" desc:@"There is a new issue"];
}

- (void)notifyWithIssueDeleted:(NSNotification *)aNotification {
    [self notifyWithName:@"QuickHub" desc:@"Issue deleted"];
}

-(void)genericListener:(NSNotification *)aNotification {
    NSLog(@"Got a notification to growl...");
    NSString *message = [aNotification object];
    [self notifyWithName:@"QuickHub" desc:message];
}

#pragma mark - growl
- (NSDictionary *)registrationDictionaryForGrowl {
    NSArray *notifications = [NSArray arrayWithObject: @"QuickHub"];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          notifications, GROWL_NOTIFICATIONS_ALL,
                          notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
    return dict;
}

- (void) notifyWithName:(NSString *)name desc:(NSString *)description {
    NSImage *image = [[[NSImage alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForImageResource:growllogo]] autorelease];

    [GrowlApplicationBridge notifyWithTitle:name
								description:description
						   notificationName:@"QuickHub"
								   iconData:[image TIFFRepresentation]
								   priority:0
								   isSticky:NO
							   clickContext:nil];    
}

@end
