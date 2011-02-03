//
//  DDRetinaResizeAppDelegate.m
//  DDRetinaResize
//
//  Created by Damien DeVille on 2/1/11.
//  Copyright 2011 Acrossair. All rights reserved.
//

#import "DDRetinaResizeAppDelegate.h"
#import "NSImage+MGCropExtensions.h"

@implementation DDRetinaResizeAppDelegate

@synthesize window ;
@synthesize originTextField ;
@synthesize destinationTextField ;
@synthesize resizeButton ;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	
}

- (void)dealloc
{
	[originTextField release] ;
	[destinationTextField release] ;
	[resizeButton release] ;
	
	[super dealloc] ;
}

- (IBAction)resizeButtonClicked:(id)sender
{
	if ([[originTextField stringValue] length] && [[destinationTextField stringValue] length])
	{
		// the origin and destination paths
		NSString *fromPath = [originTextField stringValue] ;
		NSString *toPath = [destinationTextField stringValue] ;
		
		// a copy of the file manager
		NSFileManager *fileManager = [NSFileManager defaultManager] ;
		
		// check that the path where to pull the images from is valid
		if (fromPath && [fileManager fileExistsAtPath: fromPath] == NO)
		{
			NSLog(@"The path to the images is not valid") ;
			return ;
		}
		
		// check that the user specified a path where to store the images and in that case that it is valid
		if (toPath && [fileManager fileExistsAtPath: toPath] == NO)
		{
			NSLog(@"The path where to store the images is not valid\n") ;
			return ;
		}
		
		// create a pointer to an error that we can display later (if needed)
		NSError *error = nil ;
		
		// get the content of the 'from' directory
		NSArray *content = [fileManager subpathsOfDirectoryAtPath: fromPath error: &error] ;
		
		if (error)
		{
			NSLog(@"Oups! %@", [error localizedDescription]) ;
			return ;
		}
		
		// loop through the content array
		BOOL isDirectory ;
		NSString *extension ;
		NSString *fileName ;
		NSString *newPath ;
		NSString *completePath ;
		
		for (NSString *path in content)
		{
			completePath = [fromPath stringByAppendingPathComponent: path] ;
			
			// check that the path is actually a valid file
			if ([fileManager fileExistsAtPath: completePath isDirectory: &isDirectory])
			{
				// check if the current is a directory
				if (isDirectory == YES)
				{
					// in that case, replicate the directory in the new folder
					newPath = [toPath stringByAppendingPathComponent: path] ;
					// we need to create a subdirectory if it does not already exist
					[fileManager createDirectoryAtPath: newPath withIntermediateDirectories: YES attributes: nil error: &error] ;
					
					// catch the error
					if (error)
						NSLog(@"Oups! %@ at path: %@", [error localizedDescription], newPath) ;
					
					// and we can go on with the other files
					continue ;
				}
				
				// get the file extension
				extension = [[path pathExtension] lowercaseString] ;
				
				// we only want .PNG .JPG .JPEG files
				if ([extension isEqualToString: @"png"] || [extension isEqualToString: @"jpg"] || [extension isEqualToString: @"jpeg"])
				{
					// get the last path component (filename)
					fileName = [path lastPathComponent] ;
					fileName = [fileName stringByDeletingPathExtension] ;
					
					// re-create the file name with the @2x appended to it
					// check whether the file has a @2x extension, in that case remove it
					if ([fileName length] > 3 && [[fileName substringFromIndex: [fileName length]-3] isEqualToString: @"@2x"])
						fileName = [fileName substringToIndex: [fileName length]-3] ;
					fileName = [fileName stringByAppendingPathExtension: extension] ;
					
					// remove the initial last component
					path = [path stringByDeletingLastPathComponent] ;
					
					// add the brand new one (without @2x)
					path = [path stringByAppendingPathComponent: fileName] ;
					
					// create the new directory path
					newPath = [toPath stringByAppendingPathComponent: path] ;
					
					// first load the image data from file
					NSURL *pathURL = [NSURL fileURLWithPath: completePath] ;
					NSData *imageData = [NSData dataWithContentsOfURL: pathURL] ;
					
					// get a bitmap representation of the image data
					NSBitmapImageRep *sourceRep = [[NSBitmapImageRep alloc] initWithData: imageData] ;
					
					// create a new bitmap representation scaled down
					NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes: NULL
																					   pixelsWide: 0.5f * [sourceRep pixelsWide]
																					   pixelsHigh: 0.5f * [sourceRep pixelsHigh]
																					bitsPerSample: 8
																				  samplesPerPixel: 4
																						 hasAlpha: YES
																						 isPlanar: NO
																				   colorSpaceName: NSCalibratedRGBColorSpace
																					  bytesPerRow: 0
																					 bitsPerPixel: 0] ;

					// save the graphics context, create a bitmap context and set it as current
					[NSGraphicsContext saveGraphicsState] ;
					NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep: newRep] ;
					[NSGraphicsContext setCurrentContext: context] ;
					
					// draw the bitmap image representation in it and restore the context
					[sourceRep drawInRect: NSMakeRect(0.0f, 0.0f, 0.5f * [sourceRep pixelsWide], 0.5f * [sourceRep pixelsHigh])] ;
					[NSGraphicsContext restoreGraphicsState] ;
					
					// set the size of the new bitmap representation
					[newRep setSize: NSMakeSize(0.5f * sourceRep.size.width, 0.5f * sourceRep.size.height)] ;
					[sourceRep release] ;
					
					// get the bitmap image data as PNG
					imageData = [newRep representationUsingType: NSPNGFileType properties: nil] ;
					[newRep release] ;
					
					// create the image file at the destination path
					[fileManager createFileAtPath: newPath contents: imageData attributes: nil] ;
					
					// catch the error
					if (error)
						NSLog(@"Oups! %@ at path: %@", [error localizedDescription], newPath) ;
				}
			}
		}
	}
}

@end
