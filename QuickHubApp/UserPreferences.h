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
#import "AppController.h"
#import "MenuController.h"

@interface UserPreferences : NSViewController<MASPreferencesViewController> {
    IBOutlet GithubOAuthClient* client;
    AppController *appController;
    MenuController *menuController;
    
    NSButton *accessButton;
    NSTextField *firstName;
    NSTextField *lastName;
    NSTextField *company;
    NSImageView *avatar;
    NSTextField *location;
    NSProgressIndicator *progressIndicator;
}
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet NSTextField *location;
@property (assign) IBOutlet NSImageView *avatar;
@property (assign) IBOutlet NSTextField *firstName;
@property (assign) IBOutlet NSTextField *lastName;
@property (assign) IBOutlet NSTextField *company;
@property (assign) IBOutlet NSButton *accessButton;

@property (nonatomic, retain) AppController *appController;
@property (nonatomic, retain) MenuController *menuController;

- (IBAction)accessAction:(id)sender;

@end
