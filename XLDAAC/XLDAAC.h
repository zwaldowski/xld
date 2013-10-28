//
//  XLDAAC.h
//  XLDAAC
//
//  Created by Zach Waldowski on 10/28/13.
//  Copyright (c) 2013 Taihei Monma. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void XLDAACAppendUserDefinedComment(NSMutableData *tagData, NSString *tagIdentifier, NSString *commentStr);
extern void XLDAACAppendTextTag(NSMutableData *tagData, const char *atomID, NSString *tagStr);
extern void XLDAACAppendNumericTag(NSMutableData *tagData, const char *atomID, NSNumber *tagNum, int length);
