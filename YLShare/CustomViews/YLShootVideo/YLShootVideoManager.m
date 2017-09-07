//
//  YLShootVideoManager.m
//  yl-videoRecord
//
//  Created by wyl on 2017/5/24.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import "YLShootVideoManager.h"
#import <AVFoundation/AVFoundation.h>

@interface YLShootVideoManager ()

@property (nonatomic , strong) UIViewController * shootVC;
@property (nonatomic , copy ) void (^callback)() ;

@end

@implementation YLVideoModel

+ (instancetype)modelWithPath:(NSString *)videoPath thumPath:(NSString *)thumPath recordTime:(NSDate *)recordTime {
    YLVideoModel *model = [[YLVideoModel alloc] init];
    model.videoAbsolutePath = videoPath;
    model.thumAbsolutePath = thumPath;
    model.recordTime = recordTime;
    return model;
}

@end

@implementation YLShootVideoManager

+ (YLShootVideoManager *)shareManager
{
    static YLShootVideoManager * shareManager = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        shareManager = [[YLShootVideoManager alloc]init];
    });
    return shareManager;
}


+ (BOOL)existVideo {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *nameList = [fileManager subpathsAtPath:[self getVideoPath]];
    return nameList.count > 0;
}


+ (NSMutableArray *)getVideoList {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *modelList = [NSMutableArray array];
    NSArray *nameList = [fileManager subpathsAtPath:[self getVideoPath]];
    for (NSString *name in nameList) {
        if ([name hasSuffix:@".JPG"]) {
            YLVideoModel *model = [[YLVideoModel alloc] init];
            NSString *thumAbsolutePath = [[self getVideoPath] stringByAppendingPathComponent:name];
            model.thumAbsolutePath = thumAbsolutePath;
            
            NSString *totalVideoPath = [thumAbsolutePath stringByReplacingOccurrencesOfString:@"JPG" withString:@"MOV"];
            if ([fileManager fileExistsAtPath:totalVideoPath]) {
                model.videoAbsolutePath = totalVideoPath;
            }
            NSString *timeString = [name substringToIndex:(name.length-4)];
            NSDateFormatter *dateformate = [[NSDateFormatter alloc]init];
            dateformate.dateFormat = @"yyyy-MM-dd_HH:mm:ss";
            NSDate *date = [dateformate dateFromString:timeString];
            model.recordTime = date;
            
            [modelList addObject:model];
        }
    }
    return modelList;
}

+ (NSArray *)getSortVideoList {
    NSArray *oldList = [self getVideoList];
    NSArray *sortList = [oldList sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        YLVideoModel *model1 = obj1;
        YLVideoModel *model2 = obj2;
        NSComparisonResult compare = [model1.recordTime compare:model2.recordTime];
        switch (compare) {
            case NSOrderedDescending:
                return NSOrderedAscending;
            case NSOrderedAscending:
                return NSOrderedDescending;
            default:
                return compare;
        }
    }];
    return sortList;
}

+ (void)saveThumImageWithVideoURL:(NSURL *)videoUrl second:(int64_t)second {
    AVURLAsset *urlSet = [AVURLAsset assetWithURL:videoUrl];
    NSLog(@"拍摄完的视频%@",urlSet);
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlSet];
    
    CMTime time = CMTimeMake(second, 10);
    NSError *error = nil;
    CGImageRef cgimage = [imageGenerator copyCGImageAtTime:time actualTime:nil error:&error];
    if (error) {
        NSLog(@"缩略图获取失败!:%@",error);
        return;
    }
    UIImage *image = [UIImage imageWithCGImage:cgimage scale:0.6 orientation:UIImageOrientationRight];
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
    NSString *videoPath = [videoUrl.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString: @""];
    NSString *thumPath = [videoPath stringByReplacingOccurrencesOfString:@"MOV" withString: @"JPG"];
    BOOL isok = [imgData writeToFile:thumPath atomically: YES];
    NSLog(@"缩略图获取结果:%d",isok);
    CGImageRelease(cgimage);
}

+ (YLVideoModel *)createNewVideo {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    formate.dateFormat = @"yyyy-MM-dd_HH:mm:ss";
    NSString *videoName = [formate stringFromDate:currentDate];
    NSString *videoPath = [self getVideoPath];
    
    YLVideoModel *model = [[YLVideoModel alloc] init];
    model.videoAbsolutePath = [videoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.MOV",videoName]];
    model.thumAbsolutePath = [videoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.JPG",videoName]];
    model.recordTime = currentDate;
    return model;
}

+ (void)deleteVideo:(NSString *)videoPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    [fileManager removeItemAtPath:videoPath error:&error];
    if (error) {
        NSLog(@"删除视频失败:%@",error);
    }
    NSString *thumPath = [videoPath stringByReplacingOccurrencesOfString:@"MOV" withString:@"JPG"];
    NSError *error2 = nil;
    [fileManager removeItemAtPath:thumPath error:&error2];
    if (error2) {
        NSLog(@"删除缩略图失败:%@",error);
    }
}

+ (NSString *)getVideoPath {
    return [self getDocumentSubPath:YLVideoDicName];
}

+ (NSString *)getDocumentSubPath:(NSString *)dirName {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject];
    return [documentPath stringByAppendingPathComponent:dirName];
}

+ (void)initialize {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dirPath = [self getVideoPath];
    
    NSError *error = nil;
    [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"创建文件夹失败:%@",error);
    }
}

- (BOOL)judgeIsHaveShootVideoAuthorityWithCallBackViewController: (UIViewController *)vc {
    self.shootVC = vc;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请在“设置-隐私-相机”中，更改 新热点 访问您的相机和麦克风权限" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        alert.delegate = self;
        [alert show];
        return NO;
    }else{
        AVAuthorizationStatus audioAutYLtatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if(audioAutYLtatus == AVAuthorizationStatusRestricted || audioAutYLtatus == AVAuthorizationStatusDenied){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请在“设置-隐私-相机”中，更改 新热点 访问您的相机和麦克风权限" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            alert.delegate = self;
            [alert show];
            return NO;
        }else{
            self.shootVC = nil;
            return YES;
        }
    }

}

+ (BOOL)judgeIsHaveCameraAuthority
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请在“设置-隐私-相机”中，更改 新热点 访问您的相机和麦克风权限" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        alert.delegate = self;
        [alert show];
        return NO;
    }
    return YES;
}

+ (BOOL)judgeIsHaveAudioAuthority{
    AVAuthorizationStatus audioAutYLtatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(audioAutYLtatus == AVAuthorizationStatusRestricted || audioAutYLtatus == AVAuthorizationStatusDenied){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请在“设置-隐私-相机”中，更改 新热点 访问您的相机和麦克风权限" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        alert.delegate = self;
        [alert show];
        return NO;

    }
    return YES;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (self.shootVC && buttonIndex == 0) {
        [self.shootVC dismissViewControllerAnimated:YES completion:nil];
        self.shootVC = nil;
    }
}

@end



