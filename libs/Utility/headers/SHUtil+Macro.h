//
//  SHUtil+Macro.h
//  Utility
//
//  Created by Tiger Xia on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//#ifndef            DEBUG
//#   define         DEBUG            1
//#endif


//DEBUG的定义需放在主工程的Preprocessing->Preprocessor Macros->Debug字段中填加
#ifdef DEBUG
#   define SHLog(xx, ...)  NSLog(@"[%s(%d)]\n " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define SHLog(xx, ...)  ((void)0)
#endif 


#pragma mark === ASSERT ===
#ifdef DEBUG
#   import <TargetConditionals.h>
#   define SHAssert(xx) { if(!(xx)) { SHLog(@"ASSERT failed: %s", #xx); } } ((void)0)
#else
#   define SHAssert(xx) ((void)0)
#endif // #ifdef DEBUG


/**
 *  色彩值
 */
#define RGBACOLOR(r,g,b,a)  [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define RGBCOLOR(r,g,b)     RGBACOLOR(r, g, b, 1.0f)

/**
 * 判断指定的版本号v是否高于当前的系统版本
 */
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(__version__)  ([[[UIDevice currentDevice] systemVersion] compare:__version__ options:NSNumericSearch] != NSOrderedAscending)
/**
 * 安全释放
 */
#define SH_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define SH_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }
#define SH_RELEASE_CF_SAFELY(__REF) { if (nil != (__REF)) { CFRelease(__REF); __REF = nil; } }

