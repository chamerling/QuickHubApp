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
- (void)genericListener:(NSNotification *)aNotification;
- (void)issueAdded:(NSNotification *)aNotification;
- (void)gistAdded:(NSNotification *)aNotification;
@end

@implementation GrowlManager

- (void) awakeFromNib {
    NSLog(@"Registering notification listeners for growl");
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(genericListener:)
                                                 name:GENERIC_NOTIFICATION
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(genericListener:)
                                                 name:GITHUB_NOTIFICATION_ISSUE_ADDED
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(genericListener:)
                                                 name:GITHUB_NOTIFICATION_GIST_ADDED
                                               object:nil];
    
    [GrowlApplicationBridge setGrowlDelegate:self];
    NSLog(@"delegate set");
}

-(void)genericListener:(NSNotification *)aNotification {
    NSString *message = [aNotification object];
    NSLog(@"Got a notification to growl '%@'...", message);
    [self notifyWithName:@"QuickHub" desc:message];
}

-(void)issueAdded:(NSNotification *)aNotification {
    NSString *message = [aNotification object];
    NSLog(@"Got a issue notification to growl '%@'...", message);
    [self notifyWithName:@"QuickHub - New Issue" desc:message];
}

-(void)gistAdded:(NSNotification *)aNotification {
    NSString *message = [aNotification object];
    NSLog(@"Got a gist notification to growl '%@'...", message);
    [self notifyWithName:@"QuickHub - New Gist" desc:message];
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
    NSLog(@"Let's really notify '%@' '%@'!", name, description);
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
