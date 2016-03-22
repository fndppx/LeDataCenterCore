//
//  UIDeviceAdditions.h
//  icores
//
//  Created by jinzhu on 11-8-25.
//  Copyright 2011 Ruixin Online Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: renamme to UIDevice+UniqueIdentifier
@interface UIDevice(UniqueIdentifier)

+ (NSString*)deviceWiFiIPAddr; /*该方法线程运行有机率发生延时*/
- (NSString *)hardwarePlatform DEPRECATED_ATTRIBUTE;

- (NSString *)uniqueApplicationDeviceIdentifier;
- (NSString *)uniqueGlobalDeviceIdentifier;
//- (NSString *)saveDeviceIdentifiers:(NSString *)oriUUID andFakeGlobalID:(NSString *)fakeUUID DEPRECATED_ATTRIBUTE;

@end
