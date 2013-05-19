//
//  YVSAppDelegate.h
//  Commander
//
//  Created by Kevin Meaney on 17/05/2013.
//  Copyright (c) 2013 Kevin Meaney. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface YVSAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) NSWindowController *currentWindowController;

-(IBAction)displayExportMovieDialog:(id)sender;

@end
