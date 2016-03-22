//
//  RequestItem.h
//  DataCenter
//
//  Created by cc on 12-10-25.
//  Copyright (c) 2012年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StaticValues.h"
#import "ASIDownloadCache.h"

//使用测试数据标识
//#define kTestJSONString  @"kTestJSONString"

@interface RequestItem : NSObject
{
/*
    //逻辑层请求DataCenter的参数
    HttpMethodType httpMethodType;
    NSString * requestId;//请求标识
    NSDictionary * requestHeader;//请求头
    NSDictionary * paramDict;//参数
    NSDictionary * postParamDict;//POST区域的参数
    NSData * postFileData;//post数据
    NSString * postFilePath;//post数据的本地路径
    NSString * postFileKey;//post文件的key
    id delegateTarget;//代理响应对象
    NSString * notificationName;
    SEL requestSuccessSEL;
    SEL requestFailSEL;
    BOOL isUseNotific;//是否使用通知
    BOOL isNeedHead;//是否需要传head，默认YES
    
    //DataCenter请求NetworkManager参数
    NSString * requestUrl;
    id targetCenter;//响应事件的DataCenter
    SEL parseMethod;//对应解析方法
    
    NSString * finalRequestUrl;//最终请求的地址
*/
    Class _delegateOriginalClass;//用来标识初始化时赋值的delegate
}
@property (nonatomic,assign) BOOL getDataFromCache;                    // 是否需要从缓存中读取数据
@property (nonatomic,assign) BOOL isCancelled;                         //取消该请求
@property (nonatomic,assign) BOOL isReadingCache;                      //本次是否是读取缓存数据
@property (nonatomic,assign) BOOL needsCacheResponse;                  // 是否需要缓存数据
@property (nonatomic,assign) BOOL needsResponse;                       // 是否需要回调
@property (nonatomic,assign) HttpMethodType httpMethodType;            //请求方式get,post
@property (nonatomic,assign) NSInteger requestId;
@property (nonatomic,assign) RequestProcess requestState;
@property (nonatomic,assign) SEL mainParserMethod;                     //公共解析方法
@property (nonatomic,assign) SEL parseMethod;
@property (nonatomic,assign) SEL requestFailSEL;
@property (nonatomic,assign) SEL requestSuccessSEL;
@property (nonatomic,assign) SEL targetCenterParser;                   //对返回数据做解析的方法名称
@property (nonatomic,assign) int cacheSecond;                          // 缓存的时间
@property (nonatomic,assign) int maxTimeOut;
@property (nonatomic,assign) int page;
@property (nonatomic,assign) int totalCount;
@property (nonatomic,assign) int totalPage;
@property (nonatomic,assign) kRequestCachePolicy cachePolicy;          // 缓存的策略
@property (nonatomic,strong) NSData * postFileData;
@property (nonatomic,strong) NSDictionary * requestHeader;
@property (nonatomic,strong) NSDictionary *userInfoDict;
@property (nonatomic,strong) NSMutableDictionary * paramDict;
@property (nonatomic,strong) NSMutableDictionary * postParamDict;
@property (nonatomic,strong) NSString * finalRequestUrl;
@property (nonatomic,strong) NSString * postFileKey;
@property (nonatomic,strong) NSString * postFilePath;
@property (nonatomic,strong) NSString * requestUrl;
@property (nonatomic,weak)   ASIDownloadCache * customerCache;         // 自定义缓存的Cache
@property (nonatomic,weak)   id delegateTarget;
@property (nonatomic,weak)   id targetCenter;
@property (nonatomic,assign) BOOL enableSSL; //是否使用加密套接字协议层传输,默认NO

/*
 初始化方法
 */
- (id)initWithRequestUrl:(NSString *)url getParamDict:(NSDictionary *)dict target:(id)target successSEL:(SEL)successSEL failSEL:(SEL)failSEL;//get
- (id)initWithRequestUrl:(NSString *)url postParamDict:(NSDictionary *)dict target:(id)target successSEL:(SEL)successSEL failSEL:(SEL)failSEL;//post

/*
 设置POST参数属性
 */
- (void)setPOSTAttributesOfFileData:(NSData *)fileData postFileKey:(NSString *)key;
- (void)setPOSTAttributesOfFilePath:(NSString *)filePath postFileKey:(NSString *)key;

/*
 设置缓存策略
 */
- (void)setCurrentCachePolicy:(kRequestCachePolicy)cachePolicy;

/*
 设置HTTP请求头部参数
 */
- (void)setCurrentRequestHeader:(NSDictionary *)headerDict;
- (NSDictionary *)currentRequestHeader;

/*
 设置响应请求结束回调解析的Target和方法
 */
- (void)setCenterTarget:(id)target parseSEL:(SEL)parseSEL;

/*
 逻辑对比判断
 */
+ (RequestItem *)isMutableArray:(NSMutableArray *)array containsRequestItem:(RequestItem*)requestItem;


@end
