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

#import "GistCreateWindowController.h"
#import "QHConstants.h"

@interface GistCreateWindowController (Private)
- (void) createGist:(NSString*) content withDescription:(NSString*) description andFileName:(NSString *) fileName isPublic:(BOOL) pub;
- (void) fileHasBeenDnD:(NSNotification *)aNotification;
@end

@implementation GistCreateWindowController

@synthesize ghClient;
@synthesize menuController;
@synthesize gistContent;
@synthesize gistFileName;
@synthesize gistDescription;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // listen for events
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(fileHasBeenDnD:)
                                                     name:GIST_DND
                                                   object:nil];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    if (gistContent) {
        [contentTextView setString:gistContent];
    }
    if (gistDescription) {
        [descriptionField setStringValue:gistDescription];
    }
    if (gistFileName) {
        [fileNameField setStringValue:gistFileName];
    }
}

- (IBAction)createGist:(id)sender {
    // create the gist...
    NSString *description = [[descriptionField stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *theFileName = [[fileNameField stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *content = [contentTextView string];
    
    if (!theFileName || !content || ([theFileName length] == 0) || ([content length] == 0)) {
        NSBeep();
    } else {
        [self createGist:content withDescription:description andFileName:theFileName isPublic:TRUE];
    }
}

- (IBAction)createPrivateGist:(id)sender {
    // create the gist...
    NSString *description = [[descriptionField stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *theFileName = [[fileNameField stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *content = [contentTextView string];
    
    if (!theFileName || !content || ([theFileName length] == 0) || ([content length] == 0)) {
        NSBeep();
    } else {
        [self createGist:content withDescription:description andFileName:theFileName isPublic:FALSE];
    }
}

- (IBAction)cleanFields:(id)sender {
    [fileNameField setStringValue:@""];
    [descriptionField setStringValue:@""];
    [contentTextView setString:@""];
}

- (void) createGist:(NSString*) content withDescription:(NSString*) description andFileName:(NSString *) fileName isPublic:(BOOL) pub {
    [createButton setEnabled:NO];
    [progressIndicator setHidden:NO];
    [progressIndicator startAnimation:nil];
    
    NSDictionary *result = nil;
    if (ghClient) {
        result = [ghClient createGist:content withDescription:description andFileName:fileName isPublic:pub];
    }
        
    [progressIndicator stopAnimation:nil];
    [progressIndicator setHidden:YES];
    [createButton setEnabled:YES];
    
    if (!result) {
        return;
    }

    // update the menu
    [menuController addGist:result top:YES];
    
    NSString *finalURL = [result valueForKey:@"html_url"];
    if ([copyURLToPasteBoard state] == 1) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        [pasteboard writeObjects:[NSArray arrayWithObject:finalURL]];
    }
    if ([openWebPage state] == 1) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:finalURL]];
    }
}

- (void)fileHasBeenDnD:(NSNotification *)aNotification {
    // get the notification content which should be the file name with full path
    NSString *fileName = [aNotification object];
    [fileNameField setStringValue:[fileName lastPathComponent]];
    
    // focus
    [descriptionField selectText:self];
    [[descriptionField currentEditor] setSelectedRange:NSMakeRange([[fileNameField stringValue]length], 0)];
}

@end
