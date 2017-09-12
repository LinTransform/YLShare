//
//  YLJSNativeViewController.m
//  YLShare
//
//  Created by wyl on 2017/9/7.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "YLJSNativeViewController.h"
#import "WKWebViewController.h"
#import "UIWebViewController.h"

@interface YLJSNativeViewController ()

@end

@implementation YLJSNativeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"JS-Native";
    
    CGFloat w = 200;
    CGFloat h = 50;
    UIButton * webButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, w, h)];
    webButton.centerX = self.view.centerX;
    [webButton setTitle:@"UIWebView" forState:UIControlStateNormal];
    [webButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    webButton.backgroundColor = [UIColor blueColor];
    [webButton addTarget:self action:@selector(webButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:webButton];
    
    UIButton * wkWebButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 200, w, h)];
    wkWebButton.centerX = self.view.centerX;
    [wkWebButton setTitle:@"WKWebView" forState:UIControlStateNormal];
    [wkWebButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    wkWebButton.backgroundColor = [UIColor blueColor];
    [wkWebButton addTarget:self action:@selector(wkWebButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wkWebButton];

}

- (void) webButtonClick {
    UIWebViewController * wkVC = [[UIWebViewController alloc] init];
    [self.navigationController pushViewController:wkVC animated:YES];
}

- (void) wkWebButtonClick {
    WKWebViewController * wkVC = [[WKWebViewController alloc] init];
    [self.navigationController pushViewController:wkVC animated:YES];
}


@end
