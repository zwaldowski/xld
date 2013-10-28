//
//  XLDAlacOutputTask.h
//  XLDAlacOutput
//
//  Created by tmkk on 06/09/08.
//  Copyright 2006 tmkk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XLDPlugins/XLDPlugins.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>

@interface XLDAlacOutputTask : NSObject <XLDOutputTask> {
	XLDFormat format;
	ExtAudioFileRef file;
	AudioBufferList fillBufList;
	AudioStreamBasicDescription inputFormat,outputFormat;
	BOOL addTag;
	NSMutableData *tagData;
	NSString *path;
	void *encodebuf;
	int encodebufSize;
	NSDictionary *configurations;
	NSData *chapterMdat;
	BOOL embedChapter;
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
