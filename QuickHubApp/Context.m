//
//  Context.m
//  QuickHub
//
//  Created by Christophe Hamerling on 25/11/11.
//  Copyright 2011 christophehamerling.com. All rights reserved.
//

#import "Context.h"

static Context *sharedInstance = nil;

@implementation Context

@synthesize remainingCalls;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (Context *)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[Context alloc] init];
    }
    return sharedInstance;
}

@end
