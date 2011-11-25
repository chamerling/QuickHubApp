//
//  LocalPreferencesViewController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 24/11/11.
//  Copyright 2011 christophehamerling.com. All rights reserved.
//

#import "LocalPreferencesViewController.h"
#import "Context.h"

@implementation LocalPreferencesViewController

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
    return [super initWithNibName:@"LocalPreferencesViewController" bundle:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (void)viewWillAppear {
    Context *context = [Context sharedInstance];
    NSString *s = [NSString stringWithString:context.remainingCalls];
    [remainingIndicator setIntValue:[s intValue]];
}

- (NSString *)identifier
{
    return @"LocalPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Local", @"Toolbar item name for the Local preference pane");
}

@end
