 //
 // File: avexporter.m
 // Project: avexporter
 //
 // 
 // Abstract: This file shows an example of using the export and metadata
 // functions in AVFoundation as a part of a command line tool for
 // simple exports.
 //
 // Abstract:   <Description, Points of interest, Algorithm approach>
 //
 // Version:	<1.0>
 //
 // Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc. ("Apple")
 //				in consideration of your agreement to the following terms, and your use,
 //				installation, modification or redistribution of this Apple software
 // 			constitutes acceptance of these terms.  If you do not agree with these
 //				terms, please do not use, install, modify or redistribute this Apple
 //				software.
 //
 //				In consideration of your agreement to abide by the following terms, and
 //				subject to these terms, Apple grants you a personal, non - exclusive
 //				license, under Apple's copyrights in this original Apple software ( the
 //				"Apple Software" ), to use, reproduce, modify and redistribute the Apple
 //				Software, with or without modifications, in source and / or binary forms;
 //				provided that if you redistribute the Apple Software in its entirety and
 //				without modifications, you must retain this notice and the following text
 //				and disclaimers in all such redistributions of the Apple Software. Neither
 //				the name, trademarks, service marks or logos of Apple Inc. may be used to
 //				endorse or promote products derived from the Apple Software without specific
 //				prior written permission from Apple.  Except as expressly stated in this
 //				notice, no other rights or licenses, express or implied, are granted by
 //				Apple herein, including but not limited to any patent rights that may be
 //				infringed by your derivative works or by other works in which the Apple
 //				Software may be incorporated.
 //
 //				The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 //				WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 //				WARRANTIES OF NON - INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
 //				PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION
 //				ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 //
 //				IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 //				CONSEQUENTIAL DAMAGES ( INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 //				SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 //				INTERRUPTION ) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION
 //				AND / OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER
 //				UNDER THEORY OF CONTRACT, TORT ( INCLUDING NEGLIGENCE ), STRICT LIABILITY OR
 //				OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 //
 // Copyright ( C ) 2011 Apple Inc. All Rights Reserved.
 //

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

// ---------------------------------------------------------------------------
//		S W I T C H E S
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
//		P R O T O T Y P E S
// ---------------------------------------------------------------------------

static void printNSString(NSString *string);
static void printArgs(int argc, const char **argv);


// ---------------------------------------------------------------------------
//		AVExporter Class Interface
// ---------------------------------------------------------------------------
@interface AVExporter: NSObject
{	
	NSString * programName;
	NSString * exportType;
	NSString * preset;
	NSString * sourcePath;
	NSString * destinationPath;
	NSString * fileType;
//	NSNumber * progress;
	NSNumber * startSeconds;
	NSNumber * durationSeconds;
	BOOL	   showProgress;
	BOOL	   verbose;
	BOOL	   exportFailed;
	BOOL	   exportComplete;
	BOOL	   listTracks;
	BOOL	   listMetadata;
	BOOL	   listFileTypes;
	BOOL	   removePreExistingFiles;
}

@property (nonatomic, retain) NSString	*	programName;
@property (nonatomic, retain) NSString	*	exportType;
@property (nonatomic, retain) NSString	*	preset;
@property (nonatomic, retain) NSString	*	sourcePath;
@property (nonatomic, retain) NSString	*	destinationPath;
@property (nonatomic, retain) NSString	*	fileType;
// @property (nonatomic, retain) NSNumber	*	progress;
@property (nonatomic, retain) NSNumber	*	startSeconds;
@property (nonatomic, retain) NSNumber	*	durationSeconds;
@property (assign)			  BOOL			verbose;
@property (assign)			  BOOL			showProgress;
@property (assign)			  BOOL			exportFailed;
@property (assign)			  BOOL			exportComplete;
@property (assign)			  BOOL			listTracks;
@property (assign)			  BOOL			listMetadata;
@property (assign)			  BOOL			listFileTypes;
@property (assign)			  BOOL			removePreExistingFiles;

- (id)initWithArgs: (int) argc  argv: (const char **) argv environ: (const char **) environ;
- (void)printUsage;

- (int)run;

- (NSArray *) addNewMetadata: (NSArray *)sourceMetadataList presetName:(NSString *)presetName;

+ (void) doListPresets;
- (void) doListTracks:(NSString *)assetPath;
- (void) doListMetadata:(NSString *)assetPath;
- (void) doListFileTypes:(NSArray *)listOfTypes;


@end


// ---------------------------------------------------------------------------
//		AVExporter Class Implementation
// ---------------------------------------------------------------------------

@implementation AVExporter

@synthesize programName, exportType, preset;
@synthesize sourcePath, destinationPath;
// @synthesize progress;
@synthesize fileType;
@synthesize startSeconds, durationSeconds;
@synthesize	verbose, showProgress, exportComplete, exportFailed; 
@synthesize listTracks, listMetadata, listFileTypes;
@synthesize removePreExistingFiles;

-(id) initWithArgs: (int) argc  argv: (const char **) argv environ: (const char **) environ
{
	self = [super init];
	if (self == nil) {
		return nil;
	}

	printArgs(argc,argv);
	
	BOOL gotpreset = NO;
	BOOL gotsource = NO;
	BOOL gotout = NO;
	BOOL parseOK = NO;
	BOOL listPresets = NO;
	[self setProgramName:@(*argv++)];
	argc--;
	while ( argc > 0 && **argv == '-' )
	{
		const char*	args = &(*argv)[1];
		
		argc--;
		argv++;
		
		if ( ! strcmp ( args, "source" ) )
		{
			[self setSourcePath: @(*argv++) ];
			gotsource = YES;
			argc--;
		}
		else if (( ! strcmp ( args, "dest" )) || ( ! strcmp ( args, "destination" )) )
		{
			[self setDestinationPath: @(*argv++)];
			gotout = YES;
			argc--;
		}
		else if ( ! strcmp ( args, "preset" ) )
		{
			[self setPreset: @(*argv++)];
			gotpreset = YES;
			argc--;
		}
		else if ( ! strcmp ( args, "replace" ) )
		{
			[self setRemovePreExistingFiles: YES];
		}
		else if ( ! strcmp ( args, "filetype" ) )
		{
			[self setFileType: @(*argv++)];
			argc--;
		}
		else if ( ! strcmp ( args, "verbose" ) )
		{
			[self setVerbose:YES];
		}
		else if ( ! strcmp ( args, "progress" ) )
		{
			[self setShowProgress: YES];
		}
		else if ( ! strcmp ( args, "start" ) )
		{
			[self setStartSeconds: @([@(*argv++) floatValue])];
			argc--;
		}
		else if ( ! strcmp ( args, "duration" ) )
		{
			[self setDurationSeconds: @([@(*argv++) floatValue])];
			argc--;
		}
		else if ( ! strcmp ( args, "listpresets" ) )
		{
			listPresets = YES;
			parseOK = YES;
		}
		else if ( ! strcmp ( args, "listtracks" ) )
		{
			[self setListTracks: YES];
			parseOK = YES;
		}
		else if ( ! strcmp ( args, "listmetadata" ) )
		{
			[self setListMetadata: YES];
			parseOK = YES;
		}
		else if ( ! strcmp ( args, "listfiletypes" ) )
		{
			[self setListFileTypes: YES];
			NSLog(@"listfiletypes set");
			parseOK = YES;
		}
		else if ( ! strcmp ( args, "help" ) )
		{
			[self printUsage];
		}
		else {
			printf("Invalid input parameter: %s\n", args );
			[self printUsage];
			return nil;
		}
	}
//	[self setProgress: @((float)0.0)];
	[self setExportFailed: NO];
	[self setExportComplete: NO];
	
	if (listPresets) {
		[AVExporter doListPresets];
	}
	
	if ([self verbose]) {
		printNSString([NSString stringWithFormat:@"Running: %@\n", [self programName]]);
	}
	
	// There must be a source and either a preset and output (the normal case) or parseOK set for a listing
	if ((gotsource == NO)  || ((parseOK == NO) && ((gotpreset == NO) || (gotout == NO)))) {
		[self printUsage];
		return nil;
	}
	return self;
}


-(void) printUsage
{
	printf("avexporter - usage:\n");
	printf("	./avexporter [-parameter <value> ...]\n");
	printf("	 parameters are all preceded by a -<parameterName>.  The order of the parameters is unimportant.\n");
	printf("	 Required parameters are  -preset <presetName> -source <sourceFileURL> -dest <outputFileURL>\n");
	printf("	 Available parameters are:\n");
	printf("	 	-preset <preset name>.  The preset name eg: AVAssetExportPreset640x480 AVAssetExportPresetAppleM4VWiFi. Use -listpresets to see a full list.\n");
	printf("	 	-destination (or -dest) <outputFileURL>\n");
	printf("	 	-source <sourceMovieURL>\n");
	printf("		-replace   If there is a preexisting file at the destination location, remove it before exporting.\n");
	printf("	 	-filetype <file type string> The file type (eg com.apple.m4v-video) for the output file.  If not specified, the first supported type will be used.\n");
	printf("	 	-start <start time>  time in seconds (decimal are OK).  Removes the startClip time from the beginning of the movie before exporting.\n");
	printf("	 	-duration <duration>  time in seconds (decimal are OK).  Trims the movie to this duration before exporting.  \n");
	printf("	Also available are some setup options:\n");
	printf("		-verbose  Print more information about the execution.\n");
	printf("		-progress  Show progress information.\n");
	printf("		-listpresets  For sourceMovieURL sources only, lists the tracks in the source movie before the export.  \n");
	printf("		-listtracks  For sourceMovieURL sources only, lists the tracks in the source movie before the export.  \n");
	printf("		-listfiletypes  For sourceMovieURL sources only, lists the allowed export file types.  \n");
	printf("			Always lists the tracks in the destination asset at the end of the export.\n");
	printf("		-listmetadata  Lists the metadata in the source movie before the export.  \n");
	printf("			Also lists the metadata in the destination asset at the end of the export.\n");
	printf("	Sample export lines:\n");
	printf("	./avexporter -dest /tmp/testOut.m4v -replace -preset AVAssetExportPresetAppleM4ViPod -listmetadata -source /path/to/myTestMovie.m4v\n");
	printf("	./avexporter -destination /tmp/testOut.mov -preset AVAssetExportPreset640x480 -listmetadata -listtracks -source /path/to/myTestMovie.mov\n");
}


static dispatch_time_t getDispatchTimeFromSeconds(float seconds) {
	long long milliseconds = seconds * 1000.0;
	dispatch_time_t waitTime = dispatch_time( DISPATCH_TIME_NOW, 1000000LL * milliseconds );
	return waitTime;
}

- (int)run
{	
	NSURL   *sourceURL = nil;
	AVAssetExportSession *avsession = nil;
	NSURL   *destinationURL = nil;
	BOOL	success = YES;

	@autoreleasepool
	{
		NSParameterAssert( [self sourcePath] != nil );

		if ([self listTracks] && [self sourcePath]) {
			[self doListTracks:[self sourcePath]];
		}
		if ([self listMetadata] && [self sourcePath]) {
			[self doListMetadata:[self sourcePath]];
		}
		if ([self destinationPath] == nil) {
			NSLog(@"No output path specified, only listing tracks and/or metadata.");
			goto bail;
		}
		if ([self preset] == nil) {
			NSLog(@"No preset specified, only listing tracks and/or metadata.");
			goto bail;
		}
		
		if ( [self verbose] && [self sourcePath] )
		{
			printNSString([NSString stringWithFormat:@"all av asset presets:%@",
										[AVAssetExportSession allExportPresets]]);
		}
		
		if ([self sourcePath] != nil) {
			sourceURL = [NSURL fileURLWithPath: [self sourcePath] isDirectory: NO];
		}

		AVAsset *sourceAsset = nil;
		NSError* error = nil;
		
		if ([self verbose])
		{
			printNSString([NSString stringWithFormat:
						   @"AVAssetExport for preset:%@ to with source:%@",
						   [self preset], [destinationURL path]]);
		}
		
		destinationURL = [NSURL fileURLWithPath: [self destinationPath]
															isDirectory:NO];
		if ([self removePreExistingFiles] && [[NSFileManager defaultManager]
										fileExistsAtPath:[self destinationPath]])
		{
			if ([self verbose])
			{
				printNSString([NSString stringWithFormat:
							   @"Removing pre-existing destination file at:%@",
							   destinationURL]);
			}
			[[NSFileManager defaultManager] removeItemAtURL:destinationURL
																	error:&error];
		}

		sourceAsset = [[AVURLAsset alloc] initWithURL:sourceURL options:nil];

		if ([self verbose])
		{
			printNSString([NSString stringWithFormat:@"Compatible av asset presets:%@",
				[AVAssetExportSession exportPresetsCompatibleWithAsset:sourceAsset]]);
		}
		if (!([sourceAsset isExportable] || [sourceAsset hasProtectedContent]))
		{
			int exportable = [sourceAsset isExportable];
			int hasProtectedContent = [sourceAsset hasProtectedContent];
			printNSString([NSString stringWithFormat:
						   @"Source movie exportable:%d, hasProtectedConent:%d",
						   exportable, hasProtectedContent]);
			goto bail;
		}
		
		avsession = [[AVAssetExportSession alloc] initWithAsset:sourceAsset
													 presetName:[self preset]];

		[avsession setOutputURL:destinationURL];
		if ([self listFileTypes] && [self sourcePath])
		{
			NSLog(@"printing listfiletypes called");
			[self doListFileTypes:[avsession supportedFileTypes]];
			return success;
		}

		if ([self fileType] != nil) {
			[avsession setOutputFileType:[self fileType]];
		}
		else {
			[avsession setOutputFileType:[avsession supportedFileTypes][0]];
		}
		
		if ([self verbose]) {
			printNSString([NSString stringWithFormat:@"Created AVAssetExportSession: %p", avsession]);
			printNSString([NSString stringWithFormat:@"presetName:%@", [avsession presetName]]);
			printNSString([NSString stringWithFormat:@"source URL:%@", [sourceURL path]]);
			printNSString([NSString stringWithFormat:@"destination URL:%@", [[avsession outputURL] path]]);
			printNSString([NSString stringWithFormat:@"output file type:%@", [avsession outputFileType]]);
		}
		
		// Add a metadata item to indicate how thie destination file was created.
		NSArray *sourceMetadataList = [avsession metadata];
		sourceMetadataList = [self addNewMetadata: sourceMetadataList presetName:[self preset]];
		[avsession setMetadata:sourceMetadataList];
		
		// Set up the time range
		CMTime startTime = kCMTimeZero;
		CMTime durationTime = kCMTimePositiveInfinity;
		
		if ([self startSeconds] != nil) {
			startTime = CMTimeMake([[self startSeconds] floatValue] * 1000, 1000);
		}
		if ([self durationSeconds] != nil) {
			durationTime = CMTimeMake([[self durationSeconds] floatValue] * 1000, 1000);
		}
		CMTimeRange exportTimeRange = CMTimeRangeMake(startTime, durationTime);
		[avsession setTimeRange:exportTimeRange];
	}

	@autoreleasepool
	{
		//  Set up a semaphore for the completion handler and progress timer
		dispatch_semaphore_t sessionWaitSemaphore = dispatch_semaphore_create( 0 );
		
		void (^completionHandler)(void) = ^(void)
		{
			dispatch_semaphore_signal(sessionWaitSemaphore);
		};
		
		// do it.
		[avsession exportAsynchronouslyWithCompletionHandler:completionHandler];
		
		do
		{
			dispatch_time_t dispatchTime = DISPATCH_TIME_FOREVER;  // if we dont want progress, we will wait until it finishes.
			if ([self showProgress])
			{
				dispatchTime = getDispatchTimeFromSeconds((float)1.0);
				printNSString([NSString stringWithFormat:
							   @"AVAssetExport running  progress=%3.2f%%",
							   [avsession progress]*100]);
			}
			dispatch_semaphore_wait(sessionWaitSemaphore, dispatchTime);
		}
		while( [avsession status] < AVAssetExportSessionStatusCompleted );
		
		if ([self showProgress])
			printNSString([NSString stringWithFormat:
				@"AVAssetExport finished progress=%3.2f", [avsession progress]*100]);

		if ([avsession status] != AVAssetExportSessionStatusCompleted)
		{
			success = FALSE;
			NSError *theError = [avsession error];
			if (theError)
			{
				printNSString([theError localizedFailureReason]);
				printNSString([theError localizedDescription]);
			}
		}

		avsession = nil;
		
		if ([self listMetadata] && [self destinationPath]) {
			[self doListMetadata:[self destinationPath]];
		}
		if ([self listTracks] && [self destinationPath]) {
			[self doListTracks:[self destinationPath]];
		}
		
		printNSString([NSString stringWithFormat:
					   @"Finished export of %@ to %@ using preset:%@ success=%s\n",
					   [self sourcePath], [self destinationPath], [self preset],
					   (success ? "YES" : "NO")]);
	}
bail:
	return success;
}


- (NSArray *) addNewMetadata: (NSArray *)sourceMetadataList presetName:(NSString *)presetName
{
	// This method creates a few new metadata items in different keySpaces to be inserted into
	// the exported file along with the metadata that was in the original source.
	// Depending on the output file format, not all of these items will be valid and not all of
	// them will come through to the destination.
	
	AVMutableMetadataItem *newUserDataCommentItem = [[AVMutableMetadataItem alloc] init];
	[newUserDataCommentItem setKeySpace:AVMetadataKeySpaceQuickTimeUserData];
	[newUserDataCommentItem setKey:AVMetadataQuickTimeUserDataKeyComment];
	[newUserDataCommentItem setValue:[NSString stringWithFormat:
		  @"QuickTime userdata: Exported to preset %@ using avexporter at: %@",
		  presetName,
		  [NSDateFormatter localizedStringFromDate:[NSDate date]
										 dateStyle:NSDateFormatterMediumStyle
										 timeStyle:NSDateFormatterShortStyle]]];
	
	AVMutableMetadataItem *newMetaDataCommentItem = [[AVMutableMetadataItem alloc] init];
	[newMetaDataCommentItem setKeySpace:AVMetadataKeySpaceQuickTimeMetadata];
	[newMetaDataCommentItem setKey:AVMetadataQuickTimeMetadataKeyComment];
	[newMetaDataCommentItem setValue:[NSString stringWithFormat:
		  @"QuickTime metadata: Exported to preset %@ using avexporter at: %@",
		  presetName,
		  [NSDateFormatter localizedStringFromDate:[NSDate date]
										 dateStyle:NSDateFormatterMediumStyle
										 timeStyle:NSDateFormatterShortStyle]]];
	
	AVMutableMetadataItem *newiTunesCommentItem = [[AVMutableMetadataItem alloc] init];
	[newiTunesCommentItem setKeySpace:AVMetadataKeySpaceiTunes];
	[newiTunesCommentItem setKey:AVMetadataiTunesMetadataKeyUserComment];
	[newiTunesCommentItem setValue:[NSString stringWithFormat:
		@"iTunes metadata: Exported to preset %@ using avexporter at: %@",
		presetName,
		[NSDateFormatter localizedStringFromDate:[NSDate date]
									   dateStyle:NSDateFormatterMediumStyle
									   timeStyle:NSDateFormatterShortStyle]]];
	
	NSArray *newMetadata = @[newUserDataCommentItem, newMetaDataCommentItem,
														newiTunesCommentItem];
	NSArray *newMetadataList = (sourceMetadataList == nil ? newMetadata :
				[sourceMetadataList arrayByAddingObjectsFromArray:newMetadata]);
	return newMetadataList;
}


+ (void) doListPresets
{ 
	//  A simple listing of the presets available for export
	printNSString(@"");
	printNSString(@"Presets available for AVFoundation export:");
	printNSString([NSString stringWithFormat:@"AVFoundation asset presets:%@",
				   [AVAssetExportSession allExportPresets]]);
/*
	printNSString(@"  QuickTime movie presets:");
	printNSString([NSString stringWithFormat:@"    %@", AVAssetExportPreset640x480]);
	printNSString([NSString stringWithFormat:@"    %@", AVAssetExportPreset960x540]);
	printNSString([NSString stringWithFormat:@"    %@", AVAssetExportPreset1280x720]);
	printNSString([NSString stringWithFormat:@"    %@", AVAssetExportPreset1920x1080]);
	printNSString(@"  Audio only preset:");
	printNSString([NSString stringWithFormat:@"    %@", AVAssetExportPresetAppleM4A]);
	printNSString(@"  Apple device presets:");
	printNSString([NSString stringWithFormat:@"    %@", AVAssetExportPresetAppleM4VCellular]);
	printNSString([NSString stringWithFormat:@"    %@", AVAssetExportPresetAppleM4ViPod]);
	printNSString([NSString stringWithFormat:@"    %@", AVAssetExportPresetAppleM4V480pSD]);
	printNSString([NSString stringWithFormat:@"    %@", AVAssetExportPresetAppleM4VAppleTV]);
	printNSString([NSString stringWithFormat:@"    %@", AVAssetExportPresetAppleM4VWiFi]);
	printNSString([NSString stringWithFormat:@"    %@", AVAssetExportPresetAppleM4V720pHD]);
	printNSString([NSString stringWithFormat:@"    %@", AVAssetExportPresetAppleM4V1080pHD]);
	printNSString(@"  Interim format (QuickTime movie) preset:");
	printNSString([NSString stringWithFormat:@"    %@", AVAssetExportPresetAppleProRes422LPCM]);
	printNSString(@"  Passthrough preset:");
	printNSString([NSString stringWithFormat:@"    %@", AVAssetExportPresetPassthrough]);
	printNSString(@"");
*/
}


- (void)doListTracks:(NSString *)assetPath
{ 
	//  A simple listing of the tracks in the asset provided
	NSURL *sourceURL = [NSURL fileURLWithPath: assetPath isDirectory: NO];
	if (sourceURL)
	{
		AVURLAsset *sourceAsset = [[AVURLAsset alloc] initWithURL:sourceURL options:nil];
		printNSString([NSString stringWithFormat:@"Listing tracks for asset from url:%@",
																[sourceURL path]]);
		NSInteger index = 0;
		for (AVAssetTrack *track in [sourceAsset tracks])
		{
			printNSString([ NSString stringWithFormat:
			@"  Track index:%ld, trackID:%d, mediaType:%@, enabled:%d, isSelfContained:%d",
			index, [track trackID], [track mediaType], [track isEnabled],
			[track isSelfContained] ] );
			index++;
		}
	}
}

- (void)doListFileTypes:(NSArray *)fileTypes
{ 
	//  A simple listing of the tracks in the asset provided
	if (fileTypes)
	{
		printNSString([NSString stringWithFormat:@"Listing export file types"]);
		for (NSString *theFileType in fileTypes)
		{
			printNSString([ NSString stringWithFormat:@"File Export type: %@",
																theFileType] );
		}
	}
}

enum {
	kMaxMetadataValueLength = 80,
};

-(void)printAnAVMetadataItem:(AVMetadataItem *)item
{
    NSObject *key = [item key];
    NSString *itemValue = [[item value] description];
    if ([itemValue length] > kMaxMetadataValueLength) {
        itemValue = [NSString stringWithFormat:@"%@ ...",
                     [itemValue substringToIndex:kMaxMetadataValueLength-4]];
    }
    if ([key isKindOfClass: [NSNumber class]])
    {
        NSInteger longValue = [(NSNumber *)key longValue];
        char *charSource = (char *)&longValue;
        char charValue[5] = {0};
        charValue[0] = charSource[3];
        charValue[1] = charSource[2];
        charValue[2] = charSource[1];
        charValue[3] = charSource[0];
        NSString *stringKey;
        stringKey = [[NSString alloc]
                     initWithBytes:charValue
                     length:4
                     encoding:NSMacOSRomanStringEncoding];
        printNSString([NSString stringWithFormat:
                       @"  metadata item key:%@ (%ld), keySpace:%@ commonKey:%@ value:%@",
                       stringKey, longValue, [item keySpace], [item commonKey], itemValue]);
    }
    else
    {
        printNSString([NSString stringWithFormat:
                       @"  metadata item key:%@, keySpace:%@ commonKey:%@ value:%@",
                       [item key], [item keySpace], [item commonKey], itemValue]);
    }
}

-(void)printCMTime:(CMTime)cmTime
{
    if (cmTime.timescale == 0)
    {
        printNSString([NSString stringWithFormat:@"timescale = 0, %lld",
                                                    cmTime.value]);
    }
    else
    {
        float timeInSecs = ((double)cmTime.value) / (double)cmTime.timescale;
        printNSString([NSString stringWithFormat:@"time: %f (secs), value: %lld, scale: %d",
                                            timeInSecs, cmTime.value, cmTime.timescale]);
    }
}

- (void)doListMetadata:(NSString *)assetPath
{
	//  A simple listing of the metadata in the asset provided
	NSURL *sourceURL = [NSURL fileURLWithPath: assetPath isDirectory: NO];
	if (sourceURL)
	{
		AVURLAsset *sourceAsset = [[AVURLAsset alloc] initWithURL:sourceURL
															options:nil];
		NSLog(@"Listing metadata for asset from url:%@", [sourceURL path]);
		for (NSString *format in [sourceAsset availableMetadataFormats])
		{
			NSLog(@"Metadata for format:%@", format);
            
			for (AVMetadataItem *item in [sourceAsset metadataForFormat:format])
			{
                [self printAnAVMetadataItem:item];
			}
		}
        
        NSArray *assetTracks = [sourceAsset tracks];
        for (AVAssetTrack *track in assetTracks)
        {
            printNSString(@"============================================");
            NSLog(@"Metadata for asset track media type %@ and trackID: %d",
                                            [track mediaType], [track trackID]);
            for (AVMetadataItem *item in [track commonMetadata])
            {
                [self printAnAVMetadataItem:item];
            }
            for (NSString *format in [track availableMetadataFormats])
            {
                NSLog(@"Metadata for format:%@", format);
                
                for (AVMetadataItem *item in [sourceAsset metadataForFormat:format])
                {
                    [self printAnAVMetadataItem:item];
                }
            }
            CMTimeRange timeRange = track.timeRange;
            printNSString(@"Start time: ");
            [self printCMTime:timeRange.start];
            printNSString(@"Duration: ");
            [self printCMTime:timeRange.duration];
            
            NSString *desc;
            if ([track hasMediaCharacteristic:AVMediaCharacteristicVisual])
            {
                desc = [NSString stringWithFormat:@"Visual: %@, ", track.mediaType];
                printNSString(desc);
                CGSize size = track.naturalSize;
                desc = [NSString stringWithFormat:@"Size: %f, %f",
                                                  size.width,
                                                  size.height];
                printNSString(desc);
                desc = [NSString stringWithFormat:@"Frame rate: %f",
                                                  track.nominalFrameRate];
                printNSString(desc);
                printNSString(@"Min frame duration:");
                [self printCMTime:track.minFrameDuration];
                printNSString(desc);
            }
            else if ([track hasMediaCharacteristic:AVMediaCharacteristicAudible])
            {
                printNSString(@"Audible Media");
                desc = [NSString stringWithFormat:@"Preferred volume: %f",
                        track.preferredVolume];
                printNSString(desc);
            }
            else if ([track hasMediaCharacteristic:AVMediaCharacteristicLegible])
            {
                printNSString(@"Legible Media");
            }
            
            NSArray *segments = [track segments];
            printNSString([NSString stringWithFormat:@"Num segments: %ld",
                                                     (long)segments.count]);
            for (AVAssetTrackSegment *segment in segments)
            {
                CMTimeMapping mapping = segment.timeMapping;
                printNSString(@"Source start time:");
                [self printCMTime:mapping.source.start];
                printNSString(@"Source duration:");
                [self printCMTime:mapping.source.duration];
                printNSString(@"Target start time:");
                [self printCMTime:mapping.target.start];
                printNSString(@"Target duration:");
                [self printCMTime:mapping.target.duration];
            }
            printNSString(@"============================================");
        }
	}
}

@end


// ---------------------------------------------------------------------------
//		main
// ---------------------------------------------------------------------------


int main (int argc, const char * argv[], const char* environ[])
{
	BOOL success = NO;
	//	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	@autoreleasepool
	{
		AVExporter* exportObj = [[AVExporter alloc] initWithArgs:argc argv:argv
															environ:environ];
		if (exportObj)
			success = [exportObj run];
	}
	
	return ((success == YES) ? 0 : -1);
}


// ---------------------------------------------------------------------------
//		printNSString
// ---------------------------------------------------------------------------
static void printNSString(NSString *string)
{
	printf("%s\n", [string cStringUsingEncoding:NSUTF8StringEncoding]);
}

// ---------------------------------------------------------------------------
//		printArgs
// ---------------------------------------------------------------------------
static void printArgs(int argc, const char **argv)
{
	int i;
	for( i = 0; i < argc; i++ )
		printf("%s ", argv[i]);
	printf("\n");
}

