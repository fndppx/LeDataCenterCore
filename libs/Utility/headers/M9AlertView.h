//
//  M9AlertView.h
//  iM9
//
//  Created by iwill on 2011-05-22.
//  Copyright 2011 M9. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface M9AlertView : UIAlertView <UIAlertViewDelegate>


// designated initializer
- (id) initWithTitle:(NSString *)title message:(NSString *)message;
// !!!: deprecated - This method raises an NSInvalidArgumentException.
- (id) initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate
   cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION DEPRECATED_ATTRIBUTE;

- (NSInteger) addButtonWithTitle:(NSString *)title callback:(void (^)(int index, NSString *title))callback;
- (NSInteger) addCancelButtonWithTitle:(NSString *)title callback:(void (^)(int index, NSString *title))callback;

- (NSInteger) addButtonWithTitle:(NSString *)title;
- (NSInteger) addCancelButtonWithTitle:(NSString *)title;


@end

