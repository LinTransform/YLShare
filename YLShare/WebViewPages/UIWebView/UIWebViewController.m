//
//  UIWebViewController.m
//  YLShare
//
//  Created by wyl on 2017/9/8.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "UIWebViewController.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface UIWebViewController ()<UIWebViewDelegate,NJKWebViewProgressDelegate>{
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;

}

@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, assign) CGFloat delayTime;
@property (strong, nonatomic) JSContext *context;

@end

@implementation UIWebViewController

/*
 tips:
 javascript函数的重载和java的重载方式不一样。
 定义JavaScript函数时，函数名是函数对象的标识，参数数量只是这个函数的属性。靠定义参数数量不同的函数实现重载是不行的。
 调用函数时，js通过函数名找到对应的函数对象，然后根据函数按照定义时的参数，和表达式参数列表按顺序匹配，多余的参数舍去，不够的参数按undefined处理，然后执行函数代码。所以，js重载函数需要通过函数代码判断参数值和类型实现。
 通常定义函数时，把必选参数放在参数列表最前面，可选参数放在参数放在参数列表必须参数后面，方便函数重载。
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)dealloc{
    self.webView.delegate = nil;
    self.webView = nil;
    self.view = nil;

    NSLog(@"UIWebViewController dealloc");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[AppDelegate sharedAppDelegate].tabBarViewController hideOrNotTabBar:YES];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
    NSURL * url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"UIWebView" ofType:@"html"]];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}


#pragma mark - private
- (void) initView {
    self.view.backgroundColor = [UIColor orangeColor];
    // UIWebView 的bug ,这里必须随便加一个 view , 不然 UIWebView 的布局会出现问题
    UIView * tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:tempView];
    [self.view addSubview:self.webView];
    self.webView.delegate = self;

    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    
    UIButton * callJSBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 450, 200, 50)];
    callJSBtn.centerX = self.view.centerX;
    [callJSBtn setTitle:@"原生调用JS" forState:UIControlStateNormal];
    [callJSBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    callJSBtn.backgroundColor = [UIColor yellowColor];
    [callJSBtn addTarget:self action:@selector(callJSButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:callJSBtn];

}

- (void) initJSCallNative {
    // 以 html title 设置 导航栏 title
    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    // 禁用 页面元素选择
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    // 禁用 长按弹出ActionSheet
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    
    // Undocumented access to UIWebView's JSContext
    self.context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    // 打印异常
    self.context.exceptionHandler =
    ^(JSContext *context, JSValue *exceptionValue)
    {
        context.exception = exceptionValue;
        NSLog(@"%@", exceptionValue);
    };
    
    // 以 block 形式关联 JavaScript function
    // 这里的 js中jsCallNative 方法声明不写都是可以的,因为原生会拦截js方法,写了也不会调用的
    self.context[JSCallNativeSendJsonStringMethod] =
    ^(NSString *str)
    {
        NSLog(@"JSCallNativeSendJsonStringMethod=>%@", str);
    };

}

- (void) callJSButtonClick {
    NSMutableDictionary * infoDict = [[NSMutableDictionary alloc] init];
    [infoDict setObject:@"Native" forKey:@"title"];
    [infoDict setObject:@"nativeCallJSMethod success!" forKey:@"message"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:infoDict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *paraStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString * paramStr = [self noWhiteSpaceString:[NSString stringWithFormat:@"%@",paraStr]];
    NSString *returnJSStr = [NSString stringWithFormat:@"%@('%@')",NativeCallJSSendJsonStringMethod,paramStr];
    [self.context evaluateScript:returnJSStr];

    
}

- (NSString *)noWhiteSpaceString: (NSString *)newString {
    //去除掉首尾的空白字符和换行字符
    newString = [newString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    newString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符使用
    newString = [newString stringByReplacingOccurrencesOfString:@" " withString:@""];
    //    可以去掉空格，注意此时生成的strUrl是autorelease属性的，所以不必对strUrl进行release操作！
    return newString;
}



#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"UIWebView开始加载");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"UIWebView停止加载");
    [self initJSCallNative];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}


#pragma mark - getter

- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, Main_Screen_Width, 350)];
        _webView.delegate = self;
        //加上这个属性就没有 弹簧效果
//        _webView.scrollView.bounces = NO;
        _webView.scalesPageToFit = YES;
    }
    
    return _webView;
}


@end
