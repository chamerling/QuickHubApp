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
- (void)gistCreated:(NSNotification *)aNotification;
@end

@implementation GrowlManager

- (void) awakeFromNib {
    NSLog(@"Registering notification listeners for growl");
    
    [GrowlApplicationBridge setGrowlDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(genericListener:)
                                                 name:GENERIC_NOTIFICATION
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(issueAdded:)
                                                 name:GITHUB_NOTIFICATION_ISSUE_ADDED
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(gistAdded:)
                                                 name:GITHUB_NOTIFICATION_GIST_ADDED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(gistCreated:)
                                                 name:GITHUB_NOTIFICATION_GIST_CREATED
                                               object:nil];
    
}

-(void)genericListener:(NSNotification *)aNotification {
    NSString *message = [aNotification object];
    NSLog(@"Got a notification to growl '%@'...", message);
    [self notifyWithName:@"QuickHub" desc:message context:nil];
}

-(void)issueAdded:(NSNotification *)aNotification {
    NSString *message = [aNotification object];
    NSLog(@"Got a issue notification to growl '%@'...", message);
    [self notifyWithName:@"QuickHub - New Issue" desc:message context:nil];
}

-(void)gistAdded:(NSNotification *)aNotification {
    NSString *message = [aNotification object];
    NSLog(@"Got a gist notification to growl '%@'...", message);
    [self notifyWithName:@"QuickHub - New Gist" desc:message context:nil];
}

- (void)gistCreated:(NSNotification *)aNotification {
    NSDictionary *dict = [aNotification object];
    NSLog(@"Got a gist creation to growl '%@'...", dict);
    [self notifyWithName:@"QuickHub - Gist created" desc:[NSString stringWithFormat:@"New Gist ID is %@", [dict valueForKey:@"id"]] context:dict];
}

#pragma mark - growl delegate
- (NSDictionary *)registrationDictionaryForGrowl {
    NSArray *notifications = [NSArray arrayWithObject: @"QuickHub"];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          notifications, GROWL_NOTIFICATIONS_ALL,
                          notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
    return dict;
}

- (void)growlNotificationWasClicked:(id)clickContext {
    NSLog(@"Growl notification was clicked...");
    NSDictionary *context = clickContext;
    if (context) {
        if ([context valueForKey:@"url"]) {
            NSLog(@"Let's open...");
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[context valueForKey:@"url"]]];

        }
    }
    
}

- (void) notifyWithName:(NSString *)name desc:(NSString *)description context:(NSDictionary*)context {
    if (![GrowlApplicationBridge isGrowlRunning]) {
        // return now if growl is not installed not running, looks like it can cause problems...
        return;
    }
    
    NSLog(@"Let's really notify '%@' '%@'!", name, description);
    NSImage *image = [[[NSImage alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForImageResource:growllogo]] autorelease];

    [GrowlApplicationBridge notifyWithTitle:name
								description:description
						   notificationName:@"QuickHub"
								   iconData:[image TIFFRepresentation]
								   priority:0
								   isSticky:NO
							   clickContext:context];    
}

@end
