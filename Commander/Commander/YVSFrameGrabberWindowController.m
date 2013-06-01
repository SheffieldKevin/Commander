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

- (void)generateFilename:(NSString *)baseFilename;
+ (NSString *)createCommandPath;
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
	@autoreleasepool
	{
		self.frameTimesTextField.stringValue = @"";
		NSString *selectedItemTitle = [self.frameTimesTypePopup titleOfSelectedItem];
		if (selectedItemTitle && [selectedItemTitle length])
		{
			if ([selectedItemTitle isEqualToString:@"Frame times"])
			{
				self.frameTimesLabelField.stringValue = @"Frame times:";
				self.frameTimesTextSuffix.stringValue = @"seconds";
				self.frameTimesTextField.toolTip =
						@"Enter the time (in secs) when you want a "
						@"frame grab to be taken. Times are seperated by commas. "
						@"Don't include white space. "
						@"Time accuracy for frame grabs is about 1/10th of a second."
						@" Example 1.2,1.34,25.1,280";
			}
			else if ([selectedItemTitle isEqualToString:@"Number of frame grabs"])
			{
				frameTimesLabelField.stringValue = @"Number of frame grabs:";
				frameTimesTextSuffix.stringValue = @"";
				self.frameTimesTextField.toolTip =
						@"Enter the number of frame grabs to be taken. The first frame "
						@"grab will be taken at the beginning of the movie, the last "
						@"at the end, and frame grabs will be taken evenly spaced out "
						@"during the length of the movie.";
			}
			else if ([selectedItemTitle isEqualToString:@"Frame grab every X seconds"])
			{
				frameTimesLabelField.stringValue = @"Time between frame grabs:";
				frameTimesTextSuffix.stringValue = @"seconds";
				self.frameTimesTextField.toolTip =
						@"Enter the time between when each frame grab will be taken. "
						@"The first frame to be taken will be at the beginning of "
						@"the movie and frame grabs will be taken until the end of "
						@"the movie.";
			}
		}
	}
	[self generateFrameGrabCommand:sender];
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

- (void)generateFilename:(NSString *)baseFilename
{
	NSString *extension = filenameExtension.stringValue;
	if (extension && [extension length])
	{
		[firstFrameGrabFilename setStringValue:[NSString stringWithFormat:
											   @"%@000000.%@", baseFilename, extension]];
	}	
}

#pragma mark -
#pragma mark Private methods

- (void)generateFrameGrabCommand:(id)sender
{
	NSString *replaceString = @" -replace";
	NSString *verboseString = @" -verbose";
	NSString *progressString = @" -progress";
	
	@autoreleasepool
	{
		NSMutableString *screenGrabCommand;
		
		NSURL *destinationFolderURL = [destinationFolder URL];
		if (destinationFolderURL && [destinationFolderURL checkResourceIsReachableAndReturnError:nil])
		{
			
		}		
	}
}

#pragma mark -
#pragma mark Private Class Methods

+ (NSString *)createCommandPath
{
	// Top'n tail the command path with quotes just in case path contains spaces.
	NSBundle *appBundle = [NSBundle mainBundle];
	NSString *basicPath = [appBundle pathForResource:@"avframegrab" ofType:nil];
	NSString *pathString = [NSString stringWithFormat:@"\"%@\"", basicPath];
	return pathString;
}

#pragma mark -
#pragma mark Delegate Methods

- (void)controlTextDidChange:(NSNotification *)theNotification
{
	NSTextField *textField = theNotification.object;
	if (textField == self.baseFilenameTextField)
	{
		NSTextView *textView = [[theNotification userInfo]
								objectForKey:@"NSFieldEditor"];
		NSString *baseFilename = textView.string;
		[self generateFilename:baseFilename];
		[self generateFrameGrabCommand:textField];
	}
}

@end
