//
//  XLDFlacOutputTask.h
//  XLDFlacOutput
//
//  Created by tmkk on 06/09/15.
//  Copyright 2006 tmkk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XLDPlugins/XLDPlugins.h>
#import <FLAC/FLAC.h>

@interface XLDFlacOutputTask : NSObject {
	FLAC__StreamEncoder *encoder;
	FLAC__StreamMetadata *st;
	FLAC__StreamMetadata *tag;
	FLAC__StreamMetadata *picture;
	XLDFormat format;
	BOOL addTag;
	int *internalBuffer;
	int internalBufferSize;
	NSString *path;
	NSDictionary *configurations;
	NSMutableDictionary *metadataDic;
	BOOL writeRGTags;
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
