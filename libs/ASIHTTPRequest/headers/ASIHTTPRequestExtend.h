//
//  ASIHTTPRequestExtend.h
//  ASIHTTPRequest
//
//  Created by cc on 12-11-12.
//
//

#import "ASIHTTPRequest.h"

@interface ASIHTTPRequest(CookiesExtend)


//增加RequestCookie的值
-(void)addRequestCookieValue:(NSString *)value
                      forKey:(NSString *)key
                    inDomain:(NSString *)currentDomain;
-(void)addRequestCookies:(NSArray *)cookies;
//将Cookies转换成Dict
-(NSDictionary *)responseCookiesAsDictionary;
//获取对应key的ResponseCookie的Value
-(NSString *)responseCookieValueForKey:(NSString *)key;

@end
