//
//  DataCenter.m
//  DataCenter
//
//  Created by cc on 12-10-25.
//  Copyright (c) 2012年 CC. All rights reserved.
//

#import "DataCenter.h"
#import "DataParser.h"
#import "M9Singleton.h"
#import "NSObjectAdditions.h"
#import "NSStringExtend.h"
#import "DataCaches.h"


@interface DataCenter ()

@end


@implementation DataCenter


static DataCenter *sharedDataCenter = nil;

+ (DataCenter *)sharedDataCenter{
    
    @synchronized(self)
    {
        if (sharedDataCenter == nil)
        {
            sharedDataCenter = [[self alloc] init];
        }
    }
    return sharedDataCenter;
}

- (id)init
{
    self = [super init];
    if (self)
    {

    }
    return self;
}

//检查网络状态
-(BOOL)checkNetIsEnable
{
    
    return [[NetworkManager sharedNetManager] checkNetIsEnable];
}

#pragma mark 数据解析
/*
 需要更新对应的错误码所对应的errorInfo
 希望下一个app，服务端能够提供有效的错误码机制
 */

- (ResponseItem *)parseReturnData:(ResponseItem *)item
{
    if (item.responseDict)
    {
        NSString * state = [NSString stringWithObject:[item.responseDict objectForKey:@"state"]];
        NSDictionary * dict = item.responseDict;
        item.state = [state intValue];
        item.debugMessage = [NSString stringWithObject:[item.responseDict objectForKey:@"message"]];
        item.alertMessage = [NSString stringWithObject:[item.responseDict objectForKey:@"alertMessage"]];
        if ([state isEqualToString:@"0"]||[state isEqualToString:@"000000"])
        {
            item.returnCode = kRequestSuccess;
        }
        else
        {
            //请求失败清除当前缓存
            [self clearCacheWithUrl:item.requestItem.requestUrl];
            [self clearCacheWithUrl:item.requestItem.finalRequestUrl];
            item.returnCode = kRequestServerReturnError;
        }
        id content = [dict objectForKey:@"content"];
        if ([content isNSDictionary])
        {   //page:{“current_page”: 2, “total_page”:20}
            item.responseDict = [NSDictionary dictionaryWithDictionary:content];
            id page = [content objectForKey:@"page"];
            if ([page isNSDictionary])
            {
                NSString * pageStr = [NSString stringWithObject:[page objectForKey:@"curpage"]];
                NSString * totalPageStr = [NSString stringWithObject:[page objectForKey:@"totalpage"]];
                NSString * totalCount = [NSString stringWithObject:[page objectForKey:@"totalCount"]];
                if (pageStr&&pageStr.length!=0)
                {
                    item.requestItem.page = [[NSString stringWithFormat:@"%@",pageStr] intValue];
                }
                if (totalPageStr&&totalPageStr.length!=0)
                {
                    item.requestItem.totalPage = [[NSString stringWithFormat:@"%@",totalPageStr] intValue];
                }
                if (totalCount&&totalCount.length!=0)
                {
                    item.requestItem.totalCount = [[NSString stringWithFormat:@"%@",totalCount] intValue];
                }
            }
        }
    }
    else
    {
        if (item.requestItem.isReadingCache)//本次是读取缓存数据
        {
            item.returnCode = kRequestSuccess;
            return item;
        }
        item.debugMessage = @"服务器连接失败,请稍候重试";
        item.alertMessage = @"服务器连接失败,请稍候重试";
        [self clearCacheWithUrl:item.requestItem.requestUrl];
        [self clearCacheWithUrl:item.requestItem.finalRequestUrl];
        item.returnCode = kRequestServerReturnError;
    }
    return item;
}

#pragma mark 公共Post参数
- (NSDictionary *)commonPostDict
{
    return [[NetConfiguration sharedNetConfig] commonRequestHeaders];
}

#pragma mark 公共数据解析函数
-(void)mainParserReturnData:(ResponseItem *)item
{
    if ([self respondsToSelector:item.requestItem.targetCenterParser])
    {
        ResponseItem * responseItem = [self performSelector:item.requestItem.targetCenterParser withObject:item];
        [self performSelector:item.requestItem.parseMethod withObject:responseItem];
    }
    else
    {
        [self performSelector:item.requestItem.parseMethod withObject:item];
    }
}

//请求事件
- (int)sendRequestWithRequestItem:(RequestItem *)item
{
    item.isReadingCache = NO;//是否是只读取本地缓存
    //公共解析返回方法
    item.mainParserMethod = @selector(mainParserReturnData:);
    return [[NetworkManager sharedNetManager] sendRequestWithRequestItem:item];
}

// 获取本地数据缓存
- (void)sendGetLocalCacheWithRequestItem:(RequestItem *)item
{
    item.isReadingCache = YES;//是否是只读取本地缓存
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (item.paramDict)
        {
            item.finalRequestUrl = [NSString stringWithFormat:@"%@%@",item.requestUrl,[[NetworkManager sharedNetManager] converDictToString:item.paramDict]];
        }
        else{
            item.finalRequestUrl = [NSString stringWithFormat:@"%@",item.requestUrl];
        }
        item.finalRequestUrl = [item.finalRequestUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        ResponseItem * returnItem = [ResponseItem responseItemWithRequestItem:item returnCode:kRequestSuccess responseJSONData:[DataCaches cacheDataWithRequestUrl:item.finalRequestUrl]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self mainParserReturnData:returnItem];
        });
    });    
}

//取消请求事件
-(void)cancelDataRequest:(id)sender
{
    [[NetworkManager sharedNetManager] cancelDataRequest:sender];
}

- (void)cancelDataRequestWithRequestID:(int)requestID
{
    [[NetworkManager sharedNetManager] cancelDataRequestWithRequestID:requestID];
}

// 手动清除ASI所有缓存
- (void)clearCache
{
    [[NetworkManager sharedNetManager] clearCache];
}

// 清除指定请求的缓存
- (void)clearCacheWithUrl:(NSString * )url
{
    [[NetworkManager sharedNetManager] clearASICacheWithUrl:url];
}

- (void)clearCacheWithResponseItem: (ResponseItem *)responseItem
{
    RequestItem * item = responseItem.requestItem;
    if (item)
    {
        [self clearCacheWithRequestItem:item];
    }
}

- (void)clearCacheWithRequestItem: (RequestItem *)requestItem
{
    NSString * url = requestItem.finalRequestUrl;
    if (url)
    {
        [[NetworkManager sharedNetManager] clearASICacheWithUrl:url];
    }
}

//设置Log输出等级,默认无输出
- (void)configDebugLogLv:(DataCenterDebugLogLevel)level
{
    return [[NetworkManager sharedNetManager] configDebugLogLv:level];
}

// 获取关于ReturnCode的描述
- (NSString *)getReturnCodeDesc:(kReturnCode)returnCode
{
    return [[NetworkManager sharedNetManager] getReturnCodeDesc:returnCode];
}

- (BOOL)isEmptyResponse:(NSString *)responseString
{
    if (!responseString||[responseString isEqualToString:@"{}"]||[responseString isEqualToString:@"[]"]||[responseString isEqualToString:@"{ }"]|| [responseString isEqualToString:@"[ ]"]||[responseString isEqualToString:@"()"]||[responseString isEqualToString:@"( )"])
    {
        return YES;
    }
    return NO;
}

-(BOOL) isErrorResponse:(NSString *)responseString
{
    if ([responseString isEqualToString:@"[null]"]||[responseString isEqualToString:@"{null}"]||[responseString isEqualToString:@"null"]||[responseString isEqualToString:@"(null)"])
    {
        return YES;
    }
    return NO;
}

#pragma mark 发送数据
-(void)sendFailResponseData:(ResponseItem *)item
{
    if (item.requestItem.isCancelled)
    {
        DataCenterDebugLog(DebugLogIncludeUrl, [NSString stringWithFormat:@"%d 已取消 当前请求状态:%d  ",[item.requestItem requestId],[item.requestItem requestState]]);
        return;
    }
    //给上层传一个简单的Item即可
    ResponseItem * currentItem = [ResponseItem simpleResponseItemWithResponseItemData:item];
    //
    if (currentItem.requestItem.delegateTarget && [currentItem.requestItem.delegateTarget respondsToSelector:currentItem.requestItem.requestFailSEL])
    {
        DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%@ 调用 %@",currentItem.requestItem.delegateTarget,NSStringFromSelector(currentItem.requestItem.requestFailSEL)]);
        //当前已经是主线程，需要立即执行
        [currentItem.requestItem.delegateTarget performSelectorOnMainThread:currentItem.requestItem.requestFailSEL withObject:currentItem waitUntilDone:[NSThread isMainThread]];
    }
    else
    {
        DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%@ 无法响应 %@",currentItem.requestItem.delegateTarget,NSStringFromSelector(currentItem.requestItem.requestFailSEL)]);
    }
}

-(void)sendSuccessResponseData:(ResponseItem *)item
{
    if (item.requestItem.isCancelled)
    {
        DataCenterDebugLog(DebugLogIncludeUrl, [NSString stringWithFormat:@"%d 已取消 当前请求状态:%d  ",[item.requestItem requestId],[item.requestItem requestState]]);
        return;
    }
    //给上层传一个简单的Item即可
   ResponseItem * currentItem = [ResponseItem simpleResponseItemWithResponseItemData:item];
    if (currentItem.requestItem.delegateTarget && [currentItem.requestItem.delegateTarget respondsToSelector:currentItem.requestItem.requestSuccessSEL])
    {
        DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%@ 调用 %@",currentItem.requestItem.delegateTarget,NSStringFromSelector(currentItem.requestItem.requestSuccessSEL)]);
        //当前已经是主线程，需要立即执行
        [currentItem.requestItem.delegateTarget performSelectorOnMainThread:currentItem.requestItem.requestSuccessSEL withObject:currentItem waitUntilDone:[NSThread isMainThread]];
    }
    else
    {
        DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%@ 无法响应 %@",currentItem.requestItem.delegateTarget,NSStringFromSelector(currentItem.requestItem.requestSuccessSEL)]);
    }
}


@end
