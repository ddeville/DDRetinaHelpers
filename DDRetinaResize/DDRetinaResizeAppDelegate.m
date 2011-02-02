//
//  DDRetinaResizeAppDelegate.m
//  DDRetinaResize
//
//  Created by Damien DeVille on 2/1/11.
//  Copyright 2011 Acrossair. All rights reserved.
//

#import "DDRetinaResizeAppDelegate.h"

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
					
					// half the image
					NSImage *newImage = [self resizeImageAtPath: completePath] ;
					
					// transform the image to NSData
					NSData *imageData = [newImage TIFFRepresentation] ;
					
					// copy the image to the new path
					[fileManager createFileAtPath: newPath contents: imageData attributes: nil] ;
					
					// catch the error
					if (error)
						NSLog(@"Oups! %@ at path: %@", [error localizedDescription], newPath) ;
				}
			}
		}
	}
}

- (NSImage *)resizeImageAtPath:(NSString *)path
{
	NSURL *pathURL = [NSURL fileURLWithPath: path] ;
	NSImage *sourceImage = [[NSImage alloc] initWithContentsOfURL: pathURL] ;
	[sourceImage setScalesWhenResized: YES] ;
	CGSize imageSize = [sourceImage size] ;
	CGSize smallSize = NSMakeSize(0.5f * imageSize.width, 0.5f * imageSize.height) ;
	
	NSImage *smallImage = nil ;
	
	// Report an error if the source isn't a valid image
	if (![sourceImage isValid])
	{
		NSLog(@"Invalid image at path: %@", path) ;
	}
	else
	{
		smallImage = [[NSImage alloc] initWithSize: smallSize] ;
		[smallImage lockFocus] ;
		[sourceImage setSize: smallSize];
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh] ;
		[sourceImage compositeToPoint: NSZeroPoint operation: NSCompositeCopy] ;
		[smallImage unlockFocus] ;
	}
	
	[sourceImage release] ;
	
	return [smallImage autorelease] ;
}

@end
