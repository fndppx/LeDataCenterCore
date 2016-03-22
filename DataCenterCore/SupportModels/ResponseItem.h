//
//  ResponseItem.h
//  DataCenter
//
//  Created by cc on 12-10-25.
//  Copyright (c) 2012年 CC. All rights reserved.
//

#import "RequestItem.h"

@interface ResponseItem : NSObject
{
    /*
    NSString * oriResponseString;//原始返回的JSON串
    NSDictionary * responseDict;//请求返回的字典数据
    RequestItem * requestItem;//请求时候的对象
    NSMutableArray * returnDataArray;//内存数据模型Item
    kReturnCode returnCode;//返回的错误码
    NSString * errorInfo;//错误码对应的信息
    */
}
@property(nonatomic,strong)NSString * oriResponseString;
@property(nonatomic,strong)NSDictionary * responseDict;
@property(nonatomic,strong)RequestItem * requestItem;
@property(nonatomic,strong)NSMutableArray * returnDataArray;
@property(nonatomic,assign)kReturnCode returnCode;
@property(nonatomic,strong)NSString * httpMessage;
@property(nonatomic,strong)NSString * debugMessage;
@property(nonatomic,strong)NSString * alertMessage;
@property(nonatomic,assign)BOOL hasUpdate;//数据是否更新，根据http304判断
@property(nonatomic,assign)NSInteger state;//移动代理返回的状态码


+ (ResponseItem * )responseItemWithRequestItem:(RequestItem *)requestItem
                                    returnCode:(kReturnCode)returnCode
                              responseJSONData:(NSData *)jsonData;
//获取一个简洁的ResponseItem，提供给上层使用
+ (ResponseItem *)simpleResponseItemWithResponseItemData:(ResponseItem *)responseItem;


@end

