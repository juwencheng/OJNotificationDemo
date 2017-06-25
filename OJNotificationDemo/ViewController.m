//
//  ViewController.m
//  OJNotificationDemo
//
//  Created by Juwencheng on 25/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#import "ViewController.h"
#import "OJNotificationWindow.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showNotification:(id)sender {
    [OJNotificationWindow showNotificationWithModel:nil];
}

@end
