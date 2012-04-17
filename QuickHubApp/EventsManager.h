//
//  EventsManager.h
//  QuickHub
//
//  Created by Christophe Hamerling on 15/04/12.
//  Copyright 2012 christophehamerling.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventsManager : NSObject {
    NSMutableArray *events;
    NSMutableSet *eventIds;
}

- (void) addEventsFromDictionary:(NSDictionary *) events;
- (NSArray *) getEvents;
- (void) clearEvents;

@end
