//
//  OJNormalNotificationHandler.m
//  OJNotificationDemo
//
//  Created by Juwencheng on 28/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#import "OJNormalNotificationHandler.h"

@implementation OJNormalNotificationHandler

+ (NSArray *)actionTitles {
    return @[@"查看",@"取消"];
}

+ (void)didSelectActionAtIndex:(NSInteger)index notification:(id)notification {
    NSLog(@"点击第%ld 个事件", (long)index);
}

@end
