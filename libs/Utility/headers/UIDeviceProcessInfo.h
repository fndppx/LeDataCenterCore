//
//  UIDeviceProcessInfo.h
//  TestProcessInfo
//
//  Created by Winston on 11-3-9.
//  Copyright 2011 Ruixin Online Ltd. All rights reserved.
//



#import <Foundation/Foundation.h>
#define kProcessIDKey   @"ProcessID"
#define kProcessNameKey @"ProcessName"

@interface UIDevice (ProcessesAdditions)
/*
 *获取当前运行的进程列表
 *数组中的数据为 NSDictonary ：结构为 {kProcessIDKey = processId,kProcessNameKey = processName}
 */

- (NSArray *)runningProcesses;
/*
 *传入需要过滤掉的系统进程名数组。
 *此数组由上层调用着传入
 */

- (NSArray *)runningProcessesFilterSomeProcesses:(NSArray*)systemProcesses;
@end
