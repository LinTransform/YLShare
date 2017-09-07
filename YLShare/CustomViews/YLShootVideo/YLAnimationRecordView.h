//
//  YLAnimationRecordView.h
//  YLShare
//
//  Created by wyl on 2017/7/3.
//  Copyright © 2017年 Future. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLAnimationRecordView : UIView
@property (nonatomic, copy) void(^startRecord)();
@property (nonatomic, copy) void(^completeRecord)(CFTimeInterval recordTime); //录制时长
@property (nonatomic, assign) CGFloat longPressMin;
@end
