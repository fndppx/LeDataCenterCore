//
//  NetConfiguration.m
//  DataCenter
//
//  Created by cc on 12-10-25.
//  Copyright (c) 2012年 CC. All rights reserved.
//

#import "NetConfiguration.h"
#import "StaticValues.h"
#import "NetworkManager.h"
#import "UIDevice-Hardware.h"
#import "NSStringExtend.h"
#import "UIApplicationAdditions.h"
#import "UIDeviceAdditions.h"
#import <AdSupport/AdSupport.h>
#import "UIDevice-Hardware.h"
#import <ifaddrs.h>
#import <arpa/inet.h>


#define kDefault_UUID_Key     @"idfaidentifier_uuid"

NSString * const NetEnvironmentChangedNotification = @"NetEnvironmentChangedNotification";


@interface NetConfiguration()

@property (nonatomic, strong) Reachability * reachability;
@property (nonatomic, strong) NSString * netType;


-(void)reginNotific;
-(void)connectNetHasChanged:(NSNotification *)notific;

@end

@implementation NetConfiguration

static NetConfiguration *sharedNetConfig = nil;

+ (NetConfiguration *)sharedNetConfig{
    
    @synchronized(self)
    {
        if (sharedNetConfig == nil)
        {
            sharedNetConfig = [[self alloc] init];
        }
    }
    return sharedNetConfig;
}

#pragma mark ************内部方法************
- (id)init
{
    self = [super init];
    if (self)
    {
        [self startReachabilityNotifier];
        [self reginNotific];
    }
    return self;
}

-(void)dealloc
{
    [self stopReachablityNotifier];
    
}


-(void)reginNotific
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectNetHasChanged:) name:kReachabilityChangedNotification object:nil];
}


- (NSString *)UUIDString
{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSString * uuid = [NSString stringWithObject:[userDefault objectForKey:kDefault_UUID_Key]];
    if (uuid.length != 0)
    {
        return uuid;
    }
    uuid = [[NSUUID UUID] UUIDString];
    [userDefault setObject:uuid forKey:kDefault_UUID_Key];
    [userDefault synchronize];
    return uuid;
}

#define USER_APP_PATH                 @"/User/Applications/"
- (BOOL)isJailBreak
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:USER_APP_PATH])
    {
        NSLog(@"The device is jail broken!");
        NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:USER_APP_PATH error:nil];
        NSLog(@"applist = %@", applist);
        return YES;
    }
    NSLog(@"The device is NOT jail broken!");
    return NO;
}

- (NSString *)getVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
}

- (NSString *)getDeviceModel
{
    NSString *deviceModel=[UIDevice currentDevice].platform;
    return deviceModel;
}

- (NSString *)getSysVersion
{
    NSString *sysVersion=[UIDevice currentDevice].systemVersion;
    return sysVersion;
}

- (NSString *)getLanguage
{
    NSString *language=[[NSLocale currentLocale] localeIdentifier];
    return language;
}

- (NSString *)getDeviveID
{
    NSString *deviveID=[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
    return deviveID;
}

-(NSString *)currentNetworkType
{
    NetworkStatus network = [self currentReachabilityStatus];
    self.netType = @"";
    self.currentNetType = eNet_None;
    if (network == ReachableViaWWAN)
    {
        self.netType = @"3G";
        self.currentNetType = eNet_3G;
    }
    else if (network == ReachableViaWiFi)
    {
        self.netType = @"wifi";
        self.currentNetType = eNet_Wifi;
    }
    return self.netType;
}

-(void)connectNetHasChanged:(NSNotification *)notific
{
    [self currentNetworkType];
    [[NSNotificationCenter defaultCenter] postNotificationName:NetEnvironmentChangedNotification object:nil];
}

- (NSDictionary *)commonRequestHeaders
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(commonRequestHeader)])
    {
        return [_dataSource commonRequestHeader];
    }
    return nil;
}

- (void)configCommonRequestHeader:(NSDictionary *)dict
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(configCommonRequestHeader:)])
    {
        return [_dataSource configCommonRequestHeader:dict];
    }
}

- (void)addCommonRequestHeaderValue:(NSString *)value forKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }
    if (_dataSource && [_dataSource respondsToSelector:@selector(addCommonRequestHeaderValue:forKey:)])
    {
        [_dataSource addCommonRequestHeaderValue:value forKey:key];
    }
}

#pragma mark 管理Cookies
- (NSArray *)commonCookies:(NSString *)currentDomian
{
    [self currentNetworkType];
    NSArray * cookies = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(commonCookiesInDomian:)])
    {
        cookies = [NSArray arrayWithArray:[_dataSource commonCookiesInDomian:currentDomian]];
    }
    return cookies;
}

- (NSHTTPCookie *)buileCookie:(NSString *)value forName:(NSString *)name inDomain:(NSString *)currentDomain
{
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                value, NSHTTPCookieValue,
                                name, NSHTTPCookieName,
                                currentDomain, NSHTTPCookieDomain,
                                [NSDate dateWithTimeIntervalSinceNow:60*60], NSHTTPCookieExpires,
                                @"/", NSHTTPCookiePath,
                                nil];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
    return cookie;
}


#pragma mark HTTPCookies管理
- (void)deleteCommonHTTPCookies
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *oldCookies = [NSArray arrayWithArray:[storage cookies]];
    for (NSHTTPCookie *cookie in oldCookies)
    {
        [storage deleteCookie:cookie];
    }
}

-(void)removeExistCookies:(NSArray *)cookies
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray * cookiesArray = [NSArray arrayWithArray:storage.cookies];
    for (int i = 0; i < cookies.count; i++)
    {
        NSHTTPCookie * cookie = [cookies objectAtIndex:i];
        for (NSHTTPCookie * aCookie in cookiesArray)
        {
            if ([aCookie.name isEqualToString:cookie.name])
            {
                [storage deleteCookie:aCookie];
                break;
            }
        }
    }
}

- (void)configCommonHTTPCookies:(NSString *)domainUrl
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    NSArray * cookiesArray = [NSArray arrayWithArray:[self commonCookies:domainUrl]];
    if (!cookiesArray || cookiesArray.count==0)
    {
        return;
    }
    [self removeExistCookies:cookiesArray];
    for (int i = 0; i < cookiesArray.count; i++)
    {
        [storage setCookie:[cookiesArray objectAtIndex:i]];
    }
}

#pragma mark 获取IP地址
- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

#pragma mark Reachability
-(void)startReachabilityNotifier
{
    if (!self.reachability)
    {
        self.reachability = [Reachability reachabilityForInternetConnection];
    }
    [self.reachability startNotifier];
}

-(void)stopReachablityNotifier
{
    [self.reachability stopNotifier];
}


#pragma mark -
///the following functions must be called on main thread!!!
#ifdef __cplusplus
extern "C"
{
#endif
    void DataCenterDebugLog(DataCenterDebugLogLevel level,NSString * format, ...)
    {
        DataCenterDebugLogLevel currentlogLevel = [NetworkManager sharedNetManager].debugLogLevel;
        if (level <= currentlogLevel)
        {
            va_list args;
            va_start(args, format);
            NSLogv([@"[DataCenter debugLog]:" stringByAppendingString: format], args);
        }
    }
#ifdef __cplusplus
}
#endif


#pragma mark ************外部调用************
-(BOOL)checkNetIsEnable
{
    if (([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == NotReachable) && ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)) {
        return NO;
    }
    return YES;
}

-(NetworkStatus)currentReachabilityStatus
{
    NetworkStatus status = [self.reachability currentReachabilityStatus];
    return status;
}


@end



