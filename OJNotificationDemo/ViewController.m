//
//  ViewController.m
//  OJNotificationDemo
//
//  Created by Juwencheng on 25/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#import "ViewController.h"
#import "OJNotificationModel.h"
#import "OJNotificationWindow.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *testData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.testData = [NSMutableArray array];
    
    OJNotificationModel *model1 = [[OJNotificationModel alloc] init];
    model1.time = @"1 小时前";
    model1.title = @"运动提醒";
    model1.detail = @"您今日的运动达标了吗，赶紧打开看看吧！";
    model1.type = @"华西健康";
    
    OJNotificationModel *model2 = [[OJNotificationModel alloc] init];
    model2.time = @"20:30";
    model2.title = @"";
    model2.detail = @"根据您的搜索记录，我们为您私人定制了农家乐，赶紧去看看吧！";
    model2.type = @"熊猫导游";
    
    OJNotificationModel *model3 = [[OJNotificationModel alloc] init];
    model3.time = @"刚刚";
    model3.title = @"用药提醒";
    model3.detail = @"您预约了后天（2017年6月10日）在华西体检，请不要错过哦！";
    model3.type = @"华西健康";
    
    [self.testData addObject:model1];
    [self.testData addObject:model2];
    [self.testData addObject:model3];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showNotification:(id)sender {
    //arc4random()%self.testData.count
    [OJNotificationWindow showNotificationWithModel:self.testData[arc4random()%self.testData.count] viberate:YES];
}

@end
