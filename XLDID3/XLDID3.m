//
//  XLDID3.m
//  XLDID3
//
//  Created by Zach Waldowski on 10/24/13.
//  Copyright (c) 2013 Taihei Monma. All rights reserved.
//

#import "XLDID3.h"
#import <XLDPlugins/XLDPlugins.h>

static inline unsigned int getByte(NSData *dat, int *pos)
{
	unsigned char byteData;
	[dat getBytes:&byteData range:NSMakeRange(*pos,1)];
	*pos += 1;
	return byteData;
}

static inline unsigned int getShort(NSData *dat, int *pos)
{
	unsigned short halfData;
	[dat getBytes:&halfData range:NSMakeRange(*pos,2)];
	*pos += 2;
	return NSSwapBigShortToHost(halfData);
}

static inline unsigned int getInt(NSData *dat, int *pos)
{
	unsigned int wordData;
	[dat getBytes:&wordData range:NSMakeRange(*pos,4)];
	*pos += 4;
	return NSSwapBigIntToHost(wordData);
}

static inline unsigned int get24bit(NSData *dat, int *pos)
{
	unsigned int wordData;
	wordData = getByte(dat,pos);
	wordData = (wordData << 8)|getByte(dat,pos);
	wordData = (wordData << 8)|getByte(dat,pos);
	return wordData;
}

static NSString *getString(NSData *dat, int *pos, int length, int encoding)
{
	NSString *str = nil;
	if(encoding == 0 || encoding == 3) {
		unsigned char *ptr = (unsigned char *)[dat bytes]+*pos+length-1;
		int nulllen = 0;
		while(1) {
			if(*ptr != 0) break;
			ptr--;
			nulllen++;
		}
		NSStringEncoding enc = (encoding == 0) ? NSISOLatin1StringEncoding : NSUTF8StringEncoding;
		str = [[NSString alloc] initWithData:[dat subdataWithRange:NSMakeRange(*pos,length-nulllen)] encoding:enc];
	}
	else if(encoding == 1 || encoding == 2) {
		unsigned short *ptr = (unsigned short *)((unsigned char *)[dat bytes]+*pos+length-2);
		int nulllen = 0;
		while(1) {
			if(*ptr != 0) break;
			ptr--;
			nulllen+=2;
		}
		NSStringEncoding enc = (encoding == 1) ? NSUnicodeStringEncoding : CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF16BE);
		str = [[NSString alloc] initWithData:[dat subdataWithRange:NSMakeRange(*pos,length-nulllen)] encoding:enc];
	}
	*pos += length;
	return [str autorelease];
}

static NSString *getTextFrame23(NSData *dat, int *pos)
{
	NSString *str = nil;
	int length = getInt(dat,pos);
	getShort(dat,pos); // int flag
	int encoding = getByte(dat,pos);
	length -= 1;
	if(encoding == 0 || encoding == 1) {
		str = getString(dat,pos,length,encoding);
	}
	else *pos += length;
	
	return str;
}

static NSString *getCommentDesc23(NSData *dat, int *pos, int encoding, int *read)
{
	int length = 0;
	NSString *str = nil;
	if(encoding == 0 || encoding == 3) {
		unsigned char tmp;
		while(1) {
			[dat getBytes:&tmp range:NSMakeRange(*pos+length,1)];
			length++;
			if(!tmp) break;
		}
		NSStringEncoding enc = (encoding == 0) ? NSISOLatin1StringEncoding : NSUTF8StringEncoding;
		if(length > 1) str = [[NSString alloc] initWithData:[dat subdataWithRange:NSMakeRange(*pos,length-1)] encoding:enc];
		else str = [[NSString alloc] init];
	}
	else {
		unsigned short tmp;
		while(1) {
			[dat getBytes:&tmp range:NSMakeRange(*pos+length,2)];
			length += 2;
			if(!tmp) break;
		}
		NSStringEncoding enc = (encoding == 1) ? NSUnicodeStringEncoding : CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF16BE);
		if(length > 2) str = [[NSString alloc] initWithData:[dat subdataWithRange:NSMakeRange(*pos,length-2)] encoding:enc];
		else str = [[NSString alloc] init];
	}
	if(read) *read = length;
	*pos += length;
	return [str autorelease];
}

static NSString *getCommentFrame23(NSData *dat, int *pos, NSString **desc)
{
	NSString *str = nil;
	int length = getInt(dat,pos);
	getShort(dat,pos); // int flag
	int encoding = getByte(dat,pos);
	*pos += 3;
	length -= 4;
	if(encoding == 0 || encoding == 1) {
		int read;
		NSString *tmp = getCommentDesc23(dat,pos,encoding,&read);
		if(desc) *desc = tmp;
		length -= read;
		str = getString(dat,pos,length,encoding);
	}
	else *pos += length;
	
	return str;
}

static NSData *getAPICFrame23(NSData *dat, int *pos, int *imgType)
{
	int length = getInt(dat,pos);
	getShort(dat,pos); // int flag
	int encoding = getByte(dat,pos);
	length -= 1;
	int read;
	getCommentDesc23(dat,pos,0,&read);
	length -= read;
	int type = getByte(dat,pos);
	length -= 1;
	if(imgType) *imgType = type;
	getCommentDesc23(dat,pos,encoding,&read);
	length -= read;
	NSData *img = [dat subdataWithRange:NSMakeRange(*pos,length)];
	*pos += length;
	return img;
}

static NSString *getTxxxFrame23(NSData *dat, int *pos, NSString **desc)
{
	NSString *str = nil;
	int length = getInt(dat,pos);
	getShort(dat,pos); // int flag
	int encoding = getByte(dat,pos);
	length -= 1;
	if(encoding == 0 || encoding == 1) {
		int read;
		NSString *tmp = getCommentDesc23(dat,pos,encoding,&read);
		if(desc) *desc = tmp;
		length -= read;
		str = getString(dat,pos,length,encoding);
	}
	else *pos += length;
	
	return str;
}

static NSString *getUFIDFrame23(NSData *dat, int *pos, NSString **desc)
{
	NSString *str = nil;
	int length = getInt(dat,pos);
	getShort(dat,pos); // int flag
	int read;
	NSString *tmp = getCommentDesc23(dat,pos,0,&read);
	if(desc) *desc = tmp;
	length -= read;
	str = getString(dat,pos,length,0);
	
	return str;
}

static void skipFrame23(NSData *dat, int *pos)
{
	int length = getInt(dat,pos);
	*pos += length + 2;
}

static NSString *getTextFrame22(NSData *dat, int *pos)
{
	NSString *str = nil;
	int length = get24bit(dat,pos);
	int encoding = getByte(dat,pos);
	length -= 1;
	if(encoding == 0 || encoding == 1) {
		str = getString(dat,pos,length,encoding);
	}
	else *pos += length;
	
	return str;
}

static NSString *getCommentFrame22(NSData *dat, int *pos, NSString **desc)
{
	NSString *str = nil;
	int length = get24bit(dat,pos);
	int encoding = getByte(dat,pos);
	*pos += 3;
	length -= 4;
	if(encoding == 0 || encoding == 1) {
		int read;
		NSString *tmp = getCommentDesc23(dat,pos,encoding,&read);
		if(desc) *desc = tmp;
		length -= read;
		str = getString(dat,pos,length,encoding);
	}
	else *pos += length;
	return str;
}

static NSData *getPICFrame22(NSData *dat, int *pos, int *imgType)
{
	int length = get24bit(dat,pos);
	int encoding = getByte(dat,pos);
	*pos += 3;
	length -= 4;
	int type = getByte(dat,pos);
	length -= 1;
	if(imgType) *imgType = type;
	int read;
	getCommentDesc23(dat,pos,encoding,&read);
	length -= read;
	NSData *img = [dat subdataWithRange:NSMakeRange(*pos,length)];
	*pos += length;
	return img;
}

static NSString *getTxxFrame22(NSData *dat, int *pos, NSString **desc)
{
	NSString *str = nil;
	int length = get24bit(dat,pos);
	int encoding = getByte(dat,pos);
	length -= 1;
	if(encoding == 0 || encoding == 1) {
		int read;
		NSString *tmp = getCommentDesc23(dat,pos,encoding,&read);
		if(desc) *desc = tmp;
		length -= read;
		str = getString(dat,pos,length,encoding);
	}
	else *pos += length;
	return str;
}

static NSString *getUFIFrame22(NSData *dat, int *pos, NSString **desc)
{
	NSString *str = nil;
	int length = get24bit(dat,pos);
	int read;
	NSString *tmp = getCommentDesc23(dat,pos,0,&read);
	if(desc) *desc = tmp;
	length -= read;
	str = getString(dat,pos,length,0);
	return str;
}

static void skipFrame22(NSData *dat, int *pos)
{
	int length = get24bit(dat,pos);
	*pos += length;
}

static int getFrameSize24(NSData *dat, int *pos)
{
	int size = (getByte(dat,pos)&0x7f) << 21;
	size += (getByte(dat,pos)&0x7f) << 14;
	size += (getByte(dat,pos)&0x7f) << 7;
	size += getByte(dat,pos)&0x7f;
	return size;
}

static NSString *getTextFrame24(NSData *dat, int *pos)
{
	NSString *str = nil;
	int length = getFrameSize24(dat,pos);
	int flag = getShort(dat,pos);
	if(flag) {
		*pos += length;
		return nil;
	}
	int encoding = getByte(dat,pos);
	length -= 1;
	if(encoding >= 0 && encoding <= 3) {
		str = getString(dat,pos,length,encoding);
	}
	else *pos += length;
	
	return str;
}

static NSString *getCommentFrame24(NSData *dat, int *pos, NSString **desc)
{
	NSString *str = nil;
	int length = getFrameSize24(dat,pos);
	int flag = getShort(dat,pos);
	if(flag) {
		*pos += length;
		return nil;
	}
	int encoding = getByte(dat,pos);
	*pos += 3;
	length -= 4;
	if(encoding >= 0 && encoding <= 3) {
		int read;
		NSString *tmp = getCommentDesc23(dat,pos,encoding,&read);
		if(desc) *desc = tmp;
		length -= read;
		str = getString(dat,pos,length,encoding);
	}
	else *pos += length;
	
	return str;
}

static NSData *getAPICFrame24(NSData *dat, int *pos, int *imgType)
{
	int length = getFrameSize24(dat,pos);
	int flag = getShort(dat,pos);
	if(flag) {
		*pos += length;
		return nil;
	}
	int encoding = getByte(dat,pos);
	length -= 1;
	int read;
	getCommentDesc23(dat,pos,0,&read);
	length -= read;
	int type = getByte(dat,pos);
	length -= 1;
	if(imgType) *imgType = type;
	getCommentDesc23(dat,pos,encoding,&read);
	length -= read;
	NSData *img = [dat subdataWithRange:NSMakeRange(*pos,length)];
	*pos += length;
	return img;
}

static NSString *getTxxxFrame24(NSData *dat, int *pos, NSString **desc)
{
	NSString *str = nil;
	int length = getFrameSize24(dat,pos);
	int flag = getShort(dat,pos);
	if(flag) {
		*pos += length;
		return nil;
	}
	int encoding = getByte(dat,pos);
	length -= 1;
	if(encoding >= 0 && encoding <= 3) {
		int read;
		NSString *tmp = getCommentDesc23(dat,pos,encoding,&read);
		if(desc) *desc = tmp;
		length -= read;
		str = getString(dat,pos,length,encoding);
	}
	else *pos += length;
	
	return str;
}

static NSString *getUFIDFrame24(NSData *dat, int *pos, NSString **desc)
{
	NSString *str = nil;
	int length = getFrameSize24(dat,pos);
	int flag = getShort(dat,pos);
	if(flag) {
		*pos += length;
		return nil;
	}
	int read;
	NSString *tmp = getCommentDesc23(dat,pos,0,&read);
	if(desc) *desc = tmp;
	length -= read;
	str = getString(dat,pos,length,0);
	
	return str;
}

static void skipFrame24(NSData *dat, int *pos)
{
	int length = getFrameSize24(dat,pos);
	*pos += length + 2;
}

void parseID3(NSData *dat, NSMutableDictionary *metadata)
{
	@try {
		int pos = 0;
		char id3[3];
		[dat getBytes:id3 range:NSMakeRange(pos,3)];
		if(memcmp(id3,"ID3",3)) return;
		pos += 3;
		int version = getByte(dat,&pos);
		pos += 1;
		int globalFlag = getByte(dat,&pos);
		int size = (getByte(dat,&pos)&0x7f) << 21;
		size += (getByte(dat,&pos)&0x7f) << 14;
		size += (getByte(dat,&pos)&0x7f) << 7;
		size += getByte(dat,&pos)&0x7f;
		if(version == 3 || version == 4) {
			if(globalFlag != 0) return;
			
			while(size > 0) {
				char name[4];
				int length,flag;
				if(pos+4 > [dat length]) break;
				[dat getBytes:name range:NSMakeRange(pos,4)];
				pos += 4;
				length = (version == 3) ? getInt(dat,&pos) : getFrameSize24(dat,&pos);
				flag = getShort(dat,&pos);
				if(length <= 0 || length > [dat length]-pos) break;
				pos -= 6;
				if(flag) {
					(version == 3) ? skipFrame23(dat,&pos) : skipFrame24(dat,&pos);
				}
				else if(!strncmp(name,"TIT2",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_TITLE];
				}
				else if(!strncmp(name,"TPE1",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_ARTIST];
				}
				else if(!strncmp(name,"TPE2",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_ALBUMARTIST];
				}
				else if(!strncmp(name,"TALB",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_ALBUM];
				}
				else if(!strncmp(name,"TCON",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_GENRE];
				}
				else if(!strncmp(name,"TCOM",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_COMPOSER];
				}
				else if(!strncmp(name,"TIT1",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_GROUP];
				}
				else if(!strncmp(name,"TRCK",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str) {
						[metadata setObject:[NSNumber numberWithInt:[str intValue]] forKey:XLD_METADATA_TRACK];
						if([str rangeOfString:@"/"].location != NSNotFound) {
							[metadata setObject:[NSNumber numberWithInt:[[str substringFromIndex:[str rangeOfString:@"/"].location+1] intValue]] forKey:XLD_METADATA_TOTALTRACKS];
						}
					}
				}
				else if(!strncmp(name,"TPOS",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str) {
						[metadata setObject:[NSNumber numberWithInt:[str intValue]] forKey:XLD_METADATA_DISC];
						if([str rangeOfString:@"/"].location != NSNotFound) {
							[metadata setObject:[NSNumber numberWithInt:[[str substringFromIndex:[str rangeOfString:@"/"].location+1] intValue]] forKey:XLD_METADATA_TOTALDISCS];
						}
					}
				}
				else if(!strncmp(name,"TYER",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str) {
						[metadata setObject:str forKey:XLD_METADATA_DATE];
						int year = [str intValue];
						if(year > 1000 && year < 3000) [metadata setObject:[NSNumber numberWithInt:year] forKey:XLD_METADATA_YEAR];
					}
				}
				else if(!strncmp(name,"TSOT",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_TITLESORT];
				}
				else if(!strncmp(name,"TSOP",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_ARTISTSORT];
				}
				else if(!strncmp(name,"TSOA",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_ALBUMSORT];
				}
				else if(!strncmp(name,"TSO2",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_ALBUMARTISTSORT];
				}
				else if(!strncmp(name,"TSOC",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_COMPOSERSORT];
				}
				else if(!strncmp(name,"TBPM",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str) [metadata setObject:[NSNumber numberWithInt:[str intValue]] forKey:XLD_METADATA_BPM];
				}
				else if(!strncmp(name,"TCMP",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str && [str intValue]) [metadata setObject:[NSNumber numberWithBool:YES] forKey:XLD_METADATA_COMPILATION];
				}
				else if(!strncmp(name,"TSRC",4)) {
					NSString *str = (version == 3) ? getTextFrame23(dat,&pos) : getTextFrame24(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_ISRC];
				}
				else if(!strncmp(name,"COMM",4)) {
					NSString *desc;
					NSString *str = (version == 3) ? getCommentFrame23(dat,&pos,&desc) : getCommentFrame24(dat,&pos,&desc);
					if(str) {
						if(desc && [desc isEqualToString:@""]) {
							[metadata setObject:str forKey:XLD_METADATA_COMMENT];
						}
						else if(desc && [desc isEqualToString:@"iTunPGAP"]) {
							if([str intValue]) [metadata setObject:[NSNumber numberWithBool:YES] forKey:XLD_METADATA_GAPLESSALBUM];
						}
						else if(desc && [desc isEqualToString:@"iTunes_CDDB_1"]) {
							[metadata setObject:str forKey:XLD_METADATA_GRACENOTE2];
						}
					}
				}
				else if(!strncmp(name,"USLT",4)) {
					NSString *str = (version == 3) ? getCommentFrame23(dat,&pos,NULL) : getCommentFrame24(dat,&pos,NULL);
					if(str) [metadata setObject:str forKey:XLD_METADATA_LYRICS];
				}
				else if(!strncmp(name,"UFID",4)) {
					NSString *desc;
					NSString *str = (version == 3) ? getUFIDFrame23(dat,&pos,&desc) : getUFIDFrame24(dat,&pos,&desc);
					if(str && desc && [desc isEqualToString:@"http://musicbrainz.org"]) {
						[metadata setObject:str forKey:XLD_METADATA_MB_TRACKID];
					}
				}
				else if(!strncmp(name,"TXXX",4)) {
					NSString *desc;
					NSString *str = (version == 3) ? getTxxxFrame23(dat,&pos,&desc) : getTxxxFrame24(dat,&pos,&desc);
					if(str) {
						if(desc && [desc isEqualToString:@"MusicBrainz Album Id"]) {
							[metadata setObject:str forKey:XLD_METADATA_MB_ALBUMID];
						}
						else if(desc && [desc isEqualToString:@"MusicBrainz Artist Id"]) {
							[metadata setObject:str forKey:XLD_METADATA_MB_ARTISTID];
						}
						else if(desc && [desc isEqualToString:@"MusicBrainz Album Artist Id"]) {
							[metadata setObject:str forKey:XLD_METADATA_MB_ALBUMARTISTID];
						}
						else if(desc && [desc isEqualToString:@"MusicBrainz Disc Id"]) {
							[metadata setObject:str forKey:XLD_METADATA_MB_DISCID];
						}
						else if(desc && [desc isEqualToString:@"MusicIP PUID"]) {
							[metadata setObject:str forKey:XLD_METADATA_PUID];
						}
						else if(desc && [desc isEqualToString:@"MusicBrainz Album Status"]) {
							[metadata setObject:str forKey:XLD_METADATA_MB_ALBUMSTATUS];
						}
						else if(desc && [desc isEqualToString:@"MusicBrainz Album Type"]) {
							[metadata setObject:str forKey:XLD_METADATA_MB_ALBUMTYPE];
						}
						else if(desc && [desc isEqualToString:@"MusicBrainz Album Release Country"]) {
							[metadata setObject:str forKey:XLD_METADATA_MB_RELEASECOUNTRY];
						}
						else if(desc && [desc isEqualToString:@"MusicBrainz Release Group Id"]) {
							[metadata setObject:str forKey:XLD_METADATA_MB_RELEASEGROUPID];
						}
						else if(desc && [desc isEqualToString:@"MusicBrainz Work Id"]) {
							[metadata setObject:str forKey:XLD_METADATA_MB_WORKID];
						}
						else if(desc && [desc isEqualToString:@"SMPTE_TIMECODE_START"]) {
							[metadata setObject:str forKey:XLD_METADATA_SMPTE_TIMECODE_START];
						}
						else if(desc && [desc isEqualToString:@"SMPTE_TIMECODE_DURATION"]) {
							[metadata setObject:str forKey:XLD_METADATA_SMPTE_TIMECODE_DURATION];
						}
						else if(desc && [desc isEqualToString:@"MEDIA_FPS"]) {
							[metadata setObject:str forKey:XLD_METADATA_MEDIA_FPS];
						}
					}
				}
				else if(!strncmp(name,"APIC",4)) {
					int type;
					NSData *imgData = (version == 3) ? getAPICFrame23(dat,&pos,&type) : getAPICFrame24(dat,&pos,&type);
					if(imgData && (type==3 || ![metadata objectForKey:XLD_METADATA_COVER])) {
						NSImage *img = [[NSImage alloc] initWithData:imgData];
						if(img && [img isValid]) {
							[metadata setObject:imgData forKey:XLD_METADATA_COVER];
						}
						if(img) [img release];
					}
				}
				else (version == 3) ? skipFrame23(dat,&pos) : skipFrame24(dat,&pos);
				size -= length + 10;
			}
		}
		else if(version == 2) {
			if(globalFlag != 0) return;
			
			while(size > 0) {
				char name[3];
				int length;
				if(pos+3 > [dat length]) break;
				[dat getBytes:name range:NSMakeRange(pos,3)];
				pos += 3;
				length = get24bit(dat,&pos);
				if(length <= 0 || length > [dat length]-pos) break;
				pos -= 3;
				
				if(!strncmp(name,"TT2",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_TITLE];
				}
				else if(!strncmp(name,"TP1",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_ARTIST];
				}
				else if(!strncmp(name,"TP2",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_ALBUMARTIST];
				}
				else if(!strncmp(name,"TAL",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_ALBUM];
				}
				else if(!strncmp(name,"TCO",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_GENRE];
				}
				else if(!strncmp(name,"TCM",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_COMPOSER];
				}
				else if(!strncmp(name,"TT1",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_GROUP];
				}
				else if(!strncmp(name,"TRK",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str) {
						[metadata setObject:[NSNumber numberWithInt:[str intValue]] forKey:XLD_METADATA_TRACK];
						if([str rangeOfString:@"/"].location != NSNotFound) {
							[metadata setObject:[NSNumber numberWithInt:[[str substringFromIndex:[str rangeOfString:@"/"].location+1] intValue]] forKey:XLD_METADATA_TOTALTRACKS];
						}
					}
				}
				else if(!strncmp(name,"TPA",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str) {
						[metadata setObject:[NSNumber numberWithInt:[str intValue]] forKey:XLD_METADATA_DISC];
						if([str rangeOfString:@"/"].location != NSNotFound) {
							[metadata setObject:[NSNumber numberWithInt:[[str substringFromIndex:[str rangeOfString:@"/"].location+1] intValue]] forKey:XLD_METADATA_TOTALDISCS];
						}
					}
				}
				else if(!strncmp(name,"TYE",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str) {
						[metadata setObject:str forKey:XLD_METADATA_DATE];
						int year = [str intValue];
						if(year > 1000 && year < 3000) [metadata setObject:[NSNumber numberWithInt:year] forKey:XLD_METADATA_YEAR];
					}
				}
				else if(!strncmp(name,"TST",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_TITLESORT];
				}
				else if(!strncmp(name,"TSP",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_ARTISTSORT];
				}
				else if(!strncmp(name,"TSA",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_ALBUMSORT];
				}
				else if(!strncmp(name,"TS2",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_ALBUMARTISTSORT];
				}
				else if(!strncmp(name,"TSC",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_COMPOSERSORT];
				}
				else if(!strncmp(name,"TBP",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str) [metadata setObject:[NSNumber numberWithInt:[str intValue]] forKey:XLD_METADATA_BPM];
				}
				else if(!strncmp(name,"TCP",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str && [str intValue]) [metadata setObject:[NSNumber numberWithBool:YES] forKey:XLD_METADATA_COMPILATION];
				}
				else if(!strncmp(name,"TRC",3)) {
					NSString *str = getTextFrame22(dat,&pos);
					if(str) [metadata setObject:str forKey:XLD_METADATA_ISRC];
				}
				else if(!strncmp(name,"COM",3)) {
					NSString *desc;
					NSString *str = getCommentFrame22(dat,&pos,&desc);
					if(str) {
						if(desc && [desc isEqualToString:@""]) {
							[metadata setObject:str forKey:XLD_METADATA_COMMENT];
						}
						else if(desc && [desc isEqualToString:@"iTunPGAP"]) {
							if([str intValue]) [metadata setObject:[NSNumber numberWithBool:YES] forKey:XLD_METADATA_GAPLESSALBUM];
						}
						else if(desc && [desc isEqualToString:@"iTunes_CDDB_1"]) {
							[metadata setObject:str forKey:XLD_METADATA_GRACENOTE2];
						}
					}
				}
				else if(!strncmp(name,"ULT",3)) {
					NSString *str = getCommentFrame22(dat,&pos,NULL);
					if(str) [metadata setObject:str forKey:XLD_METADATA_LYRICS];
				}
				else if(!strncmp(name,"UFI",3)) {
					NSString *desc;
					NSString *str = getUFIFrame22(dat,&pos,&desc);
					if(str && desc && [desc isEqualToString:@"http://musicbrainz.org"]) {
						[metadata setObject:str forKey:XLD_METADATA_MB_TRACKID];
					}
				}
				else if(!strncmp(name,"TXX",3)) {
					NSString *desc;
					NSString *str = getTxxFrame22(dat,&pos,&desc);
					if(str) {
						if(desc && [desc isEqualToString:@"MusicBrainz Album Id"]) {
							[metadata setObject:str forKey:XLD_METADATA_MB_ALBUMID];
						}
						else if(desc && [desc isEqualToString:@"MusicBrainz Artist Id"]) {
							[metadata setObject:str forKey:XLD_METADATA_MB_ARTISTID];
						}
						else if(desc && [desc isEqualToString:@"MusicBrainz Album Artist Id"]) {
							[metadata setObject:str forKey:XLD_METADATA_MB_ALBUMARTISTID];
						}
						else if(desc && [desc isEqualToString:@"MusicBrainz Disc Id"]) {
							[metadata setObject:str forKey:XLD_METADATA_MB_DISCID];
						}
						else if(desc && [desc isEqualToString:@"MusicIP PUID"]) {
							[metadata setObject:str forKey:XLD_METADATA_PUID];
						}
						else if(desc && [desc isEqualToString:@"MusicBrainz Album Status"]) {
							[metadata setObject:str forKey:XLD_METADATA_MB_ALBUMSTATUS];
						}
						else if(desc && [desc isEqualToString:@"MusicBrainz Album Type"]) {
							[metadata setObject:str forKey:XLD_METADATA_MB_ALBUMTYPE];
						}
						else if(desc && [desc isEqualToString:@"MusicBrainz Album Release Country"]) {
							[metadata setObject:str forKey:XLD_METADATA_MB_RELEASECOUNTRY];
						}
						else if(desc && [desc isEqualToString:@"SMPTE_TIMECODE_START"]) {
							[metadata setObject:str forKey:XLD_METADATA_SMPTE_TIMECODE_START];
						}
						else if(desc && [desc isEqualToString:@"SMPTE_TIMECODE_DURATION"]) {
							[metadata setObject:str forKey:XLD_METADATA_SMPTE_TIMECODE_DURATION];
						}
						else if(desc && [desc isEqualToString:@"MEDIA_FPS"]) {
							[metadata setObject:str forKey:XLD_METADATA_MEDIA_FPS];
						}
					}
				}
				else if(!strncmp(name,"PIC",3)) {
					int type;
					NSData *imgData = getPICFrame22(dat,&pos,&type);
					if(imgData && (type==3 || ![metadata objectForKey:XLD_METADATA_COVER])) {
						NSImage *img = [[NSImage alloc] initWithData:imgData];
						if(img && [img isValid]) {
							[metadata setObject:imgData forKey:XLD_METADATA_COVER];
						}
						if(img) [img release];
					}
				}
				else skipFrame22(dat,&pos);
				size -= length + 6;
			}
		}
	}
	@catch (NSException *exception) {
		NSLog(@"%@ in parseID3(): %@",[exception name], [exception reason]);
	}
}
