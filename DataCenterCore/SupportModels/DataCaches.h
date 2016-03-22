//
//  DataCaches.h
//  DataCenter
//
//  Created by cc on 13-11-20.
//  Copyright (c) 2013年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kASILocalCacheFileName   @"PermanentStore"

@interface DataCaches : NSObject

+ (NSData *)cacheDataWithRequestUrl:(NSString *)urlStr;

+ (NSDictionary *)cacheDataDictWithRequestUrl:(NSString *)urlStr;

@end
