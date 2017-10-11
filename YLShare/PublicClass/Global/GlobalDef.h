//
//  GlobalDef.h
//  YLShare
//
//  Created by wyl on 2017/9/6.
//  Copyright © 2017年 Future. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Request_Size        10
#define kTabbarHeight (49.f)
// app 中视频的宽高比例
#define VideoPlayerRatio (422.0 / 750)

extern CGFloat const KTabBarHeight;
extern CGFloat const KCollectionViewColumnSpace;
extern CGFloat const KCollectionViewInterItemSpace;

extern NSString * const NativeCallJSSendJsonStringMethod;
extern NSString * const JSCallNativeSendJsonStringMethod;

@interface GlobalDef : NSObject

@end
