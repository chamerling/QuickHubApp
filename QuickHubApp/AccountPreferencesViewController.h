//
//  AccountPreferencesViewController.h
//  QuickHub
//
//  Created by Christophe Hamerling on 24/11/11.
//  Copyright 2011 christophehamerling.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"

#import "AppController.h"
#import "GithubOAuthClient.h"
#import "MenuController.h"

@interface AccountPreferencesViewController : NSViewController<MASPreferencesViewController,NSWindowDelegate> {
    IBOutlet NSButton *openAtStartupButton;
}

- (IBAction)openAtStartup:(id)sender;

@end
