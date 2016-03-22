//
//  UIImageExtend.h
//  Utility
//
//  Created by GuaGuaMedia on 13-2-6.
//  Copyright (c) 2013年 guagua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CompressExtend)

- (UIImage *)compressedImageWithSize:(CGSize) compressedSize;
- (UIImage*)compressByDesiredHeight:(int) desiredHeight;
#pragma mark 修正照片旋转方法
- (UIImage*)makePhotoVerticalDirectionByMaxEdgeSize:(int)kMaxSize;
@end
