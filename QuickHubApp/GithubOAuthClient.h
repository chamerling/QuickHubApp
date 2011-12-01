//
//  GithubOAuthClient.h
//  QuickHub
//
//  Created by Christophe Hamerling on 01/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define oauthey @"2736c4fc084dbb25156b6bb4635275048e5415ef"

@interface GithubOAuthClient : NSObject

- (NSDictionary*) loadUser:(id) sender;

@end
