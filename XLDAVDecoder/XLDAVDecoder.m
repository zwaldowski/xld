//
//  XLDAVDecoder.m
//  XLDAVDecoder
//
//  Created by tmkk on 10/02/13.
//  Copyright 2010 tmkk. All rights reserved.
//

#import "XLDAVDecoder.h"
#import <libavutil/mem.h>
#import <libavutil/mathematics.h>
#import <libavutil/avutil.h>

@implementation XLDTakDecoder

+ (void)load
{
	@autoreleasepool {
		avcodec_register_all();
		av_register_all();
	}
}

+ (BOOL)canHandleFile:(char *)path
{
	AVIOContext *tmp = NULL;
	AVInputFormat *iformat = NULL;
	int ret;
	if ((ret = avio_open2(&tmp, path, AVIO_FLAG_READ, NULL, NULL)) < 0) {
		return NO;
	} else {
		ret = av_probe_input_buffer(tmp, &iformat, path, NULL, 0, 0);
		avio_closep(&tmp);
		return (ret >= 0);
	}
}

+ (BOOL)canLoadThisBundle
{
	return YES;
}

- (id)init
{
	[super init];
	
	metadataDic = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (BOOL)openFile:(char *)path
{
	formatCtx = NULL;
	if (avformat_open_input(&formatCtx, path, NULL, NULL) < 0) {
		error = YES;
		return NO;
	}
	
	if (avformat_find_stream_info(formatCtx, NULL) < 0) {
		error = YES;
		return NO;
	}
    
    int streamId = -1;
    for (int i=0; i < formatCtx->nb_streams; i++) {
        if (AVMEDIA_TYPE_AUDIO == formatCtx->streams[i]->codec->codec_type) {
            streamId = i;
            break;
        }
    }
	
	if (streamId == -1) {
        avformat_close_input(&formatCtx);
		error = YES;
        return NO;
	}
	
	codecCtx = formatCtx->streams[streamId]->codec;
	
	AVCodec *codec = avcodec_find_decoder(codecCtx->codec_id);
	if (!codec) {
        avformat_close_input(&formatCtx);
		error = YES;
        return NO;
	}
	
	if (avcodec_open2(codecCtx, codec, NULL) < 0) {
		avformat_close_input(&formatCtx);
		error = YES;
        return NO;
	}
	
	lastDecodedFrame = avcodec_alloc_frame();
    avcodec_get_frame_defaults(lastDecodedFrame);
    lastReadPacket = malloc(sizeof(AVPacket));
    av_new_packet(lastReadPacket, 0);
    readNextPacket = YES;
    bytesConsumedFromDecodedFrame = 0;
	
	totalFrames = codecCtx->sample_rate * (formatCtx->duration/AV_TIME_BASE);
	
	void(^addTag)(const char *, NSString *) = ^(const char *key, NSString *dicKey){
		AVDictionaryEntry *tag = av_dict_get(formatCtx->metadata, key, NULL, AV_DICT_IGNORE_SUFFIX);
		if (!tag) {
			return;
		}
		
		NSString *str = [NSString stringWithUTF8String:tag->value];
		if (!str) return;
		
		if(!strcasecmp(key, "track") || !strcasecmp(key, "tracknumber")) {
			int track = [str intValue];
			if(track>0) [metadataDic setObject:[NSNumber numberWithInt:track] forKey:XLD_METADATA_TRACK];
			if([str rangeOfString:@"/"].location != NSNotFound) {
				track = [[str substringFromIndex:[str rangeOfString:@"/"].location+1] intValue];
				if(track > 0) [metadataDic setObject:[NSNumber numberWithInt:track] forKey:XLD_METADATA_TOTALTRACKS];
			}
		}
		else if(!strcasecmp(key,"disc") || !strcasecmp(key,"discnumber")) {
			int disc = [str intValue];
			if(disc>0) [metadataDic setObject:[NSNumber numberWithInt:disc] forKey:XLD_METADATA_DISC];
			if([str rangeOfString:@"/"].location != NSNotFound) {
				disc = [[str substringFromIndex:[str rangeOfString:@"/"].location+1] intValue];
				if(disc > 0) [metadataDic setObject:[NSNumber numberWithInt:disc] forKey:XLD_METADATA_TOTALDISCS];
			}
		}
		else if(!strcasecmp(key,"year")) {
			int year = [str intValue];
			if(year >= 1000 && year < 3000) [metadataDic setObject:[NSNumber numberWithInt:year] forKey:XLD_METADATA_YEAR];
		}
		else if (!strncasecmp(key,"REPLAYGAIN_",11)) {
			[metadataDic setObject:[NSNumber numberWithFloat:[str floatValue]] forKey:dicKey];
		}
		else [metadataDic setObject:str forKey:dicKey];
	};
	
	addTag("title", XLD_METADATA_TITLE);
	addTag("artist", XLD_METADATA_ARTIST);
	addTag("album", XLD_METADATA_ALBUM);
	addTag("albumartist", XLD_METADATA_ALBUMARTIST);
	addTag("album artist", XLD_METADATA_ALBUMARTIST);
	addTag("genre", XLD_METADATA_GENRE);
	addTag("year", XLD_METADATA_YEAR);
	addTag("composer", XLD_METADATA_COMPOSER);
	addTag("track", XLD_METADATA_TRACK);
	addTag("disc", XLD_METADATA_DISC);
	addTag("comment", XLD_METADATA_COMMENT);
	addTag("lyrics", XLD_METADATA_LYRICS);
	addTag("isrc", XLD_METADATA_ISRC);
	addTag("cuesheet", XLD_METADATA_CUESHEET);
	addTag("iTunes_CDDB_1", XLD_METADATA_GRACENOTE2);
	addTag("MUSICBRAINZ_TRACKID", XLD_METADATA_MB_TRACKID);
	addTag("MUSICBRAINZ_ALBUMID", XLD_METADATA_MB_ALBUMID);
	addTag("MUSICBRAINZ_ARTISTID", XLD_METADATA_MB_ARTISTID);
	addTag("MUSICBRAINZ_ALBUMARTISTID", XLD_METADATA_MB_ALBUMARTISTID);
	addTag("MUSICBRAINZ_DISCID", XLD_METADATA_MB_DISCID);
	addTag("MUSICIP_PUID", XLD_METADATA_PUID);
	addTag("MUSICBRAINZ_ALBUMSTATUS", XLD_METADATA_MB_ALBUMSTATUS);
	addTag("MUSICBRAINZ_ALBUMTYPE", XLD_METADATA_MB_ALBUMTYPE);
	addTag("RELEASECOUNTRY", XLD_METADATA_MB_RELEASECOUNTRY);
	addTag("MUSICBRAINZ_RELEASEGROUPID", XLD_METADATA_MB_RELEASEGROUPID);
	addTag("MUSICBRAINZ_WORKID", XLD_METADATA_MB_WORKID);
	addTag("REPLAYGAIN_TRACK_GAIN", XLD_METADATA_REPLAYGAIN_TRACK_GAIN);
	addTag("REPLAYGAIN_TRACK_PEAK", XLD_METADATA_REPLAYGAIN_TRACK_PEAK);
	addTag("REPLAYGAIN_ALBUM_GAIN", XLD_METADATA_REPLAYGAIN_ALBUM_GAIN);
	addTag("REPLAYGAIN_ALBUM_PEAK", XLD_METADATA_REPLAYGAIN_ALBUM_PEAK);
	
    int photostreamId = -1;
    for (int i=0; i < formatCtx->nb_streams; i++) {
		AVStream *stream = formatCtx->streams[i];
		AVCodecContext *ctx = stream->codec;
        if (ctx->codec_type == AVMEDIA_TYPE_DATA ||
			ctx->codec_type == AVMEDIA_TYPE_ATTACHMENT ||
			(ctx->codec_type == AVMEDIA_TYPE_VIDEO && (ctx->codec_id == AV_CODEC_ID_JPEG2000 || ctx->codec_id == AV_CODEC_ID_MJPEG))) {
			if (stream->disposition & AV_DISPOSITION_ATTACHED_PIC) {
				photostreamId = i;
			}
            break;
        }
    }
	
	
	if (photostreamId != -1) {
		AVStream *photoStream = formatCtx->streams[photostreamId];
		AVPacket photoPacket = photoStream->attached_pic;
		NSData *photoData = [[NSData alloc] initWithBytesNoCopy:photoPacket.data length:photoPacket.size];
		[metadataDic setObject:photoData forKey:XLD_METADATA_COVER];
		[photoData release];
	}
	
	if(srcPath) [srcPath release];
	srcPath = [[NSString alloc] initWithUTF8String:path];
	currentPos = 0;
	return YES;
}

- (void)closeFile
{
	if (lastReadPacket) {
        av_free_packet(lastReadPacket);
        free(lastReadPacket);
        lastReadPacket = NULL;
    }
    
    if (lastDecodedFrame) {
		avcodec_free_frame(&lastDecodedFrame);
	}
    
    if (codecCtx) {
		avcodec_close(codecCtx);
		codecCtx = NULL;
	}
    
    if (formatCtx) {
		avformat_close_input(&formatCtx);
		formatCtx = NULL;
	}
	
	error = NO;
}

- (int)samplerate
{
	return codecCtx->sample_rate;
}

- (int)bitsPerSample
{
	return av_get_bytes_per_sample(codecCtx->sample_fmt);
}

- (int)bytesPerSample
{
	return [self bitsPerSample] * CHAR_BIT;
}

- (int)channels
{
	return codecCtx->channels;
}

- (xldoffset_t)totalFrames
{
	return totalFrames;
}

- (int)isFloat
{
	return 0;
}

- (void)dealloc
{
	if (srcPath) [srcPath release];
	if (metadataDic) [metadataDic release];
	[super dealloc];
}

- (int)decodeToBuffer:(int *)buffer frames:(int)frames
{
    int frameSize = codecCtx->channels * ([self bitsPerSample] / 8);
    int gotFrame = 0;
    int dataSize = 0;
	
    int bytesToRead = frames * frameSize;
    int bytesRead = 0;
    
    int8_t* targetBuf = (int8_t*)buffer;
    memset(buffer, 0, bytesToRead);
	
    while (bytesRead < bytesToRead)
    {
        
        if(readNextPacket)
        {
            // consume next chunk of encoded data from input stream
            av_free_packet(lastReadPacket);
            if(av_read_frame(formatCtx, lastReadPacket) < 0)
            {
                break; // end of stream;
            }
            readNextPacket = NO; // we probably won't need to consume another chunk
			// until this one is fully decoded
        }
        
        // buffer size needed to hold decoded samples, in bytes
        dataSize = av_samples_get_buffer_size(NULL, codecCtx->channels,
                                              lastDecodedFrame->nb_samples,
                                              codecCtx->sample_fmt, 1);
		
        if (dataSize <= bytesConsumedFromDecodedFrame)
        {
            // consumed all decoded samples - decode more
            avcodec_get_frame_defaults(lastDecodedFrame);
            int len = avcodec_decode_audio4(codecCtx, lastDecodedFrame, &gotFrame, lastReadPacket);
            if (len < 0 || (!gotFrame))
            {
                error = YES;
            }
            else if (len >= lastReadPacket->size)
            {
                // decoding consumed all the read packet - read another next time
                readNextPacket = YES;
            }
			
            bytesConsumedFromDecodedFrame = 0;
            if (len >= 0)
            {
                // Something has been successfully decoded
                dataSize = av_samples_get_buffer_size(NULL, codecCtx->channels,
													  lastDecodedFrame->nb_samples,
													  codecCtx->sample_fmt, 1);
            } else {
                // Decode error, discard packet and try again
                dataSize = 0;
                readNextPacket = YES;
            }
        }
        
        // copy decoded samples to Cog's buffer
        int toConsume = MIN((dataSize - bytesConsumedFromDecodedFrame), (bytesToRead - bytesRead));
        memmove(targetBuf + bytesRead, (lastDecodedFrame->data[0] + bytesConsumedFromDecodedFrame), toConsume);
        bytesConsumedFromDecodedFrame += toConsume;
        bytesRead += toConsume;
    }
	
    return (bytesRead / frameSize);
}

- (xldoffset_t)seekToFrame:(xldoffset_t)count
{
	if (count > totalFrames) { return -1; }
    int64_t ts = count * (formatCtx->duration) / totalFrames;
    avformat_seek_file(formatCtx, -1, ts - 1000, ts, ts, AVSEEK_FLAG_ANY);
    avcodec_flush_buffers(codecCtx);
	currentPos = count;
    return count;
}

- (BOOL)error
{
	return error;
}

- (XLDEmbeddedCueSheetType)hasCueSheet
{
	return [metadataDic objectForKey:XLD_METADATA_CUESHEET] ? XLDTextTypeCueSheet : XLDNoCueSheet;
}

- (id)cueSheet
{
	return [metadataDic objectForKey:XLD_METADATA_CUESHEET];
}

- (id)metadata
{
	return metadataDic;
}

- (NSString *)srcPath
{
	return srcPath;
}


@end
