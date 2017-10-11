//
//  SVProgressHUD+YLCustom.m
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "SVProgressHUD+YLCustom.h"

@implementation SVProgressHUD (YLCustom)
+ (void)setYLProgressHUD {
    [self setMinimumDismissTimeInterval:1.8];
    [self setFadeInAnimationDuration:0.2];
    [self setFadeOutAnimationDuration:0.3];
    [self setDefaultStyle:SVProgressHUDStyleCustom];
    [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    [self setForegroundColor:UIColorWhite];
    [self setCornerRadius:5];
    [self setMinimumSize:CGSizeMake(110, 84)];

}
@end
