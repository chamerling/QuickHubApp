//
//  EventMenuItemController.h
//  QuickHub
//
//  Created by Christophe Hamerling on 24/04/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EventMenuItemController : NSViewController {
    NSDictionary *event;
    NSTextField *messageLabel;
    NSTextField *detailsLabel;
}

@property (assign) IBOutlet NSTextField *messageLabel;
@property (assign) IBOutlet NSTextField *detailsLabel;

@property (assign) NSDictionary *event;

@end
