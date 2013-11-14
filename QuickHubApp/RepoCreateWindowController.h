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

#import "GithubOAuthClient.h"
#import "MenuController.h"

@interface RepoCreateWindowController : NSWindowController {
    GithubOAuthClient *ghClient;
    MenuController *menuController;
    
    IBOutlet NSTextField *nameField;
    IBOutlet NSTextField *descriptionField;
    IBOutlet NSTextField *homePageField;
    IBOutlet NSButton *issuesBox;
    IBOutlet NSButton *downloadBox;
    IBOutlet NSButton *wikiBox;
    IBOutlet NSButton *privateBox;
    IBOutlet NSButton *openBox;
    IBOutlet NSButton *autoInitBox;
    IBOutlet NSProgressIndicator *progress;
    IBOutlet NSButton *createButton;
    IBOutlet NSButton *cancelButton;
}

- (IBAction)createAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@property (assign) GithubOAuthClient *ghClient;
@property (assign) MenuController *menuController;

@end
