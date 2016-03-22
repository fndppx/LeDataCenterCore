//
//  CommonHeaderManager.m
//  DataCenterCore
//
//  Created by CC on 15/5/25.
//  Copyright (c) 2015年 CC. All rights reserved.
//

#import "CommonHeaderManager.h"


@interface CommonHeaderManager()



@end


@implementation CommonHeaderManager

static CommonHeaderManager*_shardManager;
+ (CommonHeaderManager *)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shardManager = [[CommonHeaderManager alloc]init];
    });
    return _shardManager;
}


- (id)init
{
    self = [super init];
    if (self)
    {
        [self configCommonHeader];
    }
    return self;
}

- (void)configCommonHeader
{
    _commonRequestHeaders = [NSMutableDictionary dictionary];
}

- (NSDictionary *)commonRequestHeaders
{
    return _commonRequestHeaders;
}

- (void)addCommonRequestHeaderValue:(NSString *)value forKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }
    if (_commonRequestHeaders)
    {
        [_commonRequestHeaders setObject:value forKey:key];
        return;
    }
    _commonRequestHeaders = [NSMutableDictionary dictionaryWithObject:value forKey:key];
}


@end
