//
//  RequestItem.m
//  DataCenter
//
//  Created by cc on 12-10-25.
//  Copyright (c) 2012年 CC. All rights reserved.
//

#import <objc/runtime.h>
#import "RequestItem.h"
#import "NetConfiguration.h"

////用来获取obj类的方法声明，获取的Class指针做为int型保存起来，需要4字节
//Class object_getClass(id object);

#define kDefault_MAX_RequestTimeOut       10

@interface RequestItem()


@end

@implementation RequestItem
@synthesize delegateTarget = _delegateTarget;

#pragma mark 内部初始化
- (id)init
{
    self = [super init];
    if (self)
    {
        _requestUrl = @"";
        _finalRequestUrl = @"";
        _postFilePath = nil;
        _postFileData = nil;
        _postFileKey = nil;
        _needsResponse = YES;
        _cachePolicy = kAlwaysAskForUpdate;
        _isReadingCache = NO;
        _enableSSL = NO;
        _maxTimeOut = kDefault_MAX_RequestTimeOut;
        _targetCenterParser = @selector(parseReturnData:);
        _requestHeader = [NSDictionary dictionaryWithDictionary:[[NetConfiguration sharedNetConfig] commonRequestHeaders]];
    }
    return self; 
}


#pragma mark  初始化方法

- (id)initWithRequestUrl:(NSString *)url getParamDict:(NSDictionary *)dict target:(id)target successSEL:(SEL)successSEL failSEL:(SEL)failSEL
{
    self = [self init];
    if (self)
    {
        self.httpMethodType = HttpMethodGet;
        self.requestUrl = url;
        if (dict)
        {
            self.paramDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        }
        self.delegateTarget = target;
        self.requestSuccessSEL = successSEL;
        self.requestFailSEL = failSEL;
    }
    return self;
}

- (id)initWithRequestUrl:(NSString *)url postParamDict:(NSDictionary *)dict target:(id)target successSEL:(SEL)successSEL failSEL:(SEL)failSEL
{
    self = [self init];
    if (self)
    {
        self.httpMethodType = HttpMethodGet;
        self.requestUrl = url;
        if (dict)
        {
            self.postParamDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        }
        self.delegateTarget = target;
        self.requestSuccessSEL = successSEL;
        self.requestFailSEL = failSEL;
    }
    return self;
}


#pragma mark  设置POST参数属性

- (void)setPOSTAttributesOfFileData:(NSData *)fileData postFileKey:(NSString *)key
{
    _postFileData = [NSData dataWithData:fileData];
    _postFileKey = key;
}

- (void)setPOSTAttributesOfFilePath:(NSString *)filePath postFileKey:(NSString *)key
{
    _postFilePath = filePath;
    _postFileKey = key;
}


#pragma mark  设置缓存策略

- (void)setCurrentCachePolicy:(kRequestCachePolicy)cachePolicy
{
    _cachePolicy = cachePolicy;
}

#pragma mark  设置HTTP请求头部参数

- (void)setCurrentRequestHeader:(NSDictionary *)headerDict
{
    _requestHeader = [NSDictionary dictionaryWithDictionary:headerDict];
}

- (NSDictionary *)currentRequestHeader
{
    return self.requestHeader;
}


#pragma mark 设置响应请求结束回调解析的Target和方法

- (void)setCenterTarget:(id)target parseSEL:(SEL)parseSEL
{
    _targetCenter = target;
    _parseMethod = parseSEL;
}

#pragma mark 外部调用
+ (RequestItem *)isMutableArray:(NSMutableArray *)array containsRequestItem:(RequestItem*)requestItem
{
    if (!array || ! requestItem)
    {
        return nil;
    }
    for (id object in array)
    {
        RequestItem * request = (RequestItem *)object;
        if ([requestItem.requestUrl isEqualToString:request.requestUrl] && requestItem.delegateTarget == request.delegateTarget)
        {
            if (requestItem.httpMethodType !=HttpMethodPost)
            {
                return request;
            }
        }
    }
	return nil;
}

#pragma mark 重载的方法
//以下两个方法，增加了对delegate的判断
//在set方法中，取得赋值的delegate的class类型，在get方法中，对当前的类型进行判断，如果前后两个类型不相等，则返回空，相等的话，返回本身
- (void)setDelegateTarget:(id)delegateTarget
{
    if (_delegateTarget != delegateTarget)
    {
        _delegateTarget = nil;
        _delegateTarget = delegateTarget;
    }

    _delegateOriginalClass = object_getClass(delegateTarget);
}

- (id)delegateTarget
{
    Class currentClass = object_getClass(_delegateTarget);
    
    if (currentClass == _delegateOriginalClass) {
        return _delegateTarget;
    }
    else {
        return nil;
    }
}

#pragma mark Dealloc
@end
