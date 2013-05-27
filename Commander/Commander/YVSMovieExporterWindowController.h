//
//  YVSMovieExporterWindowController.h
//  Commander
//
//  Created by Kevin Meaney on 17/05/2013.
//  Copyright (c) 2013 Kevin Meaney. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YVSAppDelegate;

@interface YVSMovieExporterWindowController : NSWindowController

@property (readonly, weak) IBOutlet NSPathControl *sourceFile;
@property (nonatomic, strong) NSURL *sourceURL;
@property (nonatomic, assign) BOOL verbose;

@property (nonatomic, assign) BOOL listAllPresets;
@property (nonatomic, assign) BOOL listTracks;
@property (nonatomic, assign) BOOL listMetadata;
@property (readonly, weak) IBOutlet NSTextField *generatedListCommand;

@property (readonly, weak) IBOutlet NSPopUpButton *presetsPopup;
@property (readonly, weak) IBOutlet NSPopUpButton *fileTypesPopup;
@property (nonatomic, assign) BOOL specifyStartTimeAndDuration;
@property (nonatomic, weak) IBOutlet NSTextField *startTimeTextField;
@property (nonatomic, weak) IBOutlet NSTextField *durationTextField;
@property (nonatomic, strong) NSArray *availablePresets;
@property (nonatomic, weak) IBOutlet NSArrayController *availablePresetsController;
@property (nonatomic, strong) NSString *selectedPreset;
@property (nonatomic, strong) NSArray *allowedFileTypes;
@property (nonatomic, weak) IBOutlet NSArrayController *allowedFileTypesController;
@property (nonatomic, strong) NSString *selectedFileType;
@property (nonatomic, weak) IBOutlet NSTextField *filenameExtension;
@property (nonatomic, assign) BOOL replaceDestinationFile;
@property (nonatomic, assign) BOOL showProgress;
@property (readonly, weak) IBOutlet NSPathControl *destinationFile;
@property (readonly, weak) IBOutlet NSTextField *baseFilenameTextField;
@property (readonly, weak) IBOutlet NSTextField *fullFilenameTextField;
@property (readonly, weak) IBOutlet NSTextField *generatedExportCommand;

-(id)initWithWindowNibName:(NSString *)windowNibName
										appDelegate:(YVSAppDelegate *)appDelegate;
-(void)windowWillClose:(NSNotification *)notification;

-(IBAction)generateListCommand:(id)sender;
-(IBAction)generateExportCommand:(id)sender;
-(IBAction)generateListAndExportCommand:(id)sender;
-(IBAction)copyListCommandToClipboard:(id)sender;
-(IBAction)copyExportCommandToClipboard:(id)sender;

@end
