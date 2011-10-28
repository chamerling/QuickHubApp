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
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSLog(@"Preferences = %@ ", prefs);
    }
    
    return self;
}

-(void)setDefault {
    NSLog(@"Setting initial defaults...");
    [self storeLogin:@"" withPassword:@""];
}

- (NSString *)login {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *result = [prefs stringForKey:@"userID"];
    if (!result) {
        result = [NSString stringWithString:@""];
    }
    return result;
}

- (NSString *)password {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *result = [prefs stringForKey:@"pwd"];

    if (!result) {
        result = [NSString stringWithString:@""];
    }
    return result;
}

- (void) storeLogin:(NSString*)login withPassword:(NSString*)password{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:login forKey:@"userID"];
    [prefs setObject:password forKey:@"pwd"];
}

+ (Preferences *)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[Preferences alloc] init];
    }
    return sharedInstance;
}

@end
