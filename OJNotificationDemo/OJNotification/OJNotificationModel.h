//
//  NotificationModel.h
//  ThreadDemo
//
//  Created by Juwencheng on 25/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OJNotificationModel : NSObject

@property (nonatomic, strong) NSString *appIcon; ///< 当前仅支持本地读取 icon
@property (nonatomic, strong) NSString *type;    ///< 通知类型
@property (nonatomic, strong) NSString *time;    ///< 通知时间
@property (nonatomic, strong) NSString *title;   ///< 通知标题
@property (nonatomic, strong) NSString *detail;  ///< 通知详情

/**
 * 从 json 数据转换为实例对象
 *
 * @param json json数据
 */
+ (instancetype)modelFromJson:(NSDictionary *)json;

@end
