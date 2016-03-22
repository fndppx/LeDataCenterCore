//
//  NSObjectAdditions.h
//  Utility
//
//  Created by Tiger Xia on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NSObjectAdditions)

- (void)performSelectorInGCDThread:(SEL)aSelector withObject:(id)arg;
- (void)performSelectorInGCDMainThread:(SEL)aSelector withObject:(id)arg;

//检查object对象是否为空，是否是字典
- (BOOL)isNSDictionary;
//检查object对象是否为空，是否是数组
- (BOOL)isNSArray;
@end

