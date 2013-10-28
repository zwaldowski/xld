
#import <Cocoa/Cocoa.h>
#import <XLDPlugins/XLDPlugins.h>
#import <sndfile/sndfile.h>

@interface XLDLibsndfileDecoder : NSObject <XLDDecoder>
{
	SNDFILE *sf;
	SF_INFO sfinfo;
	int bps;
	int isFloat;
	char errstr[256];
	xldoffset_t totalFrames;
	BOOL error;
	NSString *srcPath;
	NSMutableArray *trackArr;
	//NSString *cueData;
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
