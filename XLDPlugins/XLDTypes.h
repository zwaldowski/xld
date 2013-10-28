//
//  XLDTypes.h
//  XLD
//
//  Created by Zach Waldowski on 10/28/13.
//  Copyright (c) 2013 Taihei Monma. All rights reserved.
//

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

#ifndef XLD_XLDTypes_h
#define XLD_XLDTypes_h

typedef int64_t xldoffset_t;

typedef enum {
	XLDNoCueSheet = 0,
	XLDTrackTypeCueSheet,
	XLDTextTypeCueSheet
} XLDEmbeddedCueSheetType;

typedef struct
{
	int channels;
	int bps;
	int samplerate;
	int isFloat;
} XLDFormat;

typedef enum {
	XLDNoErr = 0,
	XLDDecodeErr,
	XLDOutputErr,
	XLDReadErr,
	XLDWriteErr,
	XLDUnknownFormatErr,
	XLDUnsupportedOutputErr,
	XLDCancelErr,
	XLDUnknownErr
} XLDErr;

typedef enum {
	XLDLittleEndian = 0,
	XLDBigEndian
} XLDEndian;

typedef enum {
	XLDNoScale = 0,
	XLDWidthScale = 1,
	XLDHeightScale = 2,
	XLDShortSideScale = 3,
	XLDLongSideScale = 4,
	XLDExpansionScale = 0x10
} XLDScaleType;

typedef enum
{
	kRipperModeBurst = 0,
	kRipperModeC2 = 0x1,
	kRipperModeParanoia = 0x2,
	kRipperModeXLD = 0x4,
} XLDRipperMode;

#endif
