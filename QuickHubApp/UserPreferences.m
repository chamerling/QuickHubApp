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


#import "UserPreferences.h"
#import "Preferences.h"
#import "QHConstants.h"
#import "Context.h"

@interface UserPreferences (Private)
- (void) loadUserData:(id)source;
@end

@implementation UserPreferences

@synthesize progressIndicator;
@synthesize location;
@synthesize avatar;
@synthesize firstName;
@synthesize lastName;
@synthesize company;
@synthesize accessButton;
@synthesize appController;
@synthesize menuController;

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
    return [super initWithNibName:@"UserPreferences" bundle:nil];
}

- (void)viewWillAppear {
    Preferences *pref = [Preferences sharedInstance];
    if (![pref oauthToken] || [[pref oauthToken]length] == 0) {
        [accessButton setTitle:@"Authorize"];
        [lastName setStringValue:@""];
        [location setStringValue:@""];
        [company setStringValue:@""];
    } else {
        [progressIndicator setHidden:NO];
        [progressIndicator startAnimation:nil];
        [accessButton setTitle:@"Revoke Access"];
        [NSThread detachNewThreadSelector:@selector(loadUserData:) toTarget:self withObject:nil];        
    }
}

- (void)loadUserData:(id)source {
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSDictionary *userData = [client loadUser:nil];
    [[Preferences sharedInstance]storeLogin:[userData valueForKey:@"login"] withPassword:@""];
    // Note : do not release anything in the GH client since it will crash all...
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:userData waitUntilDone:YES];
   [pool release];
}

- (void)updateUI:(NSDictionary*) userData {

    NSString *ghUserName = [userData valueForKey:@"name"];
    if (ghUserName == nil || ghUserName.length == 0) {
        ghUserName = @"";
    }
    
    NSString *ghLocation = [userData valueForKey:@"location"];
    if (ghLocation == nil || ghLocation.length == 0) {
        ghLocation = @"";
    }
    
    NSString *ghCompany = [userData valueForKey:@"company"];
    if (ghCompany == nil || ghCompany.length == 0) {
        ghCompany = @"";
    }
    
    [lastName setStringValue:ghUserName];
    [location setStringValue:ghLocation];
    [company setStringValue:ghCompany];
    
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [userData valueForKey:@"avatar_url"]]]];
    [image setSize:NSMakeSize(100,100)];
    [avatar setImage:image];
    [progressIndicator setHidden:YES];
    [progressIndicator stopAnimation:nil];
}

- (IBAction)accessAction:(id)sender {
    Preferences *pref = [Preferences sharedInstance];
    if (![pref oauthToken] || [[pref oauthToken]length] == 0) {
        [accessButton setTitle:@"Revoke Access"];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:oauthsite]];
    } else {
        
        // not available for now
        //NSDictionary* auths = [client getAuthorizations:nil];
        
        [pref storeToken:@""];
        [pref storeLogin:@"" withPassword:@""];
        if ([Context sharedInstance]) {
            [[Context sharedInstance] cleanAll];
        }
        [appController stopAll:nil];
        [appController cleanCache:nil];
        [menuController cleanMenus:nil];
        [menuController resetCache:nil];
        [lastName setStringValue:@""];
        [location setStringValue:@""];
        [company setStringValue:@""];
        [accessButton setTitle:@"Authorize"];
        NSImage *image = [NSImage imageNamed:@"qh.png"];
        [image setSize:NSMakeSize(100,100)];
        [avatar setImage:image];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:revokeurl]];
    }
    [[[super view]window]close];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"UserPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:@"octocat-128"];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"GitHub", @"Toolbar item name for the GitHub preference pane");
}

@end
