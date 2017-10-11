//
//  YLBaseCollectionVC.h
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "YLBaseViewController.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "SVProgressHUD+YLCustom.h"

@interface YLBaseCollectionVC : YLBaseViewController
@property (nonatomic , strong) UICollectionView * collectionView;
@property (nonatomic , strong) UICollectionViewLayout * layout;


- (void) configCollectionView;

// 网络出错处理
- (void)netWorkError:(NSError *)error andMessage:(NSString *)message;

- (void)showHUDWithMessage:(NSString *)message type:(HUDType)type;

- (void)addBackBtnWithTarget:(id)target selector:(SEL)selector;



@end
