//
//  UserDetailsViewController.h
//  QuickHub
//
//  Created by Christophe Hamerling on 06/02/12.
//  Copyright 2012 christophehamerling.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UserDetailsViewController : NSViewController {
    NSTextField *nameLabel;
    NSImageView *iconImageView;
    NSDictionary *userData;
}
@property (nonatomic, retain) NSDictionary *userData;

@property (assign) IBOutlet NSImageView *iconImageView;
@property (assign) IBOutlet NSTextField *nameLabel;

@end
