//
//  DataCaches.m
//  DataCenter
//
//  Created by cc on 13-11-20.
//  Copyright (c) 2013年 CC. All rights reserved.
//

#import "DataCaches.h"
#import "ASIDownloadCache.h"
#import "DataParser.h"

#define kASICacheHeaderExt   @"cachedheaders"

@implementation DataCaches

+ (NSData *)cacheDataWithRequestUrl:(NSString *)urlStr
{
    NSString * cacheFileName = [ASIDownloadCache keyForURL:[NSURL URLWithString:urlStr]];
    ASIDownloadCache * asiCache = [ASIDownloadCache sharedCache];
    NSFileManager * fileManager = [[NSFileManager alloc] init];
    NSArray * subFilesArray = [fileManager subpathsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",asiCache.storagePath,kASILocalCacheFileName] error:nil];
    if (subFilesArray && subFilesArray.count != 0)
    {
        for (int i = 0; i < subFilesArray.count; i++)
        {
            NSString * subFileName = [subFilesArray objectAtIndex:i];
            NSString *pathExtension = [subFileName pathExtension];
            if (![pathExtension isEqualToString:kASICacheHeaderExt])
            {
                if ([[subFileName stringByDeletingPathExtension] isEqualToString:cacheFileName])
                {
                    cacheFileName = subFileName;
                    break;
                }
            }
        }
//        NSLog(@"RequestUrlCacheFilePath:%@",[NSString stringWithFormat:@"%@/%@/%@",asiCache.storagePath,kASILocalCacheFileName,cacheFileName]);
        NSData * cacheData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/%@",asiCache.storagePath,kASILocalCacheFileName,cacheFileName]];
        return cacheData;
    }
    return nil;
}

+ (NSDictionary *)cacheDataDictWithRequestUrl:(NSString *)urlStr
{
    NSDictionary * dict = [DataParser parseOpenAPIResult:[self cacheDataWithRequestUrl:urlStr]];
    return dict;
}

@end
