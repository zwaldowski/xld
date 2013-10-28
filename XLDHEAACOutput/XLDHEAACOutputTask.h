//
//  XLDHEAACOutputTask.h
//  XLDHEAACOutput
//
//  Created by tmkk on 08/03/04.
//  Copyright 2008 tmkk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XLDPlugins/XLDPlugins.h>

@interface XLDHEAACOutputTask : NSObject <XLDOutputTask> {
	XLDFormat format;
	NSTask *task;
	BOOL addTag;
	NSMutableData *tagData;
	NSString *path;
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
