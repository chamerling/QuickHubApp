//
//  Context.h
//  QuickHub
//
//  Created by Christophe Hamerling on 25/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Context : NSObject
{
    NSString *remainingCalls;
    NSSet *repositories;
}
    
+ (Context *)sharedInstance;
- (void) cleanAll;

@property (nonatomic, assign) NSString *remainingCalls;
@property (nonatomic, assign) NSSet *repositories;

@end
