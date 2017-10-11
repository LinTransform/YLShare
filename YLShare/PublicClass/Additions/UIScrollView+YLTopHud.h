//
//  UIScrollView+YLTopHud.h
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (YLTopHud)

- (void)showRefreshHUDWithString:(NSString *)string;
- (void)hideScrollRefreshHUD;

@end
