//
//  ResponseItem.m
//  DataCenter
//
//  Created by cc on 12-10-25.
//  Copyright (c) 2012年 CC. All rights reserved.
//

#import "ResponseItem.h"
#import "DataParser.h"
#import "NetworkManager.h"

@interface ResponseItem()

#pragma mark 内部方法
- (ResponseItem *)initWithResponseItem:(ResponseItem *)responseItem;

- (ResponseItem * )initWithRequestItem:(RequestItem *)requestItem
                            returnCode:(kReturnCode)returnCode
                      responseJSONData:(NSData *)jsonData;

@end

@implementation ResponseItem

-(id)init
{
    self = [super init];
    if (self)
    {
        self.returnDataArray = [NSMutableArray array];
        self.state = 0;
    }
    return self;
}

#pragma mark 内部加载
- (ResponseItem *)initWithResponseItem:(ResponseItem *)responseItem
{
    self = [self init];
    if (self)
    {
        self.requestItem = responseItem.requestItem;
        self.debugMessage = responseItem.debugMessage;
        self.alertMessage = responseItem.alertMessage;
        self.httpMessage = responseItem.httpMessage;
        self.returnCode = responseItem.returnCode;
        self.returnDataArray = responseItem.returnDataArray;
        self.state = responseItem.state;
    }
    return self;
}

- (ResponseItem * )initWithRequestItem:(RequestItem *)requestItem
                            returnCode:(kReturnCode)returnCode
                      responseJSONData:(NSData *)jsonData
{
    self = [self init];
    if (self)
    {
//        NSLog(@"*****************%@**********",jsonData);
        NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        self.oriResponseString = jsonStr;
        self.requestItem = requestItem;
        self.returnCode = returnCode;
        self.httpMessage = [[NetworkManager sharedNetManager] getReturnCodeDesc:self.returnCode];
        self.alertMessage = [[NetworkManager sharedNetManager] getReturnCodeDesc:self.returnCode];
        id parserData = [DataParser parseOpenAPIResult:jsonData];//返回一个字典
        if (parserData&&[parserData isKindOfClass:[NSDictionary class]])
        {
            self.responseDict = [NSDictionary dictionaryWithDictionary:parserData];
        }
    }
    return self;
}

#pragma mark 外部调用
+ (ResponseItem * )responseItemWithRequestItem:(RequestItem *)requestItem
                                    returnCode:(kReturnCode)returnCode
                              responseJSONData:(NSData *)jsonData
{
    return [[self alloc] initWithRequestItem:requestItem returnCode:returnCode responseJSONData:jsonData];
}

+ (ResponseItem *)simpleResponseItemWithResponseItemData:(ResponseItem *)responseItem
{
    
    return [[self alloc] initWithResponseItem:responseItem];
}

#pragma mark -
@end
