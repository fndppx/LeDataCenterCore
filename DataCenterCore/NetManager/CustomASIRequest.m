//
//  CustomASIRequest.m
//  DataCenter
//
//  Created by cc on 12-11-1.
//  Copyright (c) 2012年 CC. All rights reserved.
//

#import "CustomASIRequest.h"
#import "ASIDownloadCache.h"
#import "ASIHTTPRequest.h"
#import "RequestItem.h"


@implementation CustomASIRequest

+ (id)requestWithItem:(id)item
{
    RequestItem * rItem = (RequestItem *)item;
    NSURL * url = [NSURL URLWithString:rItem.finalRequestUrl];
    [CustomASIRequest setShouldUpdateNetworkActivityIndicator:NO];
    CustomASIRequest * request = [[CustomASIRequest alloc] initWithURL:url];
    [request setUseCookiePersistence:NO];
    request.theRequestID = (int)rItem.requestId;
    //SSL相关配置
    if (rItem.enableSSL)
    {
        [request setValidatesSecureCertificate:NO];
        [request setSSLSecurityLevel:(CFStringRef*)kCFStreamSocketSecurityLevelSSLv3];
    }
    //
    request.shouldAttemptPersistentConnection = NO;
    request.shouldContinueWhenAppEntersBackground  = NO;
    request.timeOutSeconds = rItem.maxTimeOut;
    return request;
}

-(void)addPostDict:(NSDictionary *)postDict
{
    if (!postDict)
    {
        return;
    }
    NSArray * keyArray = [postDict allKeys];
    for (id key in keyArray)
    {
        [self setPostValue:[postDict objectForKey:key] forKey:key];
    }
}

-(void)addRequestHeaderDict:(NSDictionary*)headerDict
{
    NSArray * keyArray = [headerDict allKeys];
    for (id key in keyArray)
    {
        [self addRequestHeader:key value:[headerDict objectForKey:key]];
    }
}

#pragma mark -


@end
