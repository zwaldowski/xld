//
//  XLDAacOutputTask.h
//  XLDAacOutput
//
//  Created by tmkk on 06/09/08.
//  Copyright 2006 tmkk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XLDPlugins/XLDPlugins.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>

@interface XLDAacOutputTask : NSObject <XLDOutputTask> {
	XLDFormat format;
	ExtAudioFileRef file;
	AudioBufferList fillBufList;
	AudioStreamBasicDescription inputFormat,outputFormat;
	BOOL addTag;
	BOOL addGaplessInfo;
	NSMutableData *tagData;
	NSString *path;
	int64_t totalFrames;
	NSRange gaplessDataRange;
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
