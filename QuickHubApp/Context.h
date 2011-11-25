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
}
    
+ (Context *)sharedInstance;

@property (nonatomic, assign) NSString *remainingCalls;

@end
