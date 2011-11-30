//
//  AboutPreferencesViewController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 30/11/11.
//  Copyright 2011 christophehamerling.com. All rights reserved.
//

#import "AboutPreferencesViewController.h"
#import "QHConstants.h"

@implementation AboutPreferencesViewController
@synthesize versionField;

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
    return [super initWithNibName:@"AboutPreferencesViewController" bundle:nil];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (void)viewWillAppear {
    [versionField setStringValue:[NSString stringWithFormat:@"%@ - Version %@", (NSString *)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleNameKey), (NSString *)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey)]];
}

- (NSString *)identifier
{
    return @"AboutPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"About", @"Toolbar item name for the About preference pane");
}

- (IBAction)openAppWebSite:(id)sender {
    [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:appsite]];
}
@end
