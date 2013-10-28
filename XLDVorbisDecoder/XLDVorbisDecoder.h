
#import <Foundation/Foundation.h>
#import <XLDPlugins/XLDPlugins.h>
#import <vorbis/codec.h>
#import <vorbis/vorbisfile.h>

@interface XLDVorbisDecoder : NSObject <XLDDecoder>
{
	OggVorbis_File vf;
	vorbis_info *vi;
	short *tempBuffer;
	int tempBufferSize;
	xldoffset_t totalFrames;
	BOOL error;
	NSString *cueData;
	NSMutableDictionary *metadataDic;
	NSString *srcPath;
	BOOL opened;
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
