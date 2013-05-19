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

-(id)initWithWindowNibName:(NSString *)windowNibName appDelegate:(YVSAppDelegate *)appDelegate;

-(void)windowWillClose:(NSNotification *)notification;

@end
