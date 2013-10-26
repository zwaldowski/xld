//
//  XLDShortenDecoder.h
//  XLDShortenDecoder
//
//  Created by tmkk on 09/11/23.
//  Copyright 2009 tmkk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Shorten/decode.h>
#import "XLDDecoder.h"

@interface XLDShortenDecoder : NSObject <XLDDecoder>
{
	shn_file *shn;
	int bps;
	int samplerate;
	int channels;
	xldoffset_t totalFrames;
	BOOL error;
	NSString *srcPath;
	unsigned char *tmpBuf;
	BOOL seekable;
}

+ (BOOL)canHandleFile:(char *)path;
+ (BOOL)canLoadThisBundle;
- (BOOL)openFile:(char *)path;
- (int)samplerate;
- (int)bytesPerSample;
- (int)channels;
- (int)decodeToBuffer:(int *)buffer frames:(int)count;
- (void)closeFile;
- (xldoffset_t)seekToFrame:(xldoffset_t)count;
- (xldoffset_t)totalFrames;
- (int)isFloat;
- (BOOL)error;
- (XLDEmbeddedCueSheetType)hasCueSheet;
- (id)cueSheet;
- (id)metadata;
- (NSString *)srcPath;

@end
