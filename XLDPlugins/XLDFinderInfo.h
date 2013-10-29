//
//  XLDFinderInfo.h
//  XLD
//
//  Created by Zach Waldowski on 10/28/13.
//  Copyright (c) 2013 Taihei Monma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XLDFinderInfo : NSObject

- (id)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithData:(NSData *)data;

/**
 Sets FinderInfo flags.
 See CarbonCore/Finder.h for the set of flags.
 @param flags OR'd set of valid Finder flags.
 */
@property (nonatomic) UInt16 flags;

/**
 Sets FinderInfo extended flags.
 See CarbonCore/Finder.h for the set of extended flags.
 @param flags OR'd set of valid Finder extended flags.
 */
@property (nonatomic) UInt16 extendedFlags;

/**
 Sets FinderInfo four-char type code.
 @param typeCode The four-char type code to set.
 */
@property (nonatomic) OSType typeCode;

/**
 Sets FinderInfo four-char creator code.
 @param typeCode The four-char creator code to set.
 */
@property (nonatomic) OSType creatorCode;

/**
 Constucts the raw data for the FinderInfo.
 @result NSData for the FinderInfo based on the current settings.
 */
@property (nonatomic, readonly) NSData *data;

@end
