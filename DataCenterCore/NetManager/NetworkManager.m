//
//  NetworkManager.m
//  DataCenter
//
//  Created by cc on 12-10-25.
//  Copyright (c) 2012年 CC. All rights reserved.
//

#import "NetworkManager.h"
#import "DataRequestOperation.h"
#import "CustomASIRequest.h"
#import "ASIHTTPRequestExtend.h"
#import "ASIHttpRequest.h"
#import "ASIFormDataRequest.h"
#import "ASIDownloadCache.h"
#import "Reachability.h"
#import "NSMutableDictionary+Extention.h"
#import "NSObjectAdditions.h"
#import "M9Singleton.h"

static unsigned int kRequestID = 0;  //每次启动程序 从0开始
@interface NetworkManager()
{
    NSMutableArray * _requestArray;
    NSLock * _netLock;
}
@property (nonatomic, assign) int maxThreadCount;
@property (nonatomic, assign) int maxThreadConntForWifi;
@property (nonatomic, assign) int maxThreadConntFor3G;
@property (nonatomic, strong) NSLock * lock;
@property (nonatomic, strong) NSMutableArray * waitingItems;
@property (nonatomic, strong) NSMutableArray * loadingItems;
@property (nonatomic, strong) NSOperationQueue * requestQueue;

//获取网络状态通知相关
- (void)setMaxThreadCountByReachability:(NSNotification *)notif;
- (void)registerForNetworkReachabilityNotifications;



@end

@implementation NetworkManager
static NetworkManager *sharedNetManager = nil;

+ (NetworkManager *)sharedNetManager{
    
    @synchronized(self)
    {
        if (sharedNetManager == nil)
        {
            sharedNetManager = [[self alloc] init];
        }
    }
    return sharedNetManager;
}


#pragma mark ***********内部方法***********
#pragma mark 初始化
- (id) init
{
    self = [super init];
    if (self)
    {
        [self initRequestOperationQueue];
        
        [self registerForNetworkReachabilityNotifications];
        
        self.debugLogLevel = DebugLogBasicError;
    }
    return self;
}

#pragma mark  获取网络状态通知相关
- (void)setMaxThreadCountByReachability:(NSNotification *)notif
{
    NetworkStatus network = [[NetConfiguration sharedNetConfig] currentReachabilityStatus];
    if (network == ReachableViaWWAN)
    {
        self.maxThreadCount = self.maxThreadConntFor3G;
    }
    else if (network == ReachableViaWiFi)
    {
        self.maxThreadCount = self.maxThreadConntForWifi;
    }
    else
    {
        self.maxThreadCount = DEFAULT_MAX_POOL_THREAD_COUNT;
    }
    self.requestQueue.maxConcurrentOperationCount = self.maxThreadCount;
}

- (void)registerForNetworkReachabilityNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setMaxThreadCountByReachability:) name:kReachabilityChangedNotification object:nil];
}

-(BOOL)checkNetIsEnable
{
    return [[NetConfiguration sharedNetConfig] checkNetIsEnable];
}

#pragma mark 验证请求
-(BOOL)checkRequestItem:(RequestItem *)item
{
    if (!item.requestUrl)
    {
        DataCenterDebugLog(DebugLogBasicError,@"Error:请求URL为空");
        return NO;
    }
    if (!item.parseMethod)
    {
        DataCenterDebugLog(DebugLogBasicError,@"Error:使用通知回调，解析方法不能为空");
        return NO;
    }
    return YES;
}

#pragma mark DataCenter发起请求
-(int)sendRequestWithRequestItem:(RequestItem *)requestItem
{
    if (![self checkRequestItem:requestItem])
    {
        return K_Error_Request;
    }
    int requestID = [self addToWaitQueueWithRequestItem:requestItem];
    return requestID ;
}

#pragma mark 管理请求队列
- (int)addToWaitQueueWithRequestItem:(RequestItem *)requestItem
{
    [_lock lock];
	NSInteger waitingCount = 0;
    RequestItem * loadingItem = [self getRequestInLoadingQueue:requestItem];
    if (loadingItem !=nil&& !loadingItem.isCancelled)
    {
        DataCenterDebugLog(DebugLogBasicError, [NSString stringWithFormat:@"相同请求正在执行,返回先前请求%d url: %@",loadingItem.requestId,requestItem.requestUrl]);
        [_lock unlock];
        return loadingItem.requestId;
    }
	RequestItem * waitingItem = [self getRequestInWaitingQueue:requestItem];
    if (waitingItem != nil&& !loadingItem.isCancelled)
    {
        DataCenterDebugLog(DebugLogBasicError, [NSString stringWithFormat:@"相同请求正在等待,返回等待请求%d url: %@",[waitingItem requestId],requestItem.requestUrl]);
        [_lock unlock];
        return waitingItem.requestId;
    }
    requestItem.requestId = [self generateRequestID];
    requestItem.requestState = R_Start;
    DataCenterDebugLog(DebugLogIncludeUrl, [NSString stringWithFormat:@"%d 原始请求url: %@",[requestItem requestId],requestItem.requestUrl]);
    [_waitingItems addObject:requestItem];
    DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%d 已被加入到等待队列",[requestItem requestId]]);
    requestItem.requestState = R_InWaitingQueue;
    waitingCount = [_waitingItems count];
    int threadCount = [[_requestQueue operations] count];
	if(threadCount == 0 || (waitingCount > 0 && threadCount < _maxThreadCount))
	{
        DataRequestOperation  *op = [[DataRequestOperation alloc] initWithRequestItem:requestItem];
        op.requestItem = requestItem;
        [_waitingItems removeObject:requestItem];
        [_loadingItems addObject:requestItem];
		[_requestQueue addOperation:op];
	}
    [_lock unlock];
    return requestItem.requestId;
}

#pragma mark 判断RequestItem的状态
-(int)generateRequestID
{
    kRequestID++;
    return kRequestID;
}

- (RequestItem *)getRequestInWaitingQueue:(RequestItem *)requestItem
{
    if (_waitingItems == nil)
    {
        _waitingItems = [[NSMutableArray alloc] init];
        return nil;
    }
    RequestItem * item = [RequestItem isMutableArray:_waitingItems containsRequestItem:requestItem];
    return item;
}

- (RequestItem *)getRequestInLoadingQueue:(RequestItem *)requestItem
{
    RequestItem * item = [RequestItem isMutableArray:_loadingItems containsRequestItem:requestItem];
    return item;
}

- (BOOL)isRequestInWaitingQueue:(RequestItem*)requestItem
{
    if (_waitingItems == nil)
    {
        _waitingItems = [[NSMutableArray alloc] init];
        return NO;
    }
    if ([RequestItem isMutableArray:_waitingItems containsRequestItem:requestItem])
    {
        return YES;
    }
	return NO;
}

- (BOOL)isRequestInLoadingQueue:(RequestItem *)requestItem
{
    if ([RequestItem isMutableArray:_loadingItems containsRequestItem:requestItem])
    {
        return YES;
    }
    return NO;
}

#pragma mark 在线程中实际发送网络请求
- (void)sendNetRequestWithRequestItem:(RequestItem *)requestItem
{
    //    @autoreleasepool
    {
        requestItem.requestState = R_BeginASINetwork;
        if (requestItem.paramDict)
        {
            requestItem.finalRequestUrl = [NSString stringWithFormat:@"%@%@",requestItem.requestUrl,[self converDictToString:requestItem.paramDict]];
        }
        else{
            requestItem.finalRequestUrl = [NSString stringWithFormat:@"%@",requestItem.requestUrl];
        }
        requestItem.finalRequestUrl = [requestItem.finalRequestUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        DataCenterDebugLog(DebugLogIncludeUrl, [NSString stringWithFormat:@"%d-FinalRequestUrl: %@",[requestItem requestId],requestItem.finalRequestUrl]);
        NSURL * url = [NSURL URLWithString:requestItem.finalRequestUrl];
        CustomASIRequest * request = [CustomASIRequest requestWithItem:requestItem];
        
        if (requestItem.httpMethodType == HttpMethodGet)
        {
            if (requestItem.getDataFromCache || requestItem.needsCacheResponse || requestItem.cachePolicy != kNotUseCachedData)
            {
                if (requestItem.customerCache)
                {
                    [request setDownloadCache:requestItem.customerCache];
                }
                else
                {
                    [request setDownloadCache:[ASIDownloadCache sharedCache]];
                }
            }
            else
            {
                [request setDownloadCache:nil];
            }
            switch (requestItem.cachePolicy)
            {
                case kNotUseCachedData:
                    [request setCachePolicy:ASIDoNotReadFromCacheCachePolicy|ASIDoNotWriteToCacheCachePolicy];
                    break;
                case kAlwaysAskForUpdate:
                    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy|ASIFallbackToCacheIfLoadFailsCachePolicy];
                    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
                    [request setSecondsToCache:0.1];
                    break;
                case kAskForUpdateWhenStale:
                    [request setCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy|ASIFallbackToCacheIfLoadFailsCachePolicy];
                    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
                    [request setSecondsToCache:requestItem.cacheSecond];
                    break;
                default:
                    break;
            }
            if (requestItem.cachePolicy == kNotUseCachedData)
            {
                if (requestItem.getDataFromCache)
                {
                    [request setCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy|ASIFallbackToCacheIfLoadFailsCachePolicy];
                    DataCenterDebugLog(DebugLogIncludeConfigDetail, [NSString stringWithFormat:@"%d 缓存策略:取未过期缓存",[requestItem requestId]]);
                }
                else
                {
                    [request setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
                    DataCenterDebugLog(DebugLogIncludeConfigDetail, [NSString stringWithFormat:@"%d 缓存策略:不读缓存",[requestItem requestId]]);
                }
                if (requestItem.needsCacheResponse)
                {
                    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
                    [request setSecondsToCache:requestItem.cacheSecond];
                    DataCenterDebugLog(DebugLogIncludeConfigDetail, [NSString stringWithFormat:@"%d 缓存策略:本地缓存结果 时间: %d秒",[requestItem requestId],requestItem.cacheSecond]);
                }
                else
                {
                    DataCenterDebugLog(DebugLogIncludeConfigDetail, [NSString stringWithFormat:@"%d 设置缓存策略:不缓存请求结果",[requestItem requestId]]);
                }
            }
        }
        else
        {
            // POST
            if (requestItem.postFileData && requestItem.postFileKey)
            {
                [request addData:requestItem.postFileData forKey:requestItem.postFileKey];
            }
            if (requestItem.postFilePath && requestItem.postFileKey)
            {
                [request setFile:requestItem.postFilePath forKey:requestItem.postFileKey];
            }
            [request addPostDict:requestItem.postParamDict];
            DataCenterDebugLog(DebugLogIncludeUrl, [NSString stringWithFormat:@"%d Post参数:%@",[requestItem requestId],requestItem.postParamDict]);
            [request setDownloadCache:nil];
        }
        
        // 是否添加请求头
        if (requestItem.requestHeader)
        {
            [request addRequestHeaderDict:requestItem.requestHeader];
        }
        [self addObjectToRequestArray:request];
        NSError * error = nil;
        NSString * response = nil;
        kReturnCode errorCode = kRequestSuccess;
        if (requestItem.isCancelled)
        {
            errorCode=kRequestIsCanceled;
        }
        else{
            requestItem.requestState = R_TransferData;
            DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%d 开始同步请求",[requestItem requestId]]);
            [request startSynchronous];
            DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%d 同步请求结束",[requestItem requestId]]);
            error = [request error];
            response = [request responseString];
            DataCenterDebugLog(DebugLogIncludeData, [NSString stringWithFormat:@"%d Url: %@ 返回数据:%@",[requestItem requestId],requestItem.finalRequestUrl,response]);
        }
        if (error)
        {
            if (error.code == ASIHttpStateError)
            {
                [self clearASICacheWithUrl:[[request url] absoluteString]];
            }
            errorCode = [self mapReturnCodeWithASIHttpRequest:request];
        }
        [self removeObjectInRequestArray:request];
        BOOL hasUpdate  = (request.responseStatusCode == 304)? NO :YES;
        [self handleResultWithReturnCode:errorCode responseData:[request responseData] requestItem:requestItem hasUpdate:hasUpdate];
    }
}

#pragma mark 请求线程完成时候调用
- (void)loadingFinished:(RequestItem *)requestItem
{
    DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%d 完成",[requestItem requestId]]);
    [_lock lock];
    [_loadingItems removeObject:requestItem];
    int waitingCount = [_waitingItems count];
    int threadCount = [[_requestQueue operations] count];
    if(threadCount == 0 || (waitingCount >0 && threadCount < _maxThreadCount+1))
	{
        RequestItem * nextRequestItem = nil;
        if([_waitingItems count] > 0)
        {
            nextRequestItem = [_waitingItems objectAtIndex:0];
            DataRequestOperation  *op = [[DataRequestOperation alloc] initWithRequestItem:nextRequestItem];
            [_waitingItems removeObjectAtIndex:0];
            [_loadingItems addObject:nextRequestItem];
            [_requestQueue addOperation:op];
            DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%d 加入执行队列",[nextRequestItem requestId]]);
        }
    }
    [_lock unlock];
}

#pragma mark 总请求控制队列管理
-(void)addObjectToRequestArray:(id)object
{   [_netLock lock];
    [_requestArray addObject:object];
    [_netLock unlock];
}

-(void)removeObjectInRequestArray:(id)object
{
    [_netLock lock];
    [_requestArray removeObject:object];
    [_netLock unlock];
}

#pragma mark - 处理请求结果
-(void)handleResultWithReturnCode:(int)returnCode responseData:(NSData*)responseData requestItem:(RequestItem *)requestItem hasUpdate:(BOOL)hasUpdate
{
    requestItem.requestState = R_HandleResult;
    DataCenterDebugLog(DebugLogIncludeUrl, [NSString stringWithFormat:@"%d 网络请求结果:%@",[requestItem requestId],[self getReturnCodeDesc:returnCode]]);
    DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%d 开始处理请求结果",[requestItem requestId]]);
    if (returnCode == kRequestIsCanceled||requestItem.isCancelled)
    {
        DataCenterDebugLog(DebugLogIncludeUrl, [NSString stringWithFormat:@"%d 已取消 当前请求状态:%d  ",[requestItem requestId],[requestItem requestState]]);
        return;
    }
    if (!requestItem.needsResponse)
    {
        DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%d 完成请求, 不关心返回结果",[requestItem requestId]]);
        return;
    }
    if (returnCode == kRequestSuccess)
    {
        if (requestItem.isCancelled)
        {
            DataCenterDebugLog(DebugLogIncludeUrl, [NSString stringWithFormat:@"%d 已取消 当前请求状态:%d  ",[requestItem requestId],[requestItem requestState]]);
            return;
        }
        requestItem.requestState = R_ParseData;
        ResponseItem * returnItem = [ResponseItem responseItemWithRequestItem:requestItem returnCode:returnCode responseJSONData:responseData];
        returnItem.hasUpdate = hasUpdate;
        if (requestItem.targetCenter && [requestItem.targetCenter respondsToSelector:requestItem.mainParserMethod])
        {
            DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%@ 调用 %@",requestItem.targetCenter,NSStringFromSelector(requestItem.mainParserMethod)]);
            [requestItem.targetCenter performSelector:requestItem.mainParserMethod withObject:returnItem];
            
        }
        else
        {
            DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%@ 无法响应 %@",requestItem.targetCenter,NSStringFromSelector(requestItem.parseMethod)]);
        }
        return;
    }
    ResponseItem * returnItem = [ResponseItem responseItemWithRequestItem:requestItem returnCode:returnCode responseJSONData:responseData];
    returnItem.hasUpdate = hasUpdate;
    if (requestItem.targetCenter && [requestItem.targetCenter respondsToSelector:requestItem.parseMethod])
    {
        DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%@ 调用 %@",requestItem.targetCenter,NSStringFromSelector(requestItem.parseMethod)]);
        [requestItem.targetCenter performSelector:requestItem.parseMethod withObject:returnItem];
    }
    else
    {
        DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%@ 无法响应 %@",requestItem.targetCenter,NSStringFromSelector(requestItem.parseMethod)]);
    }
}

#pragma mark 清理请求缓存相关
- (void) clearASICacheWithUrl:(NSString * )url
{
    NSURL * theUrl = [NSURL URLWithString:url];
    [[ASIDownloadCache sharedCache] removeCachedDataForURL:theUrl];
}

- (void)clearCache
{
    [[ASIDownloadCache sharedCache] clearCachedResponsesForStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
}

//重建根目录
- (void)rebuildRootDirectory
{
    [[ASIDownloadCache sharedCache] rebuildRootDirectory];
}

#pragma mark 取消请求事件
- (void)cancelRequestInWaitingQueueWithRequestID:(int)requestID
{
    if (_waitingItems == nil)
    {
        _waitingItems = [[NSMutableArray alloc] init];
        return;
    }
    if ([_waitingItems count]==0)
    {
        return;
    }
    NSArray * theWaitingArray = [NSArray arrayWithArray:_waitingItems];
    for (RequestItem * request in theWaitingArray)
    {
        if (request.requestId == requestID)
        {
            request.isCancelled = YES;
            
            [_waitingItems removeObject:request];
            DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%d 已在等待队列中删除",[request requestId]]);
            break;
        }
    }
}

- (void)cancelRequestInLoadingQueueWithRequestID:(int)requestID
{
    if (_loadingItems == nil)
    {
        _loadingItems = [[NSMutableArray alloc] init];
        return;
    }
    if ([_loadingItems count]==0)
    {
        return;
    }
    NSArray *ops = [NSArray arrayWithArray: _requestQueue.operations];
    for (DataRequestOperation * op in ops)
    {
        if (op.requestItem.requestId == requestID)
        {
            op.requestItem.isCancelled = YES;
            if (op.requestItem.requestState < R_BeginASINetwork) {
                [op cancel];
            }
            else
            {
                [self cancelNetRequestWithRequestID:op.requestItem.requestId];
                [op cancel];
            }
            break;
        }
    }
}

- (void)cancelRequestInWaitingQueue:(id)sender
{
    NSArray * theWaitingArray = [NSArray arrayWithArray:_waitingItems];
    for (RequestItem * request in theWaitingArray)
    {
        if (request.delegateTarget == sender)
        {
            [_waitingItems removeObject:request];
            DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%d 已在等待队列中删除",[request requestId]]);
        }
    }
}

- (void)cancelRequestInLoadingQueue:(id)sender
{
    if (_loadingItems == nil)
    {
        _loadingItems = [[NSMutableArray alloc] init];
        return;
    }
    if ([_loadingItems count]==0)
    {
        return;
    }
    NSArray *ops = [NSArray arrayWithArray: _requestQueue.operations];
    for (DataRequestOperation * op in ops)
    {
        if (op.requestItem.delegateTarget == sender)
        {
            op.requestItem.isCancelled = YES;
            if (op.requestItem.requestState < R_BeginASINetwork) {
                [op cancel];
            }
            else
            {
                [self cancelNetRequestWithRequestID:op.requestItem.requestId];
            }
        }
    }
}

- (void)cancelNetRequestWithRequestID:(int)requestID
{
    CustomASIRequest * reqToCancel = nil;
    
    [_netLock lock];
    for (CustomASIRequest * request in _requestArray)
    {
        if (request.theRequestID == requestID)
        {
            reqToCancel = request;
            break;
        }
    }
    [_netLock unlock];
    
    if(reqToCancel)
    {
        [reqToCancel clearDelegatesAndCancel];
        [self removeObjectInRequestArray:reqToCancel];
        DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"[RequestID: %d] 调用ASI取消请求函数",requestID]);
    }
}

#pragma mark ***********外部调用***********
#pragma mark 设置Log日志输出
-(void)configDebugLogLv:(DataCenterDebugLogLevel)level
{
    self.debugLogLevel = level;
}

#pragma mark 主线程发送通知事件
- (void)postNotificationOnMainThread:(NSNotification*) notification
{
    [self performSelectorOnMainThread:@selector(postNotification:)
                           withObject:notification
                        waitUntilDone:YES];
}

#pragma mark 取消请求事件
-(void)cancelDataRequest:(id)sender
{
    [_lock lock];
    [self cancelRequestInWaitingQueue:sender];
    [self cancelRequestInLoadingQueue:sender];
    [_lock unlock];
}

-(void)cancelDataRequestWithRequestID:(int)requestID
{
    [_lock lock];
    [self cancelRequestInWaitingQueueWithRequestID:requestID];
    [self cancelRequestInLoadingQueueWithRequestID:requestID];
    [_lock unlock];
}

#pragma mark 获取错误码对应的提示
-(NSString *)getReturnCodeDesc:(kReturnCode)returnCode
{
    NSString * returnString = nil;
    switch (returnCode)
    {
        case kRequestSuccess:
            returnString = @"请求成功";
            break;
        case kRequestNoData:
            returnString = @"请求成功,但是没有数据";
            break;
        case kRequestCacheError:
            returnString = @"缓存错误";
            break;
        case kRequestUnknowError:
            returnString = @"未知错误";
            break;
        case kRequestValidateError:
            returnString = @"验证失败";
            break;
        case kRequestNetworkError:
            returnString = @"当前网络不可用,请检查您的网络设置";
            break;
        case kRequestTimeOut:  //连接超时
//            returnString = @"连接超时";
            returnString = @"您的网络不给力,请稍后再试";
            break;
        case kRequestASIError:
            returnString = @"ASI内部Error";
            break;
        case kRequestIsCanceled:
            returnString = @"请求被取消";
            break;
        case kRequestBadRequest:
            returnString = @"语法错误导致请求失败:400";
            break;
        case kRequestUnauthorized:
            returnString = @"请求需要验证：401";
            break;
        case kRequestServerSuddenlyShutDown:
            returnString = @"服务突然中断";
            break;
        case kRequestAuthenticationError:
            returnString = @"服务已经验证但拒绝执行：403";
            break;
        case kRequestPageNotFound:
            returnString = @"找不到服务:404";
            break;
        case kRequestServerInternalError:
            returnString = @"服务器内部错误:500";
            break;
        case kRequestServerNotImplemented:
            returnString = @"不支持当前服务:501";
            break;
        case kRequestServerDataInvalid:
            returnString = @"请求成功但服务器数据异常";
            break;
        case kRequestUrlBuildError:
            returnString = @"请求地址格式不正确";
            break;
        default:
            returnString = [NSString stringWithFormat:@"%d",returnCode];
            break;
    }
    return returnString;
}

#pragma mark ***********内部处理***********
#pragma mark  错误码转换
- (kReturnCode)mapReturnCodeWithASIHttpRequest:(ASIHTTPRequest *)request
{
    int errorCode = [request.error code];
    kReturnCode code = kRequestSuccess;
    switch (errorCode)
    {
        case ASIConnectionFailureErrorType:
            code = kRequestNetworkError;
            break;
        case ASIRequestTimedOutErrorType:
            code = kRequestTimeOut;
            break;
        case ASIAuthenticationErrorType:
            code = kRequestAuthenticationError;
            break;
        case ASIRequestCancelledErrorType:
            code = kRequestIsCanceled;
            break;
        case ASIFileManagementError:
            code = kRequestCacheError;
            break;
        case ASIUnhandledExceptionError:
            code = kRequestASIError;
            break;
        case ASIHttpStateError:
            code = [self mapReturnCodeWithHttpStateCode:request.responseStatusCode];
            break;
        case ASIInternalErrorWhileBuildingRequestType:
            code = kRequestUrlBuildError;
            break;
        default:
            code = errorCode;
            break;
    }
    return code;
}

- (kReturnCode)mapReturnCodeWithHttpStateCode:(NSInteger)stateCode
{
    kReturnCode code = kRequestSuccess;
    switch (stateCode)
    {
        case 400:
            code = kRequestBadRequest;
            break;
        case 401:
            code = kRequestUnauthorized;
            break;
        case 403:
            code = kRequestAuthenticationError;
            break;
        case 404:
            code = kRequestPageNotFound;
            break;
        case 500:
            code = kRequestServerInternalError;
            break;
        case 501:
            code = kRequestServerNotImplemented;
            break;
        default:
            code = stateCode;    //如果请求过程中服务突然中断，此时会返回ASIHttpStateError 但是此时的ResponseHeaders 返回的值仍然为200 所以向界面返回200 但是仍然认为是错误的请求
            break;
    }
    return code;
}

#pragma mark 功能方法
- (void)postNotification:(NSNotification *)note
{
	[[NSNotificationCenter defaultCenter] postNotification:note];
}

-(NSString *)converDictToString:(NSDictionary *)dict
{
    if (!dict)
    {
        DataCenterDebugLog(DebugLogBasicError, @"converDictToString,dict不能为空");
        return nil;
    }
    NSMutableString * converString = [NSMutableString string];
    NSArray * keyArray = [dict allKeys];
    for (id key in keyArray)
    {
        if (converString.length==0)
        {
            [converString appendFormat:@"?%@=%@",key,[dict objectForKey:key]];
        }
        else{
            [converString appendFormat:@"&%@=%@",key,[dict objectForKey:key]];
        }
    }
    DataCenterDebugLog(DebugLogIncludeData, [NSString stringWithFormat:@"converDictToString:%@",converString]);
    return converString;
}

#pragma mark - Manager OperationQueue
- (void)initRequestOperationQueue
{
    self.maxThreadConntForWifi = DEFAULT_MAX_POOL_THREAD_COUNT_WIFI;
    self.maxThreadConntFor3G = DEFAULT_MAX_POOL_THREAD_COUNT_3G;
    
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    self.requestQueue = queue;
    
    self.loadingItems = [NSMutableArray array];
    self.waitingItems = [NSMutableArray array];
    
    [self setMaxThreadCountByReachability:nil];
    _requestArray = [[NSMutableArray alloc] init];
    _netLock = [[NSLock alloc] init];
    _lock = [[NSLock alloc] init];
}


#pragma mark -
-(void)dealloc
{
    [_requestQueue cancelAllOperations];
    
    [_netLock lock];
    [_netLock unlock];
    
    [_lock lock];
    [_lock unlock];
}
@end
