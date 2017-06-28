//
//  UIView+NibView.m
//  OJNotificationDemo
//
//  Created by Juwencheng on 28/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#import "UIView+NibView.h"

@implementation UIView (NibView)

/**
 * 从 xib 文件中获得 UIView ， 并返回
 */
- (UIView *)loadViewWithNibName:(NSString *)nibName {
    NSArray *array = [[UINib nibWithNibName:nibName bundle:nil] instantiateWithOwner:self options:@{}];
    UIView *nibView = [array firstObject];
    // clear nibView background color
    nibView.backgroundColor = [UIColor clearColor];
    return nibView;
}

#pragma mark 载入并约束视图
/**
 * 将 view 添加到当前视图，并添加约束 V:|[view]| H:|[view]|
 */
- (void)addConstraintToNibView:(UIView *)view {
    [self addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    for (NSString *constStr in @[@"V:|[view]|",@"H:|[view]|"]) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constStr options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"view":view}]];
    }
}

@end
