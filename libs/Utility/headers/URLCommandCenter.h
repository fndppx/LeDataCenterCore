//
//  URLCommandCenter.h
//  iTest
//
//  Created by Wills on 10-12-15.
//  Copyright 2010 Finalist. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "URLCommand.h"

@protocol URLCommandCenterDelegate;


@interface URLCommandCenter : NSObject

// delegate
@property(nonatomic, readwrite, assign) id<URLCommandCenterDelegate> delegate;
- (BOOL)canDelegateExecuteCommand:(URLCommand *)command;

// notification
- (void)addObserver:(id)observer selector:(SEL)selector;
- (void)removeObserver:(id)observer;

// execute
- (void)executeCommand:(URLCommand *)command;

// singleton
+ (URLCommandCenter *)sharedURLCommandCenter;

@end


#pragma mark -

@protocol URLCommandCenterDelegate <NSObject>

// delegate method format: "${command}WithCommand:(URLCommand *)command"
// e.g. - (void)commandWithCommand:(URLCommand *)command;

@end

