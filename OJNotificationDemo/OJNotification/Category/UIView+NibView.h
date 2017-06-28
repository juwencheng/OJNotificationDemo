//
//  UIView+NibView.h
//  OJNotificationDemo
//
//  Created by Juwencheng on 28/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (NibView)

- (UIView *)loadViewWithNibName:(NSString *)nibName;

- (void)addConstraintToNibView:(UIView *)view;

@end
