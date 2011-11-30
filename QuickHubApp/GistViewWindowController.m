//
//  GistViewWindowController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 29/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
