#import <Foundation/Foundation.h>

int main (int argc, const char * argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init] ;
	
	// small check the we actually have an argument (and it is not null)
	if (argc < 1 || argv[1] == NULL)
	{
		printf("Usage:\n\t--from\t<the path to the folder containing images>\n\t--to\t<the path were you want to save the new images>\n") ;
		goto terminate ;
	}
	
	NSString *fromPath ;
	NSString *toPath ;
	
	NSFileManager *fileManager = [NSFileManager defaultManager] ;
	
	
	// let's go through the arguments
	NSUInteger arg = 1 ;
	while (arg != argc)
	{
		// what is the current 
		if (strcmp(argv[arg], "--from") == 0)
		{
			// check there is anoter param and store it as the fromPath
			if(++arg != argc)
			{
				fromPath = [fileManager stringWithFileSystemRepresentation: argv[arg] length: strlen(argv[arg])] ;
				fromPath = [fromPath stringByExpandingTildeInPath] ;
			}
			
		}
		else if (strcmp(argv[arg], "--to") == 0)
		{
			if(++arg != argc)
			{
				toPath = [fileManager stringWithFileSystemRepresentation: argv[arg] length: strlen(argv[arg])] ;
				toPath = [toPath stringByExpandingTildeInPath] ;
			}
			
		}
		else
		{
			printf("What the fuck is this? %s\n", argv[arg]) ;
			goto terminate ;
		}
		
		arg++ ;
	}
	
	// check that the user specified a path to the folder where the images are
	if (fromPath == nil)
	{
		printf("You need to specify the path to your images with --from\n") ;
		goto terminate ;
	}
	
	// check that the path where to pull the images from is valid
	if ([fileManager fileExistsAtPath: fromPath] == NO)
	{
		printf("The path to the images is not valid\n") ;
		goto terminate ;
	}
	
	// check that the user specified a path where to store the images and in that case that it is valid
	if (toPath && [fileManager fileExistsAtPath: toPath] == NO)
	{
		printf("The path where to store the images is not valid\n") ;
		goto terminate ;
	}
	
	// if no path has been specified for where to store them save in the same folder as the 'from' one
	if (toPath == nil)
		toPath = fromPath ;
	
	// create a pointer to an error that we can display later (if needed)
	NSError *error = nil ;
	
	// get the content of the 'from' directory
	NSArray *content = [fileManager subpathsOfDirectoryAtPath: fromPath error: &error] ;
	
	if (error)
	{
		NSLog(@"Oups! %@", [error localizedDescription]) ;
		goto terminate ;
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
				fileName = [NSString stringWithFormat: @"%@@2x", fileName] ;
				fileName = [fileName stringByAppendingPathExtension: extension] ;
				
				// remove the initial last component
				path = [path stringByDeletingLastPathComponent] ;
				
				// add the brand new one (with @2x)
				path = [path stringByAppendingPathComponent: fileName] ;
				
				// create the new directory path
				newPath = [toPath stringByAppendingPathComponent: path] ;
				
				// copy to the new directory
				[fileManager copyItemAtPath: completePath toPath: newPath error: &error] ;
				
				// catch the error
				if (error)
					NSLog(@"Oups! %@ at path: %@", [error localizedDescription], newPath) ;
			}
		}
	}
	
	
	printf("Done!\n") ;
	
	
	
terminate:
	[pool drain] ;
	return 0 ;
}