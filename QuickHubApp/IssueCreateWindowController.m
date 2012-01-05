//
//  IssueCreateWindowController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 03/01/12.
//  Copyright 2012 christophehamerling.com. All rights reserved.
//

#import "IssueCreateWindowController.h"
#import "Context.h"

@implementation IssueCreateWindowController

@synthesize repositoryList;
@synthesize createButton;
@synthesize cancelButton;
@synthesize titleField;
@synthesize issueDetails;
@synthesize assignToMe;
@synthesize openWebPage;
@synthesize progress;
@synthesize ghClient;
@synthesize menuController;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSSet *repositories = [[Context sharedInstance] repositories];
    NSArray *sortedArray = [[NSMutableArray arrayWithArray:[repositories allObjects]] sortedArrayUsingComparator:^(id a, id b) {
        NSString *first = (NSString*)a;
        NSString *second = (NSString*)b;
        return [[first lowercaseString] compare:[second lowercaseString]];
    }];
    
    if (sortedArray && ([sortedArray count] > 0)) {
        for (NSString *repo in sortedArray) {
            [repositoryList addItemWithTitle:repo];
        }
        [repositoryList selectItemAtIndex:0];
    } else {
        [createButton setEnabled:NO];
    }
}

- (IBAction)cancelAction:(id)sender {
    [[self window]performClose:self];
}

- (IBAction)createAction:(id)sender {
    
    NSString *title = [[titleField stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *body = [issueDetails string];
    
    BOOL toMe = ([assignToMe state] == 1) ? TRUE : FALSE;
    BOOL open = ([openWebPage state] == 1) ? TRUE : FALSE;

    NSString *repository = [[repositoryList selectedItem] title];
    
    NSString *user = [[Preferences sharedInstance]login];
    NSString *assignee = nil;
    if (toMe) {
        assignee = [[Preferences sharedInstance]login];    
    }
    
    if (!title || [title length] == 0) {
        NSBeep();
        // TODO : some modal display
    } else {
        [createButton setEnabled:FALSE];
        [cancelButton setEnabled:FALSE];
        [progress setHidden:FALSE];
        [progress startAnimation:nil];
        
        NSDictionary *result = [ghClient createIssue:repository user:user title:title boby:body assignee:assignee milestone:nil labels:nil];
        
        [progress stopAnimation:nil];
        [progress setHidden:TRUE];
        [createButton setEnabled:TRUE];
        [cancelButton setEnabled:TRUE];
        
        if (result) {
            [menuController addIssue:result top:YES];
            if (open) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[result valueForKey:@"html_url"]]];
            }
            [[self window]performClose:self];
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Issue Creation Problem"];
            [alert setInformativeText:@"There was an error while creating your issue"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];            
        }
    }
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    // future work, we can detect clicked button from NSAlert sheet here!
    if (returnCode == NSAlertFirstButtonReturn) {
    }
}

@end
