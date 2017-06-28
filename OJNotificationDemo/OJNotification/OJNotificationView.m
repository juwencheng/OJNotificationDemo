//
//  NotificationView.m
//  ThreadDemo
//
//  Created by Juwencheng on 24/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#import "OJNotificationView.h"
#import "UIView+OutletBinding.h"
#import "OJNotificationModel.h"
#import "UIView+NibView.h"
#import "OJColor.h"

#define BINGDEBUG 0
#define XOR(a,b) ((a & ~b) | (~a & b))

/**
 * 用16进制表示tag值，如果有多位，表示有层级关系，加入父视图的tag是15，子视图的是1，那么tag的值是0xf1
 */

static NSInteger tMsgTitle = 0x1;
static NSInteger tMsgDetail = 0x2;
static NSInteger tHeader = 0x3;
static NSInteger tAppIcon = 0x31;
static NSInteger tAppName = 0x32;
static NSInteger tTime = 0x33;

@interface OJNotificationView ()

@property (nonatomic, strong) UIImageView *appIcon;
@property (nonatomic, strong) UILabel *appNameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *msgTitleLabel;
@property (nonatomic, strong) UILabel *msgDetailLabel;
@property (nonatomic, strong) UIView *headerView;

@end


@implementation OJNotificationView

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
    UIView *nibView = [self loadViewWithNibName:self.nibName];
    
    [self addConstraintToNibView:nibView];
    [self connectFromView:nibView];
    [self styleView];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self doUpdateConstraints];
}

- (void)doUpdateConstraints {
    // 由当前结构决定self只有一个直接子视图
    UIView *nibView = [[self subviews] firstObject];
    [self resetHeaderAndTitleAndDetailConstrain:nibView];
    if (self.msgTitleLabel.hidden) {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.msgDetailLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeBottom multiplier:1 constant:8];
        constraint.identifier = @"header-detail-conn";
        [nibView addConstraint:constraint];
    }else {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.msgTitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeBottom multiplier:1 constant:8];
        constraint.identifier = @"header-title-conn";
        [nibView addConstraint:constraint];
    }
}

/**
 *  重置 header 和 title detail label 的约束，动态显示 title
 * 
 *  @param nibView  header title detail 的父视图
 */
- (void)resetHeaderAndTitleAndDetailConstrain:(UIView *)nibView {
    // 断开msgTitleLabel和heade的约束
    for (NSLayoutConstraint *constraint in [nibView constraints]) {
        // identifier 是在xib中指定的
        if ([constraint.identifier isEqualToString:@"header-detail-conn"] ||
            [constraint.identifier isEqualToString:@"header-title-conn"]) {
            [nibView removeConstraint:constraint];
        }
    }
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

#pragma mark 绑定属性到资源文件中
/**
 * 第一种方案，使用 viewWithTag: 方法，遍历所有子视图查找与之对应的tag
 */
- (void)connectToView {
    [self outletProperty:@"appIcon" toTag:tAppIcon];
    [self outletProperty:@"appNameLabel" toTag:tAppName];
    [self outletProperty:@"timeLabel" toTag:tTime];
    [self outletProperty:@"msgTitleLabel" toTag:tMsgTitle];
    [self outletProperty:@"msgDetailLabel" toTag:tMsgDetail];
}

/**
 * 第二种方案，使用 ov_viewWithTag: 方法，只遍历直接子视图，配合tag的定义使用，可实现可视化的层级结构，例如 tag 值是 0x1f ，解析出来就是 父视图的 tag 是 1， 子视图的 tag 是15
 */
- (void)connectFromView:(UIView *)view {
    [view connectProperty:@"appIcon" tag:tAppIcon to:self];
    [view connectProperty:@"appNameLabel" tag:tAppName to:self];
    [view connectProperty:@"timeLabel" tag:tTime to:self];
    [view connectProperty:@"msgTitleLabel" tag:tMsgTitle to:self];
    [view connectProperty:@"msgDetailLabel" tag:tMsgDetail to:self];
    [view connectProperty:@"headerView" tag:tHeader to:self];
    
    // 添加调试信息，鉴别类型是否一样
#if BINGDEBUG
    [self assertProperty:@"appIcon" class:[UIImageView class]];
    [self assertProperty:@"appNameLabel" class:[UILabel class]];
    [self assertProperty:@"timeLabel" class:[UILabel class]];
    [self assertProperty:@"msgTitleLabel" class:[UILabel class]];
    [self assertProperty:@"msgDetailLabel" class:[UILabel class]];
    [self assertProperty:@"headerView" class:[UIView class]];
#endif
}

/**
 * 为视图添加样式
 */
- (void)styleView {
    self.layer.cornerRadius = 10;
    self.clipsToBounds = 10;
    
    self.backgroundColor = HEXCOLORWITALPHA(0xF1F1F1, 1);
}

- (void)setNotification:(OJNotificationModel *)notification {
    self.timeLabel.text = notification.time;
    self.msgTitleLabel.text = notification.title;
    self.msgDetailLabel.text = notification.detail;
    self.appNameLabel.text = notification.type;
    
    self.msgTitleLabel.hidden = notification.title.length==0;
    
    if (XOR(_notification.title.length , notification.title.length)) {
        [self setNeedsUpdateConstraints];
    }
    _notification = notification;
}

#pragma mark Lazy initialize 
- (NSString *)nibName {
    if (!_nibName) {
        _nibName = @"OJNotificationView";
    }
    return _nibName;
}

- (void)dealloc {
    NSLog(@"dealloc");
}

@end
