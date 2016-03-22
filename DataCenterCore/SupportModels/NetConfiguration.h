//
//  NetConfiguration.h
//  DataCenter
//
//  Created by cc on 12-10-25.
//  Copyright (c) 2012年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"



extern NSString * const NetEnvironmentChangedNotification;//网络环境变化通知

typedef enum
{
    eNet_Wifi,    //wifi
    eNet_3G,      //3G
    eNet_None     //无网络
}AppNetType;

typedef enum
{
    LogLevelType0,    
    LogLevelType1,    
    LogLevelType2,    
    LogLevelType3
}LogLevelType;


@protocol NetConfigurationDataSource <NSObject>

@required
- (NSDictionary *)commonRequestHeader;
- (NSArray *)commonCookiesInDomian:(NSString *)currentDomian;
- (void)configCommonRequestHeader:(NSDictionary *)dict;
- (void)addCommonRequestHeaderValue:(NSString *)value forKey:(NSString *)key;

@end




@interface NetConfiguration : NSObject

@property (nonatomic, assign) LogLevelType logLevel;
@property (nonatomic, assign) AppNetType currentNetType;
@property (nonatomic, assign) id<NetConfigurationDataSource> dataSource;


+ (NetConfiguration *)sharedNetConfig;
- (NSDictionary *)commonRequestHeaders;

#pragma mark 配置通用信息
- (void)configCommonRequestHeader:(NSDictionary *)dict;
- (void)addCommonRequestHeaderValue:(NSString *)value forKey:(NSString *)key;

#pragma mark 公共属性信息

- (BOOL)isJailBreak;
- (NSString *)getVersion;
- (NSString *)getDeviceModel;
- (NSString *)getSysVersion;
- (NSString *)getLanguage;
- (NSString *)getDeviveID;
- (NSString *)UUIDString;

#pragma mark 获取当前网络类型3G/wifi
- (NSString *)currentNetworkType; 
- (BOOL)checkNetIsEnable;
- (NetworkStatus)currentReachabilityStatus;

#pragma mark HTTPCookies管理
- (void)deleteCommonHTTPCookies;
- (void)configCommonHTTPCookies:(NSString *)domainUrl;
- (NSHTTPCookie *)buileCookie:(NSString *)value forName:(NSString *)name inDomain:(NSString *)currentDomain;

#pragma mark 获取IP地址
- (NSString *)getIPAddress;

@end



