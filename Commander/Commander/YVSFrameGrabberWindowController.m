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
@synthesize frameTimesTypePopup;
@synthesize exportTypesController;

@synthesize frameTimesTextField;
@synthesize frameTimesLabelField;
@synthesize frameTimesTextSuffix;

@synthesize selectedFileType;
@synthesize exportImageFileTypes;
@synthesize filenameExtension;
@synthesize showProgress;
@synthesize destinationFolder;
@synthesize baseFilenameTextField;
@synthesize firstFrameGrabFilename;
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
	[super windowDidLoad];
	NSArray *exportImageTypes;
	exportImageTypes = CFBridgingRelease(CGImageDestinationCopyTypeIdentifiers());
	[self setExportImageFileTypes:exportImageTypes];
	[[self exportTypesController] setContent:self.exportImageFileTypes];
	self.selectedFileType = [self.exportImageFileTypes objectAtIndex:0];
	[self exportFileTypeMenuSelected:nil];
}

- (void)windowWillClose:(NSNotification *)notification
{
	[self.applicationDelegate setCurrentWindowController:nil];
	[NSApp stopModal];
}

- (void)frameTimesTypeMenuSelected:(id)sender
{
	self.frameTimesTextField.stringValue = @"";
}

- (void)exportFileTypeMenuSelected:(id)sender
{
	// Need to determine file extension from file type. See code in avframegrabber.m
	NSString *fileExtension = (NSString *)CFBridgingRelease(
					UTTypeCopyPreferredTagWithClass(
						(__bridge CFStringRef)self.selectedFileType,
						kUTTagClassFilenameExtension));
	filenameExtension.stringValue = fileExtension;
	[self generateFrameGrabCommand:sender];
}

- (void)generateFrameGrabCommand:(id)sender
{
	
}

@end
