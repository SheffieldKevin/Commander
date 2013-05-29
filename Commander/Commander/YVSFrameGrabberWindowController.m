//
//  YVSFrameGrabberWindowController.m
//  Commander
//
//  Created by Kevin Meaney on 29/05/2013.
//  Copyright (c) 2013 Kevin Meaney. All rights reserved.
//

#import "YVSFrameGrabberWindowController.h"
#import "YVSAppDelegate.h"

@interface YVSFrameGrabberWindowController ()
@property (nonatomic, weak) YVSAppDelegate *applicationDelegate;
@end

@implementation YVSFrameGrabberWindowController

@synthesize applicationDelegate;

#pragma mark -
#pragma mark Synthesize public properties

@synthesize sourceFile;
@synthesize sourceURL;
@synthesize verbose;

@synthesize listTracks;
@synthesize listMetadata;

@synthesize fileTypesPopup;

@synthesize selectedFileType;
@synthesize filenameExtension;
@synthesize showProgress;
@synthesize destinationFolder;
@synthesize baseFilenameTextField;
@synthesize generatedFrameGrabsCommand;

#pragma mark -
#pragma mark Public methods

- (id)initWithWindowNibName:(NSString *)windowNibName
								appDelegate:(YVSAppDelegate *)appDelegate
{
	self = [super initWithWindowNibName:windowNibName];
	if (self)
	{
		[self setApplicationDelegate:appDelegate];
	}
	return self;
}

- (void)windowDidLoad
{
	[self.applicationDelegate setCurrentWindowController:nil];
	[NSApp stopModal];
}

@end
