//
//  XLDSd2fOutputTask.h
//  XLD
//
//  Created by tmkk on 13/02/11.
//  Copyright 2013 tmkk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XLDPlugins/XLDPlugins.h>
#import <sndfile/sndfile.h>
#import <AudioToolbox/AudioToolbox.h>

@interface XLDSd2fOutputTask : NSObject <XLDOutputTask> {
	SF_INFO sfinfo;
	SNDFILE *sf_w;
	BOOL addTag;
	NSString *path;
	NSMutableData *regionData;
	XLDFormat outFormat;
	NSDictionary *configurations;
}

- (BOOL)setOutputFormat:(XLDFormat)fmt;
- (BOOL)openFileForOutput:(NSString *)str withTrackData:(id)track;
- (NSString *)extensionStr;
- (BOOL)writeBuffer:(int *)buffer frames:(int)counts;
- (void)finalize;
- (void)closeFile;
- (void)setEnableAddTag:(BOOL)flag;

- (id)initWithConfigurations:(NSDictionary *)cfg;

@end
