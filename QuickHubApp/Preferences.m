//
//  Preferences.m
//  GHApp
//
//  Created by Christophe Hamerling on 12/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "Preferences.h"

static Preferences *sharedInstance = nil;

@implementation Preferences

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self loadData];
    }
    
    return self;
}

-(void)saveData {
    if ([prefs writeToFile:[self path] atomically:YES])
        NSLog(@"Successfully wrote preferences to disk.");
    else
        NSLog(@"Failed to write preferences to disk. Permissions problem in ~/Library/Preferences?");
}

- (void) loadData {
    prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:[self path]];
    if (!prefs) {
        prefs = [[NSMutableDictionary alloc] init];
        [self setDefault];
    }
}

-(NSString *)path {
    // TODO : Use API
    return [@"~/Library/Preferences/org.chamerling.QuickHubApp-Preferences.plist" stringByExpandingTildeInPath];
}

-(void)setDefault {
    NSLog(@"Setting initial defaults...");
    [self storeLogin:@"" withPassword:@""];
}

- (NSString *)login {
    return (NSString *)[prefs objectForKey:@"userID"];
}

- (NSString *)password {
    return (NSString *)[prefs objectForKey:@"pwd"];    
}

- (void) storeLogin:(NSString*)login withPassword:(NSString*)password{
    [prefs setObject:login forKey:@"userID"];
    [prefs setObject:password forKey:@"pwd"];
    [self saveData];
}

+ (Preferences *)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[Preferences alloc] init];
    }
    return sharedInstance;
}

@end
