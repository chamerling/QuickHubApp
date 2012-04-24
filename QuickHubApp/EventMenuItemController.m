//
//  EventMenuItemController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 24/04/12.
//  Copyright 2012 christophehamerling.com. All rights reserved.
//

#import "EventMenuItemController.h"

@implementation EventMenuItemController

@synthesize messageLabel;
@synthesize detailsLabel;
@synthesize event;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) loadView {
    [super loadView];
    
    // set data
    NSString *title = [event objectForKey:@"message"];
    if(!title || [title length] == 0) {
        title = @"(no message)";
    }
    [messageLabel setStringValue:title];
    
    NSString *details = [event objectForKey:@"details"];
    if(!details || [details length] == 0) {
        details = @"-";
    }
    [detailsLabel setStringValue:details];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)dealloc {
    [messageLabel release];
    [detailsLabel release];
    [super dealloc];
}

@end
