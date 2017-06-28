//
//  OJNotificationActionView.h
//  OJNotificationDemo
//
//  Created by Juwencheng on 28/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OJDelegates.h"

@interface OJNotificationActionView : UIView

@property (nonatomic, strong) id<OJNotificationActionDelegateAndDataSource> handler;

@property (nonatomic, strong) id notification;

@end
