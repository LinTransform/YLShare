//
//  YLVideoPlayerView.h
//  YL
//
//  Created by wyl on 16/8/14.
//  Copyright © 2016年 Future All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@protocol  YLVideoPlayerViewDelegate<NSObject>

@optional
//返回按钮
- (void) YLVideoPlayerControlViewBackButtonClick;
//全屏按钮点击
- (void) YLVideoPlayerControlViewFullScreenButtonClick;
//视频播放结束
- (void) YLVideoPlayerControlViewFinishPlay;
//分享按钮的点击
- (void) YLVideoPlayerControlViewShareButtonClick:(NSInteger) tag;
//重新连上网络的情况下,点击播放按钮,则重新刷新视频详情界面的数据
- (void) YLVideoPlayerControlViewPlayButtonClickWhenNetworkNormal;

- (void) YLVideoPlayerControlViewNetWorkTryButtonClick;

//屏幕旋转的时候会执行的代理方法
- (void) YLVideoPlayerControlViewWillRotate;


@end

@interface YLVideoPlayerView : UIView
@property (nonatomic , strong) NSString * videoUrl;
@property (nonatomic , copy) NSString * videoTitle;
@property (nonatomic , assign) NSInteger videoPlayCount;
@property (nonatomic, strong,readonly) UIButton * backButton;
@property (nonatomic, strong,readonly) UIButton *fullScreenButton;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIView * sliderReactView;
@property (nonatomic, weak) id<YLVideoPlayerViewDelegate>delegate;

@property (nonatomic, assign) BOOL isPortrait;

//此时播放器的状态是否是暂停
@property (nonatomic , assign) BOOL isVideoPause;

//是否关闭旋转 (当前view被遮盖的时候)
@property (nonatomic , assign) BOOL closeRotate;

// superView 是一个 containerView
- (instancetype) initPlayerViewWithContainerView:(UIView *) containerView scrollView:(UIScrollView *)scrollView delegate:(id<YLVideoPlayerViewDelegate>) delegate;
- (void) convertPlayerViewToContainerView:(UIView *) containerView scrollView:(UIScrollView *)scrollView delegate:(id<YLVideoPlayerViewDelegate>) delegate;


+ (CGAffineTransform) getCurrentDeviceOrientation;

//暂停
- (void) pause ;
//播放
- (void) play ;

//去除定时器
- (void) removeTimer;

//改变横屏状态下的分享界面位置
- (void) dismissShareViewLandscape ;

//网络情况差的时候显示所有的工具栏
- (void) showAllToolBar ;

//重置播放器
-(void)resetPlayView ;

//销毁播放器
- (void)destoryVideoPlayer;

//无网络状态
- (void)setNoNetWorkStatus;




@end
