//
//  OJDelegates.h
//  OJNotificationDemo
//
//  Created by Juwencheng on 28/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#ifndef OJDelegates_h
#define OJDelegates_h

@protocol OJNotificationActionDelegateAndDataSource <NSObject>

/**
 *  按钮标题，只能是2个
 */
+ (NSArray *)actionTitles;

/**
 *  选中菜单处理事件
 *  @prama index  按钮索引
 *  @prama  notification  当前展示的通知
 */
+ (void)didSelectActionAtIndex:(NSInteger)index notification:(id)notification;

@end

#endif /* OJDelegates_h */
