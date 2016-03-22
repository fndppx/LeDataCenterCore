//
//  M9Singleton.h
//  iM9
//
//  Created by iwill on 10-12-07.
//  Copyright 2010 M9. All rights reserved.
//


// clean
#ifdef M9SingletonImplement
    #undef M9SingletonImplement
#endif


/**
 * Defining singleton methods by M9SingletonImplement($sharingMethod) in the implementation file.
 *      $sharingMethod: The method name obtain the sharedInstance, it should be declared in the header file.
 * e.g.
 *  App.h
 *      @interface App
 *      + (App *)sharedApp;
 *      @end
 *  App.m
 *      @implementation App
 *      M9SingletonImplement(sharedApp);
 *      - (id)init {
 *          ....
 *          return self;
 *      }
 *      @end
 */
#define M9SingletonImplement($sharingMethod)\
\
/* M9Singleton implementation .... */\
static id M9_SINGLETON_INSTANCE = nil;\
\
+ (id)$sharingMethod {\
    /* return INSTANCE if exists, not to synchronized */\
    if (M9_SINGLETON_INSTANCE) {\
        return M9_SINGLETON_INSTANCE;\
    }\
    @synchronized(self) {\
        if (!M9_SINGLETON_INSTANCE) {\
            M9_SINGLETON_INSTANCE = [[self alloc] init];\
        }\
    }\
    return M9_SINGLETON_INSTANCE;\
}\
\
+ (id)allocWithZone:(NSZone *)zone {\
    if (M9_SINGLETON_INSTANCE) {\
        return nil;\
    }\
    /* alloc once only! */\
    @synchronized(self) {\
        if (!M9_SINGLETON_INSTANCE) {\
            M9_SINGLETON_INSTANCE = [super allocWithZone:zone];\
            return M9_SINGLETON_INSTANCE;\
        }\
    }\
    return nil;\
}\
\
- (id)copyWithZone:(NSZone *)zone {\
    return self;\
}\
- (id)retain {\
    return self;\
}\
- (unsigned)retainCount {\
    return UINT_MAX;\
}\
- (oneway void)release {\
}\
- (id)autorelease {\
    return self;\
}\
\
/* M9Singleton implementation end. */

