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
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyWithRepositoriesAdditions:)
												 name:GITHUB_NOTIFICATION_REPOSITORIES_ADDED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyWithRepositoriesRemovals:)
												 name:GITHUB_NOTIFICATION_REPOSITORIES_REMOVED
											   object:nil];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notifyWithNewPush:)
                                                 name:GITHUB_NOTIFICATION_COMMITS_PUSHED
                                               object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notifyWithWatchersAdded:)
                                                 name:GITHUB_NOTIFICATION_WATCHERS_ADDED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(genericListener:)
                                                 name:@"GenericListener"
                                               object:nil];
	
	
	[GrowlApplicationBridge setGrowlDelegate:self];
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
    //NSMutableDictionary *context = [NSMutableDictionary dictionary];
	[GrowlApplicationBridge notifyWithTitle:@"QuickHub"
								description:@"New gist have been added"
						   notificationName:@"QuickHub"
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}

- (void)notifyWithGistsRemoved:(NSNotification *)aNotification {
    [GrowlApplicationBridge notifyWithTitle:@"QuickHub"
								description:@"Gist deleted"
						   notificationName:@"QuickHub"
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];

}

- (void)notifyWithOrgsAdded:(NSNotification *)aNotification {
    [GrowlApplicationBridge notifyWithTitle:@"QuickHub"
								description:@"Orgs added!"
						   notificationName:@"QuickHub"
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}

- (void)notifyWithOrgsDeleted:(NSNotification *)aNotification {
    [GrowlApplicationBridge notifyWithTitle:@"QuickHub"
								description:@"Orgs deleted!"
						   notificationName:@"QuickHub"
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];

}

- (void)notifyWithIssueAdded:(NSNotification *)aNotification {
    [GrowlApplicationBridge notifyWithTitle:@"QuickHub"
								description:@"Issue added!"
						   notificationName:@"QuickHub"
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];
  
}

- (void)notifyWithIssueDeleted:(NSNotification *)aNotification {
    [GrowlApplicationBridge notifyWithTitle:@"QuickHub"
								description:@"Issue deleted!"
						   notificationName:@"QuickHub"
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];
  
}

-(void)genericListener:(NSNotification *)aNotification {
    NSLog(@"Got a notification");
    [GrowlApplicationBridge notifyWithTitle:@"QuickHub"
								description:@"Got a notification..."
						   notificationName:@"QuickHub"
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}

#pragma mark - growl
- (NSDictionary *)registrationDictionaryForGrowl {
    NSArray *notifications = [NSArray arrayWithObject: @"QuickHub"];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          notifications, GROWL_NOTIFICATIONS_ALL,
                          notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
    return dict;
}

@end
