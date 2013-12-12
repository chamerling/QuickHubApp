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
    
    NSAssert([NSThread isMainThread], @"Should be on main thread");
    
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
        NSMutableDictionary *notificationDetails = [NSMutableDictionary dictionaryWithObjectsAndKeys:name, @"name", description, @"description", nil];
        [self displayNotificationUsingNotificationCenterWithDetails:notificationDetails];
    } else {
        
    }
}

- (void)notifyWithName:(NSString*)name desc:(NSString*)description url:(NSString *)urlToOpen icon:(NSURL *) iconURL {
    
    NSAssert([NSThread isMainThread], @"Should be on main thread");
    
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
        NSMutableDictionary *notificationDetails = [NSMutableDictionary dictionaryWithObjectsAndKeys:name, @"name", description, @"description", urlToOpen, @"url", nil];
        [self displayNotificationUsingNotificationCenterWithDetails:notificationDetails];
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
        NSMutableDictionary *notificationDetails = [NSMutableDictionary dictionaryWithObjectsAndKeys:name, @"name", description, @"description", urlToOpen, @"url", nil];
        [self displayNotificationUsingNotificationCenterWithDetails:notificationDetails];
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
    NSAssert([NSThread isMainThread], @"Should be on main thread");
    
    if (![self notificationsEnabled:nil]) {
        return;
    }
    
    BOOL scheduledNotification = NO;
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    if([details valueForKey:@"title"]) {
        notification.title = [details valueForKey:@"title"];
    } else {
        notification.title = @"QuickHub";
    }
    
    if([details valueForKey:@"description"])
        notification.informativeText = [details valueForKey:@"description"];
    
    if([details valueForKey:@"subtitle"])
        notification.subtitle = [details valueForKey:@"subtitle"];
    
    if([details valueForKey:@"sound"]) {
        notification.soundName = [details valueForKey:@"sound"];
    } else {
        // get the sound to play from the preferences
        // (if selected)
    }
    
    if([details valueForKey:@"actionbutton"])
        notification.hasActionButton = [[details valueForKey:@"actionbutton"] boolValue];
    
    if([details valueForKey:@"actionbuttontitle"])
        notification.actionButtonTitle = [details valueForKey:@"actionbuttontitle"];
    
    if([details valueForKey:@"deliverydate"]){
        notification.deliveryDate = [details valueForKey:@"deliverydate"];
        scheduledNotification = YES;
    }
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    if([details valueForKey:@"url"]) {
        [userInfo setValue:[details valueForKey:@"url"] forKey:@"url"];
    }
    
    notification.userInfo = userInfo;
    [userInfo release];
    
    if(scheduledNotification) {
        [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
    } else {
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
    
    [notification release];
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
