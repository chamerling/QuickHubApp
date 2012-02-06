//
//  UserDetailsViewController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 06/02/12.
//  Copyright 2012 christophehamerling.com. All rights reserved.
//

#import "UserDetailsViewController.h"

@implementation UserDetailsViewController
@synthesize iconImageView;
@synthesize nameLabel;
@synthesize userData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)loadView {
    [super loadView];
    [nameLabel setStringValue:[userData valueForKey:@"login"]];
    NSImage* iconImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[userData valueForKey:@"avatar_url"]]];
    [iconImage setSize:NSMakeSize(72,72)];
    [iconImageView setImage:iconImage];
}


@end
