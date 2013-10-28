
#import <Foundation/Foundation.h>
#import <XLDPlugins/XLDPlugins.h>
#import <MAC/MAC.h>

using namespace APE;

@interface XLDApeDecoder : NSObject <XLDDecoder>
{
	IAPEDecompress *mac;
	int bps;
	int samplerate;
	int channels;
	xldoffset_t totalFrames;
	BOOL error;
	NSString *cueData;
	NSMutableDictionary *metadataDic;
	int internalBufferBytes;
	unsigned char *internal_buffer;
	NSString *srcPath;
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