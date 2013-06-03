//
//  YVSFrameGrabberWindowController.h
//  Commander
//
//  Created by Kevin Meaney on 29/05/2013.
//  Copyright (c) 2013 Kevin Meaney. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YVSAppDelegate;

@interface YVSFrameGrabberWindowController : NSWindowController

@property (readonly, weak) IBOutlet NSPathControl *sourceFile;
@property (nonatomic, strong) NSURL *sourceURL;
@property (nonatomic, assign) BOOL verbose;

@property (nonatomic, assign) BOOL listTracks;
@property (nonatomic, assign) BOOL listMetadata;

@property (readonly, weak) IBOutlet NSPopUpButton *fileTypesPopup;
@property (readonly, weak) IBOutlet NSPopUpButton *frameTimesTypePopup;
@property (readonly, weak) IBOutlet NSArrayController *exportTypesController;

@property (nonatomic, weak) IBOutlet NSTextField *frameTimesTextField;
@property (nonatomic, weak) IBOutlet NSTextField *frameTimesLabelField;
@property (nonatomic, weak) IBOutlet NSTextField *frameTimesTextSuffix;

@property (nonatomic, strong) NSString *selectedFileType;
@property (nonatomic, strong) NSArray *exportImageFileTypes;

@property (nonatomic, weak) IBOutlet NSTextField *filenameExtension;
@property (nonatomic, assign) BOOL showProgress;
@property (readonly, weak) IBOutlet NSPathControl *destinationFolder;
@property (readonly, weak) IBOutlet NSTextField *baseFilenameTextField;
@property (readonly, weak) IBOutlet NSTextField *firstFrameGrabFilename;
@property (readonly, weak) IBOutlet NSTextField *generatedFrameGrabsCommand;

-(id)initWithWindowNibName:(NSString *)windowNibName
									appDelegate:(YVSAppDelegate *)appDelegate;

- (IBAction)frameTimesTypeMenuSelected:(id)sender;
- (IBAction)exportFileTypeMenuSelected:(id)sender;
- (IBAction)generateFrameGrabCommand:(id)sender;
- (IBAction)copyFrameGrabCommandToClipboard:(id)sender;

@end
