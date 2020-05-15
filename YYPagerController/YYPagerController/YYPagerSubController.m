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
        *titleScrollViewHeight = 55;
    }];
    
    //titleScale范围在0到1之间  <0 或者 >1 则默认不缩放 默认设置titleScale就开启缩放，不设置则关闭
    [self settingTitleButton:^(UIColor *__autoreleasing *normalColor,
                               UIColor *__autoreleasing *selectedColor,
                               UIFont  *__autoreleasing *titleButtonFont,
                               CGFloat *titleButtonWidth,
                               CGFloat *titleScale,
                               CGFloat *titlePagerMargin,
                               BOOL    *isAutoFitWidth,
                               BOOL    *isOpenShade) {
        *normalColor = [UIColor blackColor];
        *selectedColor = [UIColor orangeColor];
        *titleButtonFont = [UIFont systemFontOfSize:16];
        *titleButtonWidth = YYScreenWidth() / 3;
        *titlePagerMargin = 20;
        *titleScale = .3;
        *isAutoFitWidth = NO;
        *isOpenShade = YES;
    }];
    
    [self settingDotTextLayer:^(UIColor *__autoreleasing *backgroundColor, UIColor *__autoreleasing *textColor, CGFloat *fontSize, BOOL *isHidden) {
        *isHidden = NO;
        *textColor = UIColor.blueColor;
        *backgroundColor = UIColor.lightGrayColor;
    }];
    
    //underlineSize设置底部underline指示器的长度，有默认值为按钮的宽度的百分之56  默认高度4
    [self settingUnderline:^(UIColor *__autoreleasing *underlineColor,
                             CGSize *underlineSize,
                             BOOL *isShowUnderline,
                             BOOL *isOpenStretch) {
        *underlineColor = [UIColor purpleColor];
        *isShowUnderline = YES;
        *isOpenStretch = YES;
        *underlineSize = CGSizeMake(30, 5);
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
