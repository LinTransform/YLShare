//
//  YLTabBarController.m
//  YLShare
//
//  Created by wyl on 2017/9/6.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "YLTabBarController.h"
#import "YLNavigationController.h"
#import "YLJSNativeViewController.h"
#import "YLVideoViewController.h"
#import "YLCameraViewController.h"

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

    NSArray * titleArray = @[@"Camera",@"Video",@"JS-Native"];

    CGFloat buttonWidth = App_Frame_Width / titleArray.count;
    
    NSMutableArray *buttonArray = [NSMutableArray array];
    for (int i = 0; i < titleArray.count; i++) {
        UIButton * subButton = [[UIButton alloc]initWithFrame:CGRectMake(0, i*buttonWidth, buttonWidth, KTabBarHeight)];
        subButton.tag = i;
        [subButton setTitle:[titleArray objectAtIndex:i] forState:UIControlStateNormal];
        [subButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [subButton setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
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
    
    YLNavigationController * videoNav = [[YLNavigationController alloc] initWithRootViewController:[[YLVideoViewController alloc] init]];
    YLNavigationController * cameraNav = [[YLNavigationController alloc] initWithRootViewController:[[YLCameraViewController alloc] init]];
    YLNavigationController * jsNativeNav = [[YLNavigationController alloc] initWithRootViewController:[[YLJSNativeViewController alloc] init]];
    [self setViewControllers:[NSArray arrayWithObjects:videoNav,cameraNav,jsNativeNav,nil]];
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


#pragma mark - 关于转屏控制
- (BOOL)shouldAutorotate{
    return NO;
}


@end
