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

#import "QHUserDetailsView.h"

@implementation QHUserDetailsView

@synthesize iconImageView = _iconImageView;
@synthesize nameLabel = _nameLabel;
@synthesize userData = _userData;


- (void)setUserData:(NSDictionary *)userData
{
    if (![_userData isEqualToDictionary:userData]) {
        [_userData release];
        _userData = nil;
        _userData = [userData retain];
    }
    
    [self updateUI];
}

#pragma mark - Private -

- (void)updateUI
{
    [_nameLabel setStringValue:[_userData valueForKey:@"login"]];
    NSImage *iconImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[_userData valueForKey:@"avatar_url"]]];
    [iconImage setSize:NSMakeSize(72,72)];
    [_iconImageView setImage:iconImage];
    [iconImage release];
}

@end
