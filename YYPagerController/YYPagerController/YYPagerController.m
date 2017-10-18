//
//  YYPagerController.m
//  YYPagerController
//
//  Created by MAC on 2017/10/18.
//  Copyright © 2017年 MAC. All rights reserved.
//

#import "YYPagerController.h"

@interface YYPagerController () <UIScrollViewDelegate> {
    /** 标题背景色 */
    UIColor *_titleScrollViewBgColor;
    /** 指示器颜色 */
    UIColor *_proColor;
    /** 标题字体 */
    UIFont *_titleFont;
    /** 字体缩放比例 */
    CGFloat _titleScale;
    /** 标题按钮的宽度 */
    CGFloat _titleButtonWidth;
    /** 标题按钮下划线的size */
    CGSize _underlineSize;
    /** 标题ScrollView的高度 */
    CGFloat _titleViewHeight;
    
    
    /* 标题按钮 */
    UIButton *_titleButton;
    /* 上一次选择的按钮 */
    UIButton *_lastSelectButton;
    /** 是否加载过标题 */
    BOOL _isLoadTitles;
    
    /** 滚动条 */
    YYPagerUnderline *_pagerUnderline;
    
    /** 选中索引 */
    NSInteger _selectIndex;
    
    /* 是否显示底部指示器 */
    BOOL _isShowUnderline;
    /* 是否加载弹簧动画 */
    BOOL _isOpenStretch;
    /* 是否开启渐变 */
    BOOL _isOpenShade;
    /** 是否开启自动计算按钮宽度 */
    BOOL _isAutoFitWidth;
    
    /**
     开始颜色,取值范围0~1
     */
    CGFloat _startR;
    CGFloat _startG;
    CGFloat _startB;
    
    /**
     完成颜色,取值范围0~1
     */
    CGFloat _endR;
    CGFloat _endG;
    CGFloat _endB;
}

/** 正常标题颜色 */
@property (nonatomic, strong) UIColor *norColor;
/** 选中标题颜色 */
@property (nonatomic, strong) UIColor *selColor;

/* 标题滚动视图 */
@property (nonatomic, strong) UIScrollView *titleScrollView;
/* vc.view内容滚动视图 */
@property (nonatomic, strong) UIScrollView *contentScrollView;

/* 标题按钮数组 */
@property (nonatomic, strong) NSMutableArray *titleButtonArray;
/** 指示条的frames */
@property (nonatomic, strong) NSMutableArray *underlineFrames;

@end

@implementation YYPagerController

#pragma mark - LazyLoad
- (UIScrollView *)titleScrollView {
    if (!_titleScrollView) {
        _titleScrollView = [UIScrollView new];
        _titleScrollView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:_titleScrollView];
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
        [self.view addSubview:_contentScrollView];
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

#pragma mark - LifeCyle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_isLoadTitles == NO) {
        [self setupAllTitleButton];
        _isLoadTitles = YES;
    }
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

#pragma mark - initialize
- (void)setupConfigerSetting {
    
    _titleScrollViewBgColor = [UIColor whiteColor]; //标题View背景色（默认标题背景色为白色）
    _norColor = [UIColor darkGrayColor];            //标题未选中颜色（默认未选中状态下字体颜色为黑色）
    _selColor = [UIColor orangeColor];              //标题选中颜色（默认选中状态下字体颜色为桔色）
    _proColor = [UIColor purpleColor];              //滚动条颜色（默认为标题选中颜色）
    _titleFont = [UIFont systemFontOfSize:15];      //字体尺寸
    _titleButtonWidth = 100;                        //标题按钮的宽度
    _isShowUnderline = YES;                         //是否开启标题下部Pregress指示器
    _isOpenStretch = YES;                           //是否开启指示器拉伸效果
    _isOpenShade = YES;                             //是否开启字体渐变
    _isAutoFitWidth = NO;                           //是否自动计算标题按钮的宽度
    _isLoadTitles = NO;
    _selectIndex = 0;
    //    _underlineSize = CGSizeMake(40, 4);
    _titleViewHeight = YYNormalTitleViewH;
    
    [self setupStartColor:_norColor];
    [self setupEndColor:_selColor];
    
    self.titleScrollView.backgroundColor = _titleScrollViewBgColor;
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //设置标题和内容的尺寸
    CGFloat statusH = [UIApplication sharedApplication].statusBarFrame.size.height; //20
    CGFloat tY = (self.navigationController.navigationBarHidden == NO) ? YYNormalTitleViewH + statusH: statusH;
    CGFloat tH = _titleViewHeight;
    
    self.titleScrollView.frame = CGRectMake(0, tY, YYScreenSize().width, tH);
    self.contentScrollView.frame = CGRectMake(0, tY + tH, YYScreenSize().width, YYScreenSize().height - (tY + tH));
}

// 计算标题居中需要的偏移量
UIKIT_STATIC_INLINE CGFloat YYValueBorder (CGFloat underBorder ,CGFloat topBorder) {
    underBorder = (underBorder < 0 ? 0 : underBorder);
    return underBorder > topBorder ? topBorder : underBorder;
}

// CGFloat变量为负数的处理
UIKIT_STATIC_INLINE CGFloat YYUnderBorder(CGFloat underBorder) {
    return underBorder < 0 ? 0 : underBorder;
}

// 当标题按钮的宽度在外界被误设置为0时的处理（默认值100）
// titleButtons:按钮个数 widthValue:设置的宽度
// 只有在*isAutoFitWidth=NO & *titleButtonWidth = 0时生效
UIKIT_STATIC_INLINE CGFloat YYTitleWidthHandle(CGFloat titleButtons ,CGFloat widthValue) {
    CGFloat customW = 80;
    CGFloat screenWidth = YYScreenSize().width;
    CGFloat tmpWidth = (titleButtons * customW < screenWidth) ? screenWidth / titleButtons : customW + 20;
    return widthValue == 0 ? tmpWidth : widthValue;
}

// 标题按钮下的线的frame
// underlineWidth:线的宽
// underlineHeight:线的高
// followWidth:按钮的宽
// followX:按钮的x
// followHeight:按钮的高
UIKIT_STATIC_INLINE NSValue * YYUnderLineFrames(CGFloat underlineWidth ,CGFloat underlineHeight ,CGFloat followWidth ,CGFloat followX ,CGFloat followHeight) {
    //进度条比button短多少
    CGFloat pace = (underlineWidth && underlineWidth < followWidth) ? (followWidth - underlineWidth) / 2 : followWidth * 0.22;
    CGFloat frameX = followX + pace;
    CGFloat frameW = followWidth - 2 * pace;
    CGFloat frameY = followHeight - (underlineHeight + 1);
    CGRect frame = CGRectMake(frameX, frameY, frameW, underlineHeight);
    return [NSValue valueWithCGRect:frame];
}

// 标题按钮下的线的高
UIKIT_STATIC_INLINE CGFloat YYUnderlineHeight(CGFloat lineHeight) {
    return (lineHeight && lineHeight < YYPagerMargin && lineHeight > 0) ?  lineHeight : YYUnderLineH;
}

// 标题按钮下的线的宽
UIKIT_STATIC_INLINE CGFloat YYUnderlineWidth(UIButton *titleButton ,CGSize underlineSize ,CGFloat followWidth) {
    if (underlineSize.width==0 && followWidth *.56>titleButton.bounds.size.width) {
        return titleButton.bounds.size.width;
    } else if(underlineSize.width>0 && titleButton.bounds.size.width > underlineSize.width) {
        return underlineSize.width;
    } else {
        return titleButton.bounds.size.width ;
    }
}

#pragma mark - 设置标题
- (void)setupAllTitleButton {
    NSInteger VCCount = self.childViewControllers.count;
    
    // 标题button坐标
    __block CGFloat buttonX = 0;
    CGFloat buttonY = 0;
    __block CGFloat buttonW = 0;
    CGFloat buttonH = _titleViewHeight;

    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 初始化 标题按钮
        _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_titleButton setTitle:obj.title forState:UIControlStateNormal];
        [_titleButton setTitleColor:self.norColor forState:UIControlStateNormal];
        [_titleButton addTarget:self action:@selector(titleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _titleButton.backgroundColor = [UIColor clearColor];
        _titleButton.titleLabel.font = (!_titleFont) ? YYTitleFont : _titleFont;
        _titleButton.tag = idx + YYButtonTagValue;
        [_titleScrollView addSubview:_titleButton];
        [self.titleButtonArray addObject:_titleButton];
        
        CGFloat tempUnderlineWidth = 0;
        [_titleButton sizeToFit];
        if (_isAutoFitWidth) {
            buttonX = buttonX + buttonW + YYPagerMargin;
            buttonW = _titleButton.bounds.size.width + YYPagerMargin;
        } else {
            buttonX = idx * buttonW;
            buttonW = YYTitleWidthHandle(VCCount, _titleButtonWidth);
            tempUnderlineWidth = YYUnderlineWidth(_titleButton, _underlineSize, buttonW);
        }
        _titleButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        
        // 底部选中线条的frame数组
        [self.underlineFrames addObject:YYUnderLineFrames(tempUnderlineWidth, YYUnderlineHeight(_underlineSize.height), buttonW, buttonX, buttonH)];
    }];
    
    if (_isShowUnderline) {
        _pagerUnderline = [[YYPagerUnderline alloc] initWithFrame:CGRectMake(0, buttonH - (YYUnderlineHeight(_underlineSize.height) + 1), VCCount * buttonW, YYUnderlineHeight(_underlineSize.height))];
        _pagerUnderline.itemFrames = self.underlineFrames;
        _pagerUnderline.color = _proColor.CGColor;
        _pagerUnderline.backgroundColor = [UIColor clearColor];
        [_titleScrollView addSubview:_pagerUnderline];
    }
    
    //设置标题是否可以滚动
    _titleScrollView.contentSize = CGSizeMake(_isAutoFitWidth ? buttonX + buttonW + YYPagerMargin : VCCount * buttonW, 0);
    //设置滚动范围
    _contentScrollView.contentSize = CGSizeMake(VCCount * YYScreenSize().width, 0);
    
    if ((_selectIndex < self.titleButtonArray.count) && (self.titleButtonArray.count > 0)) {
        [self titleButtonClick:self.titleButtonArray[_selectIndex]];
    }
}

#pragma mark - 选中标题
- (void)selectButton:(UIButton *)button {
    _lastSelectButton.transform = CGAffineTransformIdentity;
    [_lastSelectButton setTitleColor:self.norColor forState:UIControlStateNormal];
    [button setTitleColor:self.selColor forState:UIControlStateNormal];
    
    //字体缩放
    if (_titleScale > 0 && _titleScale < 1) {
        button.transform = CGAffineTransformMakeScale(1 + _titleScale, 1 + _titleScale);
    }
    _lastSelectButton = button;
    
    //标题居中
    CGFloat offsetX = YYValueBorder(button.center.x - YYScreenSize().width * 0.5, _titleScrollView.contentSize.width - YYScreenSize().width);
    NSInteger buttonTag = button.tag - YYButtonTagValue;
    [UIView animateWithDuration:.25 animations:^{
        [_titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    } completion:^(BOOL finished) {
        if (finished) {
            _pagerUnderline.isStretch = NO;
            //滚动到相应的位置
            _contentScrollView.contentOffset = CGPointMake(buttonTag * YYScreenSize().width, 0);
            //添加控制器View
            [self addChildViewForIndex:buttonTag];
        }
    }];
}

#pragma mark - 底部滚动条滚动
- (void)bottomBarNaughtyWithOffset:(CGFloat)offsetx {
    _pagerUnderline.progress = YYUnderBorder(offsetx) / YYScreenSize().width;
}

//添加控制器View
- (void)addChildViewForIndex:(NSInteger)i {
    UIViewController *vc = self.childViewControllers[i];
    if (vc.view.superview) return;
    vc.view.frame = CGRectMake(i * YYScreenSize().width, 0,YYScreenSize().width , _contentScrollView.frame.size.height);
    [_contentScrollView addSubview:vc.view];
}


#pragma mark - 标题点击
- (void)titleButtonClick:(UIButton *)button {
    _pagerUnderline.isStretch = NO;
    [self selectButton:button];
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger tagI = scrollView.contentOffset.x / YYScreenSize().width;
    UIButton *button = self.titleButtonArray[tagI];
    
    [self selectButton:button];
    [self addChildViewForIndex:tagI];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //是否有拉伸
    _pagerUnderline.isStretch = _isOpenStretch;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self bottomBarNaughtyWithOffset:scrollView.contentOffset.x];
    
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
    if (_titleScale > 0 && _titleScale < 1) {
        leftButton.transform = CGAffineTransformMakeScale(scaleL * _titleScale + 1, scaleL * _titleScale + 1);
        rightButton.transform = CGAffineTransformMakeScale(scaleR * _titleScale + 1, scaleR * _titleScale + 1);
    }
    
    //开启渐变
    if (_isOpenShade) {
        //颜色渐变
        CGFloat r = _endR - _startR;
        CGFloat g = _endG - _startG;
        CGFloat b = _endB - _startB;
        
        UIColor *rightColor = YYRGBA(_startR + r * scaleR, _startG + g * scaleR, _startB + b * scaleR, 1);
        UIColor *leftColor = YYRGBA(_startR +  r * scaleL, _startG +  g * scaleL, _startB +  b * scaleL, 1);
        [rightButton setTitleColor:rightColor forState:UIControlStateNormal];
        [leftButton setTitleColor:leftColor forState:UIControlStateNormal];
    }
}

- (void)settingSelectIndex:(void (^)(NSInteger *))selectIndexSetting {
    if (selectIndexSetting) {
        selectIndexSetting(&(_selectIndex));
    }
}

#pragma mark - setting titleScrollView
- (void)settingTitleScrollView:(void (^)(UIColor *__autoreleasing *, CGFloat *))titleScrollViewPropertySetting {
    UIColor *titleScrollViewBgColor;
    if (titleScrollViewPropertySetting) {
        titleScrollViewPropertySetting(&titleScrollViewBgColor ,&_titleViewHeight);
        _titleScrollViewBgColor = titleScrollViewBgColor;
    }
}

#pragma mark - setting titleButton
- (void)settingTitleButton:(void (^)(UIColor *__autoreleasing *, UIColor *__autoreleasing *, UIFont *__autoreleasing *, CGFloat *, CGFloat *, BOOL *, BOOL *))titleButtonPropertySetting {
    UIColor *norColor;
    UIColor *selColor;
    UIFont *titleFont;
    
    if (titleButtonPropertySetting) {
    titleButtonPropertySetting(&norColor ,&selColor ,&titleFont ,&_titleButtonWidth ,&_titleScale ,&_isAutoFitWidth ,&_isOpenShade);
        _norColor = norColor;
        _selColor = selColor;
        _titleFont = titleFont;
        
        [self setupStartColor:norColor];
        [self setupEndColor:selColor];
    }
}

#pragma mark - setting underline
- (void)settingUnderline:(void (^)(UIColor *__autoreleasing *, CGSize *, BOOL *, BOOL *))underlinePropertySetting {
    //如果隐藏指示器则返回
    if (!_isShowUnderline) return ;
    
    UIColor *underlineColor;
    if (underlinePropertySetting) {
        underlinePropertySetting(&underlineColor ,&_underlineSize ,&_isShowUnderline ,&_isOpenStretch);
        _proColor = underlineColor;
    }
}

- (void)setupStartColor:(UIColor *)color {
    CGFloat components[3];
    
    [self getRGBComponents:components forColor:color];
    
    _startR = components[0];
    _startG = components[1];
    _startB = components[2];
}

- (void)setupEndColor:(UIColor *)color {
    CGFloat components[3];
    
    [self getRGBComponents:components forColor:color];
    
    _endR = components[0];
    _endG = components[1];
    _endB = components[2];
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

- (void)dealloc {
    NSLog(@"%@ - dealloc",[self class]);
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
    
    if (_isStretch) //开启拉伸效果
    {
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
/** 常量数 */
CGFloat const YYPagerMargin = 10;

/** 按钮tag附加值 */
NSInteger const YYButtonTagValue = 0x808;

/** 默认标题栏高度 */
CGFloat const YYNormalTitleViewH = 44;

/** 下划线默认高度 */
CGFloat const YYUnderLineH = 4;

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

