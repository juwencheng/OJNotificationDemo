//
//  NotificationView.m
//  ThreadDemo
//
//  Created by Juwencheng on 24/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#import "OJNotificationView.h"
#import "UIView+OutletBinding.h"

#define BINGDEBUG 0
#define HEXCOLOR(hex, a)  \
[UIColor colorWithRed:(float)((hex&0xFF0000)>>16)/255.0 green:(float)((hex&0xFF00)>>8)/255.0 blue:(float)((hex&0xFF))/255.0 alpha:1]
#define HEXCOLORWITALPHA(hex, a) \
[UIColor colorWithRed:(float)((hex&0xFF0000)>>16)/255.0 green:(float)((hex&0xFF00)>>8)/255.0 blue:(float)((hex&0xFF))/255.0 alpha:a]

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

#pragma mark - 初始化工作
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
    UIView *nibView = [self loadViewWithNibName:@"OJNotificationView"];
    
    [self addConstraintToNibView:nibView];
    [self connectFromView:nibView];
    [self styleView];
}

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

/**
 * 第一种方案，使用 viewWithTag: 方法，遍历所有子视图查找与之对应的tag
 */
- (void)connectToView {
    [self outletPropertyName:@"appIcon" toTag:tAppIcon];
    [self outletPropertyName:@"appNameLabel" toTag:tAppName];
    [self outletPropertyName:@"timeLabel" toTag:tTime];
    [self outletPropertyName:@"msgTitleLabel" toTag:tMsgTitle];
    [self outletPropertyName:@"msgDetailLabel" toTag:tMsgDetail];
}

/**
 * 第二种方案，使用 ov_viewWithTag: 方法，只遍历直接子视图，配合tag的定义使用，可实现可视化的层级结构，例如 tag 值是 0x1f ，解析出来就是 父视图的 tag 是 1， 子视图的 tag 是15
 */
- (void)connectFromView:(UIView *)view {
    [view connectPropertyName:@"appIcon" tag:tAppIcon to:self];
    [view connectPropertyName:@"appNameLabel" tag:tAppName to:self];
    [view connectPropertyName:@"timeLabel" tag:tTime to:self];
    [view connectPropertyName:@"msgTitleLabel" tag:tMsgTitle to:self];
    [view connectPropertyName:@"msgDetailLabel" tag:tMsgDetail to:self];
    [view connectPropertyName:@"headerView" tag:tHeader to:self];
    
    // 添加调试信息，鉴别类型是否一样
#if BINGDEBUG
    NSAssert(![self.appIcon isKindOfClass:[UIImageView class]], @"appIcon 必须是 UIImageView 类型");
    NSAssert(![self.appNameLabel isKindOfClass:[UIImageView class]], @"appNameLabel 必须是 UILabel 类型");
    NSAssert(![self.timeLabel isKindOfClass:[UIImageView class]], @"timeLabel 必须是 UILabel 类型");
    NSAssert(![self.msgTitleLabel isKindOfClass:[UIImageView class]], @"msgTitleLabel 必须是 UILabel 类型");
    NSAssert(![self.msgDetailLabel isKindOfClass:[UIImageView class]], @"msgDetailLabel 必须是 UILabel 类型");
    NSAssert(![self.headerView isKindOfClass:[UIView class]], @"headerView 必须是 UIView 类型");
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

- (void)dealloc {
    NSLog(@"dealloc");
}

@end
