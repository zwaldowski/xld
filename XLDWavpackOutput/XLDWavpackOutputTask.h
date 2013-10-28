//
//  XLDWavpackOutputTask.h
//  XLDWavpackOutput
//
//  Created by tmkk on 08/05/20.
//  Copyright 2008 tmkk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XLDPlugins/XLDPlugins.h>
#import <wavpack/wavpack.h>
#import <openssl/md5.h>

typedef struct
{
	FILE *fp;
	int initial_frame_size;
	char *path;
} fileID;

@interface XLDWavpackOutputTask : NSObject <XLDOutputTask> {
	WavpackContext *wpc;
	BOOL addTag;
	BOOL tagAdded;
	XLDFormat format;
	fileID *fpwv;
	fileID *fpwvc;
	int *internalBuffer;
	int internalBufferSize;
	MD5_CTX context;
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
