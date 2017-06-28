//
//  OJNotificationActionView.m
//  OJNotificationDemo
//
//  Created by Juwencheng on 28/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#import "OJNotificationActionView.h"
#import "UIView+NibView.h"
#import "UIView+OutletBinding.h"
#import "OJColor.h"
#import "OJNotificationWindow.h"

static NSInteger tActionLeftTag = 0x1;
static NSInteger tActionRightTag = 0x2;

@interface OJNotificationActionView ()

@property (nonatomic, weak) UIButton *leftBtn;
@property (nonatomic, weak) UIButton *rightBtn;

@end

@implementation OJNotificationActionView

#pragma mark 初始化工作
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    // 如果需要 还可以更改xib 实现样式的更改
    UIView *nibView = [self loadViewWithNibName:@"OJNotificationActionView"];
    
    [self addConstraintToNibView:nibView];
    [self connectFromView:nibView];
    [self bindEvent];
    [self styleView];
}

#pragma mark 绑定属性到资源文件中
/**
 * 第一种方案，使用 viewWithTag: 方法，遍历所有子视图查找与之对应的tag
 */
- (void)connectToView {
    [self outletProperty:@"leftBtn" toTag:tActionLeftTag];
    [self outletProperty:@"rightBtn" toTag:tActionRightTag];
}

/**
 * 第二种方案，使用 ov_viewWithTag: 方法，只遍历直接子视图，配合tag的定义使用，可实现可视化的层级结构，例如 tag 值是 0x1f ，解析出来就是 父视图的 tag 是 1， 子视图的 tag 是15
 */
- (void)connectFromView:(UIView *)view {
    [view connectProperty:@"leftBtn" tag:tActionLeftTag to:self];
    [view connectProperty:@"rightBtn" tag:tActionRightTag to:self];
    
    // 添加调试信息，鉴别类型是否一样
#if BINGDEBUG
    [self assertProperty:@"leftBtn" class:[UIButton class]];
    [self assertProperty:@"rightBtn" class:[UIButton class]];
#endif
}

/**
 *  绑定事件
 */
- (void)bindEvent {
    [self.leftBtn addTarget:self action:@selector(triggerLeftAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightBtn addTarget:self action:@selector(triggerRightAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)triggerLeftAction:(UIButton *)sender {
//    NSLog(@"left action");
    [OJNotificationWindow dismissNotification];
    [(Class)self.handler didSelectActionAtIndex:0 notification:self.notification];
    
}

- (void)triggerRightAction:(UIButton *)sender {
//    NSLog(@"right action");
    [OJNotificationWindow dismissNotification];
    [(Class)self.handler didSelectActionAtIndex:1 notification:self.notification];
}

/**
 * 为视图添加样式
 */
- (void)styleView {
    self.layer.cornerRadius = 10;
    self.clipsToBounds = 10;
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setHandler:(id<OJNotificationActionDelegateAndDataSource>)handler {
    _handler = handler;
    
    NSArray *actionTitles = [(Class)handler actionTitles];
    NSAssert(actionTitles.count == 2, @"actionTitles 必须返回两个按钮标题");
    [self.leftBtn setTitle:actionTitles[0] forState:UIControlStateNormal];
    [self.rightBtn setTitle:actionTitles[1] forState:UIControlStateNormal];
}

@end
