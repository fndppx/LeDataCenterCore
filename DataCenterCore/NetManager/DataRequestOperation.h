//
//  DataRequestOperation.h
//  DataCenter
//
//  Created by cc on 12-11-1.
//  Copyright (c) 2012年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestItem.h"

@interface DataRequestOperation : NSOperation

@property (nonatomic, strong) RequestItem * requestItem;

- (DataRequestOperation*)initWithRequestItem:(RequestItem *)requestItem;

@end
