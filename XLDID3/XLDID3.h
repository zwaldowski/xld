//
//  XLDID3.h
//  XLDID3
//
//  Created by Zach Waldowski on 10/24/13.
//  Copyright (c) 2013 Taihei Monma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XLDID3 : NSObject

@end

void parseID3(NSData *dat, NSMutableDictionary *metadata);
