//
//  NotificationWindow.m
//  ThreadDemo
//
//  Created by Juwencheng on 24/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#import "OJNotificationWindow.h"
#import "OJNotificationView.h"
#import <AudioToolbox/AudioServices.h>

/**
 *  实际没有用到，仅用于支持旋转
 */
@interface NotUsedViewController : UIViewController

@end

@implementation NotUsedViewController

- (BOOL)shouldAutorotate {
    return YES;
}

@end

@interface OJNotificationWindow ()

@property (nonatomic, strong) OJNotificationView *content;           ///< 内部的通知视图
@property (nonatomic, strong) NSLayoutConstraint *contentTopConst;          ///< content 和 window 顶部的约束，用于动画显示
@property (nonatomic, strong) NSLayoutConstraint *contentLeadingConst;          ///< content 和 window 左边的约束，用于动画显示
@property (nonatomic, strong) NSLayoutConstraint *contentTrailingConst;          ///< content 和 window 右边的约束，用于动画显示

@property (nonatomic, assign) OJNotificationPresentState presentState; ///< 展示状态
@property (nonatomic, assign) NSTimeInterval nw_animationDuration;     ///< 展示动画时长
@property (nonatomic, assign) NSTimeInterval nw_presentDuration;       ///< 展示时间 default 6

@property (nonatomic, assign) NSTimer *nw_animationTimer;              ///< 动画 timer

@property (nonatomic, strong) OJNotificationModel *presentingNotification;   ///< 展示的message，用于判断是否需要更新当前通知

@property (nonatomic, strong) UIVisualEffectView *blurView;

@end

@interface OJNotificationWindow (Gesture) <UIGestureRecognizerDelegate>

- (void)addGesture;

- (void)swipeLeft;

- (void)swipeNormal;

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
    self.rootViewController = [[NotUsedViewController alloc] init];
    // variable part
    _nw_animationDuration = 0.25;
    _nw_presentDuration = 6.0f;

//    self.alpha = 0.9;
    [self setupSubviews];
    [self registOrientationNotification];
    [self addGesture];
}

- (void)setupSubviews {
    [self addSubview:self.blurView];
    [self addSubview:self.content];
    
    self.content.translatesAutoresizingMaskIntoConstraints = NO;
    for (NSString *constStr in @[@"V:[alert]-(>=8)-|"]) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constStr options:0 metrics:nil views:@{@"alert":self.content}]];
    }
    
    
    self.contentTopConst = [NSLayoutConstraint constraintWithItem:self.content attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:-200];
    [self addConstraint:self.contentTopConst];
    self.contentLeadingConst = [NSLayoutConstraint constraintWithItem:self.content attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:16];
    [self addConstraint:self.contentLeadingConst];
    self.contentTrailingConst = [NSLayoutConstraint constraintWithItem:self.content attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:-16];
    [self addConstraint:self.contentTrailingConst];
    
    self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.blurView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.content attribute:NSLayoutAttributeTop multiplier:1 constant:-16]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.blurView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.content attribute:NSLayoutAttributeBottom multiplier:1 constant:16]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.blurView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.blurView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
}

#pragma mark 展示通知
+ (void)showNotificationWithModel:(OJNotificationModel *)notification viberate:(BOOL)viberate {
    if (viberate) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    [self showNotificationWithModel:notification];
}

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
    self.contentTopConst.constant = 16;
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
    if ([self.nw_animationTimer isValid]) {
        [self.nw_animationTimer invalidate];
    }
    self.contentTopConst.constant = -200;
    [UIView animateWithDuration:self.nw_animationDuration animations:^{
        [self setNeedsUpdateConstraints];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        _presentState = OJNotificationPresentStateFinished;
        [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
        
        // 恢复左右约束
        [self swipeNormal];
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
    self.frame = [UIScreen mainScreen].bounds;
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
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
    }
    return _blurView;
}


@end


@implementation OJNotificationWindow (Gesture)

- (void)addGesture {
    // 向上滑动隐藏手势
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:swipeUp];
    
    // 向左滑动显示菜单
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeft];
    
    // 向右滑动显示菜单
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRight];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gesture {
    switch (gesture.direction) {
        case UISwipeGestureRecognizerDirectionUp:
            [self dismissNotification];
            break;
        case UISwipeGestureRecognizerDirectionLeft:
        {
            [self swipeLeft];
            [UIView animateWithDuration:0.25 animations:^{
                [self setNeedsUpdateConstraints];
                [self layoutIfNeeded];
            }];
        }
            break;
        case UISwipeGestureRecognizerDirectionRight:
        {
            [self swipeNormal];
            [UIView animateWithDuration:0.25 animations:^{
                [self setNeedsUpdateConstraints];
                [self layoutIfNeeded];
            }];
        }
            break;
        default:
            break;
    }
}

- (void)swipeLeft {
    self.contentLeadingConst.constant -= 200;
    self.contentTrailingConst.constant -= 200;
}

- (void)swipeNormal {
    self.contentLeadingConst.constant = 16;
    self.contentTrailingConst.constant = -16;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    /*
    CGPoint point = [sender translationInView:_testView];
    //    sender.view.transform = CGAffineTransformMake(1, 0, 0, 1, point.x, point.y);
    
    //平移一共两种移动方式
    //第一种移动方法:每次移动都是从原来的位置移动
    //    sender.view.transform = CGAffineTransformMakeTranslation(point.x, point.y);
    
    //第二种移动方式:以上次的位置为标准(移动方式 第二次移动加上第一次移动量)
    sender.view.transform = CGAffineTransformTranslate(sender.view.transform, point.x, point.y);
    //增量置为o
    [sender setTranslation:CGPointZero inView:sender.view];
    
    _testView.backgroundColor = [UIColor colorWithRed:arc4random()%256/255.0 green:arc4random()%256/255.0 blue:arc4random()%256/255.0 alpha:1];
    */
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
