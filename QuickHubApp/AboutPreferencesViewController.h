//
//  AboutPreferencesViewController.h
//  QuickHub
//
//  Created by Christophe Hamerling on 30/11/11.
//  Copyright 2011 christophehamerling.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"

@interface AboutPreferencesViewController : NSViewController<MASPreferencesViewController> {
    NSTextField *versionField;
}

- (IBAction)openAppWebSite:(id)sender;
@property (assign) IBOutlet NSTextField *versionField;

@end
