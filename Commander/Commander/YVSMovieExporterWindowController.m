//
//  YVSMovieExporterWindowController.m
//  Commander
//
//  Created by Kevin Meaney on 17/05/2013.
//  Copyright (c) 2013 Kevin Meaney. All rights reserved.
//

#import "YVSAppDelegate.h"
#import "YVSMovieExporterWindowController.h"

@interface YVSMovieExporterWindowController ()

@property (nonatomic, weak) YVSAppDelegate *applicationDelegate;

@end

@implementation YVSMovieExporterWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName appDelegate:(YVSAppDelegate *)appDelegate
{
	self = [super initWithWindowNibName:windowNibName];
	if (self)
	{
		[self setApplicationDelegate:appDelegate];
	}
	return self;
}

- (void)windowWillClose:(NSNotification *)notification
{
	[self.applicationDelegate setCurrentWindowController:nil];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
