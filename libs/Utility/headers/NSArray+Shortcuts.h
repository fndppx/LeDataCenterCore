//
//  NSArray+Shortcuts.h
//  SoHuHDVideo
//
//  Created by MingLQ on 2011-08-04.
//  Copyright 2011 SOHU. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (Shortcuts)

@property (nonatomic, readonly, assign) NSUInteger count;
@property (nonatomic, readonly, retain) id firstObject;
@property (nonatomic, readonly, retain) id lastObject;

- (id) objectOrNilAtIndex:(int)index;
- (BOOL) containsIndex:(int)index;

@end


@interface NSMutableArray (Shortcuts)

- (void) addObjectOrNil:(id)anObject;
- (void) insertObjectOrNil:(id)anObject atIndex:(NSUInteger)index;

@end


#pragma mark -

@interface NSArray (random)

/**
 * 随机从数组中抽取一个元素对象。
 */
- (id) anyObject;
/**
 * 将传入数组进行乱序
 */
+ (NSArray*) randomOrderWithArray:(NSArray*)array;

// 生成一个根据某个key来对保存在NSArray中的对象进行排序的数组
- (NSArray*)sortArrayByKey:(id)key inAscending:(BOOL)ascending;

@end


@interface NSMutableArray (random)

/**
 * 将一个可变数组的元素随即排序。
 */
- (void) reRandomOrder;

@end

