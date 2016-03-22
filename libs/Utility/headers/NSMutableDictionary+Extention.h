//
//  NSMutableDictionary+Extention.h
//  Utility
//
//  Created by Jimmiry on 13-1-8.
//  Copyright (c) 2013年 guagua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Extention)
- (void)checkDictionary:(NSDictionary *)dictionary
        setObjectForKey:(id <NSCopying>)aKey;
@end
