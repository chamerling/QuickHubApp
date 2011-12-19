//
//  OrgRepoCreateWindowController.m
//  QuickHub
//
//  Created by Christophe Hamerling on 19/12/11.
//  Copyright 2011 christophehamerling.com. All rights reserved.
//

#import "OrgRepoCreateWindowController.h"

@implementation OrgRepoCreateWindowController

@synthesize ghClient;
@synthesize menuController;
@synthesize organisationName;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        [[self window] setTitle:[NSString stringWithFormat:@"Create A New Repository for '%@'", organisationName]];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (IBAction)createAction:(id)sender {
    
    NSString *name = [[nameField stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *description = [[descriptionField stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *url = [[homePageField stringValue]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL wiki = ([wikiBox state] == 1) ? TRUE : FALSE;
    BOOL issues = ([issuesBox state] == 1) ? TRUE : FALSE;
    BOOL downloads = ([downloadBox state] == 1) ? TRUE : FALSE;
    BOOL isPrivate = ([privateBox state] == 1) ? TRUE : FALSE;
    BOOL open = ([openBox state] == 1) ? TRUE : FALSE;
    
    if (!name || [name length] == 0) {
        NSBeep();
    } else {
        [createButton setEnabled:FALSE];
        [cancelButton setEnabled:FALSE];
        [progress setHidden:FALSE];
        [progress startAnimation:nil];
        
        NSDictionary *result = [ghClient createRepository:name forOrg:organisationName description:description homepage:url wiki:wiki issues:issues downloads:downloads isPrivate:isPrivate];
        
        [progress stopAnimation:nil];
        [progress setHidden:TRUE];
        [createButton setEnabled:TRUE];
        [cancelButton setEnabled:TRUE];
        
        if (result) {
            [menuController addOrgRepo:organisationName withRepo:result top:YES];
            if (open) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[result valueForKey:@"html_url"]]];
            }
            [[self window]performClose:self];
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Repository Creation Problem"];
            [alert setInformativeText:@"There was an error while creating your organization repository"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];            
        }
    }
}

- (IBAction)cancelAction:(id)sender {
    [[self window]performClose:self];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    // future work, we can detect clicked button from NSAlert sheet here!
    if (returnCode == NSAlertFirstButtonReturn) {
    }
}

@end
