//
//  M9BarButtonItem.h
//  iM9
//
//  Created by iwill on 2011-05-22.
//  Copyright 2011 M9. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface M9BarButtonItem : UIBarButtonItem


@property (nonatomic, readwrite, copy) void (^callback)(M9BarButtonItem *barButtonItem);


- (id) initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem callback:(void (^)(M9BarButtonItem *barButtonItem))callback;
- (id) initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style callback:(void (^)(M9BarButtonItem *barButtonItem))callback;
- (id) initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style callback:(void (^)(M9BarButtonItem *barButtonItem))callback;


@end

