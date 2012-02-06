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
    NSTextField *urlLabel;
    NSTextField *statsLabel;
}
@property (nonatomic, retain) NSDictionary *repositoryData;
@property (assign) IBOutlet NSTextField *createdAtLabel;
@property (assign) IBOutlet NSTextField *pushedAtField;

@property (nonatomic, retain) IBOutlet NSTextField *urlLabel;
@property (nonatomic, retain) IBOutlet NSTextField *statsLabel;
@property (nonatomic, retain) IBOutlet NSTextField *repositoryLabel;
@property (assign) IBOutlet NSImageView *publicPrivateImage;
@property (assign) IBOutlet NSImageView *forkImage;

- (IBAction)cloneAction:(id)sender;
- (IBAction) openHome:(id)sender;
- (IBAction)debug:(id)sender;

@end
