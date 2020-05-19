//
//  ViewController.m
//  LLPagerController
//
//  Created by MAC on 2017/10/18.
//  Copyright © 2017年 MAC. All rights reserved.
//

#import "ViewController.h"
#import "LLPagerController.h"
#import "LLPagerSubController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"LLPagerController";
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    LLPagerSubController *page = [[LLPagerSubController alloc] init];
    [self.navigationController pushViewController:page animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
