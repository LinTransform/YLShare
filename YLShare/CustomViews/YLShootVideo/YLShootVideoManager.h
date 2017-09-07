//
//  YLShootVideoManager.h
//  yl-videoRecord
//
//  Created by wyl on 2017/5/24.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -- 配置
// 视频录制 时长
#define YLRecordTime        60.1
#define kLongPressMin 0
//区分视频还是照片的界限
#define kPhotoTime 2
#define SHOOT_RATIO 656.0/750
#define SHOOT_WIDTH [UIScreen mainScreen].bounds.size.width
#define SHOOT_HEIGHT (SHOOT_WIDTH * SHOOT_RATIO)
// 视频保存路径
#define YLVideoDicName      @"YLSmailVideo"

#pragma mark -- 宏
#define BOTTOM_HEIGHT 80
#define SHOOT_TOP 65
#define SHOOT_LEFT 0
#define YLSCREEN_WIDTH      [UIScreen mainScreen].bounds.size.width
#define YLSCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height
//加载bundle中的图片资源
#define YLShootBundleName @"YLShootImages"
#define YLImageNamed(x)     [UIImage imageNamed:[[[NSBundle mainBundle] pathForResource:YLShootBundleName ofType:@"bundle"] stringByAppendingPathComponent:x]]


@class YLVideoModel;

@interface YLShootVideoManager : NSObject

+ (YLShootVideoManager *)shareManager;

/*!
 *  有视频的存在
 */
+ (BOOL)existVideo;

/*!
 *  时间倒序 后的视频列表
 */
+ (NSArray *)getSortVideoList;

/*!
 *  保存缩略图
 *
 *  @param videoUrl 视频路径
 *  @param second   第几秒的缩略图
 */
+ (void)saveThumImageWithVideoURL:(NSURL *)videoUrl second:(int64_t)second;

/*!
 *  产生新的对象
 */
+ (YLVideoModel *)createNewVideo;

/*!
 *  删除视频
 */
+ (void)deleteVideo:(NSString *)videoPath;


/*!
 *  存储路径
 */

+ (NSString *)getVideoPath;

- (BOOL)judgeIsHaveShootVideoAuthorityWithCallBackViewController: (UIViewController *)vc;
+ (BOOL)judgeIsHaveCameraAuthority;
+ (BOOL)judgeIsHaveAudioAuthority;

@end


/*!
 *  视频对象 Model类
 */
@interface YLVideoModel : NSObject
/// 完整视频 本地路径
@property (nonatomic, copy) NSString *videoAbsolutePath;
/// 缩略图 路径
@property (nonatomic, copy) NSString *thumAbsolutePath;
// 录制时间
@property (nonatomic, strong) NSDate *recordTime;

// 点击拍摄的图片 (有 shootImage 就说明是点击拍摄的照片,而不是视频)
@property (nonatomic, strong) UIImage *shootImage;
// 上传视频时候需要获取的参数
@property (nonatomic, copy) NSString * qiniuUrl;
@property (nonatomic, assign) NSInteger videoWidth;
@property (nonatomic, assign) NSInteger videoHeight;
@property (nonatomic, assign) CGFloat videoDuration;

@end


