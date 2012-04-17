//
//  EventPreferencesViewController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 17/04/12.
//  Copyright 2012 christophehamerling.com. All rights reserved.
//

#import "EventPreferencesViewController.h"

@implementation EventPreferencesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)init
{
    return [super initWithNibName:@"EventPreferencesViewController" bundle:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"EventPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameAdvanced];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Events", @"Toolbar item name for the Events preference pane");
}

@end
