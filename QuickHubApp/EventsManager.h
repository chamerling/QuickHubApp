//
//  EventsManager.h
//  QuickHub
//
//  Created by Christophe Hamerling on 15/04/12.
//  Copyright 2012 christophehamerling.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuController.h"

@interface EventsManager : NSObject {
    NSMutableArray *events;
    NSMutableSet *eventIds;
    
    MenuController *menuController;
}

@property(nonatomic, retain) MenuController *menuController;

- (void) addEventsFromDictionary:(NSDictionary *) events;
- (NSArray *) getEvents;
- (void) clearEvents;

@end
