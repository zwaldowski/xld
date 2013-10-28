
#import <Cocoa/Cocoa.h>
#import <XLDPlugins/XLDPlugins.h>
#import <FLAC/FLAC.h>

@interface XLDFlacDecoder : NSObject <XLDDecoder>
{
	FLAC__StreamDecoder *flac;
	int *tempBuffer;
	int *tempBufferPtr;
	int tempBufferSample;
@public
	xldoffset_t totalFrames;
	int channels;
	int bps;
	int samplerate;
	xldoffset_t samplesConsumpted;
	int *writeCallbackBuffer;
	int writeCallbackBufferSize;
	int writeCallbackDecodedSample;
	BOOL error;
	NSMutableArray *trackArr;
	NSString *cueData;
	NSMutableDictionary *metadataDic;
	NSString *srcPath;
	BOOL decodeError;
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