//
//  NSStringExtend.h
//  fushihui
//
//  Created by jinzhu on 10-8-11.
//  Copyright 2010 Sharppoint Group All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kMAX_NUM_LIMITE 999999

#pragma mark -
@interface NSString(ExtendedForUrlComponents)
- (NSString *)stringByAppendingUrlComponent:(NSString *)urlComponent;
- (NSString *)stringByAppendingUrlParameter:(NSString *)param forKey:(NSString *)key;
- (NSString *)stringbyDeletingUrlParameter:(NSString *)key;
- (NSString *)stringByAddPrefix:(NSString *)prefix;

- (NSString *)stringByReplaceUrlHost:(NSString *)newHost;
- (BOOL)isAppUrlString;
- (BOOL)isNmuberString;
- (BOOL)isEmailString;
@end



#pragma mark -
@interface NSString(URLEncodeExtended)

+ (NSString*)stringWithStringEncodeUTF8:(NSString *)strToEncode;
- (NSString *)encodedUTF8String;
- (NSString *)decodedUTF8String;

+ (NSString*)stringWithStringUrlEncoded:(NSString *)strToEncode usingEncoding:(NSStringEncoding)encoding;
- (NSString *)urlEncodedStringUsingEncoding:(NSStringEncoding)encoding;
- (NSString *)urlEncodedUsingCFStringEncoding:(CFStringEncoding)cfencoding;
- (NSString *)urlEncodedUsingCFStringEncoding:(CFStringEncoding)cfencoding alreadyPercentEscaped:(BOOL)percentEscaped;
@end


#pragma mark -
@interface NSString(MD5Extended)
+ (NSString *)stringWithUUIDGenerated;
+ (NSString *)generatingMD5:(NSArray *)array;

//added ypc
- (NSString*)md5Hash;
@end

#pragma mark -
@interface NSString(StringCount)
- (int)getChineseStringLength:(NSString*)strtemp;

/**
 *	@brief	以两个字节为一个字，来计算字符的个数
 *
 *	@return	字符个数（如果是“一”，返回1.0；如果是“一a”，返回1.5；如果是“一ab”，返回2.0）
 */
- (float)chineseLength;

@end

#pragma mark -
@interface NSString(Base64Extended)
- (NSString*)base64Encoding;
- (NSString*)base64Decoding;

@end


#pragma mark -
@interface NSString (CoreTextExtention)
- (NSArray *)splitStringWithFont:(UIFont *)font constrainedToWidth:(CGFloat)lineWidth;
@end


#pragma mark -
@interface NSString (WhitespaceExtention)
- (id) trimmedString;
- (BOOL)isWhitespaceAndNewlines;
- (BOOL)isEmptyOrWhitespace;
@end



@interface NSString (FormatExtention)
+ (NSString *)stringFromTime:(CGFloat)time;
+ (NSString *)trimHourStringFromTime:(CGFloat)time;
+ (NSString *)stringWithNum:(id)num;
+ (NSString *)stringWithObject:(id)object;

+ (NSString *)stringWithFormatedFileSize:(int64_t)fileSize;

- (NSString *) formatCurrentTime;
- (NSInteger) secondsValue;    //支持00:00:00 或者 00:00 格式的时间

@end

@interface NSString (MatchesEmptyString)//匹配空字符串

+(BOOL)isBlankString:(NSString *)string;

@end

@interface NSString (AssignmentExtention)
/**返回正确的字符串
 *如果object为空或不是NSString，则返回string；否则，返回object
 */
+ (NSString *)stringWithObject:(id)object withOriginalString:(NSString *)string;
@end

@interface NSString (SubstringeExtention)

- (NSString *) subStringBetweenLeftStr:(NSString *) leftStr WithRightStr:(NSString *) rightStr;

@end

@interface NSString (DateExtention)

- (NSDate *) millisecondStrDate;

@end
