//
//  UIImage+.h
//  iM9
//
//  Created by iwill on 2011-06-20.
//  Copyright 2011 M9. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (plus)

- (id) initWithName:(NSString *)name;
+ (UIImage *) imageWithName:(NSString *)name;

- (UIImage *) resizableImage;

- (UIImage *) imageByResizing:(CGSize)size;
- (UIImage *) imageByZooming:(CGFloat)zoom;

+ (UIImage *) imageWithImage:(UIImage *)image size:(CGSize)size;
+ (UIImage *) imageWithImage:(UIImage *)image zoom:(CGFloat)zoom;

+ (UIImage *) imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *) resizableImageWithColor:(UIColor *)color;

+ (UIImage *) screenshot;

@end

