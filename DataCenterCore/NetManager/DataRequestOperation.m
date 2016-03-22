//
//  DataRequestOperation.m
//  DataCenter
//
//  Created by cc on 12-11-1.
//  Copyright (c) 2012年 CC. All rights reserved.
//

#import "DataRequestOperation.h"
#import "NetworkManager.h"

@implementation DataRequestOperation


- (DataRequestOperation *)initWithRequestItem:(RequestItem *)requestItem
{
    self = [self init];
    if (self)
    {
        self.requestItem = requestItem;
    }
    
    return self;
}

-(void)main
{
    @autoreleasepool {
        self.requestItem.requestState =R_OperateOnThread;
        DataCenterDebugLog(DebugLogIncludeProcessStatus, [NSString stringWithFormat:@"%ld 开始执行DataRequestOperation",[self.requestItem requestId]]);
        if (self.isCancelled || self.requestItem.isCancelled)
        {
            DataCenterDebugLog(DebugLogIncludeUrl, [NSString stringWithFormat:@"%ld 已取消 当前请求状态:%d ",[self.requestItem requestId],[self.requestItem requestState]]);
        }
        else
        {
            self.requestItem.requestState = R_BeginASINetwork;
            [[NetworkManager sharedNetManager] sendNetRequestWithRequestItem:self.requestItem];
            self.requestItem.requestState = R_Finish;
            [[NetworkManager sharedNetManager] loadingFinished:self.requestItem];
        }
    }
    
}


#pragma mark -

@end
