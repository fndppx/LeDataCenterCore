//
//  URLCommand.h
//  iTest
//
//  Created by Wills on 10-12-15.
//  Copyright 2010 Finalist. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface URLCommand : NSObject

@property(nonatomic, readonly, retain) NSURL *url;
@property(nonatomic, readonly, retain) NSString *scheme;
@property(nonatomic, readonly, retain) NSString *command;
@property(nonatomic, readonly, retain) NSString *commandType;
@property(nonatomic, readonly, retain) NSDictionary *parameters;
// @private, relative method selector of delegate
@property(nonatomic, readonly, assign) SEL selector;

- (id)initWithURL:(NSURL *)url;
- (id)initWithURLString:(NSString *)string;

+ (URLCommand *)commandWithURL:(NSURL *)url;
+ (URLCommand *)commandWithURLString:(NSString *)string;

@end

