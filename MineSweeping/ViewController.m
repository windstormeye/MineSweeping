//
//  ViewController.m
//  MineSweeping
//
//  Created by #incloud on 17/2/21.
//  Copyright © 2017年 #incloud. All rights reserved.
//

#import "ViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width  // 屏幕宽度
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height  // 屏幕长度
#define BLUE_COLOR [UIColor colorWithRed:0 green:191/255.0 blue:1 alpha:1]
#define MAPVIEW_X (SCREEN_WIDTH - 15 * 40) / 2  // 按钮背景X坐标
#define MAPVIEW_Y (SCREEN_HEIGHT - 15 * 40) / 2  // 按钮背景Y坐标
#define MAPVIEW_WIDTH 15 * 40  // 按钮背景宽度
#define MAPVIEW_HEIGHT 15 * 40  // 按钮背景长度
#define BUTTON_TAG 100  // 按钮标签值


@interface ViewController () {
    int col;  // 列数
    int row;  // 行数
    int mapX;  // 地图起始x点
    int mapY;  // 地图起始y点
    int mineNums;//地雷的个数
    int leftMarkMineNums;//剩余标记地雷的个数
    int rightMarkMineNums;//标记正确的地雷个数

}

@property (nonatomic, strong) UIButton *restartBtn;  // 重新开始按钮

@property (nonatomic, strong) NSMutableArray *mineMapArray;  //地雷地图数组
@property (nonatomic, strong) NSMutableArray *minesArray;  //所有地雷位置
@property (nonatomic, strong) NSMutableArray *turnoverArray;  //可翻转单元的位置数组

@property (nonatomic, strong) UIView *backgroundView;  // 集齐方格的背景
@property (nonatomic, strong) UIImageView *firstNumImg;  // 第一个数字ImageView
@property (nonatomic, strong) UIImageView *secondNumImg;  // 第二个数字ImageView

@end

@implementation ViewController

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(MAPVIEW_X, MAPVIEW_Y, MAPVIEW_WIDTH, MAPVIEW_HEIGHT)];
        [self.view addSubview:_backgroundView];
    }
    return _backgroundView;
}

- (UIImageView *)firstNumImg {
    if (!_firstNumImg) {
        _firstNumImg = [[UIImageView alloc] init];
    }
    return _firstNumImg;
}

- (UIImageView *)secondNumImg {
    if (!_secondNumImg) {
        _secondNumImg = [[UIImageView alloc] init];
    }
    return _secondNumImg;
}

- (NSMutableArray *)mineMapArray {
    if (!_mineMapArray) {
        _mineMapArray = [NSMutableArray array];
        for (int i = 0; i < row * col; i++) {//初始化单元没有地雷
            [_mineMapArray addObject:@(0)];
        }
    }
    return _mineMapArray;
}

- (NSMutableArray *)minesArray {
    if (!_minesArray) {
        _minesArray = [NSMutableArray array];
    }
    return _minesArray;
}
- (NSMutableArray *)turnoverArray {
    if (!_turnoverArray) {
        _turnoverArray = [NSMutableArray array];
    }
    return _turnoverArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    col = 15;   // 列
    row = 15;   // 行
    mineNums = 40;
    leftMarkMineNums = mineNums;  // 剩余地雷数
    [self restartGame];  // 重新开始游戏
}

- (void)restartGame {
    self.mineMapArray = nil;
    self.minesArray = nil;
    self.turnoverArray = nil;
    leftMarkMineNums = mineNums;
    rightMarkMineNums = 0;
    [self setupMines];  // 设置地雷
    [self.backgroundView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setUpMapView];  // 设置地图
    [self setleftMineNumImg:mineNums];  // 设置剩余地雷数ImageView
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// 设置剩余地雷数ImageView
- (void)setleftMineNumImg:(int)num {
    int q = num / 10;
    int p = num % 10;
    self.firstNumImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", q]];
    self.secondNumImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", p]];
}

// 初始化地雷
- (void)setupMines {
    //1.创建临时地图位置数组，用于随机出地雷位置
    NSMutableArray *tmpMapArray = [NSMutableArray array];//临时地图位置数组
    for (int i = 0; i < row * col; i++) {
        [tmpMapArray addObject:@(i)];
    }
    //2.更新地图地雷位置和记录地雷位置
    int delIndex;//随机数组删除的位置
    int addIndex;//地雷地图添加的位置
    for (int i = 0; i < mineNums; i++) {
        delIndex = arc4random() % tmpMapArray.count;
        addIndex = [tmpMapArray[delIndex] intValue];
        [self.mineMapArray replaceObjectAtIndex:addIndex withObject:@(9)];//更地图上地雷位置
        [self.minesArray addObject:tmpMapArray[delIndex]];//添加地雷位置到存储所有地雷位置的数组
        [tmpMapArray removeObjectAtIndex:delIndex];//删除临时随机的地雷位置
    }
    //3.标记地雷周围数字
    for (NSNumber *obj in self.minesArray) {//找到地雷周围位置，标记数值加1
        NSInteger location = [obj integerValue];
        NSInteger aroundLocation;//遍历地雷周围8个位置
        
        aroundLocation = location - col;//上
        if (location / col != 0) {
            [self locationPlus:aroundLocation];
        }
        
        aroundLocation = location - col + 1;//右上
        if (location / col && location % col != col - 1) {
            [self locationPlus:aroundLocation];
        }
        
        aroundLocation = location + 1;//右
        if (location % col != col - 1) {
            [self locationPlus:aroundLocation];
        }
        
        aroundLocation = location + col + 1;//右下
        if (location % col != col - 1 && location / col != row - 1) {
            [self locationPlus:aroundLocation];
        }
        
        aroundLocation = location + col;//下
        if (location / col != row - 1) {
            [self locationPlus:aroundLocation];
        }
        
        aroundLocation = location + col - 1;//左下
        if (location / col != row - 1 && location % col != 0) {
            [self locationPlus:aroundLocation];
        }
        
        aroundLocation = location - 1;//左
        if (location % col != 0) {
            [self locationPlus:aroundLocation];
        }
        
        aroundLocation = location - col - 1;//左上
        if (location / col != 0 && location % col != 0) {
            [self locationPlus:aroundLocation];
        }
    }
}
- (void)locationPlus:(NSInteger)location {
    NSInteger cellMineNums = [[self.mineMapArray objectAtIndex:location] integerValue];
    if (cellMineNums != 9) {
        cellMineNums++;
    }
    [self.mineMapArray replaceObjectAtIndex:location withObject:@(cellMineNums)];
}

// 初始化地图
- (void)setUpMapView {
    int btnNums = 0;
    for (int i = 0; i < col; i++) {
        for (int j = 0; j < row; j++) {
            UIButton *button = [[UIButton alloc] init];
            [self.backgroundView addSubview:button];
            button.backgroundColor = [UIColor grayColor];
            button.frame = CGRectMake(j * 40, i * 40, 40, 40);
            button.tag = BUTTON_TAG + btnNums;
            [button setBackgroundImage:[UIImage imageNamed:@"方格"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"selected_%@", self.mineMapArray[btnNums]]] forState:UIControlStateSelected];
            [button addTarget:self action:@selector(cellButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(markMine:)];  // 添加长按手势
            [button addGestureRecognizer:longPress];
            [self.backgroundView addSubview:button];
            
            btnNums++;
        }
    }
    
    // 地图左侧边框
    UIView *leftLineView = [[UIView alloc] initWithFrame:CGRectMake(self.backgroundView.frame.origin.x - 8, self.backgroundView.frame.origin.y, 8, self.backgroundView.frame.size.height)];
    [self.view addSubview:leftLineView];
    leftLineView.backgroundColor = [UIColor lightGrayColor];
    
    // 地图顶部边框
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(self.backgroundView.frame.origin.x - 8, self.backgroundView.frame.origin.y - 8,  self.backgroundView.frame.size.width + 8, 8)];
    [self.view addSubview:topLineView];
    topLineView.backgroundColor = [UIColor lightGrayColor];
    
    // 地图右侧边框
    UIView *rightLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.backgroundView.frame), self.backgroundView.frame.origin.y - 8, 8, self.backgroundView.frame.size.height + 8)];
    [self.view addSubview:rightLineView];
    rightLineView.backgroundColor = [UIColor lightGrayColor];
    
    // 地图底部边框
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(self.backgroundView.frame.origin.x - 8, CGRectGetMaxY(self.backgroundView.frame),  self.backgroundView.frame.size.width + 16, 8)];
    [self.view addSubview:bottomLineView];
    bottomLineView.backgroundColor = [UIColor lightGrayColor];
    
    // 设置重新开始游戏按钮
    UIButton *restartBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.backgroundView.frame) + 40, self.backgroundView.frame.origin.y, 120, 40)];
    [self.view addSubview:restartBtn];
    self.restartBtn = restartBtn;
    [restartBtn setTitle:@"重新开始" forState:UIControlStateNormal];
    restartBtn.backgroundColor = [UIColor colorWithRed:0 green:191/255.0 blue:1 alpha:1];
    [restartBtn addTarget:self action:@selector(restartGame) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *leftMineNumsLabel = [[UILabel alloc] initWithFrame:CGRectMake(restartBtn.frame.origin.x, CGRectGetMaxY(restartBtn.frame) + 40, restartBtn.frame.size.width, 30)];
    leftMineNumsLabel.text = @"剩余地雷数：";
    leftMineNumsLabel.font = restartBtn.titleLabel.font;
    [self.view addSubview:leftMineNumsLabel];
    
    self.firstNumImg.frame = CGRectMake(restartBtn.frame.origin.x, CGRectGetMaxY(leftMineNumsLabel.frame) + 5, restartBtn.frame.size.width / 2, 80);
    [self.view addSubview:self.firstNumImg];
    
    self.secondNumImg.frame = CGRectMake(restartBtn.frame.origin.x + self.firstNumImg.frame.size.width, CGRectGetMaxY(leftMineNumsLabel.frame) + 5, restartBtn.frame.size.width / 2, 80);
    [self.view addSubview:self.secondNumImg];
}

// 添加长按手势
- (void)markMine:(UILongPressGestureRecognizer *)longPress {
    UIButton *button = (UIButton *)longPress.view;
    if(longPress.state == UIGestureRecognizerStateBegan) {
        //当前单元为没有标记
        if ([button.currentBackgroundImage isEqual:[UIImage imageNamed:@"方格"]]) {
            if (leftMarkMineNums > 0) {//剩余旗帜>0,才能标记旗帜
                [button setBackgroundImage:[UIImage imageNamed:@"旗子_方格"] forState:UIControlStateNormal];
                --leftMarkMineNums;
                [self setleftMineNumImg:leftMarkMineNums];
                if ([self.mineMapArray[button.tag - BUTTON_TAG] isEqualToNumber:@(9)]) {//如果标记的位置是地雷则标对+1
                    rightMarkMineNums++;
                }
                if (rightMarkMineNums == mineNums) {//判断地雷是否已经标记完全，扫雷成功
                    //翻转所有空白单元 和 数字单元
                    for (UIButton *button  in self.backgroundView.subviews) {
                        if (![self.mineMapArray[button.tag - BUTTON_TAG] isEqualToNumber:@(9)]) {
                            button.selected = YES;
                            button.userInteractionEnabled = NO;
                        }
                    }
                    //弹窗 - 游戏赢了
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"恭喜扫雷成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"再来一局" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self restartGame];
                    }];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [alert addAction:sure];
                    [alert addAction:cancel];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
            return;
        }
        //当前单元标记为地雷
        if ([button.currentBackgroundImage isEqual:[UIImage imageNamed:@"旗子_方格"]]) {
            ++leftMarkMineNums;
            [self setleftMineNumImg:leftMarkMineNums];
            [button setBackgroundImage:[UIImage imageNamed:@"问号_方格"] forState:UIControlStateNormal];
            if ([self.mineMapArray[button.tag - BUTTON_TAG] isEqualToNumber:@(9)]) {
                rightMarkMineNums--;
            }
            return;
        }
        //当前单元标记为问号
        if ([button.currentBackgroundImage isEqual:[UIImage imageNamed:@"问号_方格"]]) {
            [button setBackgroundImage:[UIImage imageNamed:@"方格"] forState:UIControlStateNormal];
            return;
        }
    }
}

- (void)cellButtonSelect:(UIButton *)button {
    button.selected = YES;
    button.userInteractionEnabled = NO;
    NSInteger mineNum = [self.mineMapArray[button.tag - BUTTON_TAG] integerValue];
    
    
    if (mineNum == 9) {//地雷，游戏结束
        //翻转所有单元
        for (UIButton *button  in self.backgroundView.subviews) {
            button.selected = YES;
            button.userInteractionEnabled = NO;
        }
        //弹窗游戏结束
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"游戏结束" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"再来一局" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self restartGame];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:sure];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
        
        
        return;
    }
    if (mineNum > 0 && mineNum < 9) {//数字单元
        return;
    }
    
    //找到空白单元周围所有可翻转的单元
    [self.turnoverArray removeAllObjects];
    [self findAllTurnover:button.tag - BUTTON_TAG];
    
    //翻转所有可翻转单元
    for (NSNumber *obj in self.turnoverArray) {
        
        UIButton *button = (UIButton *)[self.backgroundView viewWithTag:[obj integerValue] + BUTTON_TAG];

        button.selected = YES;
        button.userInteractionEnabled = NO;
    }
}


// 找到所有可翻转的单元
- (void)findAllTurnover:(NSInteger)location {
    
    if (![self.turnoverArray containsObject:@(location)]) {//如果turnoverArray不包含这个单元，存进去
        [self.turnoverArray addObject:@(location)];
    }
    if ([self.mineMapArray[location] integerValue] != 0) {//如果当前单元不是空白单元则，回到上一层继续寻找下一个位置
        return;
    }
    
    NSInteger aroundLocation;
    aroundLocation = location - col - 1;//左上
    if (location / col != 0 && location % col != 0) {
        [self addTurnover:aroundLocation];
    }
    
    aroundLocation = location - col;//上
    if (location / col != 0) {
        [self addTurnover:aroundLocation];
    }
    
    aroundLocation = location - col + 1;//右上
    if (location / col && location % col != col - 1) {
        [self addTurnover:aroundLocation];
    }
    
    aroundLocation = location + 1;//右
    if (location % col != col - 1) {
        [self addTurnover:aroundLocation];
    }
    
    aroundLocation = location + col + 1;//右下
    if (location % col != col - 1 && location / col != row - 1) {
        [self addTurnover:aroundLocation];
    }
    
    aroundLocation = location + col;//下
    if (location / col != row - 1) {
        [self addTurnover:aroundLocation];
    }
    
    aroundLocation = location + col - 1;//左下
    if (location / col != row - 1 && location % col != 0) {
        [self addTurnover:aroundLocation];
    }
    
    aroundLocation = location - 1;//左
    if (location % col != 0) {
        [self addTurnover:aroundLocation];
    }
    
}

- (void)addTurnover:(NSInteger)location {
    
    if ([self.turnoverArray containsObject:@(location)]) {//如果已经包含这个单元return
        return;
    }
    [self.turnoverArray addObject:@(location)];
    [self findAllTurnover:location];
}




@end
