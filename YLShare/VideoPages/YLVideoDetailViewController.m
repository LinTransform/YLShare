//
//  YLVideoDetailViewController.m
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "YLVideoDetailViewController.h"


@interface YLVideoDetailViewController ()<YLVideoPlayerViewDelegate>

@property (nonatomic , assign) CGFloat videoPortraitW;
@property (nonatomic , assign) CGFloat videoPortraitH;


@end

@implementation YLVideoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ColorWithHexRGB(Color_Background_Gray);
    self.videoPortraitW = [UIScreen mainScreen].bounds.size.width;
    self.videoPortraitH = self.videoPortraitW * VideoPlayerRatio;
    [self createVideoView];
}

- (void)dealloc {
    [self.videoPlayView destoryVideoPlayer];
    self.videoPlayView.delegate = nil;
    self.videoPlayView = nil;
    NSLog(@"YLVideoDetailViewController dealloc");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [[AppDelegate sharedAppDelegate].tabBarViewController hideOrNotTabBar:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    
}


- (void) createVideoView {
    
    
    UIView * videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.videoPortraitW, self.videoPortraitH)];
    [self.view addSubview:videoView];
    videoView.backgroundColor = [UIColor clearColor];
    
    if (!self.videoPlayView) {
        self.videoPlayView = [[YLVideoPlayerView alloc] initPlayerViewWithContainerView:videoView scrollView:nil delegate:self];
        self.videoPlayView.videoUrl = self.videoUrl;
    }else{
        [self.videoPlayView convertPlayerViewToContainerView:videoView scrollView:nil delegate:self];
       
    }
    
}


@end
