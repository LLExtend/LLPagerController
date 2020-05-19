//
//  LLWaterFlowController.m
//  LLWeiBoPersonView
//
//  Created by MAC on 2017/10/18.
//  Copyright © 2017年 MAC. All rights reserved.
//

#import "LLWaterFlowController.h"

static NSString *const reuseIdentifier = @"collectionCell";
@interface LLWaterFlowController () <UICollectionViewDelegate ,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView * collectionView;
@end

@implementation LLWaterFlowController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCollectionView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _collectionView.frame = self.view.bounds;
}

- (void)initCollectionView {
    LLWaterFlowLayout *flowLayout = [[LLWaterFlowLayout alloc] init];
    flowLayout.padding = 5;
    flowLayout.columnCount = arc4random()%4+1;
    flowLayout.cellMaxHeight = 200;
    flowLayout.cellMinHeight = 100;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, LLScreenWidth(), LLScreenHeight()) collectionViewLayout:flowLayout];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    //设置代理
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor colorWithRed:242/255. green:242/255. blue:242/255. alpha:1.];
    _collectionView.directionalLockEnabled = YES;
    [self.view addSubview:_collectionView];
}

#pragma mark -- UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor =  [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@",indexPath.description);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end



@implementation LLWaterFlowLayout {
    //section的数量
    NSInteger _numberOfSections;
    //section中cell的数量
    NSInteger _numberOfCellsInSections;
    
    //cell的宽度
    CGFloat _cellWidth;
    
    //存储每列cell的X坐标
    NSMutableArray *_cellXArray;
    
    //存储每个cell的随机高度，避免每次加载的随机高度都不同
    NSMutableArray *_cellHeightArray;
    
    //记录每列cell的最新cell的Y坐标
    NSMutableArray *_cellYArray;
}

- (instancetype)init {
    if (self = [super init]) {
        // 初始化相关数据
        _columnCount = 3;
        _padding = 2;
        _cellMinHeight = 50;
        _cellMaxHeight = 200;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    _numberOfSections = [self.collectionView numberOfSections];
    _numberOfCellsInSections = [self.collectionView numberOfItemsInSection:0];
    [self initCellWidth];
    [self randomCellHeight];
}

/**
 * 决定cell的排布
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    [self initCellYArray];
    NSMutableArray *array = [NSMutableArray array];
    //add cells
    for (int i = 0; i < _numberOfCellsInSections; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [array addObject:attributes];
    }
    return array;
}

/**
 * 返回indexPath位置cell对应的布局属性
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGRect frame = CGRectZero;
    CGFloat cellHeight = [_cellHeightArray[indexPath.row] floatValue];
    NSInteger minYIndex = [self minCellYArrayWithArray:_cellYArray];
    CGFloat tempX = [_cellXArray[minYIndex] floatValue];
    CGFloat tempY = [_cellYArray[minYIndex] floatValue];
    frame = CGRectMake(tempX, tempY, _cellWidth, cellHeight);
    
    //更新相应的Y坐标
    _cellYArray[minYIndex] = @(tempY + cellHeight + _padding);
    
    //计算每个cell的位置
    attributes.frame = frame;
    
    return attributes;
}

// 能滚动，就得有滚动的范围
- (CGSize)collectionViewContentSize {
    //cellYArray数组中的最大值
    CGFloat maxY = [[_cellYArray valueForKeyPath:@"@max.floatValue"] floatValue];
    return CGSizeMake(LLScreenWidth(), maxY);
}

/**
 * 根据cell的列数求出cell的宽度
 */
- (void)initCellWidth {
    //计算每个cell的宽度
    _cellWidth = (LLScreenWidth() - (_columnCount -1) * _padding) / _columnCount;
    
    //为每个cell计算X坐标
    _cellXArray = [[NSMutableArray alloc] initWithCapacity:_columnCount];
    for (int i = 0; i < _columnCount; i ++) {
        CGFloat tempX = i * (_cellWidth + _padding);
        [_cellXArray addObject:@(tempX)];
    }
}

/**
 * 随机生成cell的高度
 */
- (void)randomCellHeight {
    //随机生成Cell的高度
    _cellHeightArray = [[NSMutableArray alloc] initWithCapacity:_numberOfCellsInSections];
    for (int i = 0; i < _numberOfCellsInSections; i ++) {
        CGFloat cellHeight = arc4random() % (_cellMaxHeight - _cellMinHeight) + _cellMinHeight;
        [_cellHeightArray addObject:@(cellHeight)];
    }
}

/**
 * 初始化每列cell的Y轴坐标
 */
- (void)initCellYArray {
    _cellYArray = [[NSMutableArray alloc] initWithCapacity:_columnCount];
    
    for (int i = 0; i < _columnCount; i ++) {
        [_cellYArray addObject:@(0)];
    }
}

/**
 * 求cellY数组中的最小值的索引
 */
- (CGFloat)minCellYArrayWithArray:(NSMutableArray *)array {
    if (array.count == 0) return 0.0f;
    __block NSInteger minIndex = 0;
    __block CGFloat min = [array[0] floatValue];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat temp = [obj floatValue];
        if (min > temp) {
            min = temp;
            minIndex = idx;
        }
    }];
    return minIndex;
}

CGFloat LLScreenWidth(void) {
    return [UIScreen mainScreen].bounds.size.width;
}

CGFloat LLScreenHeight(void) {
    return [UIScreen mainScreen].bounds.size.height;
}

@end
