//
//  YLTabBarController.m
//  YLShare
//
//  Created by wyl on 2017/9/6.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "YLTabBarController.h"

@interface YLTabBarController (){

    UIToolbar * _tabBarBg;
    NSMutableArray * _btnArr;
}

@end

@implementation YLTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    _btnArr = [[NSMutableArray alloc]init];

    _tabBarBg = [[UIToolbar alloc]init];
    _tabBarBg.barTintColor = [UIColor whiteColor];
    _tabBarBg.barStyle = UIBarStyleDefault;
    
    [self.view addSubview:_tabBarBg];
    
    __weak __typeof(self) wself = self;
    [_tabBarBg mas_makeConstraints:^(MASConstraintMaker * make) {
        make.left.right.bottom.equalTo(wself.view);
        make.height.mas_equalTo(KTabBarHeight);
    }];

    NSArray * imageArr = [NSArray arrayWithObjects:@"main", @"video", @"post_pen",@"discover", nil];
    NSArray * selectImageArr = [NSArray arrayWithObjects:@"main_select.png", @"video_select.png",@"post_pen_select", @"discover_select", nil];
    NSArray * titleArray = @[@"Video",@"UIWeb",@"WKWeb",@"Test"];

    CGFloat buttonWidth = App_Frame_Width / imageArr.count;
    
    NSMutableArray *buttonArray = [NSMutableArray array];
    for (int i = 0; i < imageArr.count; i++) {
        UIButton * subButton = [[UIButton alloc]initWithFrame:CGRectMake(0, i*buttonWidth, buttonWidth, KTabBarHeight)];
        subButton.tag = i;
        [subButton setImage:[UIImage imageNamed:[imageArr objectAtIndex:i]] forState:UIControlStateNormal];
        [subButton setImage:[UIImage imageNamed:[selectImageArr objectAtIndex:i]] forState:UIControlStateSelected];
        [subButton setTitle:[titleArray objectAtIndex:i] forState:UIControlStateNormal];
        [subButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [subButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [subButton setShowsTouchWhenHighlighted:YES];
        UIBarButtonItem *spaceitem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:subButton];
        if (i == 0) {
            [subButton setSelected:YES];
            [buttonArray addObject:spaceitem];
        }
        [buttonArray addObject:item];
        [buttonArray addObject:spaceitem];
        
        [_btnArr addObject:subButton];
    }
    [_tabBarBg setItems:buttonArray];
    // 首页
    UIViewController * vc = [[UIViewController alloc] init];
    UIViewController * vc2 = [[UIViewController alloc] init];
    UIViewController * vc3 = [[UIViewController alloc] init];
    UIViewController * vc4 = [[UIViewController alloc] init];

    [self setViewControllers:[NSArray arrayWithObjects:vc,vc2, vc3, vc4,nil]];
    
    [self hideTabBar];


}

- (void)buttonTapped:(UIButton *)button
{
    for (UIButton * btn in _btnArr) {
        [btn setSelected:NO];
    }
    
    [button setSelected:YES];
    self.selectedIndex = button.tag;

}


- (void)hideTabBar
{
    for (UIView * view in self.view.subviews) {
        if ([view isKindOfClass:[UITabBar class]]) {
            view.hidden = YES;
        } else if ([view isKindOfClass:NSClassFromString(@"UITransitionView")]) {
            view.frame = self.view.bounds;
        }
    }
}

- (void)hideOrNotTabBar:(BOOL)hidden
{
    _tabBarBg.hidden = hidden;
}

@end
