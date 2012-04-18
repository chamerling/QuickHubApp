//
//  EventPreferencesViewController.h
//  QuickHub
//
//  Created by Christophe Hamerling on 17/04/12.
//  Copyright 2012 christophehamerling.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"

@interface EventPreferencesViewController : NSViewController<MASPreferencesViewController,NSWindowDelegate> {
    
    
}

- (IBAction)toggleEvent:(id)sender;

@end
