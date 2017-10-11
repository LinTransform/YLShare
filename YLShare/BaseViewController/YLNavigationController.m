//
//  YLNavigationController.m
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "YLNavigationController.h"

@interface YLNavigationController ()<UINavigationControllerDelegate,UIGestureRecognizerDelegate>


@end

@implementation YLNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 手势滑动返回上一层功能
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = self;
        self.delegate = self;
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 滑动返回时 当前界面不会再有滑动的迹象
    self.interactivePopGestureRecognizer.delegate = nil;
    
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
