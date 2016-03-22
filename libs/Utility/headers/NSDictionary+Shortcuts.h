//
//  NSDictionary+Shortcuts.h
//  iM9
//
//  Created by iwill on 2011-05-20.
//  Copyright 2011 M9. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (Shortcuts)

// @see NSNumber - xxxxValue
//      TODO: ....
- (float)floatForKey:(id)aKey;
- (float)floatForKey:(id)aKey defaultValue:(float)defaultValue;
- (double)doubleForKey:(id)aKey;
- (double)doubleForKey:(id)aKey defaultValue:(double)defaultValue;
- (long long)longLongForKey:(id)aKey;
- (unsigned long long)unsignedLongLongForKey:(id)aKey;

// @see NSObjCRuntime.h
- (BOOL)boolForKey:(id)aKey;
- (NSInteger)integerForKey:(id)aKey;
- (NSInteger)integerOrNotFoundForKey:(id)aKey;
- (NSInteger)integerForKey:(id)aKey defaultValue:(NSInteger)defaultValue;
- (NSUInteger)unsignedIntegerForKey:(id)aKey;
- (NSUInteger)unsignedIntegerOrNotFoundForKey:(id)aKey;
- (NSUInteger)unsignedIntegerForKey:(id)aKey defaultValue:(NSUInteger)defaultValue;

// @see NSDictionary - (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
//      NSData, NSDate, NSNumber, NSString, NSArray, or NSDictionary
- (NSNumber *)numberForKey:(id)aKey;
- (NSString *)stringForKey:(id)aKey;
- (NSString *)stringOrEmptyStringForKey:(id)akey;
- (NSString *)stringForKey:(id)akey defaultValue:(NSString *)defaultValue;
- (NSArray *)arrayForKey:(id)aKey;
- (NSDictionary *)dictionaryForKey:(id)aKey;
- (NSDate *)dateForKey:(id)aKey;
- (NSData *)dataForKey:(id)aKey;
- (NSURL *)URLForKey:(id)aKey;

- (id)objectOfClass:(Class)class forKey:(id)aKey;
- (id)objectOfClass:(Class)class defaultValue:(id)defaultValue forKey:(id)aKey;

@end


@interface NSMutableDictionary (Shortcuts)

- (void)setBool:(BOOL)value forKey:(id)aKey;
- (void)setFloat:(float)value forKey:(id)aKey;
- (void)setDouble:(double)value forKey:(id)aKey;
- (void)setLongLong:(long long)value forKey:(id)aKey;
- (void)setUnsignedLongLong:(unsigned long long)value forKey:(id)aKey;

- (void)setInteger:(NSInteger)value forKey:(id)aKey;
- (void)setUnsignedInteger:(NSUInteger)value forKey:(id)aKey;

- (void)setObjectOrNil:(id)anObject forKey:(id)aKey;

@end


#pragma mark -

@interface NSDictionary (WebFormEncoded)

/**
 * 将要把字典内容转化为url参数字符串
 */
- (NSString *)webFormEncoded;

@end

