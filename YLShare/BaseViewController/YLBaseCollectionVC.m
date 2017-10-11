//
//  YLBaseCollectionVC.m
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "YLBaseCollectionVC.h"
#import "SVProgressHUD+YLCustom.h"

@interface YLBaseCollectionVC ()<CHTCollectionViewDelegateWaterfallLayout,UICollectionViewDataSource,UICollectionViewDelegate>

@end

@implementation YLBaseCollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[UIDevice currentDevice] systemVersion].floatValue>=7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if (!self.layout) {
        CHTCollectionViewWaterfallLayout * chtLayout = [[CHTCollectionViewWaterfallLayout alloc] init];
        chtLayout.sectionInset = UIEdgeInsetsMake(KCollectionViewColumnSpace, KCollectionViewColumnSpace, KCollectionViewColumnSpace, KCollectionViewColumnSpace);
        chtLayout.minimumInteritemSpacing = KCollectionViewInterItemSpace;
        chtLayout.minimumColumnSpacing = KCollectionViewColumnSpace;
        self.layout = chtLayout;
    }
    [self.view addSubview:self.collectionView];
    [self configCollectionView];
}

- (void) configCollectionView {
    
}



- (void)netWorkError:(NSError *)error andMessage:(NSString *)message
{
    
    if ([self.collectionView.mj_header isRefreshing]) {
        [self.collectionView.mj_header endRefreshing];
        
    }
    if ([self.collectionView.mj_footer isRefreshing]) {
        [self.collectionView.mj_footer endRefreshing];
    }
    
    
    if (error) {
        [SVProgressHUD setYLProgressHUD];
        switch (error.code) {
            case -1001:
            case -1003:
            case -1004:
            case -1009:
            case -2000:
            {
                [SVProgressHUD showImage:[UIImage imageNamed:@"warning"] status:@"没有网络连接"];
            }
                break;
            case -1008:
            case -1011:
            {
                [SVProgressHUD showImage:[UIImage imageNamed:@"wrong"] status:@"网络连接出错"];
                
            }
                break;
            default:
                [SVProgressHUD showImage:[UIImage imageNamed:@"wrong"] status:@"亲！ 网路异常啦"];
                
                break;
        }
    } else {
        [SVProgressHUD setYLProgressHUD];
        
        if (!message) {
            [SVProgressHUD showImage:[UIImage imageNamed:@"warning"] status:@"您的网络好像不太给力，\n请稍后再试"];
        } else {
            [SVProgressHUD showImage:[UIImage imageNamed:@"wrong"] status:message];
        }
    }
}


- (void)showHUDWithMessage:(NSString *)message type:(HUDType)type
{
    [SVProgressHUD setYLProgressHUD];
    switch (type) {
        case TypeWarning:
        {
            [SVProgressHUD showImage:[UIImage imageNamed:@"wrong"] status:message];
            
        }
            break;
        case TypeCorrect:
        {
            [SVProgressHUD showImage:[UIImage imageNamed:@"correct"] status:message];
            
        }
            break;
        case TypeWrong:
        {
            [SVProgressHUD showImage:[UIImage imageNamed:@"wrong"] status:message];
            
        }
            break;
        case TypeWaiting:
        {
            [SVProgressHUD show];
        }
            break;
        default:
            break;
    }
}


- (void)showNONetowrk
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD setYLProgressHUD];
        [SVProgressHUD showImage:nil status:@"您的网络好像不太给力，\n请稍后再试"];
    });
    
}

// system NavigationBar
- (void)addBackBtnWithTarget:(id)target selector:(SEL)selector
{
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    backButton.tag = 1001;
    UIImage * image = UIImageNamed(@"back");
    [backButton setImage:image forState:UIControlStateNormal];
    [backButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 30, 30);
    backButton.contentMode = UIViewContentModeScaleAspectFit;
    UIBarButtonItem * negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = 15;
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:backButton], negativeSpacer];
    
}



#pragma mark -- getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_layout];
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = ColorWithHexRGB(Color_Background_Gray);
        _collectionView.delegate = self;
        _collectionView.alwaysBounceVertical = YES;
    }
    return _collectionView;
}

@end
