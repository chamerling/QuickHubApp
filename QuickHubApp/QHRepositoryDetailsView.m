// (The MIT License)
//
// Copyright (c) 2013 Christophe Hamerling <christophe.hamerling@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// 'Software'), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "QHRepositoryDetailsView.h"

@implementation QHRepositoryDetailsView

@synthesize publicPrivateImage;
@synthesize forkImage;
@synthesize repoNameButton;
@synthesize repositoryData;
@synthesize createdAtLabel;
@synthesize pushedAtField;
@synthesize statsLabel;
@synthesize urlButton;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setRepositoryData:(NSDictionary *)repositoryDataIn
{
    repositoryData = repositoryDataIn;
    
    [self updateUI];
}

- (void)updateUI
{
   [repoNameButton setTitle:[repositoryData valueForKey:@"name"]];

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
        [urlButton setHidden:YES];
    } else {
        [urlButton setTitle:url];
    }

}

- (IBAction)openURL:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[repositoryData valueForKey:@"homepage"]]];
}

- (IBAction)cloneAction:(id)sender {       
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"github-mac://openRepo/%@", [repositoryData valueForKey:@"html_url"]]]];
}

- (IBAction)openRepository:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[repositoryData valueForKey:@"html_url"]]];
}

- (void)dealloc
{
    [super dealloc];
    [repositoryData release];
}

@end
