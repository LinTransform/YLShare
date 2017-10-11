//
//  VideoListRequestModel.h
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoListRequestModel : NSObject

@property (nonatomic, copy) NSString *recentTime;//最新的video的时间

@property (nonatomic, copy) NSString *remoteTime;//最晚的video的时间

@property (nonatomic, copy) NSString *maxtime;

@property (nonatomic, assign) NSInteger page;


@end
