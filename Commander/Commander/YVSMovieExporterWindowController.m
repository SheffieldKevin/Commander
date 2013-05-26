//
//  YVSMovieExporterWindowController.m
//  Commander
//
//  Created by Kevin Meaney on 17/05/2013.
//  Copyright (c) 2013 Kevin Meaney. All rights reserved.
//

#import "YVSAppDelegate.h"
#import "YVSMovieExporterWindowController.h"
#import <AVFoundation/AVFoundation.h>

@interface YVSMovieExporterWindowController ()

@property (nonatomic, weak) YVSAppDelegate *applicationDelegate;
- (void)generateFilename:(NSString *)baseFilename;
+ (NSString *)convertHoursMinSecondsToSeconds:(NSString *)hoursMinsSecs;
@end

@implementation YVSMovieExporterWindowController

@synthesize applicationDelegate;

@synthesize sourceFile; // IBOutlet NSPathControl
@synthesize sourceURL;
@synthesize verbose;

@synthesize listAllPresets;
@synthesize listTracks;
@synthesize listMetadata;
@synthesize generatedListCommand; // IBOutlet NSTextField

@synthesize presetsPopup; // IBOutlet NSPopupButton
@synthesize fileTypesPopup; // IBOutlet NSPopupButton
@synthesize specifyStartTimeAndDuration;
@synthesize startTimeTextField;
@synthesize durationTextField;
@synthesize availablePresets;
@synthesize availablePresetsController; // IBOutlet NSArrayController
@synthesize selectedPreset;
@synthesize allowedFileTypes;
@synthesize allowedFileTypesController; // IBOutlet NSArrayController
@synthesize selectedFileType;
@synthesize filenameExtension;
@synthesize replaceDestinationFile;
@synthesize showProgress;
@synthesize destinationFile;
@synthesize baseFilenameTextField; // IBOutlet NSTextField
@synthesize fullFilenameTextField; // IBOutlet NSTextField
@synthesize generatedExportCommand; // IBOutlet NSTextField

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

- (void)windowWillClose:(NSNotification *)notification
{
	[self.applicationDelegate setCurrentWindowController:nil];
	[self removeObserver:self forKeyPath:@"sourceURL" context:nil];
	[self removeObserver:self forKeyPath:@"selectedPreset" context:nil];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
	[self setAvailablePresets:[[NSArray alloc] init]];
	[self.availablePresetsController setContent:[self availablePresets]];
	NSKeyValueObservingOptions theObservingOptions;
	theObservingOptions = (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld);
	[self addObserver:self forKeyPath:@"sourceURL"
										options:theObservingOptions context:nil];
	[self addObserver:self forKeyPath:@"selectedPreset"
										options:theObservingOptions context:nil];
	[self addObserver:self forKeyPath:@"selectedFileType"
										options:theObservingOptions context:nil];
    [self.window makeKeyAndOrderFront:nil];
}

- (void)generateFilename:(NSString *)baseFilename
{
	NSString *extension = filenameExtension.stringValue;
	if (extension && [extension length])
	{
		[fullFilenameTextField setStringValue:[NSString stringWithFormat:
											   @"%@.%@", baseFilename, extension]];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
								change:(NSDictionary *)change context:(void *)context
{
	@autoreleasepool
	{
		if ([keyPath isEqualToString:@"sourceURL"])
		{
			AVURLAsset *theAsset;
			theAsset = [[AVURLAsset alloc] initWithURL:[self sourceURL] options:nil];
			self.availablePresets = [AVAssetExportSession
										exportPresetsCompatibleWithAsset:theAsset];
			[self.availablePresetsController setContent:self.availablePresets];
			if (!self.selectedPreset)
				self.selectedPreset = [self.availablePresets objectAtIndex:0];
			else if (![self.availablePresets containsObject:self.selectedPreset])
				self.selectedPreset = [self.availablePresets objectAtIndex:0];
		}
		else if ([keyPath isEqualToString:@"selectedPreset"])
		{
			AVURLAsset *theAsset;
			theAsset = [[AVURLAsset alloc] initWithURL:[self sourceURL] options:nil];
			AVAssetExportSession *avsession;
			avsession = [[AVAssetExportSession alloc] initWithAsset:theAsset
													presetName:[self selectedPreset]];
			self.allowedFileTypes = [avsession supportedFileTypes];
			[self.allowedFileTypesController setContent:self.allowedFileTypes];
			if (!self.selectedFileType)
				self.selectedFileType = [self.allowedFileTypes objectAtIndex:0];
			else if (![self.allowedFileTypes containsObject:self.selectedFileType])
				self.selectedFileType = [self.allowedFileTypes objectAtIndex:0];
		}
		else if ([keyPath isEqualToString:@"selectedFileType"])
		{
			NSString *fileExtension;
			fileExtension = (NSString *)CFBridgingRelease(
										  UTTypeCopyPreferredTagWithClass(
										  (__bridge CFStringRef)
										  self.selectedFileType,
										  kUTTagClassFilenameExtension));
			[filenameExtension setStringValue:fileExtension];
			NSString *baseFilename = self.baseFilenameTextField.stringValue;
			if (baseFilename && [baseFilename length])
				[self generateFilename:baseFilename];
		}
	}
}

- (IBAction)generateListCommand:(id)sender
{
	NSString *listTracksString = @" -listtracks";
	NSString *listMetadataString = @" -listmetadata";
	NSString *listPresets = @" -listpresets";
	NSString *verboseString = @" -verbose";
	
	NSMutableString *listCommand;
	NSString *sourceMoviePath = [sourceURL path];
	if (sourceMoviePath)
	{
		listCommand = [[NSMutableString alloc] initWithFormat:@"-source \"%@\"",
																	sourceMoviePath];
		if (self.verbose)
			[listCommand appendString:verboseString];

		if (self.listTracks)
			[listCommand appendString:listTracksString];

		if (self.listMetadata)
			[listCommand appendString:listMetadataString];
		
		if (self.listAllPresets)
			[listCommand appendString:listPresets];
		
		NSString *listCommandString = [[NSString alloc] initWithString:listCommand];
		[generatedListCommand setStringValue:listCommandString];
	}
}

- (IBAction)generateListAndExportCommand:(id)sender
{
	[self generateListCommand:sender];
	[self generateExportCommand:sender];
}

+ (NSString *)convertHoursMinSecondsToSeconds:(NSString *)hoursMinsSecs
{
	NSArray *stringArray = [hoursMinsSecs componentsSeparatedByString:@":"];
	if ([stringArray count] != 3)
		return hoursMinsSecs; // don't know what the results might be.
	
	Float64 time = 0.0L;
	NSNumberFormatter *theFormatter = [[NSNumberFormatter alloc] init];
	NSNumber *theNum = [theFormatter numberFromString:[stringArray objectAtIndex:0]];
	Float64 theTimeNum = (Float64)[theNum doubleValue];
	time = theTimeNum * 60.0L;	// 60 minutes in an hour.
	theNum = [theFormatter numberFromString:[stringArray objectAtIndex:1]];
	theTimeNum = (Float64)[theNum doubleValue];
	time += theTimeNum;
	time *= 60.0L;
	theNum = [theFormatter numberFromString:[stringArray objectAtIndex:2]];
	theTimeNum = (Float64)[theNum doubleValue];
	time += theTimeNum;
//	theNum = [NSNumber numberWithDouble:time];
	NSString *returnString = [NSString stringWithFormat:@"%5.2F", time];
	return returnString;
}

- (IBAction)generateExportCommand:(id)sender
{
	NSString *replaceString = @" -replace";
	NSString *verboseString = @" -verbose";
	NSString *progressString = @" -progress";

	@autoreleasepool
	{
		NSMutableString *exportCommand;
		NSString *sourceMoviePath = [sourceURL path];
		if (sourceMoviePath)
		{
			exportCommand = [[NSMutableString alloc] initWithFormat:@"-source \"%@\"",
							 sourceMoviePath];
			
			if (self.verbose)
				[exportCommand appendString:verboseString];
			
			if (self.replaceDestinationFile)
				[exportCommand appendString:replaceString];

			if (self.showProgress)
				[exportCommand appendString:progressString];

			NSURL *destinationURL = self.destinationFile.URL;
			if (destinationURL)
			{
				NSString *pathString = [destinationURL path];
				if (pathString && [pathString length])
				{
					NSString *fullName = self.fullFilenameTextField.stringValue;
					if (fullName && [fullName length])
						[exportCommand appendFormat:@" -destination \"%@/%@\"",
															pathString, fullName];
				}
			}
			if (self.selectedPreset)
				[exportCommand appendFormat:@" -preset %@", self.selectedPreset];

			if (self.selectedFileType)
				[exportCommand appendFormat:@" -filetype %@", self.selectedFileType];

			if (self.specifyStartTimeAndDuration)
			{
				NSString *startTimeString = self.startTimeTextField.stringValue;
				NSString *durationString = self.durationTextField.stringValue;
				
				if (startTimeString && [startTimeString length])
				{
					if (durationString && [durationString length])
					{
						NSString *timeString;
						timeString = [YVSMovieExporterWindowController
								convertHoursMinSecondsToSeconds:startTimeString];
						[exportCommand appendFormat:@" -start %@", timeString];
						timeString = [YVSMovieExporterWindowController
									  convertHoursMinSecondsToSeconds:durationString];
						[exportCommand appendFormat:@" -duration %@", timeString];
					}
				}
			}
			NSString *exportCommandString;
			exportCommandString = [[NSString alloc] initWithString:exportCommand];
			[generatedExportCommand setStringValue:exportCommandString];
		}
	}
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
		[self generateExportCommand:textField];
	}
}

@end
