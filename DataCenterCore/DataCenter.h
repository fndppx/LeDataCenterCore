//
//  DataCenter.h
//  DataCenter
//
//  Created by cc on 12-10-25.
//  Copyright (c) 2012年 CC. All rights reserved.
//

/*
 注意：
 在使用DataCenter请求的时候，如果你使用的是代理回调，这时候你需要在是在delegate被销毁前
 调用
 [[DataCenter sharedDataCenter] cancelDataRequest:self];
 请切记，这个是必须调用的,另外是在销毁前。
 */


#import "NetworkManager.h"
#import "NSObjectAdditions.h"

#define kBaseUrl    @"http://121.40.114.226/"







@interface DataCenter : NSObject

+ (DataCenter *)sharedDataCenter;

#pragma mark 网络可用性检测
- (BOOL)checkNetIsEnable;

#pragma mark 公共Post参数
- (NSDictionary *)commonPostDict;

#pragma mark 统一请求事件
- (int)sendRequestWithRequestItem:(RequestItem *)item;

#pragma mark 获取本地数据缓存
- (void)sendGetLocalCacheWithRequestItem:(RequestItem *)item;

#pragma mark 数据解析
- (ResponseItem *)parseReturnData:(ResponseItem *)item;//统一判断返回的数据是否正确

#pragma mark 公共数据解析方法
- (void)mainParserReturnData:(ResponseItem *)item;

#pragma mark 向上层发送返回结果
- (void)sendSuccessResponseData:(ResponseItem *)item;
- (void)sendFailResponseData:(ResponseItem *)item;

#pragma mark 取消请求事件
- (void)cancelDataRequest:(id)sender;
- (void)cancelDataRequestWithRequestID:(int)requestID;

#pragma mark 手动清除ASI所有缓存
- (void)clearCache;

#pragma mark 清除指定Url的缓存
- (void)clearCacheWithUrl:(NSString * )url;

#pragma mark 清除指定ResponseItem的 缓存
- (void)clearCacheWithResponseItem: (ResponseItem *)responseItem;

#pragma mark 清除指定RequestItem 的缓存
- (void)clearCacheWithRequestItem: (RequestItem *)requestItem;

#pragma mark 设置Log输出等级,默认无输出
- (void)configDebugLogLv:(DataCenterDebugLogLevel)level;

#pragma mark 获取关于ReturnCode的描述
- (NSString *)getReturnCodeDesc:(kReturnCode)returnCode;

#pragma mark  是否返回空数据 包括: {} [] () { } [ ] ()
- (BOOL)isEmptyResponse:(NSString *)responseString;

#pragma mark  是否返回错误数据 包括: {null} [null] (null) null
- (BOOL)isErrorResponse:(NSString *)responseString;


@end
