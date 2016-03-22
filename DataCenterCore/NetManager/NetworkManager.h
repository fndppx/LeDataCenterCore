//
//  NetworkManager.h
//  DataCenter
//
//  Created by cc on 12-10-25.
//  Copyright (c) 2012年 CC. All rights reserved.
//


#import "RequestItem.h"
#import "ResponseItem.h"
#import "NetConfiguration.h"






@interface NetworkManager : NSObject


@property (nonatomic,assign) DataCenterDebugLogLevel debugLogLevel; 

#pragma mark 外部DataCenter调用
+ (NetworkManager *)sharedNetManager;
- (BOOL)checkNetIsEnable;
/*
 设置调试输出Log等级,默认无任何输出
 */
- (void)configDebugLogLv:(DataCenterDebugLogLevel)level;
/*
 数据请求相关
 */
- (int)sendRequestWithRequestItem:(RequestItem *)requestItem;
- (void)sendNetRequestWithRequestItem:(RequestItem *)requestItem;
- (void)loadingFinished:(RequestItem *)requestItem;
/*
 主线程发送通知事件
 */
- (void)postNotificationOnMainThread:(NSNotification*) notification;
/*
 取消请求事件
 */
- (void)cancelDataRequest:(id)sender;
- (void)cancelDataRequestWithRequestID:(int)requestID;
/*
 清理请求缓存
 */
- (void)clearCache;
- (void)clearASICacheWithUrl:(NSString *)url;
/*
 重建根目录
 */
- (void)rebuildRootDirectory;
/*
 获取错误码对应的提示
 */
- (NSString *)getReturnCodeDesc:(kReturnCode)returnCode;
/*
 转换参数为String
 */
- (NSString *)converDictToString:(NSDictionary *)dict;
/*
 调试设置
 */
void DataCenterDebugLog(DataCenterDebugLogLevel level,NSString * format, ...);

@end
