//
//  YLShootPlayerView.h
//  YLShare
//
//  Created by wyl on 2017/7/7.
//  Copyright © 2017年 Future. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLShootPlayerView : UIView

- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl;

@property (nonatomic, strong, readonly) NSURL *videoUrl;

@property (nonatomic,assign) BOOL autoReplay; 

- (void)play;

- (void)stop;

@end
