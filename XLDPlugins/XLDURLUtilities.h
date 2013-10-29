//
//  XLDURLUtilities.h
//  XLD
//
//  Created by Zach Waldowski on 10/28/13.
//  Copyright (c) 2013 Taihei Monma. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XLDFinderInfo;

@interface XLDURLUtilities : NSObject

+ (BOOL)setFinderInfo:(XLDFinderInfo *)info forURL:(NSURL *)URL error:(out NSError **)outError;
+ (BOOL)getFinderInfo:(out XLDFinderInfo **)info forURL:(NSURL *)URL error:(out NSError **)outError;
+ (BOOL)setFinderInfoForURL:(NSURL *)URL usingBlock:(void(^)(XLDFinderInfo *))block error:(out NSError **)outError;

@end
