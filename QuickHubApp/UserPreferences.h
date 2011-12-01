//
//  UserPreferences.h
//  QuickHub
//
//  Created by Christophe Hamerling on 01/12/11.
//  Copyright 2011 christophehamerling.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GithubOAuthClient.h"
#import "MASPreferencesViewController.h"

@interface UserPreferences : NSViewController<MASPreferencesViewController> {
    IBOutlet GithubOAuthClient* client;
    NSButton *accessButton;
    NSTextField *firstName;
    NSTextField *lastName;
    NSImageView *avatar;
}
@property (assign) IBOutlet NSImageView *avatar;
@property (assign) IBOutlet NSTextField *firstName;
@property (assign) IBOutlet NSTextField *lastName;

@property (assign) IBOutlet NSButton *accessButton;
- (IBAction)accessAction:(id)sender;

@end
