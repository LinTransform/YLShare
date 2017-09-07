//
//  YLShootVideoViewController.m
//  yl-videoRecord
//
//  Created by wyl on 2017/5/23.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import "YLShootVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "YLShootVideoManager.h"
#import "YLAnimationRecordView.h"
#import "YLShootPlayerView.h"
#import "UIImage+Additions.h"



typedef NS_ENUM(NSInteger,YLShootType) {
    YLShootTypeImage,
    YLShootTypeVideo,
};


@interface YLShootVideoViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate,UIGestureRecognizerDelegate>


//保存到相册的 asset
@property (nonatomic , strong) PHAsset * videoAsset;

@property (nonatomic , strong) UIView * videoView;
@property (nonatomic , strong) YLAnimationRecordView * recordView;
@property (nonatomic , strong) YLShootPlayerView *playerView;
@property (nonatomic , strong) UIImageView * shootImageView;
@property (nonatomic , strong) UIImage * shootImage;
@property (nonatomic , assign) YLShootType shootType;

@property (nonatomic , strong) UIButton  * cancelBtn;
@property (nonatomic , strong) UIButton * switchCameraBtn;
@property (nonatomic , strong) UIButton * recordBackBtn;
@property (nonatomic , strong) UIButton * recordSureBtn;
@property (nonatomic , strong) UILabel * tipLabel;

@property (nonatomic , strong) AVCaptureSession *videoSession;
@property (nonatomic , strong) AVCaptureVideoPreviewLayer *videoPreLayer;
@property (nonatomic , strong) AVCaptureDevice *videoDevice;

@property (nonatomic , strong) AVCaptureDeviceInput *videoInput;

@property (nonatomic , strong) AVCaptureVideoDataOutput *videoDataOut;
@property (nonatomic , strong) AVCaptureAudioDataOutput *audioDataOut;

@property (nonatomic , strong) AVAssetWriter *assetWriter;
@property (nonatomic , strong) AVAssetWriterInputPixelBufferAdaptor *assetWriterPixelBufferInput;
@property (nonatomic , strong) AVAssetWriterInput *assetWriterVideoInput;
@property (nonatomic , strong) AVAssetWriterInput *assetWriterAudioInput;
@property (nonatomic , assign) CMTime currentSampleTime;
@property (nonatomic , assign) BOOL recoding;
@property (nonatomic , strong) YLVideoModel * currentRecord;

/**闪光灯状态*/
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
@property (nonatomic, assign) AVCaptureTorchMode torchMode;

@property (nonatomic , strong) dispatch_queue_t recodingQueue;
@property (nonatomic , assign) BOOL currentRecordIsCancel;

@property (nonatomic , assign) NSInteger recordW;
@property (nonatomic , assign) NSInteger recordH;

//标记是否已经获取了图片
@property (nonatomic , assign) BOOL isGetShootImg;

@end

@implementation YLShootVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.recordW = (int)SHOOT_WIDTH;
    self.recordH = (int)SHOOT_HEIGHT;
    self.isGetShootImg = NO;
    if ( (int)SHOOT_WIDTH % 16 != 0) {
        self.recordW = (self.recordW / 16 + 1) * 16;
    }
    
    if ( (int)SHOOT_HEIGHT % 16 != 0) {
        self.recordH = (self.recordH / 16 + 1) * 16;
    }

    [self setupViews];
    
}

- (void)dealloc {
    NSLog(@"ShootVideoVC dealloc");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self closeView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupVideo];
}

#pragma mark --- init
- (void) setupViews {
    self.view.backgroundColor = ColorWithHexRGB(0xffffff);
    self.videoView = [[UIView alloc] initWithFrame:CGRectMake(SHOOT_LEFT, SHOOT_TOP, SHOOT_WIDTH, SHOOT_HEIGHT)];
    self.videoView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.videoView];
    @weakObj(self);
    self.recordView = [[YLAnimationRecordView alloc] init];
    self.recordView.longPressMin = kLongPressMin;
    self.recordView.startRecord = ^(){
        @strongObj(self);
        [strongSelf startShootVideo];
    };
    self.recordView.completeRecord = ^(CFTimeInterval recordTime) {
        @strongObj(self);
        [strongSelf endShootVideoWithTime:recordTime];
        [strongSelf remakeBtnLayout];
    };
    [self.view addSubview:self.recordView];
    [self.recordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@115);
        make.bottom.equalTo(self.view).offset(-62.5);
        make.centerX.equalTo(self.view);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongObj(self);
        make.centerX.equalTo(strongSelf.view);
        make.width.equalTo(@250);
        make.height.equalTo(@30);
        make.bottom.equalTo(strongSelf.recordView.mas_top).offset(0);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongObj(self);
        strongSelf.tipLabel.hidden = YES;
    });
    
    [self.recordBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongObj(self);
        make.center.equalTo(strongSelf.recordView);
    }];
    
    [self.recordSureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongObj(self);
        make.center.equalTo(strongSelf.recordView);
    }];

    
    // 闪光灯 暂时不添加了
//    UIButton * flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [flashBtn setTitle:@"关闭" forState:UIControlStateNormal];
//    flashBtn.frame = CGRectMake(15, 15, 40, 40);
//    [flashBtn addTarget:self action:@selector(flashTriggerAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:flashBtn];
    
    // 取消按钮
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongObj(self);
        make.left.equalTo(strongSelf.view).offset(10);
        make.top.equalTo(strongSelf.view).offset(20);
        make.width.mas_equalTo(@55);
        make.height.mas_equalTo(@32);
    }];
    
    // 切换摄像头
    [self.switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongObj(self);
        make.right.equalTo(strongSelf.view).offset(-10);
        make.top.equalTo(strongSelf.view).offset(20);
        make.width.mas_equalTo(@55);
        make.height.mas_equalTo(@32);
    }];
}


- (void)setupVideo {
    
//    NSInteger time1 = (long)[[NSDate date] timeIntervalSince1970];

    if (![[YLShootVideoManager shareManager] judgeIsHaveShootVideoAuthorityWithCallBackViewController:self]) {
        
    }
    
    if (TARGET_IPHONE_SIMULATOR) {
        NSLog(@"警告: 模拟器不可以");
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    self.flashMode = AVCaptureFlashModeOff;
    self.torchMode = AVCaptureTorchModeOff;
    self.recodingQueue = dispatch_queue_create("com.YL.queue", DISPATCH_QUEUE_SERIAL);
    
    NSArray *devicesVideo = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    NSArray *devicesAudio = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:devicesVideo[0] error:nil];
   
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:devicesAudio[0] error:nil];
    
    self.videoDevice = devicesVideo[0];
    
    self.videoDataOut = [[AVCaptureVideoDataOutput alloc] init];
    self.videoDataOut.videoSettings = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
    self.videoDataOut.alwaysDiscardsLateVideoFrames = YES;
    [self.videoDataOut setSampleBufferDelegate:self queue:self.recodingQueue];
    
    self.audioDataOut = [[AVCaptureAudioDataOutput alloc] init];
    [self.audioDataOut setSampleBufferDelegate:self queue:self.recodingQueue];
    
    self.videoSession = [[AVCaptureSession alloc] init];
    
    if ([self.videoSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        self.videoSession.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    if ([self.videoSession canAddInput:self.videoInput]) {
        [self.videoSession addInput:self.videoInput];
    }
    if ([self.videoSession canAddInput:audioInput]) {
        [self.videoSession addInput:audioInput];
    }
    if ([self.videoSession canAddOutput:self.videoDataOut]) {
        [self.videoSession addOutput:self.videoDataOut];
    }
    if ([self.videoSession canAddOutput:self.audioDataOut]) {
        [self.videoSession addOutput:self.audioDataOut];
    }
    self.videoPreLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.videoSession];
    self.videoPreLayer.frame = self.videoView.bounds;
    self.videoPreLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.videoView.layer addSublayer:self.videoPreLayer];
    [self.videoSession startRunning];
//    NSInteger time2 = (long)[[NSDate date] timeIntervalSince1970];
//    NSLog(@"启动摄像机用时  %ld",time2 - time1);
    
}

#pragma mark --- view releated methods
// 闪光灯切换
- (void)flashTriggerAction:(UIButton *)btn {
    switch (self.flashMode) {
        case AVCaptureFlashModeOff:{
            self.flashMode = AVCaptureFlashModeOn;
            self.torchMode = AVCaptureTorchModeOn;
            [btn setTitle:@"打开" forState:UIControlStateNormal];
        }break;
        case AVCaptureFlashModeOn:{
            self.flashMode = AVCaptureFlashModeAuto;
            self.torchMode = AVCaptureTorchModeAuto;
            [btn setTitle:@"自动" forState:UIControlStateNormal];
        }break;
        case AVCaptureFlashModeAuto:{
            self.flashMode = AVCaptureFlashModeOff;
            self.torchMode = AVCaptureTorchModeOff;
            [btn setTitle:@"关闭" forState:UIControlStateNormal];
        }break;

            
        default:
            break;
    }
    AVCaptureDevice * device = _videoInput.device;
    if ([device isFlashModeSupported:self.flashMode] && device.flashMode != self.flashMode) {
        NSError * error;
        // 更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
        if ([device lockForConfiguration:&error]) {
            [device setFlashMode:self.flashMode];
            [device setTorchMode:self.torchMode];
            [device unlockForConfiguration];
        }else{
            NSLog(@"闪光灯切换失败");
        }
    }
}

//切换摄像头
- (void) changeCamera:(UIButton *) buuton {
    if ([AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1) {
        NSArray *devicesVideo = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput * newVideoInput;
        AVCaptureDevicePosition position = self.videoInput.device.position;
        if (position == AVCaptureDevicePositionBack)
             newVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:devicesVideo[1] error:nil];
        else if (position == AVCaptureDevicePositionFront)
            newVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:devicesVideo[0] error:nil];
        if (newVideoInput != nil) {
            [self.videoSession beginConfiguration];
            [self.videoSession removeInput:self.videoInput];
            if ([self.videoSession canAddInput:newVideoInput]) {
                [self.videoSession addInput:newVideoInput];
                self.videoInput = newVideoInput;
            } else{
                [self.videoSession addInput:_videoInput];
            }
            [self.videoSession commitConfiguration];
        }
    
    }
}

//取消录制
- (void) cancelTakePhoto {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)remakeBtnLayout
{
    @weakObj(self);
    [self.recordSureBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongObj(self);
        make.width.height.equalTo(@80);
        make.right.equalTo(strongSelf.view).offset(-50);
        make.bottom.equalTo(strongSelf.view).offset(-80);
    }];
    
    [self.recordBackBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongObj(self);
        make.width.height.equalTo(@80);
        make.left.equalTo(strongSelf.view).offset(50);
        make.bottom.equalTo(strongSelf.view).offset(-80);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        @strongObj(self);
        [strongSelf.view layoutIfNeeded];
        strongSelf.recordSureBtn.alpha = 1.;
        strongSelf.recordBackBtn.alpha = 1.;
        strongSelf.recordView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)resetBtnLayout
{
    self.isGetShootImg = NO;
    if (self.playerView) {
        [self.playerView stop];
        [self.playerView removeFromSuperview];
        self.playerView = nil;
    }
    
    if (self.shootImageView) {
        self.shootImage = nil;
        [self.shootImageView removeFromSuperview];
    }
    
    
    [self startRunning];
    [YLShootVideoManager deleteVideo:self.currentRecord.videoAbsolutePath];
    
    @weakObj(self);
    [self.recordSureBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongObj(self);
        make.center.equalTo(strongSelf.recordView);
    }];
    
    [self.recordBackBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongObj(self);
        make.center.equalTo(strongSelf.recordView);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        @strongObj(self);
        [strongSelf.view layoutIfNeeded];
        strongSelf.recordSureBtn.alpha = 0.;
        strongSelf.recordBackBtn.alpha = 0.;
        strongSelf.recordView.alpha = 1.;
    }];
}

//确定保存视频
- (void) recordSureAction {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.shootType == YLShootTypeImage) {
        if ( [PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusDenied) {
            UIImageWriteToSavedPhotosAlbum(self.shootImage, self, @selector(image:didFinisYLavingWithError:contextInfo:), NULL);
        }
        _currentRecord.shootImage = self.shootImage;
        
        @weakObj(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongObj(self);
            if (_delegate) {
                [_delegate videoViewController:strongSelf didRecordVideo:_currentRecord];
            }
        });

    }else{
        @weakObj(self);
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:self.currentRecord.videoAbsolutePath]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            @strongObj(self);
            if (!error && success) {
                
            }
                        
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_delegate) {
                
                [_delegate videoViewController:self didRecordVideo:_currentRecord];
            }

        });


    }
}

// 保存图片的回调
- (void)image:(UIImage *)image didFinisYLavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
}


#pragma mark --- prevate methods

//开始录制视频

- (void) startShootVideo {
    self.currentRecord = [YLShootVideoManager createNewVideo];
    _currentRecordIsCancel = NO;
    NSURL *outURL = [NSURL fileURLWithPath:self.currentRecord.videoAbsolutePath];
    [self createWriter:outURL];
    
    _recoding = YES;
}

//停止录制视频
- (void) endShootVideoWithTime: (CFTimeInterval) recordTime{
    _recoding = NO;
    @weakObj(self);
    
    if (recordTime < kPhotoTime) {
        self.shootType = YLShootTypeImage;
        [self addImageView];

    }else{
        [self saveVideo:^(NSURL *outFileURL) {
            @strongObj(self);
            [strongSelf addPlayerView];
            strongSelf.shootType = YLShootTypeVideo;
        }];
    
    }
}

- (void) addImageView {
    self.isGetShootImg = YES;
    CGFloat oriImgWidth = self.shootImage.size.width;
    CGFloat oriImgHeight = self.shootImage.size.height;
    CGFloat targetW = oriImgWidth;
    CGFloat targetH = oriImgWidth * SHOOT_RATIO;
    self.shootImage = [self.shootImage clipImageInRect:CGRectMake(0, (oriImgHeight - targetH) * 0.5, targetW, targetH)];
    self.shootImageView = [[UIImageView alloc] initWithFrame:self.videoView.bounds];
    self.shootImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.shootImageView.clipsToBounds = YES;
    self.shootImageView.image = self.shootImage;
    [self.videoView addSubview:self.shootImageView];
}

- (void)addPlayerView {
    NSURL *videoURL = [NSURL fileURLWithPath:self.currentRecord.videoAbsolutePath];
    self.playerView = [[YLShootPlayerView alloc] initWithFrame:self.videoView.bounds videoUrl:videoURL];
    [self.videoView addSubview:self.playerView];
    [self.playerView play];
    [self stopRunning];
}

- (void)startRunning
{
    [_videoSession startRunning];
}

- (void)stopRunning
{
    [_videoSession stopRunning];
}



- (void)createWriter:(NSURL *)assetUrl {
    
    _assetWriter = [AVAssetWriter assetWriterWithURL:assetUrl fileType:AVFileTypeMPEG4 error:nil];
    //默认横屏录入的,所以这里要旋转 90
    NSDictionary *outputSettings = @{
                                     AVVideoCodecKey : AVVideoCodecH264,
                                     AVVideoWidthKey : @(self.recordH),
                                     AVVideoHeightKey : @(self.recordW),
                                     AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill,
                                     //                          AVVideoCompressionPropertiesKey:codecSettings
                                     };
    _assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    _assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    
    CGFloat rate = M_PI / 2.0;
    //判断此时设备方向
//    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
//    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
//    CGFloat rate = 0;
//    switch (interfaceOrientation) {
//        case UIInterfaceOrientationPortraitUpsideDown:{
////            NSLog(@"第3个旋转方向---电池栏在下");
//            rate = 3 * M_PI / 2.0;
//        }
//            break;
//        case UIInterfaceOrientationPortrait:{
////            NSLog(@"第0个旋转方向---电池栏在上");
//            rate = M_PI / 2.0;
//        }
//            break;
//        case UIInterfaceOrientationLandscapeLeft:{
////            NSLog(@"第2个旋转方向---电池栏在左");
//            rate = M_PI ;
//        }
//            break;
//        case UIInterfaceOrientationLandscapeRight:{
////            NSLog(@"第1个旋转方向---电池栏在右");
//            rate = 0;
//        }
//            break;
//        default:
//            break;
//    }
    _assetWriterVideoInput.transform = CGAffineTransformMakeRotation(rate);

    
    NSDictionary *audioOutputSettings = @{
                                          AVFormatIDKey:@(kAudioFormatMPEG4AAC),
                                          AVEncoderBitRateKey:@(64000),
                                          AVSampleRateKey:@(44100),
                                          AVNumberOfChannelsKey:@(1),
                                          };
    
    _assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioOutputSettings];
    _assetWriterAudioInput.expectsMediaDataInRealTime = YES;
    
    
    NSDictionary *SPBADictionary = @{
                                     (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                     (__bridge NSString *)kCVPixelBufferWidthKey : @(self.recordW),
                                     (__bridge NSString *)kCVPixelBufferHeightKey  : @(self.recordH),
                                     (__bridge NSString *)kCVPixelFormatOpenGLESCompatibility : ((__bridge NSNumber *)kCFBooleanTrue)
                                     };
    _assetWriterPixelBufferInput = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_assetWriterVideoInput sourcePixelBufferAttributes:SPBADictionary];
    if ([_assetWriter canAddInput:_assetWriterVideoInput]) {
        [_assetWriter addInput:_assetWriterVideoInput];
    }else {
        NSLog(@"不能添加视频writer的input \(assetWriterVideoInput)");
    }
    if ([_assetWriter canAddInput:_assetWriterAudioInput]) {
        [_assetWriter addInput:_assetWriterAudioInput];
    }else {
        NSLog(@"不能添加视频writer的input \(assetWriterVideoInput)");
    }
    
}

- (void)saveVideo:(void(^)(NSURL *outFileURL))complier {
    if (_recoding) return;
    
    if (!self.recodingQueue){
        complier(nil);
        return;
    };

    dispatch_async(self.recodingQueue, ^{
        NSURL *outputFileURL = [NSURL fileURLWithPath:_currentRecord.videoAbsolutePath];
        [YLShootVideoManager saveThumImageWithVideoURL:outputFileURL second:0.1];
        
        if (_assetWriter.status != AVAssetWriterStatusUnknown) {
            [_assetWriter finishWritingWithCompletionHandler:^{
                
                if (_currentRecordIsCancel) return ;
                
                [YLShootVideoManager saveThumImageWithVideoURL:outputFileURL second:1];
                
                if (complier) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complier(outputFileURL);
                    });
                }
            }];

        }else{
            NSLog(@"状态不对,没能保存");
        }
    });
    
}

- (void)closeView {
    [_videoSession stopRunning];
    [_videoPreLayer removeFromSuperlayer];
    _videoPreLayer = nil;
    [_videoView removeFromSuperview];
    _videoView = nil;
    _videoDevice = nil;
    _videoInput = nil;
    _assetWriter = nil;
    _videoDataOut = nil;
    _audioDataOut = nil;
    _assetWriterAudioInput = nil;
    _assetWriterVideoInput = nil;
    _assetWriterPixelBufferInput = nil;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    UIImage * image = [self imageFromSampleBuffer:sampleBuffer];
    if (image && !self.isGetShootImg) {
        self.shootImage = image;
    }
    if (!_recoding) return;
    
    @autoreleasepool {
        _currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
        if (_assetWriter.status != AVAssetWriterStatusWriting) {
            [_assetWriter startWriting];
            [_assetWriter startSessionAtSourceTime:_currentSampleTime];
        }
        if (captureOutput == _videoDataOut) {
            if (_assetWriterPixelBufferInput.assetWriterInput.isReadyForMoreMediaData) {
                CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                BOOL success = [_assetWriterPixelBufferInput appendPixelBuffer:pixelBuffer withPresentationTime:_currentSampleTime];
                if (!success) {
                    NSLog(@"Pixel Buffer没有append成功");
                }
            }
        }
        if (captureOutput == _audioDataOut) {
            [_assetWriterAudioInput appendSampleBuffer:sampleBuffer];
        }
    }
}

// 通过抽样缓存数据创建一个UIImage对象
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    if (!context) {
        return nil;
    }
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    //    cgimageget`
    
    // 用Quartz image创建一个UIImage对象image
    //UIImage *image = [UIImage imageWithCGImage:quartzImage];
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationRight];
//     释放Quartz image对象
        CGImageRelease(quartzImage);
    return (image);
    
    
}

- (UIImage*) cropImageInRect:(UIImage*)image{
    
    CGSize size = [image size];
    CGRect cropRect = [self calcRect:size];
    
    float scale = fminf(1.0f, fmaxf(size.width, size.height));
    CGPoint offset = CGPointMake(-cropRect.origin.x, -cropRect.origin.y);
    
    size_t subsetWidth = cropRect.size.width * scale;
    size_t subsetHeight = cropRect.size.height * scale;
    
    
    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef ctx =
    CGBitmapContextCreate(nil,
                          subsetWidth,
                          subsetHeight,
                          8,
                          0,
                          grayColorSpace,
                          kCGImageAlphaNone|kCGBitmapByteOrderDefault);
    CGColorSpaceRelease(grayColorSpace);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationNone);
    CGContextSetAllowsAntialiasing(ctx, false);
    
    // adjust the coordinate system
    CGContextTranslateCTM(ctx, 0.0, subsetHeight);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    
    UIGraphicsPushContext(ctx);
    CGRect rect = CGRectMake(offset.x * scale, offset.y * scale, scale * size.width, scale * size.height);
    
    [image drawInRect:rect];
    
    UIGraphicsPopContext();
    
    CGContextFlush(ctx);
    
    
    CGImageRef subsetImageRef = CGBitmapContextCreateImage(ctx);
    
    UIImage* subsetImage = [UIImage imageWithCGImage:subsetImageRef];
    
    CGImageRelease(subsetImageRef);
    
    CGContextRelease(ctx);
    
    
    return subsetImage;
}

- (CGRect) calcRect:(CGSize)imageSize{
    NSString* gravity = self.videoPreLayer.videoGravity;
    CGRect cropRect = self.videoPreLayer.bounds;
    CGSize screenSize = self.videoPreLayer.bounds.size;
    
    CGFloat screenRatio = screenSize.height / screenSize.width ;
    CGFloat imageRatio = imageSize.height /imageSize.width;
    
    CGRect presentImageRect = self.videoPreLayer.bounds;
    CGFloat scale = 1.0;
    
    
    if([AVLayerVideoGravityResizeAspect isEqual: gravity]){
        
        CGFloat presentImageWidth = imageSize.width;
        CGFloat presentImageHeigth = imageSize.height;
        if(screenRatio > imageRatio){
            presentImageWidth = screenSize.width;
            presentImageHeigth = presentImageWidth * imageRatio;
            
        }else{
            presentImageHeigth = screenSize.height;
            presentImageWidth = presentImageHeigth / imageRatio;
        }
        
        presentImageRect.size = CGSizeMake(presentImageWidth, presentImageHeigth);
        presentImageRect.origin = CGPointMake((screenSize.width-presentImageWidth)/2.0, (screenSize.height-presentImageHeigth)/2.0);
        
    }else if([AVLayerVideoGravityResizeAspectFill isEqual:gravity]){
        
        CGFloat presentImageWidth = imageSize.width;
        CGFloat presentImageHeigth = imageSize.height;
        if(screenRatio > imageRatio){
            presentImageHeigth = screenSize.height;
            presentImageWidth = presentImageHeigth / imageRatio;
        }else{
            presentImageWidth = screenSize.width;
            presentImageHeigth = presentImageWidth * imageRatio;
        }
        
        presentImageRect.size = CGSizeMake(presentImageWidth, presentImageHeigth);
        presentImageRect.origin = CGPointMake((screenSize.width-presentImageWidth)/2.0, (screenSize.height-presentImageHeigth)/2.0);
        
    }else{
        NSAssert(0, @"dont support:%@",gravity);
    }
    
    scale = CGRectGetWidth(presentImageRect) / imageSize.width;
    
    CGRect rect = cropRect;
    rect.origin = CGPointMake(CGRectGetMinX(cropRect)-CGRectGetMinX(presentImageRect), CGRectGetMinY(cropRect)-CGRectGetMinY(presentImageRect));
    
    rect.origin.x /= scale;
    rect.origin.y /= scale;
    rect.size.width /= scale;
    rect.size.height  /= scale;
    
    return rect;
}

#pragma mark --- getter

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:ColorWithHexRGB(0x7d8496) forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancelBtn addTarget:self action:@selector(cancelTakePhoto) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_cancelBtn];
    }
    return _cancelBtn;
}

- (UIButton *)switchCameraBtn {
    if (!_switchCameraBtn) {
        _switchCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];

        [_switchCameraBtn setImage:YLImageNamed(@"record_swichCamera") forState:UIControlStateNormal];
        [_switchCameraBtn addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_switchCameraBtn];
    }
    return _switchCameraBtn;
}

- (UIButton *)recordBackBtn
{
    if(!_recordBackBtn){
        _recordBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordBackBtn setImage:YLImageNamed(@"record_shootBack") forState:UIControlStateNormal];
        [_recordBackBtn addTarget:self action:@selector(resetBtnLayout) forControlEvents:UIControlEventTouchUpInside];
        _recordBackBtn.alpha = 0.;
        [self.view addSubview:_recordBackBtn];
    }
    return _recordBackBtn;
}

- (UIButton *)recordSureBtn
{
    if(!_recordSureBtn){
        _recordSureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordSureBtn setImage:YLImageNamed(@"record_shootSure") forState:UIControlStateNormal];
        _recordSureBtn.alpha = 0.;
        [_recordSureBtn addTarget:self action:@selector(recordSureAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_recordSureBtn];
    }
    return _recordSureBtn;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.text = @"点击拍照片, 长按拍视频";
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColor = ColorWithHexRGB(0x7d8496);
        _tipLabel.font = [UIFont systemFontOfSize:16];
    }
    [self.view addSubview:_tipLabel];
    return _tipLabel;
}


- (BOOL)shouldAutorotate {
    return NO;
}

@end
