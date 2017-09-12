//
//  WKWebViewController.m
//  YLShare
//
//  Created by wyl on 2017/9/8.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "WKWebViewController.h"
#import <WebKit/WebKit.h>


@interface WKWebViewController ()<WKScriptMessageHandler,WKUIDelegate,WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *wkWebView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) CGFloat delayTime;

@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    
    [self initView];
}

- (void)dealloc {
    NSLog(@"WKWebViewController dealloc");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[AppDelegate sharedAppDelegate].tabBarViewController hideOrNotTabBar:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[AppDelegate sharedAppDelegate].tabBarViewController hideOrNotTabBar:NO];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self releaseWebView];
}

#pragma mark - WKUIDelegate
//提示框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认框" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入框" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor blackColor];
        textField.placeholder = defaultText;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(nil);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

#pragma mark - WKNavigationDelegate

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"1.decidePolicyForNavigationAction==>%@", navigationAction);
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"2.didStartProvisionalNavigation==>%@", navigation);
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"3.decidePolicyForNavigationResponse==>%@", navigationResponse);
    decisionHandler(WKNavigationResponsePolicyAllow);
}



// 内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"4.didCommitNavigation==>%@", navigation);
}

// 页面加载完调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    //可以再这里添加一些原生界面的修改
    NSLog(@"5.didFinishNavigation==>%@", navigation);
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    //使用原生方法展现 加载失败
}


// 加载 HTTPS 的链接，需要权限认证时调用  \  如果 HTTPS 是用的证书在信任列表中这不要此代理方法
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([challenge previousFailureCount] == 0) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:JSCallNativeSendJsonStringMethod]) {
        //获取用户信息
        [self jsCallNativeSendMessage:message.body];
    }
}

#pragma mark - KVO 
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:YES];
        if (self.wkWebView.estimatedProgress < 1.0) {
            self.delayTime = 1 - self.wkWebView.estimatedProgress;
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.progressView.progress = 0;
        });
    } else if ([keyPath isEqualToString:@"title"]) {
        self.title = self.wkWebView.title;
    } else if ([keyPath isEqualToString:@"contentSize"]) {
       
        NSLog(@"scrollView.contentSize==>%@", NSStringFromCGSize(self.wkWebView.scrollView.contentSize));
        
    }
}


#pragma mark - private
- (void) initView {

    // WKWebView 的bug ,这里必须随便加一个 view , 不然 WKWebView 的布局会出现问题
    UIView * tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:tempView];
    
    
    [self.view addSubview:self.wkWebView];
    
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, Main_Screen_Width, 2)];
    [self.view addSubview:self.progressView];
    self.progressView.progressTintColor = [UIColor greenColor];
    self.progressView.trackTintColor = [UIColor clearColor];
    NSKeyValueObservingOptions observingOptions = NSKeyValueObservingOptionNew;
    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:observingOptions context:nil];
    [self.wkWebView addObserver:self forKeyPath:@"title" options:observingOptions context:nil];
    [self.wkWebView.scrollView addObserver:self forKeyPath:@"contentSize" options:observingOptions context:nil];


    UIButton * callJSBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 450, 200, 50)];
    callJSBtn.centerX = self.view.centerX;
    [callJSBtn setTitle:@"原生调用JS" forState:UIControlStateNormal];
    [callJSBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    callJSBtn.backgroundColor = [UIColor yellowColor];
    [callJSBtn addTarget:self action:@selector(callJSButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:callJSBtn];
    
    NSString *webViewURLStr = [[NSBundle mainBundle] pathForResource:@"WKWebView.html" ofType:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:webViewURLStr];
    [self.wkWebView loadFileURL:fileURL allowingReadAccessToURL:fileURL];

}

- (void) jsCallNativeSendMessage: (NSString *)jsonStr {
    NSLog(@"jsCallNativeSendMessage => %@",jsonStr);
    UILabel * greenLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 350, 200, 50)];
    greenLabel.centerX = self.view.centerX;
    greenLabel.backgroundColor = [UIColor greenColor];
    greenLabel.text = @"jsCallNativeSendMessage";
    greenLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:greenLabel];
}

- (void) callJSButtonClick {
    NSMutableDictionary * infoDict = [[NSMutableDictionary alloc] init];
    [infoDict setObject:@"Native" forKey:@"title"];
    [infoDict setObject:@"nativeCallJSMethod success!" forKey:@"message"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:infoDict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *paraStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString * paramStr = [self noWhiteSpaceString:[NSString stringWithFormat:@"%@",paraStr]];
    NSString *returnJSStr = [NSString stringWithFormat:@"%@('%@')",NativeCallJSSendJsonStringMethod,paramStr];
    [self.wkWebView evaluateJavaScript:returnJSStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@ result = %@,error = %@",NativeCallJSSendJsonStringMethod, result, error);
    }];

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

- (void) releaseWebView {
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.wkWebView removeObserver:self forKeyPath:@"title"];
    [self.wkWebView.scrollView removeObserver:self forKeyPath:@"contentSize"];
    [[self.wkWebView configuration].userContentController removeScriptMessageHandlerForName:JSCallNativeSendJsonStringMethod];
    self.wkWebView.UIDelegate = nil;
    self.wkWebView.navigationDelegate = nil;
    
}


#pragma mark - getter
- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = [[WKUserContentController alloc] init];
        
        [configuration.userContentController addScriptMessageHandler:self name:JSCallNativeSendJsonStringMethod];

        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, Main_Screen_Width, 350) configuration:configuration];
        _wkWebView.scrollView.bounces = NO;
    
        _wkWebView.UIDelegate = self;
        _wkWebView.navigationDelegate = self;
    }
    return _wkWebView;
}

@end
