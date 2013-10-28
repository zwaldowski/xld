//
//  XLDVorbisOutputTask.h
//  XLDVorbisOutput
//
//  Created by tmkk on 06/09/08.
//  Copyright 2006 tmkk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XLDPlugins/XLDPlugins.h>
#import <vorbis/vorbisenc.h>

@interface XLDVorbisOutputTask : NSObject <XLDOutputTask>
{
	FILE *fp;
	int eos;
	XLDFormat format;
	ogg_stream_state os;
	ogg_page         og;
	ogg_packet       op;
	vorbis_info      vi;
	vorbis_comment   vc;
	vorbis_dsp_state vd;
	vorbis_block     vb;
	BOOL addTag;
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
