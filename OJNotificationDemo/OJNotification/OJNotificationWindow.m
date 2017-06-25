//
//  NotificationWindow.m
//  ThreadDemo
//
//  Created by Juwencheng on 24/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#import "OJNotificationWindow.h"
#import "OJNotificationView.h"

// TODO: 处理 window 旋转后的布局

@interface OJNotificationWindow ()

@property (nonatomic, strong) OJNotificationView *content;           ///< 内部的通知视图
@property (nonatomic, strong) NSLayoutConstraint *topConst;          ///< content 和 window 顶部的约束，用于动画显示

@property (nonatomic, assign) OJNotificationPresentState presentState; ///< 展示状态
@property (nonatomic, assign) NSTimeInterval nw_animationDuration;     ///< 展示动画时长
@property (nonatomic, assign) NSTimeInterval nw_presentDuration;       ///< 展示时间 default 6

@property (nonatomic, assign) NSTimer *nw_animationTimer;              ///< 动画 timer

@property (nonatomic, strong) OJNotificationModel *presentingNotification;   ///< 展示的message，用于判断是否需要更新当前通知

@property (nonatomic, strong) UIVisualEffectView *blurView;

@end

@implementation OJNotificationWindow

#pragma mark 初始化
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static OJNotificationWindow *instance;
    dispatch_once(&onceToken, ^{
        @synchronized (self) {
            if (!instance) {
                instance = [[OJNotificationWindow alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 200)];
            }
        }
    });
    return instance;
}

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
    
    // variable part
    _nw_animationDuration = 0.25;
    _nw_presentDuration = 6.0f;
    
//    self.alpha = 0.9;
    [self setupSubviews];
    [self registOrientationNotification];
}

- (void)setupSubviews {
    [self addSubview:self.blurView];
    [self addSubview:self.content];
    
    self.content.translatesAutoresizingMaskIntoConstraints = NO;
    for (NSString *constStr in @[@"H:|-(16)-[alert]-(16)-|",@"V:[alert]-(>=8)-|"]) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constStr options:0 metrics:nil views:@{@"alert":self.content}]];
    }
    
    self.topConst = [NSLayoutConstraint constraintWithItem:self.content attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:-200];
    [self addConstraint:self.topConst];
    
    self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.blurView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.content attribute:NSLayoutAttributeTop multiplier:1 constant:-16]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.blurView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.content attribute:NSLayoutAttributeBottom multiplier:1 constant:16]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.blurView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.blurView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
}

#pragma mark 展示通知
+ (void)showNotificationWithModel:(OJNotificationModel *)model {
    [[self sharedInstance] showNotificationWithModel:model];
}

- (void)showNotificationWithModel:(OJNotificationModel *)model {
    [self makeKeyAndVisible];
    // 应该有state
    switch (_presentState) {
            
        case OJNotificationPresentStateNone:
            self.content.notification = model;
            [self preparePresetAnimation:YES];
            break;
        case OJNotificationPresentStateShowing:
        {
            // 这里应该用compare进行对比
            // 如果是重复消息，不重置显示时间
            if (self.presentingNotification == model) {
                break;
            }
            if (self.nw_animationTimer) {
                [self.nw_animationTimer invalidate];
            }
            // 重置显示时间
            self.nw_animationTimer = [NSTimer scheduledTimerWithTimeInterval:self.nw_presentDuration target:self selector:@selector(dismissNotification) userInfo:nil repeats:NO];
            // 更新显示内容
            self.content.notification = model;
        }
            break;
        case OJNotificationPresentStateHiding:
        {    // 如果正在隐藏，等0.25秒显示
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showNotificationWithModel:model];
            });
        }
            break;
        case OJNotificationPresentStateFinished:
            // 重新设置显示内容
            self.content.notification = model;
            [self preparePresetAnimation:NO];
            break;
        default:
            break;
    }
}

- (void)preparePresetAnimation:(BOOL)first {
    _presentState = OJNotificationPresentStateShowing;
    if (first) {
        [self layoutIfNeeded];
    }
    self.topConst.constant = 16;
    [UIView animateWithDuration:self.nw_animationDuration animations:^{
        [self setNeedsUpdateConstraints];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        if ([self.nw_animationTimer isValid]) {
            [self.nw_animationTimer invalidate];
        }
        self.nw_animationTimer = [NSTimer scheduledTimerWithTimeInterval:self.nw_presentDuration target:self selector:@selector(dismissNotification) userInfo:nil repeats:NO];
    }];
}

#pragma mark 隐藏通知
+ (void)dismissNotification {
    [[self sharedInstance] dismissNotification];
}

- (void)dismissNotification {
    self.topConst.constant = -200;
    [UIView animateWithDuration:self.nw_animationDuration animations:^{
        [self setNeedsUpdateConstraints];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        _presentState = OJNotificationPresentStateFinished;
        [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
    }];
    // 不设置会导致crash，估计是野指针的问题
    self.nw_animationTimer = nil;
}

#pragma mark 处理屏幕旋转
- (void)registOrientationNotification {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationChanged:(NSNotification *)notification {
    //    UIDeviceOrientation orientation = [notification.object integerForKey:@"UIDeviceOrientationRotateAnimatedUserInfoKey"];
    self.frame = [UIScreen mainScreen].bounds;
    if (self.presentState == OJNotificationPresentStateShowing) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.content layoutIfNeeded];
        }];
    }
}

#pragma mark Lazy initialize
- (OJNotificationView *)content {
    if (!_content) {
        _content = [[OJNotificationView alloc] initWithFrame:CGRectZero];
        _content.layer.shadowOffset = CGSizeMake(0, 2);
        _content.layer.shadowOpacity = 0.8;
        _content.layer.shadowColor = [UIColor blackColor].CGColor;
        _content.layer.shadowRadius = 5;
        
        _content.alpha = 0.8;
    }
    return _content;
}

- (UIVisualEffectView *)blurView {
    if (!_blurView) {
        UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
    }
    return _blurView;
}


@end
