//
//  YYPagerSubController.m
//  YYWeiBoPersonView
//
//  Created by MAC on 2017/10/16.
//  Copyright © 2017年 MAC. All rights reserved.
//

#import "YYPagerSubController.h"
#import "YYWaterFlowController.h"

@interface YYPagerSubController ()

@end

@implementation YYPagerSubController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAllChildViewController];
    
    [self settingTitleScrollView:^(UIColor *__autoreleasing *titleScrollViewBackgroundColor,
                                   CGFloat *titleScrollViewHeight) {
        *titleScrollViewBackgroundColor = [UIColor whiteColor];
        *titleScrollViewHeight = 44;
    }];
    
    //titleScale范围在0到1之间  <0 或者 >1 则默认不缩放 默认设置titleScale就开启缩放，不设置则关闭
    [self settingTitleButton:^(UIColor *__autoreleasing *normalColor,
                               UIColor *__autoreleasing *selectedColor,
                               UIFont *__autoreleasing *titleButtonFont,
                               CGFloat *titleButtonWidth,
                               CGFloat *titleScale,
                               BOOL *isAutoFitWidth,
                               BOOL *isOpenShade) {
        *normalColor = [UIColor blackColor];
        *selectedColor = [UIColor orangeColor];
        *titleButtonFont = [UIFont systemFontOfSize:16];
        *titleButtonWidth = 100;
        *titleScale = .1;
        *isAutoFitWidth = YES;
        *isOpenShade = YES;
    }];
    
    //underlineSize设置底部underline指示器的长度，有默认值为按钮的宽度的百分之56  默认高度4(并且不能大于10)
    [self settingUnderline:^(UIColor *__autoreleasing *underlineColor,
                             CGSize *underlineSize,
                             BOOL *isShowUnderline,
                             BOOL *isOpenStretch) {
        *underlineColor = [UIColor purpleColor];
        *isShowUnderline = YES;
        *isOpenStretch = YES;
    }];
    
    [self settingSelectIndex:^(NSInteger *index) {
        *index = 3;
    }];

}

#pragma mark - 添加所有子控制器
- (void)setupAllChildViewController {
    NSArray *titles = @[@"关注",@"推荐",@"视频",@"热点",@"社会",@"中国好声音",@"瀑布流布局"];
    [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIViewController *vc = idx%2 ? [UIViewController new] : [YYWaterFlowController new];
        vc.title = titles[idx];
        vc.view.backgroundColor = RandColor;
        [self addChildViewController:vc];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
