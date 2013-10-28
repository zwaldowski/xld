//
//  XLDAAC.m
//  XLDAAC
//
//  Created by Zach Waldowski on 10/28/13.
//  Copyright (c) 2013 Taihei Monma. All rights reserved.
//

#import "XLDAAC.h"

void XLDAACAppendUserDefinedComment(NSMutableData *tagData, NSString *tagIdentifier, NSString *commentStr)
{
	NSData *commentData = [commentStr dataUsingEncoding:NSUTF8StringEncoding];
	NSData *tagIdentifierData = [tagIdentifier dataUsingEncoding:NSUTF8StringEncoding];

	uint32_t tmp;
	tmp = 0x40 + (uint32_t)[commentData length] + (uint32_t)[tagIdentifierData length];
	tmp = NSSwapHostIntToBig(tmp);
	[tagData appendBytes:&tmp length:sizeof(uint32_t)];
	[tagData appendBytes:"----" length:4];
	tmp = 0x1C;
	tmp = NSSwapHostIntToBig(tmp);
	[tagData appendBytes:&tmp length:sizeof(uint32_t)];
	[tagData appendBytes:"mean" length:4];
	tmp = 0;
	[tagData appendBytes:&tmp length:4];
	[tagData appendBytes:"com.apple.iTunes" length:16];
	tmp = 0xC + (uint32_t)[tagIdentifierData length];
	tmp = NSSwapHostIntToBig(tmp);
	[tagData appendBytes:&tmp length:sizeof(uint32_t)];
	[tagData appendBytes:"name" length:4];
	tmp = 0;
	[tagData appendBytes:&tmp length:sizeof(uint32_t)];
	[tagData appendData:tagIdentifierData];
	tmp = 0x10 + (uint32_t)[commentData length];
	tmp = NSSwapHostIntToBig(tmp);
	[tagData appendBytes:&tmp length:sizeof(uint32_t)];
	[tagData appendBytes:"data" length:4];
	
	char reserved[3] = { 0, 0, 0 };
	[tagData appendBytes:&reserved length:sizeof(reserved)]; //reserved
	uint8_t type = 0x1;
	[tagData appendBytes:&type length:sizeof(uint8_t)]; //type (1:UTF-8)
	uint32_t locale = 0;
	[tagData appendBytes:&locale length:sizeof(int32_t)]; //locale (reserved to be 0)
	
	[tagData appendData:commentData];
}

void XLDAACAppendTextTag(NSMutableData *tagData, const char *atomID, NSString *tagStr)
{
	NSData *data = [tagStr dataUsingEncoding:NSUTF8StringEncoding];

	uint32_t tmp;
	tmp = 24 + (uint32_t)[data length];
	tmp = NSSwapHostIntToBig(tmp);
	[tagData appendBytes:&tmp length:sizeof(uint32_t)];
	[tagData appendBytes:atomID length:sizeof(uint32_t)];
	tmp = 16 + (uint32_t)[data length];
	tmp = NSSwapHostIntToBig(tmp);
	[tagData appendBytes:&tmp length:sizeof(uint32_t)];
	[tagData appendBytes:"data" length:4];
	
	char reserved[3] = { 0, 0, 0 };
	[tagData appendBytes:&reserved length:sizeof(reserved)]; //reserved
	uint8_t type = 0x1;
	[tagData appendBytes:&type length:sizeof(uint8_t)]; //type (1:UTF-8)
	uint32_t locale = 0;
	[tagData appendBytes:&locale length:sizeof(uint32_t)]; //locale (reserved to be 0)

	[tagData appendData:data];
}

void XLDAACAppendNumericTag(NSMutableData *tagData, const char *atomID, NSNumber *tagNum, int length)
{
	if (length != 1 && length != 2 && length != 4 && length != 8) return;
	
	uint32_t tmp;
	tmp = 24 + length;
	tmp = NSSwapHostIntToBig(tmp);
	[tagData appendBytes:&tmp length:sizeof(uint32_t)];
	[tagData appendBytes:atomID length:sizeof(uint32_t)];
	tmp = 16 + length;
	tmp = NSSwapHostIntToBig(tmp);
	[tagData appendBytes:&tmp length:sizeof(uint32_t)];
	[tagData appendBytes:"data" length:4];
	
	char reserved[3] = { 0, 0, 0 };
	[tagData appendBytes:&reserved length:sizeof(reserved)]; //reserved
	uint8_t type = 0x15;
	[tagData appendBytes:&type length:sizeof(uint8_t)]; //type (0x15:integer)
	uint32_t locale = 0;
	[tagData appendBytes:&locale length:sizeof(uint32_t)]; //locale (reserved to be 0)
	
	if(length == sizeof(uint8_t)) {
		uint8_t tag = [tagNum unsignedCharValue];
		[tagData appendBytes:&tag length:sizeof(uint8_t)];
	}
	else if(length == sizeof(uint16_t)) {
		uint16_t tag = NSSwapHostShortToBig([tagNum unsignedShortValue]);
		[tagData appendBytes:&tag length:sizeof(uint16_t)];
	}
	else if(length == sizeof(uint32_t)) {
		uint32_t tag = NSSwapHostIntToBig([tagNum unsignedIntValue]);
		[tagData appendBytes:&tag length:sizeof(uint32_t)];
	}
	else if(length == sizeof(uint64_t)) {
		uint64_t tag = NSSwapHostLongToBig([tagNum unsignedLongValue]);
		[tagData appendBytes:&tag length:sizeof(uint64_t)];
	}
}