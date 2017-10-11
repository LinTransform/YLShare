//
//  YLVideoPlayerView.m
//  YL
//
//  Created by wyl on 16/8/14.
//  Copyright © 2016年 Future All rights reserved.
//

#import "YLVideoPlayerView.h"
#import "AFNetworking.h"
#import "SVProgressHUD+YLCustom.h"
#import "YLLocalSetting.h"
#import <MediaPlayer/MediaPlayer.h>
#import "YLVideoViewController.h"
#import "YLVideoDetailViewController.h"
#import "NSString+Test.h"

static NSString * PlayButtonImage = @"videoDetail_play";
static NSString * PauseButtonImage = @"videoDetail_pause";

typedef enum : NSUInteger {
    YLPlayerNetStateUnknow = -1,
    YLPlayerNetStateNotReachable = 0,
    YLPlayerNetStateViaWWAN = 1,
    YLPlayerNetStateViaWiFi = 2,
} YLPlayerNetState;

typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved, // 横向移动
    PanDirectionVerticalMoved    // 纵向移动
};

static void *PlayViewCMTimeValue = &PlayViewCMTimeValue;

static void *PlayViewStatusObservationContext = &PlayViewStatusObservationContext;

#define ShareView_Width 320
#define UpdateProgress_Moment 1.0

#define TitleLabelLeftWithBack 44
#define TitleLabelLeftWithoutBack 18
#define TitleLabelTop 20
#define AUTODISMISS_TIME 8.0

@interface YLVideoPlayerView (){

    UITapGestureRecognizer* singleTap;
    
    //此时视频是否已经播放结束
    BOOL _isVideoEnd;
    
    //此时视频是否正在播放
    BOOL _isPlaying;
}

// 竖屏时存放播放器的父view
@property (nonatomic, strong) UIView * superView;
// 父控制器中的 scrollview 用来开关 点击statusBar回到顶部的属性
@property (nonatomic, strong) UIScrollView * scrollView;

@property (nonatomic, strong) AVPlayerItem *playerItem;
/* 播放器 */
@property (nonatomic, strong) AVPlayer *player;

// 播放器的Layer
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) UIView * shareBtnContainer;
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *topStatusBar;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIButton * backButton;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * playCountLabel;
//无网络状态
@property (nonatomic, strong) UILabel * noNetLabel;
@property (nonatomic, strong) UIButton * noNetTryBtn;
@property (nonatomic, strong) UIView * noNetTryView;

@property (nonatomic, strong) UIButton *playOrPauseButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *fullScreenButton;
@property (nonatomic, strong) UISlider *cacheSlider;
@property (nonatomic, strong) UILabel *currentVideoTime;
@property (nonatomic, strong) UILabel *totalVideoTime;

@property (nonatomic, assign) BOOL isBarShowing;
@property (nonatomic, strong) UIActivityIndicatorView *progressView;
@property (nonatomic, strong) UIPanGestureRecognizer * voicePanGes;
/* 定时器 */
@property (nonatomic, strong) NSTimer *progressTimer;

/**
 *  定时器
 */
@property (nonatomic, retain) NSTimer  *autoDismissTimer;

//点击分享的时候从右向左推出来的界面
@property (nonatomic, strong) UIView * shareView;

//网络状态
@property (nonatomic, assign) YLPlayerNetState netState;

//声音引导层
@property (nonatomic, strong) UIView * voiceGuideView;
@property (nonatomic, retain) NSTimer *voiceDismissTimer;
@property (nonatomic, assign) PanDirection           panDirection;
@property (nonatomic, strong) UISlider               *volumeViewSlider;

@property (nonatomic , assign) CGFloat videoPortraitW;
@property (nonatomic , assign) CGFloat videoPortraitH;
@property (nonatomic , assign) CGFloat videoLandscapeW;
@property (nonatomic , assign) CGFloat videoLandscapeH;

//记录进入后台之前的播放状态
@property (nonatomic , assign) BOOL isPlayResignActive;

@property (nonatomic , assign) CGFloat startSliderValue;

@end

@implementation YLVideoPlayerView

#pragma mark - init

- (instancetype) initPlayerViewWithContainerView:(UIView *) containerView scrollView:(UIScrollView *)scrollView delegate:(id<YLVideoPlayerViewDelegate>) delegate {
    if (self = [super init]) {
        [self convertPlayerViewToContainerView:containerView scrollView:scrollView delegate:delegate];
    }
    return self;
}

- (void) convertPlayerViewToContainerView:(UIView *) containerView scrollView:(UIScrollView *)scrollView delegate:(id<YLVideoPlayerViewDelegate>) delegate {
    [self removeFromSuperview];
    self.isVideoPause = NO;
    _isVideoEnd = NO;
    _isPlaying = NO;
    self.closeRotate = NO;
    self.delegate = delegate;
    self.isPortrait = YES;
    self.superView = containerView;
    if (scrollView) {
        self.scrollView = scrollView;
    }
    self.videoPortraitW = self.superView.bounds.size.width;
    self.videoPortraitH = self.superView.bounds.size.height;
    self.videoLandscapeW = [UIScreen mainScreen].bounds.size.height;
    self.videoLandscapeH = [UIScreen mainScreen].bounds.size.width;
    [self.superView addSubview:self];
    @weakObj(self);
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongObj(self);
        make.edges.equalTo(strongSelf.superview);
    }];
    [self.superView bringSubviewToFront:self];
}

//获取当前的旋转状态
+(CGAffineTransform)getCurrentDeviceOrientation{
    //状态条的方向已经设置过,所以这个就是你想要旋转的方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //根据要进行旋转的方向来计算旋转的角度
    if (orientation ==UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    }else if (orientation ==UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    }else if(orientation ==UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}




- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:CGRectZero]) {
        [self initialize];
        

    }
    return self;
}

- (void)dealloc {
      NSLog(@"VideoPlayView dealloc");
    
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.playerLayer.frame = self.bounds;
}

#pragma mark - View Contol Related
- (void) YLVideoPlayerControlViewBackButtonClick {
    if (self.isPortrait) {
        if ([self.delegate respondsToSelector:@selector(YLVideoPlayerControlViewBackButtonClick)]) {
            [self.delegate YLVideoPlayerControlViewBackButtonClick];
        }

    }else{
        [self fullScreenButtonClick];
    }
}

- (void) fullScreenButtonClick {
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {
        orientation = UIInterfaceOrientationLandscapeRight;
    }else{
        orientation = UIInterfaceOrientationPortrait;
    }
    [self rotateWithOritation:orientation];
    
    if ([self.delegate respondsToSelector:@selector(YLVideoPlayerControlViewFullScreenButtonClick)]) {
        [self.delegate YLVideoPlayerControlViewFullScreenButtonClick];
    }
}

- (void) rotateWithOritation:(UIInterfaceOrientation) orientation {

    if (self.closeRotate) {
        return;
    }
    
    
    @weakObj(self);
    if (orientation != UIInterfaceOrientationPortrait) {
        if ([self.delegate respondsToSelector:@selector(YLVideoPlayerControlViewWillRotate)]) {
            [self.delegate YLVideoPlayerControlViewWillRotate];
        }

        self.isPortrait = NO;
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            @strongObj(self);
            make.width.equalTo(@(strongSelf.videoLandscapeW));
            make.height.equalTo(@(strongSelf.videoLandscapeH));
            make.center.equalTo(strongSelf.superview);
        }];
        if (self.scrollView) {
            self.scrollView.scrollsToTop = NO;
        }
    }else{
        self.isPortrait = YES;
        [self.superView addSubview:self];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            @strongObj(self);
            make.top.equalTo(strongSelf.superView).with.offset(0);
            make.left.equalTo(strongSelf.superView).with.offset(0);
            make.right.equalTo(strongSelf.superView).with.offset(0);
            make.height.equalTo(@(strongSelf.videoPortraitH));
        }];
        if (self.scrollView) {
            self.scrollView.scrollsToTop = YES;
        }
    }
    
    //iOS6.0之后,设置状态条的方法能使用的前提是shouldAutorotate为NO,也就是说这个视图控制器内,旋转要关掉;
    //也就是说在实现这个方法的时候-(BOOL)shouldAutorotate返回值要为NO
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
    //获取旋转状态条需要的时间:
    [UIView beginAnimations:nil context:nil];
    //更改了状态条的方向,但是设备方向UIInterfaceOrientation还是正方向的,这就要设置给你播放视频的视图的方向设置旋转
    //给你的播放视频的view视图设置旋转
    self.transform = CGAffineTransformIdentity;
    self.transform = [YLVideoPlayerView getCurrentDeviceOrientation];
    [UIView setAnimationDuration:1.0];
    //开始旋转
    [UIView commitAnimations];
    
}


//总 分享按钮的点击
- (void) shareBtnClick {
    @weakObj(self);
    //添加 点击分享
    [self addSubview:self.shareView];
    [UIView animateWithDuration:0.4 animations:^{
        @strongObj(self);
        strongSelf.shareBtnContainer.left = strongSelf.bounds.size.width - ShareView_Width;
    } completion:^(BOOL finished) {
        
    }];
    
}

//点击退出分享
- (void) shareViewTapAction {
    @weakObj(self);
    [UIView animateWithDuration:0.4 animations:^{
        @strongObj(self);
        _shareBtnContainer.left = strongSelf.bounds.size.width;
    } completion:^(BOOL finished) {
        @strongObj(self);
        [strongSelf.shareView removeFromSuperview];
    }];
}


//分享按钮的点击
- (void)shareButtonClick:(UIButton *)button
{
    [self shareViewTapAction];
    if ([self.delegate respondsToSelector:@selector(YLVideoPlayerControlViewShareButtonClick:)]) {
        [self.delegate YLVideoPlayerControlViewShareButtonClick:button.tag];
    }
}

- (void) shareButtonTap:(UITapGestureRecognizer *) tapGes {
    [self shareViewTapAction];
    if ([self.delegate respondsToSelector:@selector(YLVideoPlayerControlViewShareButtonClick:)]) {
        [self.delegate YLVideoPlayerControlViewShareButtonClick:tapGes.view.tag];
    }
}

//无网络状态
- (void)setNoNetWorkStatus {
    @weakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongObj(self);
        [strongSelf.progressView stopAnimating];
        [strongSelf addSubview:self.noNetTryView];
        [strongSelf bringSubviewToFront:self.backButton];
        [strongSelf.noNetTryView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.edges.equalTo(strongSelf);
        }];

    });

}


- (void) noNetWorkTryAgainAction {
    [self.noNetTryView removeFromSuperview];
    if (self.videoUrl) {
        CGFloat currentTime = CMTimeGetSeconds(self.playerItem.currentTime);
        if (currentTime == 0) {
            //这里发现的bug ,第一次加载时,如果没有网络,重新连上继续播放时必须这样再次初始化
            self.videoUrl = _videoUrl;
        }
        [self play];
    }else if ([self.delegate respondsToSelector:@selector(YLVideoPlayerControlViewNetWorkTryButtonClick)]) {
        [self.delegate YLVideoPlayerControlViewNetWorkTryButtonClick];
    }
}

#pragma mark - Video Control Button
//暂停
- (void) pause {
    
    if (!_isPlaying) {
        return;
    }
    self.isVideoPause = YES;
    [self.playOrPauseButton setImage:[UIImage imageNamed:PlayButtonImage] forState:UIControlStateNormal];
    [self.progressView stopAnimating];
    [self.player pause];
    [self removeProgressTimer];

}
//播放
- (void) play {
    
    [self.noNetTryView removeFromSuperview];
    if (self.netState == YLPlayerNetStateNotReachable ) {
        [self.progressView stopAnimating];
//        [self showAllToolBar];
        [self setNoNetWorkStatus];
        return;
    }

    if (_isPlaying) {
        return;
    }
    
    
    [self.playOrPauseButton setImage:[UIImage imageNamed:@"videoDetail_pause"] forState:UIControlStateNormal];
    self.isVideoPause = NO;
    if (!_isVideoEnd) {
        [self.player play];

        [self addProgressTimer];
    }else{
        
        @weakObj(self);
        if (self.progressSlider.value == 1.0) {
            self.progressSlider.value = 0.0;
            NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.duration) * self.progressSlider.value ;
            [self.player seekToTime:CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                @strongObj(self);
                _isVideoEnd = NO;
                [strongSelf.player play];
                [strongSelf addProgressTimer];
            }];

        }else{
            _isVideoEnd = NO;
            [self.player play];
            [self addProgressTimer];

        }
    }


}

- (void) playOrPauseButtonClick: (UIButton *) playOrPauseButton {
    
    if (_videoUrl.length) {
        if (self.isVideoPause) {
            [self play];
        }else {
            [self pause];
        }
        
    }else{
        if ([self.delegate respondsToSelector:@selector(YLVideoPlayerControlViewPlayButtonClickWhenNetworkNormal)]) {
            [self.delegate YLVideoPlayerControlViewPlayButtonClickWhenNetworkNormal];
        }
    }
    
}

//网络情况差的时候显示所有的工具栏
- (void) showAllToolBar {
    
    self.isVideoPause = YES;
    [self.playOrPauseButton setImage:[UIImage imageNamed:PlayButtonImage] forState:UIControlStateNormal];
    [self.progressView stopAnimating];
    [self.player pause];
    [self removeProgressTimer];
    
    self.bottomBar.alpha = 1.0;
    self.playOrPauseButton.alpha = 1.0;
    self.topBar.alpha = 1.0;
    self.backButton.alpha = 1.0;
}

-(void)resetPlayView {
    [self.player pause];
    [self removeProgressTimer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    _videoUrl = nil;
    [self.progressView startAnimating];
    self.progressSlider.value = 0.0;
    self.cacheSlider.value = 0.0;
    self.totalVideoTime.text = @"00:00";
    self.currentVideoTime.text = @"00:00";
    [self.progressView startAnimating];
}


//销毁播放器
- (void)destoryVideoPlayer {
    NSLog(@"destoryVideoPlayer");
    [self removeFromSuperview];
    self.superView = nil;
    self.delegate = nil;
    [self pause];
    [self removeTimer];
    
    @weakObj(self);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @strongObj(self);
        [[NSNotificationCenter defaultCenter] removeObserver:strongSelf name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:strongSelf name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [strongSelf.playerItem removeObserver:strongSelf forKeyPath:@"status"];
        [strongSelf.playerItem removeObserver:strongSelf forKeyPath:@"playbackBufferEmpty"];
        [strongSelf.playerItem removeObserver:strongSelf forKeyPath:@"playbackLikelyToKeepUp"];
        
        [strongSelf.player.currentItem cancelPendingSeeks];
        [strongSelf.player.currentItem.asset cancelLoading];
        [strongSelf.player pause];
        [strongSelf.playerLayer removeFromSuperlayer];
        [strongSelf.player replaceCurrentItemWithPlayerItem:nil];
        strongSelf.player = nil;
        strongSelf.playerItem = nil;
        
    });

    
}

#pragma mark - Video Control Gesterture

- (void) sliderReactViewGestureAction:(UIPanGestureRecognizer *)rec {
    CGPoint point = [rec translationInView:self];
    
    if (rec.state == UIGestureRecognizerStateBegan) {
        self.startSliderValue = self.progressSlider.value;
        if (self.progressTimer) {
            [self removeProgressTimer];
        }

    }else if (rec.state == UIGestureRecognizerStateChanged){
        self.progressSlider.value = self.startSliderValue + point.x * 1.0 / self.sliderReactView.width;
        if (self.progressTimer) {
            [self removeProgressTimer];
        }
        NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.duration) * self.progressSlider.value;
        NSTimeInterval duration = CMTimeGetSeconds(self.player.currentItem.duration);
        [self updateTimeWithCurrentTime:currentTime duration:duration];

    }else{
        [self pause];
        [self.progressView startAnimating];
        NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.duration) * self.progressSlider.value;
        __weak typeof (self) wself = self;
        // 设置当前播放时间
        [self.player seekToTime:CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (!wself.isVideoPause) {
                [wself addProgressTimer];
                [wself.player play];
                [wself.progressView stopAnimating];
            }else{
                _isPlaying = NO;
            }
        }];

    }
    
}



- (void)handleSingleTap:(UITapGestureRecognizer *)sender{

    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoDismissBottomView:) object:nil];
    
//    WeakSelf(wself);
    
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    self.autoDismissTimer = [NSTimer timerWithTimeInterval:AUTODISMISS_TIME target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
    @weakObj(self);
    [UIView animateWithDuration:0.5 animations:^{
        @strongObj(self);
        if (strongSelf.bottomBar.alpha == 0.0) {
            strongSelf.bottomBar.alpha = 1.0;
            strongSelf.playOrPauseButton.alpha = 1.0;
            strongSelf.topBar.alpha = 1.0;
            strongSelf.backButton.alpha = 1.0;
            
            [UIApplication sharedApplication].statusBarHidden = NO;
        }else{
            strongSelf.bottomBar.alpha = 0.0;
            strongSelf.topBar.alpha = 0.0;
            strongSelf.playOrPauseButton.alpha = 0.0;
            if (!_isPortrait) {
                strongSelf.backButton.alpha = 0.0;
                [UIApplication sharedApplication].statusBarHidden = YES;
            }
        }
    } completion:^(BOOL finish){
        
    }];
}

- (void) voiceGuideViewTap: (UITapGestureRecognizer *) tapGes {
    @weakObj(self);
    [self.voiceDismissTimer invalidate];
    self.voiceDismissTimer = nil;
    [UIView animateWithDuration:0.5 animations:^{
        @strongObj(self);
        strongSelf.voiceGuideView.alpha = 0.0;
    } completion:^(BOOL finish){
        @strongObj(self);
        [strongSelf.voiceGuideView removeFromSuperview];
    }];
    
}

- (void)voiceControlGesture:(UIPanGestureRecognizer *)pan
{
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self];
    
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x < y){ // 垂直移动
                self.panDirection = PanDirectionVerticalMoved;
            }else{
                self.panDirection = PanDirectionHorizontalMoved;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.panDirection) {
                case PanDirectionVerticalMoved:{
                    self.volumeViewSlider.value -= veloctyPoint.y / 10000;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            break;
        }
        default:
            break;
    }
    
    
}

- (void) noNetTryViewAction {
    
}


#pragma mark - Notification Action
- (void)moviePlayDidEnd:(NSNotification *)notification {
    
    [self updateTime];
    self.progressSlider.value = 1;
    self.isVideoPause = YES;
    _isVideoEnd = YES;
    [self removeProgressTimer];
    
    [self.player pause];
    self.bottomBar.alpha = 1.0;
    self.playOrPauseButton.alpha = 1.0;
    self.topBar.alpha = 1.0;
    self.backButton.alpha = 1.0;
    
    [self.playOrPauseButton setImage:[UIImage imageNamed:PlayButtonImage] forState:UIControlStateNormal];
    
    if ([self.delegate respondsToSelector:@selector(YLVideoPlayerControlViewFinishPlay)]) {
        [self.delegate YLVideoPlayerControlViewFinishPlay];
    }
}

/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            //            NSLog(@"第3个旋转方向---电池栏在下");
            return;
        }
            break;
        case UIInterfaceOrientationPortrait:{
            //            NSLog(@"第0个旋转方向---电池栏在上");
            [self rotateWithOritation:interfaceOrientation];

        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            //            NSLog(@"第2个旋转方向---电池栏在左");
            [self rotateWithOritation:interfaceOrientation];

        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            //            NSLog(@"第1个旋转方向---电池栏在右");
            [self rotateWithOritation:interfaceOrientation];
        }
            break;
        default:
            break;
    }
}

- (void)appWillResignActive:(NSNotification*)note{
    _isPlayResignActive = _isPlaying;
    [self pause];
    
}

- (void)appBecomeActive:(NSNotification *)note{
    if (_isPlayResignActive) {
        [self play];
    }
}


#pragma mark - private

- (void) initialize {
    //设置静音状态也可播放声音
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    self.player = [[AVPlayer alloc] init];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.layer addSublayer:self.playerLayer];
    
    
    self.backgroundColor = [UIColor blackColor];
    [self addSubview:self.topBar];
    @weakObj(self);
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongObj(self);
        make.left.right.equalTo(strongSelf);
        make.top.equalTo(strongSelf);
        make.height.mas_equalTo(@68);
    }];
    
    [self addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongObj(self);
        make.left.equalTo(strongSelf);
        make.top.equalTo(strongSelf).offset(TitleLabelTop - 12);
        make.width.mas_equalTo(@43.5);
        make.height.mas_equalTo(@47.5);
    }];

    
    [self addSubview:self.bottomBar];
    
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongObj(self);
        make.left.bottom.right.equalTo(strongSelf);
        make.height.mas_equalTo(@40);
    }];
    
    [self addSubview:self.playOrPauseButton];
    
    self.progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:self.progressView];
    [self.progressView startAnimating];
    self.progressView.hidesWhenStopped = YES;
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongObj(self);
        make.center.equalTo(strongSelf);
    }];
    
    [self addSubview:self.playOrPauseButton];
    [self.playOrPauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongObj(self);
        make.center.equalTo(strongSelf);
        make.width.height.mas_equalTo(@38);
    }];
    
    //         单击的 Recognizer
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1; // 单击
    singleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:singleTap];
    
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    self.autoDismissTimer = [NSTimer timerWithTimeInterval:8.0 target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
    
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    self.netState = [reachabilityManager networkReachabilityStatus];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        @strongObj(self);
        strongSelf.netState = status;
    }];
    [reachabilityManager startMonitoring];

    //添加一个声音引导层
    [self addVoiceControlGuide];
}

-(void)autoDismissBottomView:(NSTimer *)timer{
    
    if(self.player.rate==1.0f){
        if (self.bottomBar.alpha==1.0) {
            @weakObj(self);
            [UIView animateWithDuration:0.5 animations:^{
                @strongObj(self);
                strongSelf.bottomBar.alpha = 0.0;
                strongSelf.topBar.alpha = 0.0;
                strongSelf.playOrPauseButton.alpha = 0.0;
                if (!_isPortrait) {
                    strongSelf.backButton.alpha = 0.0;
                    [UIApplication sharedApplication].statusBarHidden = YES;
                }
            } completion:^(BOOL finish){
                
            }];
        }
    }
    
}

- (void) voiceGuideViewAutoDismiss: (NSTimer *) timer {
    
    @weakObj(self);
    [UIView animateWithDuration:0.5 animations:^{
        @strongObj(self);
        strongSelf.voiceGuideView.alpha = 0.0;
    } completion:^(BOOL finish){
        @strongObj(self);
        [strongSelf.voiceGuideView removeFromSuperview];
    }];
}

/**
 *  获取系统音量
 */
- (void)configureVolume
{
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
}

- (void) addVoiceControlGuide {
    BOOL isKnow;
    isKnow = [YLLocalSetting isVideoDetailFirstUse];
    if (!isKnow) {
        @weakObj(self);
        [self addSubview:self.voiceGuideView];
        [self.voiceGuideView mas_makeConstraints:^(MASConstraintMaker *make) {
            @strongObj(self);
            make.edges.equalTo(strongSelf);
        }];
        self.voiceDismissTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(voiceGuideViewAutoDismiss:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.voiceDismissTimer forMode:NSDefaultRunLoopMode];
    }
    //添加音量调节
    self.voicePanGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(voiceControlGesture:)];
    [self configureVolume];
    [YLLocalSetting setVideoDetailFirstUse:YES];

}

- (void) addShareButtonsWithContainerView: (UIView *) containerView andImageNameArray:(NSArray *) imgNameArray andZhNameArray: (NSArray *) zhNameArray {
    
    for (int i = 0; i < imgNameArray.count ; i++) {
        
        UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:imgNameArray[i]] forState:UIControlStateNormal];
        [button setTitle:zhNameArray[i] forState:UIControlStateNormal];
        button.titleLabel.font = UIFontSystem(13);
        [button setImageEdgeInsets:UIEdgeInsetsMake(-20, 8, 0, 0)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(65, -55, 0, 0)];
        [containerView addSubview:button];
        
        button.tag = i;
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(containerView);
            make.width.mas_equalTo(@75.25);
            make.height.mas_equalTo(@77);
            make.left.equalTo(containerView).offset(9.5 + i * 75.25);
        }];
        [button addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
}

- (void ) shareContainerTapAction {
}

//改变横屏状态下的分享界面位置
- (void) dismissShareViewLandscape{
    _shareBtnContainer.left = [UIScreen mainScreen].bounds.size.height;
    //这里不要调用 self.shareView
    [_shareView removeFromSuperview];
}


#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        
        AVPlayerItem *item = (AVPlayerItem *)object;
        if (item.status == AVPlayerItemStatusReadyToPlay) {
//            @weakObj(self);
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                @strongObj(self);
//                NSTimeInterval timeInterval = [self availableDuration];
//                if (timeInterval != 0) {
//                    [strongSelf.progressView stopAnimating];
//                }
//
//            });
            self.sliderReactView.userInteractionEnabled = YES;
        }else{
            self.sliderReactView.userInteractionEnabled = NO;
        }
        
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
        // 当缓冲是空的时候
        if (self.netState == YLPlayerNetStateNotReachable ) {
            [self.progressView stopAnimating];
            [self setNoNetWorkStatus];
        }else{
            @weakObj(self);
            [self.player pause];
            [self.progressView startAnimating];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongObj(self);
                if (!_isVideoPause) {
                    [strongSelf.player play];
                    [strongSelf.progressView stopAnimating];
                }
                
            });
            
        }
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        // 当缓冲好的时候
        [self.progressView stopAnimating];
        if (!self.isVideoPause) {
            [self.player play];
        }
    }
}

- (void)updateTimeWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration
{
    
    NSInteger dMin = duration / 60;
    NSInteger dSec = (NSInteger)duration % 60;
    
    NSInteger cMin = currentTime / 60;
    NSInteger cSec = (NSInteger)currentTime % 60;
    
    dMin = dMin<0?0:dMin;
    dSec = dSec<0?0:dSec;
    cMin = cMin<0?0:cMin;
    cSec = cSec<0?0:cSec;
    
    NSString *durationString = [NSString stringWithFormat:@"%02ld:%02ld", (long)dMin, (long)dSec];
    NSString *currentString = [NSString stringWithFormat:@"%02ld:%02ld", (long)cMin, (long)cSec];
    
    self.currentVideoTime.text = currentString;
    self.totalVideoTime.text = durationString;
}


#pragma mark - Timer
- (void)addProgressTimer
{
    
    _isPlaying = YES;
    
    @weakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongObj(self);
        strongSelf.progressTimer = [NSTimer scheduledTimerWithTimeInterval:UpdateProgress_Moment target:strongSelf selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
        if (strongSelf.progressTimer) {
            [[NSRunLoop mainRunLoop] addTimer:strongSelf.progressTimer forMode:NSRunLoopCommonModes];
        }

    });
}

- (void)removeProgressTimer
{
    _isPlaying = NO;
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

- (void)updateProgressInfo
{
    // 1.更新时间
    [self updateTime];
    // 2.设置进度条的value
    self.progressSlider.value = CMTimeGetSeconds(self.player.currentTime) / CMTimeGetSeconds(self.player.currentItem.duration);
    // 计算缓冲进度
    NSTimeInterval timeInterval = [self availableDuration];
    CMTime duration             = self.playerItem.duration;
    CGFloat totalDuration       = CMTimeGetSeconds(duration);
    self.cacheSlider.value = timeInterval / totalDuration;

}

/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [_playerItem loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}


- (void)updateTime
{
    NSTimeInterval duration = CMTimeGetSeconds(self.player.currentItem.duration);
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentTime);
    
    return [self updateTimeWithCurrentTime:currentTime duration:duration];
}



- (void) removeTimer {
    
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    [self removeProgressTimer];
}

#pragma mark - setter

- (void)setVideoUrl:(NSString *)videoUrl {
    [self resetPlayView];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _videoUrl = videoUrl;
    [self.progressView startAnimating];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:videoUrl]];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 缓冲区空了，需要等待数据
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options: NSKeyValueObservingOptionNew context:PlayViewStatusObservationContext];
    // 缓冲区有足够数据可以播放了
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options: NSKeyValueObservingOptionNew context:PlayViewStatusObservationContext];
    
}

- (void)setVideoTitle:(NSString *)videoTitle {
    _videoTitle = videoTitle;
    self.titleLabel.text = _videoTitle;
}

- (void)setVideoPlayCount:(NSInteger)videoPlayCount{
    _videoPlayCount = videoPlayCount;
    self.playCountLabel.text = [NSString stringWithFormat:@"%@次播放",[NSString getLegalPlayCountStringWithString:[NSString stringWithFormat:@"%ld",videoPlayCount]]];
}

- (void)setIsPortrait:(BOOL)isPortrait {
    _isPortrait = isPortrait;
    
    if (_isPortrait) {
        self.topStatusBar.backgroundColor = [UIColor clearColor];
        [UIApplication sharedApplication].statusBarHidden = NO;
        self.backButton.alpha = 1.0;
        [self.fullScreenButton setImage:[UIImage imageNamed:@"videoDetail_fullScreen"] forState:UIControlStateNormal];
        [self removeGestureRecognizer:self.voicePanGes];
        if ([self.delegate isKindOfClass:[YLVideoDetailViewController class]]) {
            self.titleLabel.hidden = YES;
            self.playCountLabel.hidden = YES;
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_topBar).offset(TitleLabelTop);
                make.left.equalTo(_topBar).offset(TitleLabelLeftWithBack);
                make.right.equalTo(_topBar).offset(-18);
            }];
            self.backButton.hidden = NO;
            
        }else {
            self.titleLabel.hidden = NO;
            self.playCountLabel.hidden = YES;
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_topBar).offset(TitleLabelTop);
                make.left.equalTo(_topBar).offset(TitleLabelLeftWithoutBack);
                make.right.equalTo(_topBar).offset(-18);
            }];
            self.backButton.hidden = YES;

        }
        
    }else{
        [self addGestureRecognizer:self.voicePanGes];
        self.topStatusBar.backgroundColor = [UIColor blackColor];
        //这里的隐藏需要加一个 延时 , 不然会引起bug (navgationbar 会往上顶起20)
        @weakObj(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongObj(self);
            if (strongSelf.topBar.alpha == 0.0) {
                [UIApplication sharedApplication].statusBarHidden = YES;
            }else{
                [UIApplication sharedApplication].statusBarHidden = NO;
            }
        });
        [self.fullScreenButton setImage:[UIImage imageNamed:@"videoDetail_portraitScreen"] forState:UIControlStateNormal];
        
        self.titleLabel.hidden = NO;
        self.playCountLabel.hidden = YES;
        self.backButton.hidden = NO;
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_topBar).offset(TitleLabelTop);
            make.left.equalTo(_topBar).offset(TitleLabelLeftWithBack);
            make.right.equalTo(_topBar).offset(-18);
        }];
    }
}

- (void)setNetState:(YLPlayerNetState)netState {
    _netState = netState;
}


#pragma mark - getter
- (UIView *)topBar
{
    if (!_topBar) {
        @weakObj(self);
        
        _topBar = [[UIView alloc] init];
        
        self.topStatusBar = [[UIView alloc] init];
        self.topStatusBar.backgroundColor = [UIColor blackColor];
        [_topBar addSubview:self.topStatusBar];
        [self.topStatusBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(_topBar);
            make.height.mas_equalTo(@20);
        }];
        
        UIImageView * backImg = [[UIImageView alloc] init];
        backImg.image = [UIImage imageNamed:@"videoDetail_titleBack"];
        [_topBar addSubview:backImg];
        [backImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(_topBar);
            make.height.mas_equalTo(80);
        }];
        
        [_topBar addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_topBar).offset(TitleLabelTop);
            make.left.equalTo(_topBar).offset(TitleLabelLeftWithoutBack);
            make.right.equalTo(_topBar).offset(-18);
        }];
        
        [_topBar addSubview:self.playCountLabel];
        [self.playCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            @strongObj(self);
            make.top.equalTo(strongSelf.titleLabel.mas_bottom).offset(10);
            make.left.equalTo(strongSelf.titleLabel.mas_left).offset(0);
            make.width.mas_equalTo(@100);
            make.height.mas_equalTo(@10);
        }];

        _topBar.alpha = 0.0;
    }
    return _topBar;
}


- (UIView *)bottomBar
{

    if (!_bottomBar) {
        _bottomBar = [[UIView alloc] init];
        _bottomBar.backgroundColor = [UIColor clearColor];
        _bottomBar.alpha = 0.0;
        
        [_bottomBar addSubview:self.fullScreenButton];
        [self.fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_bottomBar);
            make.right.equalTo(_bottomBar).offset(-4);
            make.width.height.mas_equalTo(@39);
        }];
        
        UIImageView * backImg = [[UIImageView alloc] init];
        backImg.image = [UIImage imageNamed:@"videoDetail_progressBack"];
        [_bottomBar addSubview:backImg];
        [backImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_bottomBar).offset(0);
        }];
        
        [_bottomBar addSubview:self.totalVideoTime];
        [self.totalVideoTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_bottomBar);
            make.right.equalTo(_bottomBar).offset(-43);
            make.width.mas_equalTo(@32);
            make.height.mas_equalTo(@12);
        }];
        
        
        
        [_bottomBar addSubview:self.currentVideoTime];
        [self.currentVideoTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_bottomBar);
            make.left.equalTo(_bottomBar).offset(17);
            make.width.mas_equalTo(@32);
            make.height.mas_equalTo(@12);
        }];
        
        [_bottomBar addSubview:self.cacheSlider];
        [self.cacheSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_bottomBar);
            make.left.equalTo(_bottomBar).offset(68);
            make.right.equalTo(_bottomBar).offset(-98);
            make.height.mas_equalTo(@3);
        }];
        

        
        [_bottomBar addSubview:self.progressSlider];
        [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_bottomBar);
            make.left.equalTo(_bottomBar).offset(66);
            make.right.equalTo(_bottomBar).offset(-96);
        }];
        
        [_bottomBar addSubview:self.sliderReactView];
        [self.sliderReactView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_bottomBar);
            make.left.equalTo(_bottomBar).offset(66);
            make.right.equalTo(_bottomBar).offset(-96);
        }];


    }
    return _bottomBar;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        
        [_backButton setImage:[UIImage imageNamed:@"videoDetail_back"] forState:UIControlStateNormal];
        _backButton.imageEdgeInsets = UIEdgeInsetsMake(12, 15, 12, 15);
        [_backButton addTarget:self action:@selector(YLVideoPlayerControlViewBackButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font =[UIFont fontWithName:@"Helvetica-Bold" size:18];
        _titleLabel.text = @"";
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColor = ColorWithHexRGB(0xffffff);
    }
    return _titleLabel;
}

- (UILabel *)playCountLabel {
    if (!_playCountLabel) {
        _playCountLabel = [[UILabel alloc] init];
        _playCountLabel.textAlignment = NSTextAlignmentLeft;
        _playCountLabel.font = [UIFont systemFontOfSize:10];
        _playCountLabel.numberOfLines = 1;
        _playCountLabel.textColor = ColorWithHexRGB(0xc0c0c0);
    }
    return _playCountLabel;

}


- (UIButton *)playOrPauseButton
{
    if (!_playOrPauseButton) {
        _playOrPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playOrPauseButton setImage:[UIImage imageNamed:@"videoDetail_pause"] forState:UIControlStateNormal];
        [_playOrPauseButton addTarget:self action:@selector(playOrPauseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _playOrPauseButton.alpha = 0.0;
        
    }
    return _playOrPauseButton;
}



- (UIButton *)fullScreenButton
{
    if (!_fullScreenButton) {
        
        _fullScreenButton = [[UIButton alloc] init];
        _fullScreenButton.imageEdgeInsets = UIEdgeInsetsMake(13, 13, 13, 13);
        [_fullScreenButton setImage:[UIImage imageNamed:@"videoDetail_fullScreen"] forState:UIControlStateNormal];
        [_fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenButton;
}


- (UISlider *)cacheSlider {
    if (!_cacheSlider) {
        _cacheSlider = [[UISlider alloc] init];
        _cacheSlider.userInteractionEnabled = NO;
        [_cacheSlider setThumbImage:[UIImage imageNamed:@"videoDetail_cachePoint.jpg"] forState:UIControlStateNormal];
        [_cacheSlider setMinimumTrackTintColor:ColorWithHexRGB(0xffffff)];
        [_cacheSlider setMaximumTrackTintColor:ColorWithHexRGBA(0xffffff, 0.35)];
        _cacheSlider.value = 0.f;
        _cacheSlider.continuous = YES;
    }
    return _cacheSlider;
    
}

- (UISlider *)progressSlider
{
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 10)];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"videoDetail_progressPoint"] forState:UIControlStateNormal];
        [_progressSlider setMinimumTrackTintColor:ColorWithHexRGB(0xb91223)];
        [_progressSlider setMaximumTrackTintColor:[UIColor clearColor]];
        _progressSlider.value = 0.0f;
        _progressSlider.continuous = YES;
        _progressSlider.userInteractionEnabled = NO;
    }
    return _progressSlider;
}

- (UIView *)sliderReactView {
    if (!_sliderReactView) {
        _sliderReactView = [[UIView alloc] init];
        _sliderReactView.userInteractionEnabled = NO;
        //首页视频频道底部有 scrollview 容易发生左右滑动交互覆盖掉 进度条的交互,所以这里这样处理下
        UIPanGestureRecognizer * panRightGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderReactViewGestureAction:)];
        [_sliderReactView addGestureRecognizer:panRightGes];

    }
    return _sliderReactView;
}

- (UILabel *)currentVideoTime{
    if (!_currentVideoTime) {
        _currentVideoTime = [[UILabel alloc] init];
        _currentVideoTime.textAlignment = NSTextAlignmentCenter;
        _currentVideoTime.textColor = ColorWithHexRGB(0xffffff);
        _currentVideoTime.font = [UIFont systemFontOfSize:10];
        _currentVideoTime.text = @"00:00";
    }
    return _currentVideoTime;
}

- (UILabel *)totalVideoTime {
    if (!_totalVideoTime) {
        _totalVideoTime = [[UILabel alloc] init];
        _totalVideoTime.textAlignment = NSTextAlignmentCenter;
        _totalVideoTime.textColor = ColorWithHexRGB(0xffffff);
        _totalVideoTime.font = [UIFont systemFontOfSize:10];
        _totalVideoTime.text = @"00:00";
    }
    return _totalVideoTime;
}

- (UIView *)shareView {
    if (!_shareView) {
        
        _shareView = [[UIView alloc] initWithFrame:self.bounds];
        
        _shareView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareViewTapAction)];

        [_shareView addGestureRecognizer:tapGes];
        
        _shareBtnContainer = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width, 0, 320, self.bounds.size.height)];
        UITapGestureRecognizer * shareContainerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareContainerTapAction)];
        [_shareBtnContainer addGestureRecognizer:shareContainerTap];
        
        [_shareView addSubview:_shareBtnContainer];
        _shareBtnContainer.backgroundColor = ColorWithHexRGBA(0x000000, 0.75);
    
        //分享到
        UILabel * shareToLabel = [[UILabel alloc] init];
        shareToLabel.backgroundColor = [UIColor clearColor];
        shareToLabel.text = @"分享到";
        shareToLabel.textColor = ColorWithHexRGB(0xffffff);
        shareToLabel.font = [UIFont systemFontOfSize:17];
        shareToLabel.textAlignment = NSTextAlignmentCenter;
        [_shareBtnContainer addSubview:shareToLabel];
        [shareToLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_shareBtnContainer);
            make.top.equalTo(_shareBtnContainer).offset(70);
            make.height.mas_equalTo(@18);
        }];
    
        //添加分享按钮
        NSArray * imgNameArray = @[@"share_wechat_session",@"videoDetail_circleOfFriends",@"share_sina",@"share_qq"];
        NSArray * zhNameArray = @[@"微信好友",@"微信朋友圈",@"新浪微博",@"腾讯QQ"];
        [self addShareButtonsWithContainerView:_shareBtnContainer andImageNameArray:imgNameArray andZhNameArray:zhNameArray];
        
    }
    return _shareView;
}

- (UIView *)voiceGuideView {
    if (!_voiceGuideView) {
        _voiceGuideView = [[UIView alloc] init];
        _voiceGuideView.backgroundColor = ColorWithHexRGB(0x000000);
        _voiceGuideView.alpha = 0.6;
        
        UIImageView * voiceImg = [[UIImageView alloc] init];
        voiceImg.image = [UIImage imageNamed:@"videoDetail_voiceGuide"];
        [_voiceGuideView addSubview:voiceImg];
        [voiceImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_voiceGuideView);
            make.width.mas_equalTo(@50);
            make.height.mas_equalTo(@115);
        }];
        
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voiceGuideViewTap:)];
        [_voiceGuideView addGestureRecognizer:tapGes];
    }
    return _voiceGuideView;
}

- (UILabel *)noNetLabel {
    if (!_noNetLabel) {
        _noNetLabel = [[UILabel alloc] init];
        _noNetLabel.text = @"无网络,视频播放失败";
        _noNetLabel.textAlignment = NSTextAlignmentCenter;
        _noNetLabel.textColor = [UIColor whiteColor];
        _noNetLabel.font = [UIFont systemFontOfSize:14];
        
    }
    return _noNetLabel;
}

- (UIButton *)noNetTryBtn {
    if (!_noNetTryBtn) {
        _noNetTryBtn = [[UIButton alloc] init];
        [_noNetTryBtn setTitle:@"重试" forState:UIControlStateNormal];
        [_noNetTryBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _noNetTryBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _noNetTryBtn.layer.cornerRadius = 5;
        _noNetTryBtn.layer.masksToBounds = YES;
        _noNetTryBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _noNetTryBtn.layer.borderWidth = 1;
        [_noNetTryBtn addTarget:self action:@selector(noNetWorkTryAgainAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _noNetTryBtn;
}

- (UIView *)noNetTryView {
    if (!_noNetTryView) {
        _noNetTryView = [[UIView alloc] init];
        _noNetTryView.backgroundColor = [UIColor blackColor];
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noNetTryViewAction)];
        [_noNetTryView addGestureRecognizer:tapGes];
        
        [_noNetTryView addSubview:self.noNetLabel];
        [self.noNetLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_noNetTryView);
            make.width.mas_equalTo(160);
            make.height.mas_equalTo(20);
            make.centerY.equalTo(_noNetTryView.mas_centerY).offset(-15);
        }];
        
        [_noNetTryView addSubview:self.noNetTryBtn];
        [self.noNetTryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_noNetTryView);
            make.width.mas_equalTo(57);
            make.height.mas_equalTo(27);
            make.centerY.equalTo(_noNetTryView.mas_centerY).offset(15);
        }];
        
    }
    return _noNetTryView;
}

@end
