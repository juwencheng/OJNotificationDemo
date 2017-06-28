//
//  NSObject+OutletBinding.h
//  ThreadDemo
//
//  Created by Juwencheng on 24/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIView (OutletBinding)

/**
 *  模拟可视化编辑的 outlet ，绑定 tag 到对应的属性名
 *  @prama  name 属性名，后面将用来 setValue:forKey 方法，如果没有 name 对应属性将导致 crash
 *  @prama  tag  xib 布局文件设置的 tag
 */
- (void)outletProperty:(NSString *)property toTag:(NSInteger)tag;

/**
 *  模拟可视化编辑的 outlet ，绑定 tag 到 target 对应的属性名
 *  @prama  name 属性名，后面将用来 setValue:forKey 方法，如果没有 name 对应属性将导致 crash
 *  @prama  tag  xib 布局文件设置的 tag
 *  @prama  target  目标类
 */
- (void)connectProperty:(NSString *)property tag:(NSInteger)tag to:(UIView *)target;

/**
 *  判断属性是否为指定类型，用于校验绑定属性是否有异常
 *  @prama  property 属性名，后面将用来 setValue:forKey 方法，如果没有 name 对应属性将导致 crash
 *  @prama  clazz    属性类型
 */
- (void)assertProperty:(NSString *)property class:(Class)clazz;

@end
