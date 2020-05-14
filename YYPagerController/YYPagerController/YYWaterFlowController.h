//
//  YYWaterFlowController.h
//  YYWeiBoPersonView
//
//  Created by MAC on 2017/10/18.
//  Copyright © 2017年 MAC. All rights reserved.
// 瀑布流布局

#import <UIKit/UIKit.h>

@interface YYWaterFlowController : UIViewController

@end

@interface YYWaterFlowLayout : UICollectionViewLayout

//瀑布流的列数
@property (nonatomic ,assign) NSInteger columnCount;

//cell边距
@property (nonatomic ,assign) NSInteger padding;

//cell的最小高度
@property (nonatomic ,assign) NSInteger cellMinHeight;

//cell的最大高度，最大高度比最小高度小，以最小高度为准
@property (nonatomic ,assign) NSInteger cellMaxHeight;

CGFloat YYScreenWidth(void);
CGFloat YYScreenHeight(void);
@end
