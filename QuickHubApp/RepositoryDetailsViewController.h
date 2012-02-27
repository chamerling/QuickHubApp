//
//  RepositoryDetailsViewController.h
//  QuickHub
//
//  Created by Christophe Hamerling on 06/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RepositoryDetailsViewController : NSViewController {

    NSDictionary *repositoryData;
    NSTextField *createdAtLabel;
    NSTextField *pushedAtField;
    
    NSTextField *repositoryLabel;
    NSImageView *publicPrivateImage;
    NSImageView *forkImage;
    NSTextField *statsLabel;
    IBOutlet NSButton *urlButton;
    NSButton *repoNameButton;
}
@property (assign) IBOutlet NSButton *repoNameButton;
@property (nonatomic, retain) NSDictionary *repositoryData;
@property (assign) IBOutlet NSTextField *createdAtLabel;
@property (assign) IBOutlet NSTextField *pushedAtField;

@property (nonatomic, retain) IBOutlet NSTextField *statsLabel;
@property (nonatomic, retain) IBOutlet NSTextField *repositoryLabel;
@property (assign) IBOutlet NSImageView *publicPrivateImage;
@property (assign) IBOutlet NSImageView *forkImage;

- (IBAction)openURL:(id)sender;
- (IBAction)openRepository:(id)sender;
- (IBAction)cloneAction:(id)sender;

@end
