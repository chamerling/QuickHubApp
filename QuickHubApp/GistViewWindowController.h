//
//  GistViewWindowController.h
//  QuickHub
//
//  Created by Christophe Hamerling on 29/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GitHubController.h"

@interface GistViewWindowController : NSWindowController {
    NSTextField *gistTitleField;
    NSTextField *descriptionField;
    NSTextView *gstContentField;
    NSImageView *starImage;
    NSProgressIndicator *statusIndicator;
    NSImageView *privacyBullert;
    NSTextField *publicCloneURLField;
    NSTextField *privateCloneURLField;
    NSTextField *createdAtField;
    
    NSArray *gist;
    NSImageView *privacyBullet;
}
@property (assign) IBOutlet NSImageView *privacyBullet;

@property (assign) NSArray *gist;

@property (assign) IBOutlet NSTextField *publicCloneURLField;
@property (assign) IBOutlet NSTextField *privateCloneURLField;
@property (assign) IBOutlet NSTextField *createdAtField;
@property (assign) IBOutlet NSTextField *gistTitleField;
@property (assign) IBOutlet NSTextField *descriptionField;
@property (assign) IBOutlet NSTextView *gstContentField;
@property (assign) IBOutlet NSImageView *starImage;
@property (assign) IBOutlet NSProgressIndicator *statusIndicator;

- (IBAction)favoriteAction:(id)sender;
- (IBAction)updateAction:(id)sender;

@end
