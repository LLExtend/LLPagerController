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

typedef struct  {
    UIColor *titleScrollViewBackgroundColor;
    CGFloat  titleScrollViewHeight;
} YYTitleScrollViewCustomItem;

CG_INLINE YYTitleScrollViewCustomItem
YYTitleScrollViewCustomItemMake(UIColor *titleScrollViewBackgroundColor,
                                CGFloat  titleScrollViewHeight) {
    YYTitleScrollViewCustomItem item;
    item.titleScrollViewBackgroundColor = titleScrollViewBackgroundColor;
    item.titleScrollViewHeight          = titleScrollViewHeight;
    return item;
}

typedef struct  {
    YYPagerUnderlineSizeType sizeType; // size大小类型
    UIColor *underlineColor;  //字体下方指示器颜色 默认[UIColor purpleColor]
    CGSize   underlineSize;   //字体下方指示器大小
    BOOL     isShowUnderline; //是否开启字体下方指示器 默认YES
    BOOL     isOpenStretch;   //是否开启指示器拉伸效果 默认YES
} YYUnderLineCustomItem;

CG_INLINE YYUnderLineCustomItem
YYUnderLineCustomItemMake(YYPagerUnderlineSizeType sizeType,
                          BOOL      isShowUnderline,
                          BOOL      isOpenStretch,
                          UIColor   *underlineColor,
                          CGSize    underlineSize) {
    YYUnderLineCustomItem item;
    item.sizeType           = sizeType;
    item.isShowUnderline    = isShowUnderline;
    item.isOpenStretch      = isOpenStretch;
    item.underlineColor     = underlineColor;
    item.underlineSize      = underlineSize;
    return item;
}

typedef struct {
    BOOL     isHidden;
    CGFloat  dotFontSize;
    UIColor *backgroundColor;
    UIColor *textColor;
} YYNotReadDotCustomItem;

CG_INLINE YYNotReadDotCustomItem
YYNotReadDotCustomItemMake(BOOL isHidden,
                           CGFloat dotFontSize,
                           UIColor *backgroundColor,
                           UIColor *textColor) {
    YYNotReadDotCustomItem item;
    item.isHidden        = isHidden;
    item.dotFontSize     = dotFontSize;
    item.backgroundColor = backgroundColor;
    item.textColor       = textColor;
    return item;
}

typedef struct {
    UIColor *normalColor;     //标题字体未选中状态下颜色 默认[UIColor darkGrayColor]
    UIColor *selectedColor;   //标题字体选中状态下颜色 默认[UIColor orangeColor]
    UIFont  *titleButtonFont; //标题字体大小 默认[UIFont systemFontOfSize:15]
    
    CGFloat  titleScale;      //标题的字体缩放比例 默认不缩放为0。值区间[0-1]
    CGFloat  titlePagerMargin;//标题之间的间距 默认10
    CGFloat  titleButtonWidth;//标题按钮的宽度 默认100
    BOOL     isOpenShade;     //是否开启字体渐变效果 默认NO
    BOOL     isAutoFitWidth;  //是否开启自动计算按钮宽度 默认NO (isAutoFitWidth优先级高于titleButtonWidth,当isAutoFitWidth=YES时，titleButtonWidth设置失效)
    
} YYTitleButtonCustomItem;

CG_INLINE YYTitleButtonCustomItem
YYTitleButtonCustomItemMake(BOOL    isAutoFitWidth,
                            CGFloat titleButtonWidth,
                            CGFloat titlePagerMargin) {
    YYTitleButtonCustomItem item;
    item.isAutoFitWidth   = isAutoFitWidth;
    item.titleButtonWidth = titleButtonWidth;
    item.titlePagerMargin = titlePagerMargin;
    return item;
}


@interface YYPagerController : UIViewController

/// 按钮改变block
@property (nonatomic ,copy) void (^titleButtonChangeClickBlock)(UIButton *fromButton, UIButton *toButton);

/// 指定选中项
/// @param selectIndexSetting 回调配置（选中索引）
- (void)settingSelectIndex:(void(^)(NSInteger *index))selectIndexSetting;

/// 按钮承载视图配置
/// @param titleScrollViewCustomItemBlock 配置回调
- (void)settingTitleScrollViewCustomItem:(void (^)(YYTitleScrollViewCustomItem *item))titleScrollViewCustomItemBlock;

/// 按钮配置
/// @param titleButtonCustomItemBlock 配置回调
- (void)settingTitleButtonCustomItem:(void (^)(YYTitleButtonCustomItem *item))titleButtonCustomItemBlock;

/// 未读消息视图配置
/// @param notReadDotCustomItemBlock 配置回调
- (void)settingNotReadDotCustomItem:(void (^)(YYNotReadDotCustomItem *item))notReadDotCustomItemBlock;

/// 选择指示器配置
/// @param underLineCustomItemBlock 配置回调
- (void)settingUnderLineCustomItem:(void (^)(YYUnderLineCustomItem *item))underLineCustomItemBlock;

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


/** 按钮tag附加值 */
UIKIT_EXTERN NSInteger const YYButtonTagValue;

CGSize YYScreenSize(void);

//色值
#define YYRGBA(r,g,b,a) [UIColor colorWithRed:r green:g blue:b alpha:a]
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)
#define RandColor RGB(arc4random_uniform(255), arc4random_uniform(255), arc4random_uniform(255))

@end

