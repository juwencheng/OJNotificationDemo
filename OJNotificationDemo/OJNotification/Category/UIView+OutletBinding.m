//
//  NSObject+OutletBinding.m
//  ThreadDemo
//
//  Created by Juwencheng on 24/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#import "UIView+OutletBinding.h"

@implementation UIView (OutletBinding)

- (void)outletPropertyName:(NSString *)name toTag:(NSInteger)tag {
    UIView *view = [self viewWithTag:tag];
    if (view) {
        [self setValue:view forKey:name];
    }
}

- (void)connectPropertyName:(NSString *)name tag:(NSInteger)tag to:(UIView *)target {
    NSInteger newTag = [self inverseHexNumber:tag];
    UIView *view = self;
    while(newTag) {
        view = [view ob_viewWithTag:tag];
        newTag = newTag >> 4;
    }
    if (view) {
        [target setValue:view forKey:name];
    }
}

/**
 * 两种解决思路，一种是把tag值倒序，再处理，一种是正序处理，假设最多3层
 */
- (NSInteger)inverseHexNumber:(NSInteger)num {
    NSInteger temp;
    NSInteger newValue = 0;
    while(num) {
        temp = num & 0xF;
        newValue = (newValue << 4) | temp;
        num = num >> 4;
    }
    return newValue;
}

/**
 * 不用遍历所有子视图的tag，只查找直接子视图的
 */
- (UIView *)ob_viewWithTag:(NSInteger)tag {
    __block UIView *view ;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == tag) {
            view = obj;
        }
    }];
    return view;
}

@end
