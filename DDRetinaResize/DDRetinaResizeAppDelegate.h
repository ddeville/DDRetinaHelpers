//
//  DDRetinaResizeAppDelegate.h
//  DDRetinaResize
//
//  Created by Damien DeVille on 2/1/11.
//  Copyright 2011 Acrossair. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DDRetinaResizeAppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate>
{
	NSWindow *window ;
	
	NSTextField *originTextField ;
	NSTextField *destinationTextField ;
	NSButton *resizeButton ;
}

@property (assign) IBOutlet NSWindow *window ;

@property (assign) IBOutlet NSTextField *originTextField ;
@property (assign) IBOutlet NSTextField *destinationTextField ;
@property (assign) IBOutlet NSButton *resizeButton ;

- (IBAction)resizeButtonClicked:(id)sender ;

@end
