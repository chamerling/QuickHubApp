//
//  Preferences.h
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

#import <Foundation/Foundation.h>

@interface Preferences : NSObject {
    BOOL filled;
}

- (void) setDefault;

// deprecated
- (NSString *) login;
- (NSString *) password;

// use oauth
- (NSString *) oauthToken;

- (void) storeLogin:(NSString*)login withPassword:(NSString*)password;
- (void) deleteOldPreferences;
- (void) storeToken:(NSString*)token;

+ (Preferences *)sharedInstance;

@end
