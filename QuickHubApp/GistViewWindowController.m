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

#import "GistViewWindowController.h"

@implementation GistViewWindowController
@synthesize publicCloneURLField;
@synthesize privateCloneURLField;
@synthesize createdAtField;
@synthesize gistTitleField;
@synthesize descriptionField;
@synthesize gstContentField;
@synthesize starImage;
@synthesize statusIndicator;
@synthesize privacyBullet;
@synthesize gist;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    // get the gist from github
    [statusIndicator setHidden:FALSE];
    [statusIndicator startAnimation:nil];
        
    // fill data
    [descriptionField setStringValue:[gist valueForKey:@"description"]];
    [createdAtField setStringValue:[gist valueForKey:@"created_at"]];
    [gistTitleField setStringValue:[gist valueForKey:@"description"]];
    NSNumber *pub = [gist valueForKey:@"public"];
    NSImage* iconImage = nil;
    if ([pub boolValue]) {
        iconImage = [NSImage imageNamed: @"bullet_green.png"];
    } else {
        iconImage = [NSImage imageNamed: @"bullet_red.png"];
    }
    [privacyBullet setImage:iconImage];
    
    [publicCloneURLField setStringValue:[gist valueForKey:@"html_url"]];
    
    // get the content
    NSArray* files = [gist valueForKey:@"files"];
    if (files) {
        for (NSArray *currentGist in files) {
            for (NSArray *data in currentGist) {
            NSLog(@"Current Gist : %@", data);
            [descriptionField setStringValue:[data valueForKey:@"filename"]];
            [gstContentField setString:[data valueForKey:@"content"]];
            }
        }
    }
    
    [statusIndicator stopAnimation:nil];
    [statusIndicator setHidden:TRUE];
}

- (IBAction)favoriteAction:(id)sender {
    [statusIndicator setHidden:FALSE];
    [statusIndicator startAnimation:nil];
    
    NSLog(@"TODO!");
    
    [statusIndicator stopAnimation:nil];
    [statusIndicator setHidden:TRUE];
}

- (IBAction)updateAction:(id)sender {
    [statusIndicator setHidden:FALSE];
    [statusIndicator startAnimation:nil];

    NSLog(@"TODO!");

    [statusIndicator stopAnimation:nil];
    [statusIndicator setHidden:TRUE];
}
@end
