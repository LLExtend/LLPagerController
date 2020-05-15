//
//  YYPagerController.h
//  YYPagerController
//
//  Created by MAC on 2017/10/18.
//  Copyright © 2017年 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger ,YYPagerUnderlineSizeType) {
    YYPagerUnderlineSizeType_followButton = 0,
    YYPagerUnderlineSizeType_followTitleLabel,
    YYPagerUnderlineSizeType_underSize
};

@interface YYPagerController : UIViewController

@property (nonatomic ,copy) void (^titleButtonChangeClickBlock)(UIButton *fromButton, UIButton *toButton);

/**
 * selectIndexSetting 默认选中索引
 */
- (void)settingSelectIndex:(void(^)(NSInteger *index))selectIndexSetting ;

/**
 * *titleScrollViewBackgroundColor  titleScrollView背景色
 * *titleScrollViewHeight           titleScrollView的高度
 */
- (void)settingTitleScrollView:(void(^)(UIColor **titleScrollViewBackgroundColor,
                                        CGFloat  *titleScrollViewHeight
                                        ))titleScrollViewPropertySetting;

/**
 * *normalColor            标题字体未选中状态下颜色 默认[UIColor darkGrayColor]
 * *selectedColor          标题字体选中状态下颜色 默认[UIColor orangeColor]
 * *titleButtonFont        标题字体大小 默认[UIFont systemFontOfSize:15]
 * *titleButtonWidth       标题按钮的宽度 默认100
 * *titleScale             标题的字体缩放比例
 * *titlePagerMargin       标题之间的间距 默认10
 * *isAutoFitWidth         是否开启自动计算按钮宽度 默认NO (isAutoFitWidth优先级高于titleButtonWidth,当*isAutoFitWidth=YES时，*titleButtonWidth设置失效)
 * *isOpenShade            是否开启字体渐变效果 默认NO
 */
- (void)settingTitleButton:(void(^)(UIColor **normalColor ,
                                    UIColor **selectedColor ,
                                    UIFont  **titleButtonFont ,
                                    CGFloat  *titleButtonWidth ,
                                    CGFloat  *titleScale ,
                                    CGFloat  *titlePagerMargin ,
                                    BOOL     *isAutoFitWidth ,
                                    BOOL     *isOpenShade
                                    ))titleButtonPropertySetting;
/**
 * *backgroundColor        红点数据控件背景色
 * *textColor              红点文本颜色 默认[UIColor orangeColor]
 * *fontSize               红点文本大小 默认[UIFont systemFontOfSize:11]
 * *isHidden               是否隐藏红点数据显示 默认YES
*/
- (void)settingDotTextLayer:(void(^)(UIColor **backgroundColor ,
                                     UIColor **textColor ,
                                     CGFloat  *fontSize ,
                                     BOOL     *isHidden
                                     ))dotTextLayerPropertySetting;

/**
 * *underlineColor         字体下方指示器颜色 默认[UIColor purpleColor]
 * *underlineSize          字体下方指示器大小
 * *isShowUnderline        是否开启字体下方指示器 默认YES
 * *isOpenStretch          是否开启指示器拉伸效果 默认YES
 */
- (void)settingUnderline:(void(^)(UIColor **underlineColor ,
                                  YYPagerUnderlineSizeType *sizeType,
                                  CGSize   *underlineSize ,
                                  BOOL     *isShowUnderline,
                                  BOOL     *isOpenStretch
                                  ))underlinePropertySetting;


/// 刷新按钮上 扩展数据（未读标识）
/// @param dotText 标识展示数据
/// @param index 获取按钮下标
- (void)refreshDotText:(NSString *)dotText index:(NSInteger)index;

- (void)refreshDotText:(NSString *)dotText button:(UIButton *)button;


@end

@interface YYPagerUnderline : UIView
/** 进度条 */
@property (nonatomic, assign) CGFloat progress;
/** 尺寸 */
@property (nonatomic, strong) NSMutableArray *itemFrames;
/** 颜色 */
@property (nonatomic, assign) CGColorRef color;
/** 是否拉伸 */
@property (nonatomic, assign) BOOL isStretch;

@end


@interface YYPagerConsts : NSObject
///** 常量数 */
UIKIT_EXTERN CGFloat const YYPagerMargin;

/** 按钮tag附加值 */
UIKIT_EXTERN NSInteger const YYButtonTagValue;

/** 默认标题栏高度 */
UIKIT_EXTERN CGFloat const YYNormalTitleViewH;

/** 下划线默认高度 */
UIKIT_EXTERN CGFloat const YYUnderLineH;


CGSize YYScreenSize(void);

/** 默认标题字体 */
#define YYTitleFont [UIFont systemFontOfSize:15]

//色值
#define YYRGBA(r,g,b,a) [UIColor colorWithRed:r green:g blue:b alpha:a]
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)
#define RandColor RGB(arc4random_uniform(255), arc4random_uniform(255), arc4random_uniform(255))

@end

