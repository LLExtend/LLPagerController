//
//  LLPagerSubController.m
//  LLWeiBoPersonView
//
//  Created by MAC on 2017/10/16.
//  Copyright © 2017年 MAC. All rights reserved.
//

#import "LLPagerSubController.h"
#import "LLWaterFlowController.h"

@interface LLPagerSubController ()

@end

@implementation LLPagerSubController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAllChildViewController];
    

    [self settingTitleScrollViewCustomItem:^(LLTitleScrollViewCustomItem *item) {
        *item = LLTitleScrollViewCustomItemMake(UIColor.whiteColor, 55);
    }];
    
    
    [self settingTitleButtonCustomItem:^(LLTitleButtonCustomItem *item) {
        LLTitleButtonCustomItem titleButtonItem = LLTitleButtonCustomItemMake(YES, LLScreenSize().width / 3, 20);
        titleButtonItem.normalColor = UIColor.blackColor;
        titleButtonItem.selectedColor = UIColor.orangeColor;
        titleButtonItem.titleButtonFont = [UIFont systemFontOfSize:16];
        titleButtonItem.titleScale = .3;
        titleButtonItem.isOpenShade = YES;
        *item = titleButtonItem;
    }];

//    LLNotReadDotCustomItem dotItem;
//    dotItem.isHidden = NO;
//    dotItem.dotFontSize = 11;
//    dotItem.backgroundColor = UIColor.blueColor;
    
    [self settingNotReadDotCustomItem:^(LLNotReadDotCustomItem *item) {
        *item = LLNotReadDotCustomItemMake(NO, 11, UIColor.lightGrayColor, UIColor.blueColor);
    }];
    
    [self settingUnderLineCustomItem:^(LLUnderLineCustomItem *item) {
        *item = LLUnderLineCustomItemMake(LLPagerUnderlineSizeType_followTitleLabel, YES, YES, UIColor.purpleColor, CGSizeMake(30, 5));
    }];
    
    [self settingSelectIndex:^(NSInteger *index) {
        *index = 1;
    }];

    
    __weak typeof(self)weakSelf = self;
    self.titleButtonChangeClickBlock = ^(UIButton *fromButton, UIButton *toButton) {
        [weakSelf refreshDotText:@"23" button:toButton];
        [weakSelf refreshDotText:@"120" button:fromButton];
    };

}


#pragma mark - 添加所有子控制器
- (void)setupAllChildViewController {
    NSArray *titles = @[@"关注",@"推荐",@"瀑布流布局",@"视频",@"热点",@"社会",@"中国好声音"];//  @[@"关注",@"推荐",@"视频",@"热点",@"社会",@"中国好声音",@"瀑布流布局"];
    [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIViewController *vc = idx%2 ? [UIViewController new] : [LLWaterFlowController new];
        vc.title = titles[idx];
        vc.view.backgroundColor = RandColor;
        [self addChildViewController:vc];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
