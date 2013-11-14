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

#import <Cocoa/Cocoa.h>
#import "GitHubController.h"

@interface GistViewWindowController : NSWindowController {
    NSTextField *gistTitleField;
    NSTextField *descriptionField;
    NSTextView *gstContentField;
    NSImageView *starImage;
    NSProgressIndicator *statusIndicator;
    NSImageView *privacyBullert;
    NSTextField *publicCloneURLField;
    NSTextField *privateCloneURLField;
    NSTextField *createdAtField;
    
    NSArray *gist;
    NSImageView *privacyBullet;
}
@property (assign) IBOutlet NSImageView *privacyBullet;

@property (assign) NSArray *gist;

@property (assign) IBOutlet NSTextField *publicCloneURLField;
@property (assign) IBOutlet NSTextField *privateCloneURLField;
@property (assign) IBOutlet NSTextField *createdAtField;
@property (assign) IBOutlet NSTextField *gistTitleField;
@property (assign) IBOutlet NSTextField *descriptionField;
@property (assign) IBOutlet NSTextView *gstContentField;
@property (assign) IBOutlet NSImageView *starImage;
@property (assign) IBOutlet NSProgressIndicator *statusIndicator;

- (IBAction)favoriteAction:(id)sender;
- (IBAction)updateAction:(id)sender;

@end
