//
//  CustomASIRequest.h
//  DataCenter
//
//  Created by cc on 12-11-1.
//  Copyright (c) 2012年 CC. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import "ASIHTTPRequestExtend.h"


@interface CustomASIRequest : ASIFormDataRequest

@property (nonatomic, assign) int theRequestID;


+ (id)requestWithItem:(id)item;
- (void)addPostDict:(NSDictionary *)postDict;
- (void)addRequestHeaderDict:(NSDictionary*)headerDict;


@end
