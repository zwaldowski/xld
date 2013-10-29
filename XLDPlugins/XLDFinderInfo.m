//
//  XLDFinderInfo.m
//  XLD
//
//  Created by Zach Waldowski on 10/28/13.
//  Copyright (c) 2013 Taihei Monma. All rights reserved.
//

#import "XLDFinderInfo.h"

// All fields should be in network order. See CoreServices/CarbonCore/Finder.h
// for details on what flags and extendedFlags can be.
#pragma pack(push, 1)
typedef struct {
	union {
		struct {
			UInt32 type;
			UInt32 creator;
		} fileInfo;
		struct {
			UInt16 y1;  // Top left of window.
			UInt16 x1;
			UInt16 y2;  // Bottom right of window.
			UInt16 x2;
		} dirInfo;
	} fileOrDirInfo;
	UInt16 flags;  // Finder flags.
	struct {
		UInt16 y;
		UInt16 x;
	} location;
	UInt16 reserved;
} GenericFinderInfo;

typedef struct {
	UInt32 ignored0;
	UInt32 ignored1;
	UInt16 extendedFlags;  // Extended finder flags.
	UInt16 ignored3;
	UInt32 ignored4;
} GenericExtendedFinderInfo;

typedef struct {
	GenericFinderInfo base;
	GenericExtendedFinderInfo extended;
} PackedFinderInfo;
#pragma pack(pop)

@implementation XLDFinderInfo

- (id)initWithData:(NSData *)data
{
	self = [super init];
	if (self) {
		if (!data || !data.length) {
			return nil;
		}
		
		PackedFinderInfo info;
		bzero(&info, sizeof(info));
		
		size_t len = MIN(data.length, sizeof(info));
		memcpy(&info, data.bytes, len);
		
		self.typeCode = ntohl(info.base.fileOrDirInfo.fileInfo.type);
		self.creatorCode = ntohl(info.base.fileOrDirInfo.fileInfo.creator);
		self.flags = ntohs(info.base.flags);
		self.extendedFlags = ntohs(info.extended.extendedFlags);
	}
	return self;
}

- (NSData *)data {
	PackedFinderInfo info;
	assert(sizeof(info) == 32);
	bzero(&info, sizeof(info));
	info.base.fileOrDirInfo.fileInfo.type = htonl(self.typeCode);
	info.base.fileOrDirInfo.fileInfo.creator = htonl(self.creatorCode);
	info.base.flags = htons(self.flags);
	info.extended.extendedFlags = htons(self.extendedFlags);
	return [NSData dataWithBytes:&info length:sizeof(info)];
}


@end
