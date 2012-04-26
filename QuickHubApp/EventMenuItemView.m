//
//  EventMenuItemView.m
//  QuickHub
//
//  Created by Christophe Hamerling on 24/04/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "EventMenuItemView.h"

#define menuItem ([self enclosingMenuItem])

@implementation EventMenuItemView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) drawRect: (NSRect) rect {
    BOOL isHighlighted = [menuItem isHighlighted];
    if (isHighlighted) {
        [[NSColor selectedMenuItemColor] set];
        [NSBezierPath fillRect:rect];
        
        [messageField setTextColor:[NSColor whiteColor]];
        [detailsField setTextColor:[NSColor whiteColor]];
    } else {
        [messageField setTextColor:[NSColor blackColor]];
        [detailsField setTextColor:[NSColor headerColor]];
        
    }
    [super drawRect: rect];
}

- (void)mouseDown:(NSEvent *)event {
    // TODO : Check http://cocoatricks.com/2010/07/a-label-color-picker-menu-item-2/ for blink selection
    
    NSMenuItem* mitem = [self enclosingMenuItem];
    NSMenu* m = [mitem menu];
    
    [m cancelTracking];
    [m performActionForItemAtIndex: [m indexOfItem: mitem]];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

@end
