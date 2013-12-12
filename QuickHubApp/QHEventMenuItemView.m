// (The MIT License)
//
// Copyright (c) 2013 Christophe Hamerling <christophe.hamerling@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// 'Software'), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "QHEventMenuItemView.h"

@implementation QHEventMenuItemView

@synthesize messageField;
@synthesize detailsField;
@synthesize event = _event;

- (void)setEvent:(NSDictionary *)event
{
    if (![_event isEqualToDictionary:event]) {
        [_event release];
        _event = nil;
        
        _event = [event retain];
    }
    
    [self updateUI];
}

- (void)updateUI
{
    // set data
    NSString *title = [_event objectForKey:@"message"];
    if(!title || [title length] == 0) {
        title = @"(no message)";
    }
    [messageField setStringValue:title];
    
    NSString *details = [_event objectForKey:@"details"];
    if(!details || [details length] == 0) {
        details = @"-";
    }
    [detailsField setStringValue:details];

}

- (void)drawRect:(NSRect)rect
{
    BOOL isHighlighted = [[self enclosingMenuItem] isHighlighted];
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

- (void)mouseDown:(NSEvent *)event
{
    // TODO : Check http://cocoatricks.com/2010/07/a-label-color-picker-menu-item-2/ for blink selection
    NSMenuItem *mitem = [self enclosingMenuItem];
    NSMenu *m = [mitem menu];
    
    [m cancelTracking];
    [m performActionForItemAtIndex: [m indexOfItem: mitem]];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)dealloc
{
    [_event release];
    [super dealloc];
}

@end
