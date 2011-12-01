//
//  GithubOAuthClient.m
//  QuickHub
//
//  Created by Christophe Hamerling on 01/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GithubOAuthClient.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"

@implementation GithubOAuthClient

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSDictionary*) loadUser:(id) sender {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/user?access_token=2736c4fc084dbb25156b6bb4635275048e5415ef"]];
    [request setDelegate:self];
    [request startSynchronous];
    NSDictionary *result = [[request responseString] objectFromJSONString];
    // DO not release the request, it cause failures on the threads...
    //[request release];
    return result;
}

@end
