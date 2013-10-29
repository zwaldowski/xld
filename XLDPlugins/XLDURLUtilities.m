//
//  XLDURLUtilities.m
//  XLD
//
//  Created by Zach Waldowski on 10/28/13.
//  Copyright (c) 2013 Taihei Monma. All rights reserved.
//

#import "XLDURLUtilities.h"
#import <XLDPlugins/XLDFinderInfo.h>
#include <sys/xattr.h>

@implementation XLDURLUtilities

+ (BOOL)setFinderInfo:(XLDFinderInfo *)info forURL:(NSURL *)URL error:(out NSError **)outError
{
	if (outError) {
		*outError = nil;
	}
	
	BOOL(^errPosix)(void) = ^{
		if (outError) {
			*outError = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:NULL];
		}
		return NO;
	};
	
	const char *path = URL.fileSystemRepresentation;
	
	if (info) {
		NSData *data = [info data];
		if (setxattr(path, XATTR_FINDERINFO_NAME, data.bytes, data.length, 0, XATTR_NOFOLLOW) == 0) {
			return YES;
		} else {
			return errPosix();
		}
	} else {
		if (removexattr(path, XATTR_FINDERINFO_NAME, XATTR_NOFOLLOW) == 0) {
			return YES;
		} else {
			return errPosix();
		}
	}
}

+ (BOOL)getFinderInfo:(out XLDFinderInfo **)info forURL:(NSURL *)URL error:(out NSError **)outError
{
	if (info) {
		*info = nil;
	}
	
	if (outError) {
		*outError = nil;
	}
	
	BOOL(^errPosix)(void) = ^{
		if (outError) {
			*outError = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:NULL];
		}
		return NO;
	};
	
	const char *path = URL.fileSystemRepresentation;
	
	ssize_t size;
	if ((size = getxattr(path, XATTR_FINDERINFO_NAME, NULL, 0, 0, XATTR_NOFOLLOW)) > 0) {
		NSMutableData *data = [NSMutableData dataWithLength:size];
		if (getxattr(path, XATTR_FINDERINFO_NAME, data.mutableBytes, size, 0, XATTR_NOFOLLOW) > 0) {
			if (info) {
				*info = [[XLDFinderInfo alloc] initWithData:data];
			}
			return YES;
		} else {
			return errPosix();
		}
	} else if (size == 0) {
		return YES;
	} else {
		return errPosix();
	}
}

+ (BOOL)setFinderInfoForURL:(NSURL *)URL usingBlock:(void(^)(XLDFinderInfo *))block error:(out NSError **)outError
{
	if (!block) return YES;
	
	XLDFinderInfo *info = nil;
	BOOL success;
	
	success = [self getFinderInfo:&info forURL:URL error:outError];
	if (!success) return NO;
	
	block(info);
	
	success = [self setFinderInfo:info forURL:URL error:outError];
	return success;
}


@end
