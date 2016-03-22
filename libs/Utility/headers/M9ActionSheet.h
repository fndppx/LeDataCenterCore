//
//  M9ActionSheet.h
//  iM9
//
//  Created by iwill on 2011-05-21.
//  Copyright 2011 M9. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface M9ActionSheet : UIActionSheet <UIActionSheetDelegate>


// The only initialize method!!
- (id) initWithTitle:(NSString *)title;

- (NSInteger) addButtonWithTitle:(NSString *)title callback:(void (^)(int index, NSString *title))callback;
- (NSInteger) addCancelButtonWithTitle:(NSString *)title callback:(void (^)(int index, NSString *title))callback;
- (NSInteger) addDestructiveButtonWithTitle:(NSString *)title callback:(void (^)(int index, NSString *title))callback;

- (NSInteger) addButtonWithTitle:(NSString *)title;
- (NSInteger) addCancelButtonWithTitle:(NSString *)title;
- (NSInteger) addDestructiveButtonWithTitle:(NSString *)title;

- (void) show;


@end

