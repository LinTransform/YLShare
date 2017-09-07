//
//  YLShootVideoViewController.h
//  yl-videoRecord
//
//  Created by wyl on 2017/5/23.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLShootVideoManager.h"
@class YLShootVideoViewController;

@protocol YLShootVideoViewControllerDelegate <NSObject>
@required
- (void)videoViewController:(YLShootVideoViewController *)videoController didRecordVideo:(YLVideoModel *)videoModel;

@optional
- (void)videoViewControllerDidCancel:(YLShootVideoViewController *)videoController;

@end


@interface YLShootVideoViewController : UIViewController

@property (nonatomic, weak) id<YLShootVideoViewControllerDelegate> delegate;

@end




