//
//  main.m
//  XLD
//
//  Created by tmkk on 06/06/08.
//  Copyright (c) 2006-2013 Taihei Monma. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XLDCustomClasses.h"

extern int cmdline_main(int argc, const char *argv[]);

int main(int argc, const char * argv[])
{
	if(argc > 1 && !strncmp(argv[1],"--cmdline",9)) {
		[NSBundle xld_performCmdLineSwizzle];
		return cmdline_main(argc,argv);
	}
	return NSApplicationMain(argc, argv);
}
