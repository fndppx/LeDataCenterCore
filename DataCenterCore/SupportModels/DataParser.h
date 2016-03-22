//
//  DataParser.h
//  DataCenter
//
//  Created by cc on 12-10-25.
//  Copyright (c) 2012年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataParser : NSObject

+ (id)parseOpenAPIResult:(NSData *)responseData;

@end
