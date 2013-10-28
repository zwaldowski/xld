//
//  XLDOpusOutputTask.h
//  XLDOpusOutput
//
//  Created by tmkk on 12/08/09.
//  Copyright 2012 tmkk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XLDPlugins/XLDPlugins.h>
#import <opus/opus.h>
#import <opus/opus_multistream.h>
#import <ogg/ogg.h>
#import "speex_resampler.h"

typedef struct {
	int version;
	int channels; /* Number of channels: 1..255 */
	int preskip;
	ogg_uint32_t input_sample_rate;
	int gain; /* in dB S7.8 should be zero whenever possible */
	int channel_mapping;
	/* The rest is only used if channel_mapping != 0 */
	int nb_streams;
	int nb_coupled;
	unsigned char stream_map[255];
} OpusHeader;

@interface XLDOpusOutputTask : NSObject <XLDOutputTask> {
	FILE *fp;
	XLDFormat format;
	ogg_stream_state os;
	ogg_page         og;
	ogg_packet       op;
	OpusMSEncoder *st;
	OpusHeader header;
	BOOL addTag;
	NSDictionary *configurations;
	int                max_frame_bytes;
	unsigned char      *packet;
	opus_int32         coding_rate;
	opus_int32         frame_size;
	ogg_int32_t        pid;
	float *input;
	opus_int64         original_samples;
	ogg_int64_t        enc_granulepos;
	int                last_segments;
	ogg_int64_t        last_granulepos;
	int bufferedSamples;
	int bufferSize;
	SpeexResamplerState *resampler;
	float *resamplerBuffer;
	int bufferedResamplerSamples;
	BOOL useVariableFramesize;
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
