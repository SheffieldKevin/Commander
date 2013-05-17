 //
 // File: avframegrabber.m // based on avexporter.m
 // Project: avexporter
 // Target: avframegrab
 // 
 // Abstract: This file shows an example of using the export and metadata
 // functions in AVFoundation as a part of a command line tool for
 // simple exports.
 //
 // Abstract:   <Description, Points of interest, Algorithm approach>
 //
 // Version:	<1.0>
 //
 //
 // Copyright ( C ) 2011 Apple Inc. All Rights Reserved.
 //

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>

// ---------------------------------------------------------------------------
//		S W I T C H E S
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
//		P R O T O T Y P E S
// ---------------------------------------------------------------------------

static void printNSString(NSString *string);
static void printArgs(int argc, const char **argv);

#pragma mark -
#pragma mark AVFrameGrab Interface

// ---------------------------------------------------------------------------
//		AVFrameGrab Class Interface
// ---------------------------------------------------------------------------

@interface AVFrameGrab : NSObject
{	
	NSString	*programName;
	NSString	*exportImageFileType;
	NSString	*sourcePath;
	NSString	*destinationPath;	// The name of the directory.
	NSString	*baseFileName;
	NSString	*times;
// Initially implement only a version where the times for a screen grab are listed in command.
// But afterwards add a number version which specifies the number of screen grabs to be taken which
// are obtained at regular intervals during the length of the video. Also add a withperiod option
// that specifies the time between when each frames is grabbed. Since there will be three different
// ways to enter the times when screen grabs should happen, if more than one way is entered in the
// command arguments then the last option in the argument list will be the one that is used.
	NSNumber	*progress;
//	NSInteger	imageNumber;
	BOOL		showProgress;
	BOOL		verbose;
	BOOL		exportFailed;
	BOOL		exportComplete;
	BOOL		listTracks;
	BOOL		listMetadata;
//	BOOL		removePreExistingFiles;
}

@property (strong) NSString	*programName;
@property (strong) NSString	*exportImageFileType;
@property (strong) NSString	*sourcePath;
@property (strong) NSString	*destinationPath;
@property (strong) NSString *baseFileName;
@property (strong) NSString *times;
@property (strong) NSNumber	*progress;
// @property (assign) NSInteger imageNumber;
@property (assign) BOOL		verbose;
@property (assign) BOOL		showProgress;
@property (assign) BOOL		frameGrabFailed;
@property (assign) BOOL		frameGrabComplete;
@property (assign) BOOL		listTracks;
@property (assign) BOOL		listMetadata;
// @property (assign) BOOL		removePreExistingFiles;

- (id)initWithArgs: (int) argc  argv: (const char **) argv environ: (const char **) environ;
- (void)printUsage;

- (int)run;

- (void) doListTracks:(NSString *)assetPath;
- (void) doListMetadata:(NSString *)assetPath;

@end


// ---------------------------------------------------------------------------
//		AVFrameGrab Class Implementation
// ---------------------------------------------------------------------------

@implementation AVFrameGrab

@synthesize programName;
@synthesize exportImageFileType;
@synthesize sourcePath;
@synthesize destinationPath;
@synthesize baseFileName;
@synthesize times;
@synthesize progress;
// @synthesize imageNumber;
@synthesize	verbose;
@synthesize showProgress;
@synthesize frameGrabComplete;
@synthesize frameGrabFailed;
@synthesize listTracks;
@synthesize listMetadata;
// @synthesize removePreExistingFiles;

-(id) initWithArgs: (int) argc  argv: (const char **) argv environ: (const char **) environ
{
	self = [super init];
	if (self == nil)
	{
		return nil;
	}

	printArgs(argc,argv);
	
	BOOL gotsource = NO;
	BOOL gotout = NO;
	BOOL parseOK = NO;
	BOOL gotBaseFileName = NO;
	BOOL gotExportFileType = NO;
	BOOL gotTimes = NO;

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
			NSString *expandedPath = [@(*argv++) stringByExpandingTildeInPath];
			[self setDestinationPath:expandedPath];
			gotout = YES;
			argc--;
		}
		else if (!strcmp(args, "filetype"))
		{
			[self setExportImageFileType:@(*argv++)];
			gotExportFileType = YES;
			argc--;
		}
		else if (!strcmp(args, "basefilename"))
		{
			[self setBaseFileName:@(*argv++)];
			gotBaseFileName = YES;
			argc--;
		}
		else if (!strcmp(args, "times"))
		{
			[self setTimes:@(*argv++)];
			gotTimes = YES;
			argc--;
		}
//		else if ( ! strcmp ( args, "replace" ) )
//		{
//			[self setRemovePreExistingFiles: YES];
//		}
		else if ( ! strcmp ( args, "verbose" ) )
		{
			[self setVerbose:YES];
		}
		else if ( ! strcmp ( args, "progress" ) )
		{
			[self setShowProgress: YES];
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
		else if ( ! strcmp ( args, "help" ) )
		{
			[self printUsage];
		}
		else
		{
			printf("Invalid input parameter: %s\n", args );
			[self printUsage];
			return nil;
		}
	}
//	[self setProgress: @((float)0.0)];
//	[self setImageNumber:0];
	
	if ([self verbose])
	{
		printNSString([NSString stringWithFormat:@"Running: %@\n", [self programName]]);
	}
	
	// There must be a source, times, base file name, and output (the normal case) or parseOK set for a listing
	if (! (parseOK || ((gotsource && gotout && gotBaseFileName && gotExportFileType && gotTimes))) )
	{
		[self printUsage];
		return nil;
	}
	
	return self;
}


-(void) printUsage
{
	printf("avframegrab - usage:\n");
	printf("	./avframegrab [-parameter <value> ...]\n");
	printf("	 parameters are all preceded by a -<parameterName>.  The order of the parameters is unimportant.\n");
	printf("	 Required parameters are -source <sourceFileURL> -dest <outputFolderURL>\n");
	printf("	 Source and destination URL strings cannot contain spaces.\n");
	printf("	 Available parameters are:\n");
	printf("	 	-destination (or -dest) <outputFolderURL>\n");
	printf("	 	-source <sourceMovieURL>\n");
//	printf("		-replace   Replace any files if they already exist.\n");
	printf("	 	-filetype <file type string> The file type (eg public.jpeg) for the output file.\n");
	printf("		-times a,b,c,d  A list of times to take framegrabs (seconds from start). Has dec point, no spaces, sep by ,. Ignores invalid times.\n");
	printf("		-basefilename The base file name which will have appended grab # and extension.\n");
	printf("	Also available are some setup options:\n");
	printf("		-verbose  Print more information about the execution.\n");
	printf("		-progress  Show progress information.\n");
	printf("		-listmetadata  Lists the metadata in the source movie before the export.  \n");
	printf("		-listtracks  Lists the tracks in the source movie before exporting.  \n");
	printf("	Sample export lines:\n");
	printf("	./avframegrab -dest ~/Pictures/temp -listmetadata -source /path/to/myTestMovie.m4v -times 1.3,5.0,7.0,12.0 -filetype public.jpeg -basefilename Image\n");
	printf("	./avframegrab -destination ~/Documents/temp -listtracks -source /path/to/myTestMovie.mov -times 0.2,0.4,0.6,0.8,1.0 -filetype public.png -basefilename Image\n");
}


static dispatch_time_t getDispatchTimeFromSeconds(float seconds)
{
	long long milliseconds = seconds * 1000.0;
	dispatch_time_t waitTime = dispatch_time( DISPATCH_TIME_NOW, 1000000LL * milliseconds );
	return waitTime;
}

- (int)run
{	
	NSURL   *sourceURL;
	AVAssetImageGenerator *imageGenerator;
	NSURL   *destinationURL;
	BOOL	success = YES;

	@autoreleasepool
	{
		NSParameterAssert( [self sourcePath] != nil );

		if ([self listTracks] && [self sourcePath])
			[self doListTracks:[self sourcePath]];

		if ([self listMetadata] && [self sourcePath])
			[self doListMetadata:[self sourcePath]];

		if ([self destinationPath] == nil)
		{
			NSLog(@"No output path specified, only listing tracks and/or metadata, export was not performed.");
			goto bail;
		}

		if ([self sourcePath] != nil)
		{
			sourceURL = [NSURL fileURLWithPath: [self sourcePath] isDirectory: NO];
		}

		AVAsset *sourceAsset = nil;
//		NSError* error = nil;
		
		destinationURL = [NSURL fileURLWithPath: [self destinationPath] isDirectory: YES];
//		if ([self verbose])
//		{
//			printNSString([NSString stringWithFormat:@"AVFrameGrab for source:%@",
//						   [sourceURL path]]);
//		}

/*
		if ([self removePreExistingFiles] && [[NSFileManager defaultManager] fileExistsAtPath:[self destinationPath]])
		{
			if ([self verbose])
				printNSString([NSString stringWithFormat:@"Removing re-existing destination files in:%@", destinationURL]);

			[[NSFileManager defaultManager] removeItemAtURL:destinationURL error:&error];
		}
*/
		NSDictionary *optionDict = [[NSDictionary alloc] initWithObjectsAndKeys:@((NSInteger)YES), AVURLAssetPreferPreciseDurationAndTimingKey, nil];
		sourceAsset = [[AVURLAsset alloc] initWithURL:sourceURL options:optionDict];

		if ([[sourceAsset tracksWithMediaType:AVMediaTypeVideo] count] == 0)
			return NO;

		imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:sourceAsset];
//		AVAssetImageGenerator * __weak imageGeneratorWeakReference = imageGenerator;
//		[imageGeneratorWeakReference setRequestedTimeToleranceAfter:kCMTimeZero];
		[imageGenerator setRequestedTimeToleranceAfter:kCMTimeZero];
		[imageGenerator setRequestedTimeToleranceBefore:kCMTimeZero];
		if ([self verbose])
		{
			printNSString([NSString stringWithFormat:@"Created AVAssetImageGenerator: %p", imageGenerator]);
			printNSString([NSString stringWithFormat:@"source URL:%@", [sourceURL path]]);
			printNSString([NSString stringWithFormat:@"destination URL:%@", [destinationURL path]]);
		}
	}

	//	pool = [[NSAutoreleasePool alloc] init];
	@autoreleasepool
	{
		NSArray *timesArray = [[self times] componentsSeparatedByString:@","];
		NSInteger numTimes = [timesArray count];
		if (numTimes == 0)
			return NO;

		__block NSInteger imageNumber = 0;
		NSNumber *theNum = nil;
		NSNumberFormatter *theFormatter = [[NSNumberFormatter alloc] init];
		NSMutableArray *cmTimesArray = [[NSMutableArray alloc] initWithCapacity:0];
		NSValue *cmTimeValue = nil;

		for (NSString *theString in timesArray)
		{
			theNum = [theFormatter numberFromString:theString];
			Float64 theTimeNum = (Float64)[theNum doubleValue];
			CMTime frameGrabTime = CMTimeMakeWithSeconds(theTimeNum, 600);
			cmTimeValue = [NSValue valueWithCMTime:frameGrabTime];
			[cmTimesArray addObject:cmTimeValue];
		}
		
//		NSFileManager *fileManager = [NSFileManager defaultManager];
		//  Set up a semaphore for the completion handler and progress timer
		dispatch_semaphore_t sessionWaitSemaphore = dispatch_semaphore_create( 0 );
		
		AVAssetImageGeneratorCompletionHandler imageCreatedCompletionHandler;
		imageCreatedCompletionHandler = ^(CMTime requestedTime, CGImageRef image, CMTime actualTime,
										  AVAssetImageGeneratorResult result, NSError *error)
		{
			NSInteger localImageNumber = imageNumber++;
			NSString *requestedTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, requestedTime));
			NSString *actualTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, actualTime));
			NSLog(@"Requested: %@; actual %@", requestedTimeString, actualTimeString);
			
			if (result == AVAssetImageGeneratorSucceeded)
			{
				// Need to put together the file name.
				NSString *numString = [NSString stringWithFormat:@"%.6ld", (long)localImageNumber];
				NSString *fileExtension = (NSString *)CFBridgingRelease(
							UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)[self exportImageFileType], kUTTagClassFilenameExtension));
				NSString *fullPath = [NSString stringWithFormat:@"%@/%@%@.%@", [self destinationPath], [self baseFileName], numString, fileExtension];
				NSURL *destinationURL = [[NSURL alloc] initFileURLWithPath:fullPath];
				CGImageDestinationRef destination = CGImageDestinationCreateWithURL(
																		(__bridge CFURLRef)destinationURL,
																		(__bridge CFStringRef)[self exportImageFileType],
																					1, nil);
				CGImageDestinationAddImage(destination, image, nil);
				bool result = CGImageDestinationFinalize(destination);
				if (!result && [self verbose])
				{
					NSLog(@"Failed to write image to %@", fullPath);
				}
				CFRelease(destination);
			}
			if (result == AVAssetImageGeneratorFailed && [self verbose])
			{
				NSLog(@"Failed with error: %@", [error localizedDescription]);
			}
			
			if (result == AVAssetImageGeneratorCancelled && [self verbose])
			{
				NSLog(@"Canceled");
				dispatch_semaphore_signal(sessionWaitSemaphore);
			}
			else if (imageNumber == numTimes)
				dispatch_semaphore_signal(sessionWaitSemaphore);
		};
		
		[imageGenerator generateCGImagesAsynchronouslyForTimes:cmTimesArray completionHandler:imageCreatedCompletionHandler];
		
		do
		{
			dispatch_time_t dispatchTime = DISPATCH_TIME_FOREVER;  // if we dont want progress, we will wait until it finishes.
			if ([self showProgress])
			{
				dispatchTime = getDispatchTimeFromSeconds((float)1.0);
				printNSString([NSString stringWithFormat:@"generateCGImagesAsynchronouslyForTimes running  progress=%3.2f%%", imageNumber*100.0 / numTimes]);
			}
			dispatch_semaphore_wait(sessionWaitSemaphore, dispatchTime);
		}
		while( imageNumber < numTimes );
		
		if ([self showProgress])
			printNSString(@"AVAssetImageGenerator finished progress");
		
		if ([self listMetadata] && [self destinationPath])
			[self doListMetadata:[self destinationPath]];

		if ([self listTracks] && [self destinationPath])
			[self doListTracks:[self destinationPath]];
		
		printNSString([NSString stringWithFormat:@"Finished creating images of %@ to %@ success=%s\n",
					   [self sourcePath], [self destinationPath], (success ? "YES" : "NO")]);
	}
bail:
	return success;
}

- (void)doListTracks:(NSString *)assetPath
{ 
	//  A simple listing of the tracks in the asset provided
	NSURL *sourceURL = [NSURL fileURLWithPath: assetPath isDirectory: NO];
	if (sourceURL)
	{
		AVURLAsset *sourceAsset = [[AVURLAsset alloc] initWithURL:sourceURL options:nil];
		printNSString([NSString stringWithFormat:@"Listing tracks for asset from url:%@", [sourceURL path]]);
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
//		NSLog(@"file types: %@", [fileTypes description]);
		printNSString([NSString stringWithFormat:@"Listing possible file export types"]);
		for (NSString *theFileType in fileTypes)
		{
			printNSString([ NSString stringWithFormat:@"File Export type: %@", theFileType] );
		}
	}
}

enum {
	kMaxMetadataValueLength = 80,
};

- (void)doListMetadata:(NSString *)assetPath
{
	//  A simple listing of the metadata in the asset provided
	NSURL *sourceURL = [NSURL fileURLWithPath: assetPath isDirectory: NO];
	if (sourceURL)
	{
		AVURLAsset *sourceAsset = [[AVURLAsset alloc] initWithURL:sourceURL options:nil];
		NSLog(@"Listing metadata for asset from url:%@", [sourceURL path]);
		for (NSString *format in [sourceAsset availableMetadataFormats])
		{
			NSLog(@"Metadata for format:%@", format);
			for (AVMetadataItem *item in [sourceAsset metadataForFormat:format])
			{
				NSObject *key = [item key];
				NSString *itemValue = [[item value] description];
				if ([itemValue length] > kMaxMetadataValueLength) {
					itemValue = [NSString stringWithFormat:@"%@ ...", [itemValue substringToIndex:kMaxMetadataValueLength-4]];
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
					NSString *stringKey = [[NSString alloc] initWithBytes: charValue length:4 encoding:NSMacOSRomanStringEncoding];
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
	@autoreleasepool
	{
		AVFrameGrab* frameGrabber = [[AVFrameGrab alloc] initWithArgs:argc argv:argv  environ:environ];
		if (frameGrabber)
			success = [frameGrabber run];
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

