//
//  CommonHeaderManager.h
//  DataCenterCore
//
//  Created by CC on 15/5/25.
//  Copyright (c) 2015年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CommonHeaderManager : NSObject
{
    NSMutableDictionary * commonRequestHeaders;
}
@property (nonatomic,strong) NSMutableDictionary * commonRequestHeaders;

+ (CommonHeaderManager *)sharedManager;
/*
 子类重写
 */
- (void)configCommonHeader;


/*
 增加请求Header字段
 */
- (void)addCommonRequestHeaderValue:(NSString *)value forKey:(NSString *)key;

@end
