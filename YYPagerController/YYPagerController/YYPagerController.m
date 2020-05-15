//
//  YYPagerController.m
//  YYPagerController
//
//  Created by MAC on 2017/10/18.
//  Copyright © 2017年 MAC. All rights reserved.
//

#import "YYPagerController.h"

typedef struct {
    CGFloat r;
    CGFloat g;
    CGFloat b;
} YYColorRGB;

/** 按钮非选中颜色 */
const UIColor  *YYButtonNormalColor;

/** 按钮选中颜色 */
const UIColor *YYButtonSelectedColor;

@interface YYPagerController () <UIScrollViewDelegate> {
    
    /** 按钮承载容器 配置项 */
    YYTitleScrollViewCustomItem _titleScrollViewItem;
    
    /** 按钮显示 配置项 */
    YYTitleButtonCustomItem _titleButtonItem;
    
    /** 选择指示器 配置项 */
    YYUnderLineCustomItem _underLineItem;
    
    /** 未读消息 视图配置项 */
    YYNotReadDotCustomItem _dotItem;
    
    
    /* 上一次选择的按钮 */
    UIButton *_lastSelectButton;

    /** 滚动条 */
    YYPagerUnderline *_pagerUnderline;
    
    /** 选中索引 */
    NSInteger _selectIndex;
    
    /**
     开始颜色,取值范围0~1
     */
    YYColorRGB _startRGB;
    /**
     完成颜色,取值范围0~1
     */
    YYColorRGB _endRGB;
}

/* 标题滚动视图 */
@property (nonatomic, strong) UIScrollView *titleScrollView;
/* vc.view内容滚动视图 */
@property (nonatomic, strong) UIScrollView *contentScrollView;

/* 标题按钮数组 */
@property (nonatomic, strong) NSMutableArray *titleButtonArray;
/** 指示条的frames */
@property (nonatomic, strong) NSMutableArray *underlineFrames;

@end


/// 计算标题居中需要的偏移量
UIKIT_STATIC_INLINE CGFloat YYValueBorder (CGFloat underBorder,
                                           CGFloat topBorder) {
    underBorder = (underBorder < 0 ? 0 : underBorder);
    return underBorder > topBorder ? topBorder : underBorder;
}

/// CGFloat变量为负数的处理
UIKIT_STATIC_INLINE CGFloat YYUnderBorder(CGFloat underBorder) {
    return underBorder < 0 ? 0 : underBorder;
}

/// 当标题按钮的宽度在外界被误设置为0时的处理（默认值100）
/// titleButtons:按钮个数 widthValue:设置的宽度
/// 只有在*isAutoFitWidth=NO & *titleButtonWidth = 0时生效
UIKIT_STATIC_INLINE CGFloat YYTitleWidthHandle(CGFloat titleButtons,
                                               CGFloat widthValue) {
    CGFloat customW = 80;
    CGFloat screenWidth = YYScreenSize().width;
    CGFloat tmpWidth = (titleButtons * customW < screenWidth) ? screenWidth / titleButtons : customW + 20;
    return widthValue == 0 ? tmpWidth : widthValue;
}


/// 生成按钮底部进度线的frame
/// @param sizeType 类型
/// @param underlineSize 外部设置size（YYPagerUnderlineSizeType_followButton|YYPagerUnderlineSizeType_followTitleLabel 模式下 此设置只针对高度生效）
/// @param followButton 当前按钮
UIKIT_STATIC_INLINE NSValue * YYUnderLineFrame(
                                               YYPagerUnderlineSizeType sizeType,
                                               CGSize underlineSize,
                                               UIButton *followButton) {
    CGFloat frameX = 0;
    CGFloat frameW = 0;
    CGFloat frameH = 0;
    
    switch (sizeType) {
        case YYPagerUnderlineSizeType_underSize: {
            frameX = (CGRectGetWidth(followButton.frame) - underlineSize.width) / 2 + CGRectGetMinX(followButton.frame);
            frameW = underlineSize.width;
            frameH = underlineSize.height;
            break;
        }
        case YYPagerUnderlineSizeType_followButton: {
            frameX = CGRectGetMinX(followButton.frame);
            frameW = CGRectGetWidth(followButton.frame);
            frameH = MAX(underlineSize.height, 2);
            break;
        }
        case YYPagerUnderlineSizeType_followTitleLabel: {
            CGFloat textWidth = [followButton.currentTitle sizeWithAttributes:@{NSFontAttributeName : followButton.titleLabel.font}].width;
            frameX = (CGRectGetWidth(followButton.frame) - textWidth) / 2 + CGRectGetMinX(followButton.frame);
            frameW = textWidth;
            frameH = MAX(underlineSize.height, 2);
            break;
        }
    }
    CGFloat frameY = CGRectGetHeight(followButton.frame) - frameH - 1;
    CGRect frame = CGRectMake(frameX, frameY, frameW, frameH);
    return [NSValue valueWithCGRect:frame];
}

@implementation YYPagerController

#pragma mark - LifeCycle

- (void)dealloc {
    NSLog(@"%@ - dealloc",[self class]);
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupConfigerSetting];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupConfigerSetting];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //设置标题和内容的尺寸
    CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat topY = (self.navigationController.navigationBarHidden == NO) ? 44 + statusHeight : statusHeight;
    CGFloat topHeight = _titleScrollViewItem.titleScrollViewHeight;
    
    self.titleScrollView.frame = CGRectMake(0, topY, YYScreenSize().width, topHeight);
    self.contentScrollView.frame = CGRectMake(0, topY + topHeight, YYScreenSize().width, YYScreenSize().height - (topY + topHeight));
    
}

#pragma mark - 初始化默认配置
- (void)setupConfigerSetting {
    YYButtonNormalColor = UIColor.darkGrayColor;
    YYButtonSelectedColor = UIColor.orangeColor;
    
    _selectIndex = 0;

    _startRGB = [self generateColorRGBWithColor:_titleButtonItem.normalColor ?: YYButtonNormalColor];
    _endRGB = [self generateColorRGBWithColor:_titleButtonItem.selectedColor ?: YYButtonSelectedColor];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.titleScrollView.backgroundColor = _titleScrollViewItem.titleScrollViewBackgroundColor ?: UIColor.whiteColor;
    [self.view addSubview:self.titleScrollView];
    [self.view addSubview:self.contentScrollView];
    [self setupUI];
}


#pragma mark - 初始化UI
- (void)setupUI {
    NSInteger childControllerCount = self.childViewControllers.count;
    
    // 标题button坐标
    __block CGFloat buttonX = 0;
    __block CGFloat buttonW = 0;
    CGFloat buttonY = 0;
    CGFloat buttonH = _titleScrollViewItem.titleScrollViewHeight;

    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 初始化 标题按钮
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleButton setTitle:obj.title forState:UIControlStateNormal];
        [titleButton setTitleColor:_titleButtonItem.normalColor ?: YYButtonNormalColor forState:UIControlStateNormal];
        [titleButton addTarget:self action:@selector(titleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        titleButton.backgroundColor = [UIColor clearColor];
        titleButton.titleLabel.font = _titleButtonItem.titleButtonFont ?: [UIFont systemFontOfSize:15];
        titleButton.tag = idx + YYButtonTagValue;
        [self.titleScrollView addSubview:titleButton];
        [self.titleButtonArray addObject:titleButton];
        
        if (_titleButtonItem.isAutoFitWidth) {
            [titleButton sizeToFit];
            buttonX = buttonX + buttonW + _titleButtonItem.titlePagerMargin;
            buttonW = titleButton.bounds.size.width + _titleButtonItem.titlePagerMargin;
        } else {
            buttonX = idx * buttonW;
            buttonW = YYTitleWidthHandle(childControllerCount, _titleButtonItem.titleButtonWidth);
        }
        titleButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        
        // 进度线 frame 处理
        NSValue *underlineRectValue = YYUnderLineFrame(_underLineItem.sizeType, _underLineItem.underlineSize, titleButton);
        [self.underlineFrames addObject:underlineRectValue];

        if (!_dotItem.isHidden) {
            
            CATextLayer *textLayer = CATextLayer.layer;
            
            textLayer.string = [NSString stringWithFormat:@"%ld",titleButton.tag - YYButtonTagValue];
            textLayer.fontSize = _dotItem.dotFontSize;//_dotFontSize;
            
            // 设置frame
            [self autolayoutFrameWithButton:titleButton textlayer:textLayer];

            textLayer.cornerRadius = textLayer.frame.size.height / 2;
            textLayer.alignmentMode = kCAAlignmentCenter;
            textLayer.truncationMode = kCATruncationEnd;
            textLayer.contentsScale = UIScreen.mainScreen.scale;
            textLayer.backgroundColor = _dotItem.backgroundColor ? _dotItem.backgroundColor.CGColor:UIColor.orangeColor.CGColor;
            textLayer.foregroundColor = _dotItem.textColor ? _dotItem.textColor.CGColor:UIColor.whiteColor.CGColor;
            [titleButton.layer addSublayer:textLayer];
        }
    }];
    
    // 设置标题是否可以滚动
    _titleScrollView.contentSize = CGSizeMake(_titleButtonItem.isAutoFitWidth ? buttonX + buttonW + _titleButtonItem.titlePagerMargin : childControllerCount * buttonW, 0);
    
    // 设置滚动范围
    _contentScrollView.contentSize = CGSizeMake(childControllerCount * YYScreenSize().width, 0);
    
    if (_underLineItem.isShowUnderline) {
        CGRect underlineFrame = [self.underlineFrames[0] CGRectValue];
        _pagerUnderline = [[YYPagerUnderline alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(underlineFrame), _titleScrollView.contentSize.width, CGRectGetHeight(underlineFrame))];
        _pagerUnderline.itemFrames = self.underlineFrames;
        _pagerUnderline.color = _underLineItem.underlineColor ? _underLineItem.underlineColor.CGColor :UIColor.purpleColor.CGColor;
        _pagerUnderline.backgroundColor = [UIColor clearColor];
        [_titleScrollView addSubview:_pagerUnderline];
    }
    
    if ((_selectIndex < self.titleButtonArray.count) &&
        (self.titleButtonArray.count > 0)) {
        UIButton *button = self.titleButtonArray[_selectIndex];
        [self titleButtonClick:button];
    }
}

- (void)autolayoutFrameWithButton:(UIButton *)button textlayer:(CATextLayer *)textLayer {
    textLayer.hidden = _dotItem.isHidden;//_isHiddenDot;
    if ([textLayer.string length] == 0) {
        textLayer.hidden = YES;
        return;
    }
    
    CGFloat scale = 1;
    if (!CGAffineTransformIsIdentity(button.transform)) {
        scale = (1 + _titleButtonItem.titleScale);
    }
    
    CGSize textSize = [textLayer.string sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:textLayer.fontSize]}];
    CGSize titleSize = [button.currentTitle sizeWithAttributes:@{NSFontAttributeName : button.titleLabel.font}];
    
    CGFloat buttonOriWidth = (CGRectGetWidth(button.frame) / scale);
    CGFloat buttonOriHeight = (CGRectGetHeight(button.frame) / scale);
    CGFloat textMargin = 10;
    CGFloat textLayerX = 0;
    CGFloat textLayerY = (buttonOriHeight/2 - textSize.height/2 - textMargin);
    CGFloat textLayerW = MIN((textSize.width + textMargin), buttonOriWidth/2);
    CGFloat textLayerH = (textSize.height);
    if (_titleButtonItem.isAutoFitWidth) {
        textLayerX = buttonOriWidth - textMargin;
    } else {
        CGFloat x = buttonOriWidth / 2 + titleSize.width / 2;
        textLayerX = MIN(x, buttonOriWidth - textLayerW);
    }
    textLayer.frame = CGRectMake(textLayerX, textLayerY, textLayerW, textLayerH);
}

#pragma mark - 刷新指定按钮 的未读消息
- (void)refreshDotText:(NSString *)dotText index:(NSInteger)index {
    if (index >= self.titleButtonArray.count) {
        // 越界处理
        return ;
    }
    
    UIButton *button = self.titleButtonArray[index];
    [self refreshDotText:dotText button:button];
}

- (void)refreshDotText:(NSString *)dotText button:(UIButton *)button {
    NSArray *layers = button.layer.sublayers;
    int i = 0;
    while (i < layers.count) {
        if ([layers[i] isKindOfClass:CATextLayer.class]) {
            CATextLayer *l = layers[i];
            
            // 坐标处理 超出99 显示99+
            if (dotText.intValue > 99) {
                l.string = @"99+";
            } else {
                l.string = dotText;
            }
            
            [self autolayoutFrameWithButton:button textlayer:l];

            break;
        }
        i++;
    }
}

#pragma mark - 标题点击
- (void)titleButtonClick:(UIButton *)button {
    _pagerUnderline.isStretch = NO;
    [self selectButton:button];
}

- (void)selectButton:(UIButton *)button {
    if (button == _lastSelectButton) return;
    
    _lastSelectButton.transform = CGAffineTransformIdentity;
    [_lastSelectButton setTitleColor:_titleButtonItem.normalColor ?: YYButtonNormalColor forState:UIControlStateNormal];
    [button setTitleColor:_titleButtonItem.selectedColor ?: YYButtonSelectedColor forState:UIControlStateNormal];
    
    // 标题居中
    CGFloat offsetX = YYValueBorder(button.center.x - YYScreenSize().width * 0.5, _titleScrollView.contentSize.width - YYScreenSize().width);
    NSInteger buttonTag = button.tag - YYButtonTagValue;
    [UIView animateWithDuration:.25 animations:^{
        // 最后一个按钮的坐标maxX <= 父容器_titleScrollView宽度时，不设置偏移
        UIButton *button = self.titleButtonArray.lastObject;
        if (CGRectGetMaxX(button.frame) > CGRectGetWidth(_titleScrollView.frame)) {
            [_titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
        }
        
    } completion:^(BOOL finished) {
        if (finished) {
            
            // 滚动到相应的位置
            [_contentScrollView setContentOffset:CGPointMake(buttonTag * YYScreenSize().width, 0) animated:YES];
            
            // 添加控制器View
            [self addChildViewForIndex:buttonTag];
            
            if (self.titleButtonChangeClickBlock) {
                self.titleButtonChangeClickBlock(_lastSelectButton, button);
            }
            
            // 点击按钮时 缩放功能 单独处理，不受scrollViewDidScroll:处理
            if (!_pagerUnderline.isStretch) {
                _lastSelectButton.transform = CGAffineTransformIdentity;
                button.transform = CGAffineTransformMakeScale(1 + _titleButtonItem.titleScale, 1 + _titleButtonItem.titleScale);
            }
            
            _lastSelectButton = button;
            _pagerUnderline.isStretch = NO;
        }
    }];
}

#pragma mark - 底部滚动条滚动
- (void)bottomBarNaughtyWithOffset:(CGFloat)offsetx {
    _pagerUnderline.progress = YYUnderBorder(offsetx) / YYScreenSize().width;
}

// 添加控制器View
- (void)addChildViewForIndex:(NSInteger)i {
    UIViewController *vc = self.childViewControllers[i];
    if (vc.view.superview) return;
    vc.view.frame = CGRectMake(i * YYScreenSize().width, 0,YYScreenSize().width , _contentScrollView.frame.size.height);
    [_contentScrollView addSubview:vc.view];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger tagI = scrollView.contentOffset.x / YYScreenSize().width;
    UIButton *button = self.titleButtonArray[tagI];
    [self selectButton:button];
    [self addChildViewForIndex:tagI];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //是否有拉伸
    _pagerUnderline.isStretch = _underLineItem.isOpenStretch;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self bottomBarNaughtyWithOffset:scrollView.contentOffset.x];
    
    // 手动点击按钮时 单独处理缩放
    if (!_pagerUnderline.isStretch) {
        return;
    }

    NSInteger tagI = scrollView.contentOffset.x / YYScreenSize().width;
    
    NSInteger leftI = tagI;
    NSInteger rightI = tagI + 1;
    
    //缩放
    UIButton *leftButton = self.titleButtonArray[leftI];
    UIButton *rightButton= ((rightI < self.titleButtonArray.count) ? self.titleButtonArray[rightI] : nil);
    
    CGFloat scaleR = scrollView.contentOffset.x / YYScreenSize().width;
    scaleR -= leftI;
    
    CGFloat scaleL = 1 - scaleR;
    
    //缩放尺寸限定
    if (_titleButtonItem.titleScale > 0 && _titleButtonItem.titleScale < 1) {
        leftButton.transform = CGAffineTransformMakeScale(scaleL * _titleButtonItem.titleScale + 1, scaleL * _titleButtonItem.titleScale + 1);
        rightButton.transform = CGAffineTransformMakeScale(scaleR * _titleButtonItem.titleScale + 1, scaleR * _titleButtonItem.titleScale + 1);
    }
    
    // 开启渐变
    if (_titleButtonItem.isOpenShade) {
        //颜色渐变
        CGFloat r = _endRGB.r - _startRGB.r;
        CGFloat g = _endRGB.g - _startRGB.g;
        CGFloat b = _endRGB.b - _startRGB.b;
        
        UIColor *rightColor = YYRGBA(_startRGB.r + r * scaleR, _startRGB.g + g * scaleR, _startRGB.b + b * scaleR, 1);
        UIColor *leftColor = YYRGBA(_startRGB.r +  r * scaleL, _startRGB.g +  g * scaleL, _startRGB.b +  b * scaleL, 1);
        [rightButton setTitleColor:rightColor forState:UIControlStateNormal];
        [leftButton setTitleColor:leftColor forState:UIControlStateNormal];
    }
}

#pragma mark - setting
- (void)settingSelectIndex:(void (^)(NSInteger *))selectIndexSetting {
    if (selectIndexSetting) {
        selectIndexSetting(&_selectIndex);
    }
}

- (void)settingTitleScrollViewCustomItem:(void (^)(YYTitleScrollViewCustomItem *))titleScrollViewCustomItemBlock {
    if (titleScrollViewCustomItemBlock) {
        titleScrollViewCustomItemBlock(&_titleScrollViewItem);
    }
}

- (void)settingTitleButtonCustomItem:(void (^)(YYTitleButtonCustomItem *))titleButtonCustomItemBlock {

    if (titleButtonCustomItemBlock) {
        titleButtonCustomItemBlock(&_titleButtonItem);

        _startRGB = [self generateColorRGBWithColor:_titleButtonItem.normalColor ?: YYButtonNormalColor];
        _endRGB = [self generateColorRGBWithColor:_titleButtonItem.selectedColor ?: YYButtonSelectedColor];
    }
}

- (void)settingNotReadDotCustomItem:(void (^)(YYNotReadDotCustomItem *))notReadDotCustomItemBlock {
    if (notReadDotCustomItemBlock) {
        notReadDotCustomItemBlock(&_dotItem);
    }
}

- (void)settingUnderLineCustomItem:(void (^)(YYUnderLineCustomItem *))underLineCustomItemBlock {
    if (underLineCustomItemBlock) {
        underLineCustomItemBlock(&_underLineItem);
    }
}

#pragma mark - private method
- (YYColorRGB)generateColorRGBWithColor:(UIColor *)color {
    
    CGFloat components[3];
    
    [self getRGBComponents:components forColor:color];
    
    YYColorRGB colorRGB ;
    colorRGB.r = components[0];
    colorRGB.g = components[1];
    colorRGB.b = components[2];
    return colorRGB;
}


/**
 *  指定颜色，获取颜色的RGB值
 *
 *  @param components RGB数组
 *  @param color      颜色
 */
- (void)getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color {
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,1,1,8,4,rgbColorSpace,1);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component] / 255.0f;
    }
}

#pragma mark - LazyLoad
- (UIScrollView *)titleScrollView {
    if (!_titleScrollView) {
        _titleScrollView = [UIScrollView new];
        _titleScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _titleScrollView;
}

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        _contentScrollView = [UIScrollView new];
        _contentScrollView.backgroundColor = [UIColor whiteColor];
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.bounces = NO;
        _contentScrollView.delegate = self;
    }
    return _contentScrollView;
}

- (NSMutableArray *)titleButtonArray {
    if (!_titleButtonArray) {
        _titleButtonArray = [NSMutableArray array];
    }
    return _titleButtonArray;
}

- (NSMutableArray *)underlineFrames {
    if (!_underlineFrames) {
        _underlineFrames = [NSMutableArray array];
    }
    return _underlineFrames;
}

@end

@implementation YYPagerUnderline
#pragma mark - 颜色
- (CGColorRef)color {
    if (!_color) self.color = [UIColor whiteColor].CGColor;
    return _color;
}

#pragma mark - 进度条
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

#pragma mark - 重绘
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat height = self.frame.size.height;
    int index = (int)self.progress;
    index = (index <= self.itemFrames.count - 1) ? index : (int)self.itemFrames.count - 1;
    CGFloat rate = self.progress - index;
    CGRect currentFrame = [self.itemFrames[index] CGRectValue];
    CGFloat currentWidth = currentFrame.size.width;
    int nextIndex = index + 1 < self.itemFrames.count ? index + 1 : index;
    CGFloat nextWidth = [self.itemFrames[nextIndex] CGRectValue].size.width;
    
    CGFloat currentX = currentFrame.origin.x;
    CGFloat nextX = [self.itemFrames[nextIndex] CGRectValue].origin.x;
    CGFloat startX = currentX + (nextX - currentX) * rate;
    CGFloat width = currentWidth + (nextWidth - currentWidth)*rate;
    CGFloat endX = startX + width;
    
    CGFloat nextMaxX = nextX + nextWidth;
    
    //开启拉伸效果
    if (_isStretch) {
        if (rate <= 0.5) {
            startX = currentX ;
            CGFloat currentMaxX = currentX + currentWidth;
            endX = currentMaxX + (nextMaxX - currentMaxX) * rate * 2.0;
        } else {
            startX = currentX + (nextX - currentX) * (rate - 0.5) * 2.0;
            CGFloat nextMaxX = nextX + nextWidth;
            endX = nextMaxX ;
        }
    }
    
    width = endX - startX;
    CGFloat lineWidth =  1.0;
    CGFloat cornerRadius = (height >= 4) ? 2.0 : 1.0;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(startX, lineWidth / 2.0, width, height - lineWidth) cornerRadius:cornerRadius];
    CGContextAddPath(ctx, path.CGPath);
    
    CGContextSetFillColorWithColor(ctx, self.color);
    CGContextFillPath(ctx);
}

@end

@implementation YYPagerConsts

/** 按钮tag附加值 */
NSInteger const YYButtonTagValue = 0x808;

CGSize YYScreenSize() {
    static CGSize size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        size = [UIScreen mainScreen].bounds.size;
        if (size.height < size.width) {
            CGFloat tmp = size.height;
            size.height = size.width;
            size.width = tmp;
        }
    });
    return size;
}
@end

