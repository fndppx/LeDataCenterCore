//
//  TimeHelper.h
//  Utility
//
//  Created by cc on 12-12-28.
//  Copyright (c) 2012年 guagua. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
  负责计算代码运行时间
 -(id)initWithTips:(NSString *)tips;//tips需要的提示
 你的代码
 [TimeHelper的对象 release];
 查看Log
 */
@interface TimeLossHelper : NSObject


-(id)initWithTips:(NSString *)tips;

@end
