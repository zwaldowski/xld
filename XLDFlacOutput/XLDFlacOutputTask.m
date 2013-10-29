//
//  XLDFlacOutputTask.m
//  XLDFlacOutput
//
//  Created by tmkk on 06/09/15.
//  Copyright 2006 tmkk. All rights reserved.
//

#import "XLDFlacOutputTask.h"
#import "XLDFlacOutput.h"
#import <FLAC/private.h>

@implementation XLDFlacOutputTask

- (id)initWithConfigurations:(NSDictionary *)cfg
{
	self = [super init];
	if (self) {
		configurations = [cfg copy];
		if (configurations[@"WriteRGTags"]) writeRGTags = [configurations[@"WriteRGTags"] boolValue];
	}
	return self;
}

- (void)dealloc
{
	if(tag) FLAC__metadata_object_delete(tag);
	if(st) FLAC__metadata_object_delete(st);
	if(encoder) FLAC__stream_encoder_delete(encoder);
	if(picture) FLAC__metadata_object_delete(picture);
	if(internalBuffer) free(internalBuffer);
}

- (BOOL)setOutputFormat:(XLDFormat)fmt
{
	if(fmt.isFloat) return NO;
	if(fmt.channels <= 0 || fmt.channels > FLAC__MAX_CHANNELS) return NO;
	if(fmt.bps > FLAC__REFERENCE_CODEC_MAX_BITS_PER_SAMPLE/8) return NO;
	format = fmt;
	internalBufferSize = 16384*4*fmt.channels;
	if(internalBuffer) free(internalBuffer);
	internalBuffer = (int *)malloc(internalBufferSize);
	return YES;
}

- (BOOL)openFileForOutput:(NSString *)str withTrackData:(id)track
{
	int ret;
	encoder = FLAC__stream_encoder_new();
	
	FLAC__stream_encoder_set_channels(encoder, (unsigned)format.channels);
	FLAC__stream_encoder_set_bits_per_sample(encoder, (unsigned)format.bps*8);
	FLAC__stream_encoder_set_sample_rate(encoder, (unsigned)format.samplerate);
	if([(XLDTrack *)track frames] > 0)
		FLAC__stream_encoder_set_total_samples_estimate(encoder, [(XLDTrack *)track frames]);
	else FLAC__stream_encoder_set_total_samples_estimate(encoder, 0);
	
	/* set up metadata */
	FLAC__StreamMetadata *metadata[5];
	
	st = FLAC__metadata_object_new(FLAC__METADATA_TYPE_SEEKTABLE);
	int i;
	for(i=0;i<=[track seconds]/10;i++) {
		FLAC__metadata_object_seektable_template_append_point(st,i*10*format.samplerate);
	}
	FLAC__metadata_object_seektable_template_sort(st,true);
	metadata[0] = st;
	
	__block FLAC__StreamMetadata_VorbisComment_Entry entry;
	tag = FLAC__metadata_object_new(FLAC__METADATA_TYPE_VORBIS_COMMENT);
	
	NSString *data = [NSString stringWithFormat:@"ENCODER=X Lossless Decoder %@",[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]];
	entry.entry = (FLAC__byte *)[data UTF8String];
	entry.length = (FLAC__uint32)[data length];
	FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
	
	if(addTag) {
		if([(XLDTrack *)track metadata][XLD_METADATA_TITLE]) {
			NSString *data = [NSString stringWithFormat:@"TITLE=%@",[(XLDTrack *)track metadata][XLD_METADATA_TITLE]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_ARTIST]) {
			NSString *data = [NSString stringWithFormat:@"ARTIST=%@",[(XLDTrack *)track metadata][XLD_METADATA_ARTIST]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_ALBUM]) {
			NSString *data = [NSString stringWithFormat:@"ALBUM=%@",[(XLDTrack *)track metadata][XLD_METADATA_ALBUM]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_GENRE]) {
			NSString *data = [NSString stringWithFormat:@"GENRE=%@",[(XLDTrack *)track metadata][XLD_METADATA_GENRE]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_COMPOSER]) {
			NSString *data = [NSString stringWithFormat:@"COMPOSER=%@",[(XLDTrack *)track metadata][XLD_METADATA_COMPOSER]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_ALBUMARTIST]) {
			NSString *data = [NSString stringWithFormat:@"ALBUMARTIST=%@",[(XLDTrack *)track metadata][XLD_METADATA_ALBUMARTIST]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_TRACK]) {
			NSString *data = [NSString stringWithFormat:@"TRACKNUMBER=%d",[[(XLDTrack *)track metadata][XLD_METADATA_TRACK] intValue]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_TOTALTRACKS]) {
			NSString *data = [NSString stringWithFormat:@"TRACKTOTAL=%d",[[(XLDTrack *)track metadata][XLD_METADATA_TOTALTRACKS] intValue]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_TOTALTRACKS]) {
			NSString *data = [NSString stringWithFormat:@"TOTALTRACKS=%d",[[(XLDTrack *)track metadata][XLD_METADATA_TOTALTRACKS] intValue]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_DISC]) {
			NSString *data = [NSString stringWithFormat:@"DISCNUMBER=%d",[[(XLDTrack *)track metadata][XLD_METADATA_DISC] intValue]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_TOTALDISCS]) {
			NSString *data = [NSString stringWithFormat:@"DISCTOTAL=%d",[[(XLDTrack *)track metadata][XLD_METADATA_TOTALDISCS] intValue]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_TOTALDISCS]) {
			NSString *data = [NSString stringWithFormat:@"TOTALDISCS=%d",[[(XLDTrack *)track metadata][XLD_METADATA_TOTALDISCS] intValue]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_DATE]) {
			NSString *data = [NSString stringWithFormat:@"DATE=%@",[(XLDTrack *)track metadata][XLD_METADATA_DATE]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		else if([(XLDTrack *)track metadata][XLD_METADATA_YEAR]) {
			NSString *data = [NSString stringWithFormat:@"DATE=%d",[[(XLDTrack *)track metadata][XLD_METADATA_YEAR] intValue]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_GROUP]) {
			NSString *data = [NSString stringWithFormat:@"CONTENTGROUP=%@",[(XLDTrack *)track metadata][XLD_METADATA_GROUP]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_COMMENT]) {
			NSString *data = [NSString stringWithFormat:@"COMMENT=%@",[(XLDTrack *)track metadata][XLD_METADATA_COMMENT]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_CUESHEET] && [configurations[@"AllowEmbeddedCuesheet"] boolValue]) {
			NSString *data = [NSString stringWithFormat:@"CUESHEET=%@",[(XLDTrack *)track metadata][XLD_METADATA_CUESHEET]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_ISRC]) {
			NSString *data = [NSString stringWithFormat:@"ISRC=%@",[(XLDTrack *)track metadata][XLD_METADATA_ISRC]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_CATALOG]) {
			NSString *data = [NSString stringWithFormat:@"MCN=%@",[(XLDTrack *)track metadata][XLD_METADATA_CATALOG]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_COMPILATION]) {
			NSString *data = [NSString stringWithFormat:@"COMPILATION=%d",[[(XLDTrack *)track metadata][XLD_METADATA_COMPILATION] intValue]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_TITLESORT]) {
			NSString *data = [NSString stringWithFormat:@"TITLESORT=%@",[(XLDTrack *)track metadata][XLD_METADATA_TITLESORT]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_ARTISTSORT]) {
			NSString *data = [NSString stringWithFormat:@"ARTISTSORT=%@",[(XLDTrack *)track metadata][XLD_METADATA_ARTISTSORT]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_ALBUMSORT]) {
			NSString *data = [NSString stringWithFormat:@"ALBUMSORT=%@",[(XLDTrack *)track metadata][XLD_METADATA_ALBUMSORT]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_ALBUMARTISTSORT]) {
			NSString *data = [NSString stringWithFormat:@"ALBUMARTISTSORT=%@",[(XLDTrack *)track metadata][XLD_METADATA_ALBUMARTISTSORT]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_COMPOSERSORT]) {
			NSString *data = [NSString stringWithFormat:@"COMPOSERSORT=%@",[(XLDTrack *)track metadata][XLD_METADATA_COMPOSERSORT]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_GRACENOTE2]) {
			NSString *data = [NSString stringWithFormat:@"iTunes_CDDB_1=%@",[(XLDTrack *)track metadata][XLD_METADATA_GRACENOTE2]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_MB_TRACKID]) {
			NSString *data = [NSString stringWithFormat:@"MUSICBRAINZ_TRACKID=%@",[(XLDTrack *)track metadata][XLD_METADATA_MB_TRACKID]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_MB_ALBUMID]) {
			NSString *data = [NSString stringWithFormat:@"MUSICBRAINZ_ALBUMID=%@",[(XLDTrack *)track metadata][XLD_METADATA_MB_ALBUMID]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_MB_ARTISTID]) {
			NSString *data = [NSString stringWithFormat:@"MUSICBRAINZ_ARTISTID=%@",[(XLDTrack *)track metadata][XLD_METADATA_MB_ARTISTID]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_MB_ALBUMARTISTID]) {
			NSString *data = [NSString stringWithFormat:@"MUSICBRAINZ_ALBUMARTISTID=%@",[(XLDTrack *)track metadata][XLD_METADATA_MB_ALBUMARTISTID]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_MB_DISCID]) {
			NSString *data = [NSString stringWithFormat:@"MUSICBRAINZ_DISCID=%@",[(XLDTrack *)track metadata][XLD_METADATA_MB_DISCID]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_PUID]) {
			NSString *data = [NSString stringWithFormat:@"MUSICIP_PUID=%@",[(XLDTrack *)track metadata][XLD_METADATA_PUID]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_MB_ALBUMSTATUS]) {
			NSString *data = [NSString stringWithFormat:@"MUSICBRAINZ_ALBUMSTATUS=%@",[(XLDTrack *)track metadata][XLD_METADATA_MB_ALBUMSTATUS]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_MB_ALBUMTYPE]) {
			NSString *data = [NSString stringWithFormat:@"MUSICBRAINZ_ALBUMTYPE=%@",[(XLDTrack *)track metadata][XLD_METADATA_MB_ALBUMTYPE]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_MB_RELEASECOUNTRY]) {
			NSString *data = [NSString stringWithFormat:@"RELEASECOUNTRY=%@",[(XLDTrack *)track metadata][XLD_METADATA_MB_RELEASECOUNTRY]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_MB_RELEASEGROUPID]) {
			NSString *data = [NSString stringWithFormat:@"MUSICBRAINZ_RELEASEGROUPID=%@",[(XLDTrack *)track metadata][XLD_METADATA_MB_RELEASEGROUPID]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_MB_WORKID]) {
			NSString *data = [NSString stringWithFormat:@"MUSICBRAINZ_WORKID=%@",[(XLDTrack *)track metadata][XLD_METADATA_MB_WORKID]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_SMPTE_TIMECODE_START]) {
			NSString *data = [NSString stringWithFormat:@"SMPTE_TIMECODE_START=%@",[(XLDTrack *)track metadata][XLD_METADATA_SMPTE_TIMECODE_START]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_SMPTE_TIMECODE_DURATION]) {
			NSString *data = [NSString stringWithFormat:@"SMPTE_TIMECODE_DURATION=%@",[(XLDTrack *)track metadata][XLD_METADATA_SMPTE_TIMECODE_DURATION]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if([(XLDTrack *)track metadata][XLD_METADATA_MEDIA_FPS]) {
			NSString *data = [NSString stringWithFormat:@"MEDIA_FPS=%@",[(XLDTrack *)track metadata][XLD_METADATA_MEDIA_FPS]];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}
		if(writeRGTags) {
			if([(XLDTrack *)track metadata][XLD_METADATA_REPLAYGAIN_TRACK_GAIN]) {
				NSString *data = [NSString stringWithFormat:@"REPLAYGAIN_TRACK_GAIN=%+.2f dB",[[(XLDTrack *)track metadata][XLD_METADATA_REPLAYGAIN_TRACK_GAIN] floatValue]];
				entry.entry = (FLAC__byte *)[data UTF8String];
				entry.length = (FLAC__uint32)[data length];
				FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
			}
			if([(XLDTrack *)track metadata][XLD_METADATA_REPLAYGAIN_TRACK_PEAK]) {
				NSString *data = [NSString stringWithFormat:@"REPLAYGAIN_TRACK_PEAK=%.8f",[[(XLDTrack *)track metadata][XLD_METADATA_REPLAYGAIN_TRACK_PEAK] floatValue]];
				entry.entry = (FLAC__byte *)[data UTF8String];
				entry.length = (FLAC__uint32)[data length];
				FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
			}
			if([(XLDTrack *)track metadata][XLD_METADATA_REPLAYGAIN_ALBUM_GAIN]) {
				NSString *data = [NSString stringWithFormat:@"REPLAYGAIN_ALBUM_GAIN=%+.2f dB",[[(XLDTrack *)track metadata][XLD_METADATA_REPLAYGAIN_ALBUM_GAIN] floatValue]];
				entry.entry = (FLAC__byte *)[data UTF8String];
				entry.length = (FLAC__uint32)[data length];
				FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
			}
			if([(XLDTrack *)track metadata][XLD_METADATA_REPLAYGAIN_ALBUM_PEAK]) {
				NSString *data = [NSString stringWithFormat:@"REPLAYGAIN_ALBUM_PEAK=%.8f",[[(XLDTrack *)track metadata][XLD_METADATA_REPLAYGAIN_ALBUM_PEAK] floatValue]];
				entry.entry = (FLAC__byte *)[data UTF8String];
				entry.length = (FLAC__uint32)[data length];
				FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
			}
		}
		
		if([(XLDTrack *)track metadata][XLD_METADATA_COVER]) {
			NSData *imgData = [(XLDTrack *)track metadata][XLD_METADATA_COVER];
			NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:imgData];
			if(rep) {
				picture = FLAC__metadata_object_new(FLAC__METADATA_TYPE_PICTURE);
				FLAC__metadata_object_picture_set_data(picture, (FLAC__byte *)[imgData bytes], (FLAC__uint32)[imgData length], true);
				picture->data.picture.width = (FLAC__uint32)[rep pixelsWide];
				picture->data.picture.height = (FLAC__uint32)[rep pixelsHigh];
				picture->data.picture.type = FLAC__STREAM_METADATA_PICTURE_TYPE_FRONT_COVER;
				picture->data.picture.depth = (FLAC__uint32)[rep bitsPerPixel];
				if(picture->data.picture.data_length >= 8 && 0 == memcmp(picture->data.picture.data, "\x89PNG\x0d\x0a\x1a\x0a", 8))
					FLAC__metadata_object_picture_set_mime_type(picture, "image/png", true);
				else if(picture->data.picture.data_length >= 6 && (0 == memcmp(picture->data.picture.data, "GIF87a", 6) || 0 == memcmp(picture->data.picture.data, "GIF89a", 6))) {
					FLAC__metadata_object_picture_set_mime_type(picture, "image/gif", true);
					picture->data.picture.colors = 256;
				}
				else if(picture->data.picture.data_length >= 2 && 0 == memcmp(picture->data.picture.data, "\xff\xd8", 2))
					FLAC__metadata_object_picture_set_mime_type(picture, "image/jpeg", true);
				//int ret = FLAC__metadata_object_picture_is_legal(picture,&mime);
				//NSLog(@"%d,%s",ret,mime);
			}
		}
		
		[[(XLDTrack *)track metadata] enumerateKeysAndObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *key, NSString *dat, BOOL *stop) {
			NSRange range = [key rangeOfString:@"XLD_UNKNOWN_TEXT_METADATA_"];
			if (range.location != 0) return;
			
			NSString *idx = [key substringFromIndex:range.length];
			NSString *data = [NSString stringWithFormat:@"%@=%@",idx,dat];
			entry.entry = (FLAC__byte *)[data UTF8String];
			entry.length = (FLAC__uint32)[data length];
			FLAC__metadata_object_vorbiscomment_append_comment(tag,entry,true);
		}];
	}
	metadata[1] = tag;
	
	FLAC__StreamMetadata padding;
	padding.is_last = false; /* the encoder will set this for us */
	padding.type = FLAC__METADATA_TYPE_PADDING;
	padding.length = [configurations[@"Padding"] intValue]*1024;
	metadata[2] = &padding;
	
	if(picture) {
		metadata[3] = picture;
	}
	
	metadataDic = [(XLDTrack *)track metadata];
	
	FLAC__stream_encoder_set_metadata(encoder,metadata,picture ? 4 : 3);
	
	int level = [configurations[@"CompressionLevel"] intValue];
	if(level >= 0) {
		FLAC__stream_encoder_set_compression_level(encoder,level);
		if(format.channels != 2) {
			FLAC__stream_encoder_set_do_mid_side_stereo(encoder, false);
			FLAC__stream_encoder_set_loose_mid_side_stereo(encoder, false);
		}
		NSString *apodization = configurations[@"Apodization"];
		if(apodization && ![apodization isEqualToString:@""]) {
			NSMutableString *str = [NSMutableString stringWithString:apodization];
			[str replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, [str length])];
			FLAC__stream_encoder_set_apodization(encoder,[str UTF8String]);
		}
	}
	else {
		FLAC__stream_encoder_disable_constant_subframes(encoder,true);
		FLAC__stream_encoder_disable_fixed_subframes(encoder,true);
		FLAC__stream_encoder_set_do_mid_side_stereo(encoder, false);
		FLAC__stream_encoder_set_loose_mid_side_stereo(encoder, false);
	}
	
	if([configurations[@"OggFlac"] boolValue]) {
		FLAC__stream_encoder_set_ogg_serial_number(encoder,(long)rand());
		ret = FLAC__stream_encoder_init_ogg_file(encoder,[str UTF8String],NULL,NULL);
	}
	else ret = FLAC__stream_encoder_init_file(encoder,[str UTF8String],NULL,NULL);
	
	if(ret != FLAC__STREAM_ENCODER_INIT_STATUS_OK) return NO;
	
	path = str;
	
	return YES;
}

- (NSString *)extensionStr
{
	if([configurations[@"OggFlac"] boolValue]) return @"oga";
	else return @"flac";
}

- (BOOL)writeBuffer:(int *)buffer frames:(int)counts
{
	int i;
	if(internalBufferSize < counts*format.channels*4) internalBuffer = realloc(internalBuffer, counts*format.channels*4);
	int samples = counts*format.channels;
	int shamt = 32-format.bps*8;
	for(i=0;i<samples;i++) {
		internalBuffer[i] = buffer[i] >> shamt;
	}
	int ret = FLAC__stream_encoder_process_interleaved(encoder, internalBuffer, counts);
	if(!ret) return NO;
	return YES;
}


- (void)closeFile
{
	if(tag) FLAC__metadata_object_delete(tag);
	tag = NULL;
	if(st) FLAC__metadata_object_delete(st);
	st = NULL;
	if(encoder) FLAC__stream_encoder_delete(encoder);
	encoder = NULL;
	if(picture) FLAC__metadata_object_delete(picture);
	picture = NULL;
	path = nil;
	metadataDic = nil;
}

- (void)setEnableAddTag:(BOOL)flag
{
	addTag = flag;
}

@end
