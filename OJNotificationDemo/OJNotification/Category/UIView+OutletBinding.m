//
//  NSObject+OutletBinding.m
//  ThreadDemo
//
//  Created by Juwencheng on 24/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#import "UIView+OutletBinding.h"

@implementation UIView (OutletBinding)

- (void)outletProperty:(NSString *)property toTag:(NSInteger)tag {
    UIView *view = [self viewWithTag:tag];
    if (view) {
        [self setValue:view forKey:property];
    }
}

- (void)connectProperty:(NSString *)property tag:(NSInteger)tag to:(UIView *)target {
    NSInteger newTag = [self inverseHexNumber:tag];
    UIView *view = self;
    while(newTag) {
        view = [view ob_viewWithTag:(newTag & 0xF)];
        newTag = newTag >> 4;
    }
    if (view) {
        [target setValue:view forKey:property];
    }
}

/**
 * 校验通过 viewWithTag: 获得到的属性值是否为指定类型
 */
- (void)assertProperty:(NSString *)property class:(Class)clazz {
    id propertyValue = [self valueForKey:property];
    NSString *errorMsg = [NSString stringWithFormat:@"%@ 必须是 %@ 类型", property, NSStringFromClass(clazz)];
    NSAssert([propertyValue isKindOfClass:clazz], errorMsg);
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
