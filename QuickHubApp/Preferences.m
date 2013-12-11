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

#import "Preferences.h"
#import "QHConstants.h"

static Preferences *sharedInstance = nil;

@implementation Preferences

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

-(void)setDefault {
    [self storeLogin:@"" withPassword:@""];
}

- (void) setStandardUserDefault {
    
    // Set some default values for preferences. The framework will use them if they are not already set.
    // If they are, they will be ignored.
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary * states = [NSMutableDictionary dictionaryWithCapacity:18];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHCommitCommentEvent];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHCreateEvent];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHDeleteEvent];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHDownloadEvent];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHFollowEvent];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHForkApplyEvent];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHForkEvent];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHGistEvent];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHGollumEvent];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHIssueCommentEvent];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHIssuesEvent];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHMemberEvent];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHPublicEvent];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHPullRequestEvent];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHPullRequestReviewCommentEvent];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHPushEvent];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHTeamAddEvent];
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHWatchEvent];
    
    [states setObject:[NSNumber numberWithBool:YES] forKey:GHEventActive];

    [states setObject:[NSNumber numberWithBool:YES] forKey:PREF_SHOW_ACTIONS];

    [userdefaults registerDefaults:states];
}

- (NSString *)login {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *result = [prefs stringForKey:@"userID"];
    if (!result) {
        result = @"";
    }
    return result;
}

- (NSString *)password {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *result = [prefs stringForKey:@"pwd"];

    if (!result) {
        result = @"";
    }
    return result;
}

- (NSString *)oauthToken {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *result = [prefs stringForKey:@"oauth"];
    
    if (!result) {
        result = @"";
    }
    return result;
}

- (void) storeLogin:(NSString*)login withPassword:(NSString*)password{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:login forKey:@"userID"];
    [prefs setObject:password forKey:@"pwd"];
}

- (void) deleteOldPreferences {
    [self setDefault];
}

- (void) storeToken:(NSString*)token {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:token forKey:@"oauth"];
}

- (void) put:(NSString *) key value:(id) value {
    if (!key) {
        return;
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:value forKey:[NSString stringWithFormat:@"%@.%@", APP_PREFIX, key]];
}

- (id) get:(NSString *) key {
    if (!key) {
        return nil;
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs valueForKey:[NSString stringWithFormat:@"%@.%@", APP_PREFIX, key]];    
}

+ (Preferences *)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[Preferences alloc] init];
    }
    return sharedInstance;
}

@end
