//
//  SVProgressHUD+YLCustom.h
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
typedef NS_ENUM(NSInteger,HUDType)
{
    TypeWarning,
    TypeCorrect,
    TypeWrong,
    TypeWaiting,
};

@interface SVProgressHUD (YLCustom)

+ (void)setYLProgressHUD;

@end
