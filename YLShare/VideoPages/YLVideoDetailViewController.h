//
//  YLVideoDetailViewController.h
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "YLBaseViewController.h"
#import "YLVideoPlayerView.h"

@interface YLVideoDetailViewController : YLBaseViewController

@property (nonatomic , strong) YLVideoPlayerView * videoPlayView;
@property (nonatomic , copy) NSString * videoUrl;

@end
