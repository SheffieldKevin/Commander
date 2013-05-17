//
//  YVSAppDelegate.m
//  Commander
//
//  Created by Kevin Meaney on 17/05/2013.
//  Copyright (c) 2013 Kevin Meaney. All rights reserved.
//

#import "YVSAppDelegate.h"
#import "YVSMovieExporterWindowController.h"

@implementation YVSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
}

-(IBAction)displayExportMovieDialog:(id)sender
{
	movieExportController = [[YVSMovieExporterWindowController alloc] initWithWindowNibName:@"YVSMovieExporterWindowController"];
	[movieExportController window];
}

@end
