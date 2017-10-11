//
//  YLLocalSetting.m
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "YLLocalSetting.h"
NSString * const VideoDetail_First = @"videoDetail_First";
@implementation YLLocalSetting
+ (void) setVideoDetailFirstUse: (BOOL) isFirstUse{
    [[NSUserDefaults standardUserDefaults] setBool:isFirstUse forKey:VideoDetail_First];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (BOOL) isVideoDetailFirstUse{
    return [[NSUserDefaults standardUserDefaults] boolForKey:VideoDetail_First];
}

@end
