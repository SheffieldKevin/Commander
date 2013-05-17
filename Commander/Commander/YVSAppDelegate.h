//
//  YVSAppDelegate.h
//  Commander
//
//  Created by Kevin Meaney on 17/05/2013.
//  Copyright (c) 2013 Kevin Meaney. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YVSMovieExporterWindowController;

@interface YVSAppDelegate : NSObject <NSApplicationDelegate>
{
	YVSMovieExporterWindowController *movieExportController;
}

-(IBAction)displayExportMovieDialog:(id)sender;

@end
