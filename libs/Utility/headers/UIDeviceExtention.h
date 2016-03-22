//
//  UIDeviceExtention.h
//  SViPad
//
//  Created by yangbaocheng on 11-8-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	eReachbilityWifi,
	eReachbility3G,
	eReachbilityNone
}E_REACHABILITY_STATUS;

@interface UIDevice(SVExtention)
+(E_REACHABILITY_STATUS)getReachabilityStatus;
+(BOOL) startReachabilityNotifer;
+(void) stopReachabilityNotifer;

@end
