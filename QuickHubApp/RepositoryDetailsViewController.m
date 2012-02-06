//
//  RepositoryDetailsViewController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 06/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RepositoryDetailsViewController.h"

@implementation RepositoryDetailsViewController
@synthesize urlLabel;
@synthesize repositoryLabel;
@synthesize publicPrivateImage;
@synthesize forkImage;
@synthesize repositoryData;
@synthesize createdAtLabel;
@synthesize pushedAtField;
@synthesize statsLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) loadView {
    [super loadView];
    [repositoryLabel setStringValue:[repositoryData valueForKey:@"name"]];

    NSNumber *forks = [repositoryData valueForKey:@"forks"];
    NSNumber *watchers = [repositoryData valueForKey:@"watchers"];
    NSNumber *issues = [repositoryData valueForKey:@"open_issues"];
            
    NSString *statsText = [NSString stringWithFormat:@"%@ %@, %@ %@, %@ %@", issues, (([issues intValue] == 1) ? @"issue" : @"issues"), forks, (([forks intValue] == 1) ? @"fork" : @"forks"), watchers, (([watchers intValue] == 1) ? @"watcher" : @"watchers")];
    [statsLabel setStringValue:statsText];
    
    NSNumber *priv = [repositoryData valueForKey:@"private"];
    if (priv && [priv boolValue]) {
        [publicPrivateImage setImage:[NSImage imageNamed:@"bullet_red.png"]];
    }
    
    NSNumber *fork = [repositoryData valueForKey:@"fork"];
    if (![fork boolValue]) {
        [forkImage setHidden:TRUE];
    }
    
    [createdAtLabel setStringValue:[NSString stringWithFormat:@"Created at %@", [repositoryData valueForKey:@"created_at"]]];
    
    NSString *pushedAt = [repositoryData valueForKey:@"pushed_at"];
    if (pushedAt == (id)[NSNull null] || (pushedAt.length == 0)) {
        [pushedAtField setStringValue:@"Never pushed!"];
     } else {
         [pushedAtField setStringValue:[NSString stringWithFormat:@"Pushed at %@", [repositoryData valueForKey:@"pushed_at"]]];
     }
    
    NSString *url = [repositoryData valueForKey:@"homepage"];
    if (url == (id)[NSNull null] || (url.length == 0)) {
        [urlLabel setHidden:YES];
    } else {
        [urlLabel setStringValue:url];
    }

}

- (IBAction)cloneAction:(id)sender {       
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"github-mac://openRepo/%@", [repositoryData valueForKey:@"html_url"]]]];
}

- (IBAction) openHome:(id)sender {
    NSLog(@"Open home");
}

- (IBAction)debug:(id)sender {
    NSLog(@"%@", repositoryData);
}

@end
