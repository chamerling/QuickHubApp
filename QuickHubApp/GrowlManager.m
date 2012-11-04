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

static GrowlManager *sharedInstance = nil;

@interface GrowlManager (Private)
- (void)genericListener:(NSNotification *)aNotification;
- (void)issueAdded:(NSNotification *)aNotification;
- (void)gistAdded:(NSNotification *)aNotification;
- (void)gistCreated:(NSNotification *)aNotification;
- (void)displayNotificationUsingNotificationCenterWithDetails:(NSDictionary *)details;
@end

@implementation GrowlManager

+ (GrowlManager *)get {
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[GrowlManager alloc] init];
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [GrowlApplicationBridge setGrowlDelegate:self];
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    }
    return self;
}

- (void) awakeFromNib {    
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
    [self notifyWithName:@"QuickHub" desc:message context:nil];
}

-(void)issueAdded:(NSNotification *)aNotification {
    NSString *message = [aNotification object];
    [self notifyWithName:@"New Issue" desc:message context:nil];
}

-(void)gistAdded:(NSNotification *)aNotification {
    NSString *message = [aNotification object];
    [self notifyWithName:@"New Gist" desc:message context:nil];
}

- (void)gistCreated:(NSNotification *)aNotification {
    NSDictionary *dict = [aNotification object];
    [self notifyWithName:@"Gist created" desc:[NSString stringWithFormat:@"New Gist ID is %@", [dict valueForKey:@"id"]] context:dict];
}

#pragma mark - growl delegate
- (NSDictionary *)registrationDictionaryForGrowl {
    NSArray *notifications = [NSArray arrayWithObjects: @"QuickHub", @"Github", @"GitHub", nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          notifications, GROWL_NOTIFICATIONS_ALL,
                          notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
    return dict;
}

- (void)growlNotificationWasClicked:(id)clickContext {
    NSDictionary *context = clickContext;
    if (context) {
        if ([context valueForKey:@"url"]) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[context valueForKey:@"url"]]];

        }
    }
}

#pragma mark - implementation
- (void) notifyWithName:(NSString *)name desc:(NSString *)description context:(NSDictionary*)context {
    
    if (![self notificationsEnabled:nil]) {
        return;
    }
    
    if ([self growlAvailable:nil] && [self growlEnabled:nil]) {
        NSImage *image = [[[NSImage alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForImageResource:growllogo]] autorelease];
        
        [GrowlApplicationBridge notifyWithTitle:name
                                    description:description
                               notificationName:@"QuickHub"
                                       iconData:[image TIFFRepresentation]
                                       priority:0
                                       isSticky:NO
                                   clickContext:context];
    }
    
    if ([self notificationCenterAvailable:nil] && [self notificationCenterEnabled:nil]) {
        NSMutableDictionary *notificationDetails = [[NSMutableDictionary alloc] init];
        notificationDetails[@"name"] = name;
        notificationDetails[@"description"] = description;
        [self displayNotificationUsingNotificationCenterWithDetails:[notificationDetails copy]]; 
    } else {
        
    }
}

- (void)notifyWithName:(NSString*)name desc:(NSString*)description url:(NSString *)urlToOpen icon:(NSURL *) iconURL {
    
    if (![self notificationsEnabled:nil]) {
        return;
    }
    
    if ([self growlAvailable:nil] && [self growlEnabled:nil]) {
        NSImage *image = nil;
        if (iconURL) {
            image = [[[NSImage alloc] initWithContentsOfURL:iconURL] autorelease];
            
        } else {
            image = [[[NSImage alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForImageResource:growllogo]] autorelease];
        }
        
        NSDictionary *context = nil;
        if (urlToOpen) {
            context = [[NSMutableDictionary alloc] init];
            [context setValue:urlToOpen forKey:@"url"];
        }
        
        NSString *notificationName = @"QuickHub";
        if (name) {
            notificationName = name;
        }
        
        [GrowlApplicationBridge notifyWithTitle:notificationName
                                    description:description
                               notificationName:@"QuickHub"
                                       iconData:[image TIFFRepresentation]
                                       priority:0
                                       isSticky:NO
                                   clickContext:context];
    }
    
    if ([self notificationCenterAvailable:nil] && [self notificationCenterEnabled:nil]) {
        NSMutableDictionary *notificationDetails = [[NSMutableDictionary alloc] init];
        notificationDetails[@"name"] = name;
        notificationDetails[@"description"] = description;
        notificationDetails[@"url"] = urlToOpen;
        [self displayNotificationUsingNotificationCenterWithDetails:[notificationDetails copy]];
    }
}

- (void)notifyWithName:(NSString*)name desc:(NSString*)description url:(NSString *)urlToOpen iconName:(NSString *) iconName {
    
    if (![self notificationsEnabled:nil]) {
        return;
    }
    
    if ([self growlAvailable:nil] && [self growlEnabled:nil]) {
        NSImage *image = nil;
        if (iconName && [[NSBundle mainBundle] URLForImageResource:iconName]) {
            image = [[[NSImage alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForImageResource:iconName]] autorelease];
        } else {
            image = [[[NSImage alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForImageResource:growllogo]] autorelease];
        }
        
        NSDictionary *context = nil;
        if (urlToOpen) {
            context = [[NSMutableDictionary alloc] init];
            [context setValue:urlToOpen forKey:@"url"];
        }
        
        NSString *notificationName = @"QuickHub";
        if (name) {
            notificationName = name;
        }
        
        [GrowlApplicationBridge notifyWithTitle:notificationName
                                    description:description
                               notificationName:@"QuickHub"
                                       iconData:[image TIFFRepresentation]
                                       priority:0
                                       isSticky:NO
                                   clickContext:context];
    }
    
    if ([self notificationCenterAvailable:nil] && [self notificationCenterEnabled:nil]) {
        NSMutableDictionary *notificationDetails = [[NSMutableDictionary alloc] init];
        notificationDetails[@"name"] = name;
        notificationDetails[@"description"] = description;
        notificationDetails[@"url"] = urlToOpen;
        [self displayNotificationUsingNotificationCenterWithDetails:[notificationDetails copy]];
    }
}

#pragma mark - Notifiers checking

- (BOOL) growlAvailable:(id)sender {
    return [GrowlApplicationBridge isGrowlRunning];
}

- (BOOL) growlEnabled:(id)sender {
    return [[NSUserDefaults standardUserDefaults] boolForKey:NOTIFICATION_GROWL];
}

- (BOOL) notificationCenterEnabled:(id) sender {
    BOOL centerEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:NOTIFICATION_OSX];
    return centerEnabled;
}

- (BOOL) notificationCenterAvailable:(id) sender {
    Class notificationCenterClass = NSClassFromString(@"NSUserNotificationCenter");
    if(!notificationCenterClass) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - private methods

- (void)displayNotificationUsingNotificationCenterWithDetails:(NSDictionary *)details
{    
    if (![self notificationsEnabled:nil]) {
        return;
    }
    
    BOOL scheduledNotification = NO;
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    if(details[@"title"]) {
        notification.title = details[@"title"];
    } else {
        notification.title = @"QuickHub";
    }
    
    if(details[@"description"])
        notification.informativeText = details[@"description"];
    
    if(details[@"subtitle"])
        notification.subtitle = details[@"subtitle"];
    
    if(details[@"sound"]) {
        notification.soundName = details[@"sound"];
    } else {
        // get the sound to play from the preferences
        // (if selected)
    }
    
    if(details[@"actionbutton"])
        notification.hasActionButton = [details[@"actionbutton"] boolValue];
    
    if(details[@"actionbuttontitle"])
        notification.actionButtonTitle = details[@"actionbuttontitle"];
    
    if(details[@"deliverydate"]){
        notification.deliveryDate = details[@"deliverydate"];
        scheduledNotification = YES;
    }
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    if(details[@"url"]) {
        userInfo[@"url"] = details[@"url"];
    }
    
    notification.userInfo = [userInfo copy];

    if(scheduledNotification) {
        [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
    } else {
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
}

- (BOOL) notificationsEnabled:(id) sender {
    return [[NSUserDefaults standardUserDefaults] boolForKey:QUICKHUB_NOTIFICATION_ACTIVE];
}

#pragma mark - NSNotification delegate
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    NSLog(@"Notification clicked!");
    // get the URL from the dictionary and open it if any
    if ([notification userInfo] && [[notification userInfo] valueForKey:@"url"]) {
        // open the URL
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[notification userInfo] valueForKey:@"url"]]];
    }
}

// RTFM
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

@end
