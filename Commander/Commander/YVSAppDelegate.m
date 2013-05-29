//
//  YVSAppDelegate.m
//  Commander
//
//  Created by Kevin Meaney on 17/05/2013.
//  Copyright (c) 2013 Kevin Meaney. All rights reserved.
//

#import "YVSAppDelegate.h"
#import "YVSMovieExporterWindowController.h"
#import "YVSFrameGrabberWindowController.h"

@implementation YVSAppDelegate

@synthesize currentWindowController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
}

-(IBAction)displayExportMovieDialog:(id)sender
{
	YVSMovieExporterWindowController *movieExportController;
	movieExportController = [[YVSMovieExporterWindowController alloc]
						initWithWindowNibName:@"YVSMovieExporterWindowController"
						appDelegate:self];
	[self setCurrentWindowController:movieExportController];
	[NSApp runModalForWindow:[self.currentWindowController window]];
}

-(IBAction)displayFrameGrabDialog:(id)sender
{
	YVSFrameGrabberWindowController *frameGrabberController;
	frameGrabberController = [[YVSFrameGrabberWindowController alloc]
							 initWithWindowNibName:@"YVSFrameGrabberWindow"
							 appDelegate:self];
	[self setCurrentWindowController:frameGrabberController];
	[NSApp runModalForWindow:[self.currentWindowController window]];
}

@end
