//
//  NotificationView.h
//  ThreadDemo
//
//  Created by Juwencheng on 24/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OJNotificationModel;

@interface OJNotificationView : UIView

@property (nonatomic, strong) OJNotificationModel *notification;  ///< 消息数据模型类

@property (nonatomic, copy) NSString *nibName;  ///< 需要绑定的布局文件名字，供子类修改。Default OJNotificationView

/**
 *  校验通过 viewWithTag: 获得到的属性值是否为指定类型
 */
- (void)assertProperty:(NSString *)property class:(Class)clazz;

/**
 *  为子类预留更新约束的接口。重写时不用调用 [super doUpdateConstraints]
 */
- (void)doUpdateConstraints;

@end
