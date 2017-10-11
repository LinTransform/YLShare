//
//  YLLocalSetting.h
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YLLocalSetting : NSObject
+ (void) setVideoDetailFirstUse: (BOOL) isFirstUse;
+ (BOOL) isVideoDetailFirstUse;
@end
