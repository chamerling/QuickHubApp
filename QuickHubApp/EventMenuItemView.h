//
//  EventMenuItemView.h
//  QuickHub
//
//  Created by Christophe Hamerling on 24/04/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EventMenuItemView : NSView {
    IBOutlet NSTextField* messageField;
    IBOutlet NSTextField* detailsField;
}

@end
