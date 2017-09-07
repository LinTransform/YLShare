//
//  YLCameraViewController.m
//  YLShare
//
//  Created by wyl on 2017/9/7.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "YLCameraViewController.h"
#import "YLShootVideoViewController.h"
#import "YLShootPlayerView.h"
#import "YLShootVideoManager.h"

@interface YLCameraViewController ()<YLShootVideoViewControllerDelegate>
@property (nonatomic , strong) UIImageView * shootImageView;
@property (nonatomic , strong) YLShootPlayerView * playerView;
@property (nonatomic , strong) UIView * showView;

@end

@implementation YLCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Camera";
    
    self.showView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, Main_Screen_Width, Main_Screen_Width * SHOOT_RATIO)];
    self.showView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.showView];

    CGFloat w = 100;
    CGFloat h = w;
    CGFloat x = (Main_Screen_Width - w) * 0.5;
    CGFloat y = CGRectGetMaxY(self.showView.frame);
    UIButton * shootButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [shootButton setTitle:@"录像" forState:UIControlStateNormal];
    [shootButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [shootButton addTarget:self action:@selector(shootButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shootButton];
    
    
}

#pragma mark - view related methods
- (void) shootButtonClick {
    //拍摄
    YLShootVideoViewController * shootVC = [[YLShootVideoViewController alloc] init];
    shootVC.delegate = self;
    [self presentViewController:shootVC animated:YES completion:nil];

}

#pragma mark - YLShootVideoViewControllerDelegate
- (void)videoViewController:(YLShootVideoViewController *)videoController didRecordVideo:(YLVideoModel *)videoModel {
    [self.shootImageView removeFromSuperview];
    [self.playerView removeFromSuperview];
    if (videoModel.shootImage) {
        [self addImageViewWithModel:videoModel];

    }else{
        [self addPlayerViewWithModel:videoModel];

    }
}

- (void) addImageViewWithModel: (YLVideoModel *)model {
    self.shootImageView = [[UIImageView alloc] initWithFrame:self.showView.bounds];
    self.shootImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.shootImageView.clipsToBounds = YES;
    self.shootImageView.image = model.shootImage;
    [self.showView addSubview:self.shootImageView];
}

- (void)addPlayerViewWithModel: (YLVideoModel *)model {
    NSURL *videoURL = [NSURL fileURLWithPath:model.videoAbsolutePath];
    self.playerView = [[YLShootPlayerView alloc] initWithFrame:self.showView.bounds videoUrl:videoURL];
    [self.showView addSubview:self.playerView];
    [self.playerView play];
}



@end
