//
//  TitleControllerView.m
//  CLDemo
//
//  Created by JmoVxia on 2016/11/21.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import "TitleControllerView.h"

#define ButtonTag    1132


@interface TitleControllerView ()<UIScrollViewDelegate>

/**标题滑动视图*/
@property (nonatomic, weak) UIScrollView *titlesView;
/**滑动视图*/
@property (nonatomic, weak) UIScrollView *scrollView;
/**标题数组*/
@property (nonatomic, strong) NSArray *titlesArray;
/**控制器类名数组*/
@property (nonatomic,strong) NSMutableArray *controllerClassNameArray;
/**标题常态颜色数组*/
@property (nonatomic,strong) NSMutableArray *titleNormalColorArray;
/**标题选中颜色数组*/
@property (nonatomic,strong) NSMutableArray *titleSelectedColorArray;
/**父控制器*/
@property (nonatomic,weak) UIViewController *fatherController;
/**标题按钮选中标记*/
@property (nonatomic,weak) UIButton *selectedButton;
/**选中下标控件*/
@property (nonatomic,weak) UIView *selectedView;
/**是否被点击数组*/
@property (nonatomic,strong) NSMutableArray *clickArray;

@end


@implementation TitleControllerView

- (void)initWithTitleArray:(NSMutableArray *)titleArray controllerClassNameArray:(NSMutableArray *)controllerClassNameArray titleNormalColorArray:(NSMutableArray *)titleNormalColorArray titleSelectedColorArray:(NSMutableArray *)titleSelectedColorArray fatherController:(UIViewController *)fatherController;
{
    _titlesArray = titleArray;
    _controllerClassNameArray = controllerClassNameArray;
    _titleNormalColorArray = titleNormalColorArray;
    _titleSelectedColorArray = titleSelectedColorArray;
    _fatherController = fatherController;
    [self initUI];
}

- (void)initUI
{
    //关掉自动上移
    _fatherController.automaticallyAdjustsScrollViewInsets = NO;
    //调用懒加载
    self.titlesView.backgroundColor = [UIColor clearColor];
    self.scrollView.backgroundColor = [UIColor clearColor];
}
#pragma mark - 标题按钮点击事件
- (void)buttonAction:(UIButton *)button
{
    self.selectedButton.selected = NO;
    button.selected = YES;
    self.selectedButton = button;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.selectedView.width = button.titleLabel.width;
        self.selectedView.centerX = button.centerX;
        self.selectedView.backgroundColor = [button titleColorForState:UIControlStateSelected];
    }];
    
    //计算按钮和屏幕中间需要的偏移量
    CGFloat offsetX = button.centerX - ScreenWidth / 2.0;
    //屏幕左边按钮,重置偏移
    if (offsetX < 0)
    {
        offsetX = 0;
    }
    else
    {
        //得到最大偏移量
        CGFloat maxOffsetX = _titlesView.contentSize.width - ScreenWidth;
        // 处理最大偏移量
        if (offsetX > maxOffsetX)
        {
            offsetX = maxOffsetX;
        }
    }
    //设置偏移
    [_titlesView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    
    // 滚动
    CGPoint offset = self.scrollView.contentOffset;
    offset.x = (button.tag - ButtonTag) * _scrollView.width;
    [self.scrollView setContentOffset:offset animated:YES];
    
}

#pragma mark - <UIScrollViewDelegate>
//手动拖拽不会触发
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 当前的按钮所在索引
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;

    NSNumber *num = _clickArray[index];
    //为0代表没有被点击过，需要创建控制器
    if ([num integerValue] == 0)
    {
        UIViewController *vc = [NSClassFromString(_controllerClassNameArray[index]) new];
        // 创建控制器
        vc.view.frame = CGRectMake(scrollView.contentOffset.x, 0, scrollView.frame.size.width, scrollView.frame.size.height);
        [scrollView addSubview:vc.view];
        //将当前控制器添加到父控制器
        [_fatherController addChildViewController:vc];
        //将被点击按钮标记为1
        [_clickArray replaceObjectAtIndex:index withObject:[NSNumber numberWithInteger:1]];
    }
}
#pragma mark - 手动拖拽结束
//通过代码调用滑动时不会触发的
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //手动拖拽不会触发scrollViewDidEndScrollingAnimation，这里通过代码调用
    [self scrollViewDidEndScrollingAnimation:scrollView];
    // 点击按钮
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    [self buttonAction:self.titlesView.subviews[index]];
}
#pragma mark - 懒加载
//下方滑动视图
- (UIScrollView *) scrollView
{
    if (_scrollView == nil)
    {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.frame = CGRectMake(0, self.titlesView.bottom, self.width, self.height - self.titlesView.height);
        scrollView.delegate = self;
        scrollView.pagingEnabled = YES;
        scrollView.bounces = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:scrollView];
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * _controllerClassNameArray.count, 0);
        _scrollView = scrollView;
        // 添加第一个控制器的view
        [self scrollViewDidEndScrollingAnimation:_scrollView];
    }
    return _scrollView;
}
//标题视图
- (UIScrollView *) titlesView
{
    if (_titlesView == nil)
    {
        UIScrollView *titlesView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, 40)];
        CGFloat width = self.width/5.0;
        titlesView.contentSize = CGSizeMake(width * _titlesArray.count, titlesView.height);
        titlesView.bounces = NO;
        titlesView.showsHorizontalScrollIndicator = NO;
        titlesView.showsVerticalScrollIndicator = NO;
        [self addSubview:titlesView];
        
        _titlesView = titlesView;
        
        _clickArray = [NSMutableArray array];
        //根据标题数组创建标题按钮
        [_titlesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton * button = [[UIButton alloc]init];
            button.frame = CGRectMake(idx * width, 0, width, titlesView.height);
            button.tag = ButtonTag + idx;
            [button setTitle:_titlesArray[idx] forState:UIControlStateNormal];
            //常态颜色
            [button setTitleColor:_titleNormalColorArray[idx] forState:UIControlStateNormal];
            //选中颜色
            [button setTitleColor:_titleSelectedColorArray[idx] forState:UIControlStateSelected];
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [titlesView addSubview:button];
            //将所有按钮都标记为0
            [_clickArray addObject:[NSNumber numberWithInteger:0]];
        }];
        //取出第一个按钮
        UIButton *fristButton = titlesView.subviews.firstObject;
        UIView *selectedView = [[UIView alloc]init];
        selectedView.height = 2;
        selectedView.top = titlesView.height-selectedView.height;
        [titlesView addSubview:selectedView];
        self.selectedView = selectedView;
        //根据文字内容计算宽高
        [fristButton.titleLabel sizeToFit];
        //给定初始位置
        selectedView.width = fristButton.titleLabel.width;
        selectedView.centerX = fristButton.centerX;
        //默认选中第一个按钮
        [self buttonAction:fristButton];
    }
    return _titlesView;
}






@end
