//
//  XLDAVDecoder.h
//  XLDAVDecoder
//
//  Created by tmkk on 10/02/13.
//  Copyright 2010 tmkk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XLDPlugins/XLDPlugins.h>
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>

@interface XLDTakDecoder : NSObject <XLDDecoder> {
	BOOL error;
	NSString *srcPath;
	xldoffset_t currentPos;
	xldoffset_t totalFrames;
    AVFormatContext *formatCtx;
    AVCodecContext *codecCtx;
    AVFrame *lastDecodedFrame;
    AVPacket *lastReadPacket;
    int bytesConsumedFromDecodedFrame;
    BOOL readNextPacket;
	NSMutableDictionary *metadataDic;
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
