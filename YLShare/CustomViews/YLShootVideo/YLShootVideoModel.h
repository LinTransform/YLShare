//
//  YLShootVideoModel.h
//  YLShare
//
//  Created by wyl on 2017/7/3.
//  Copyright © 2017年 Future. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YLShootVideoModel : NSObject
/// 完整视频 本地路径
@property (nonatomic, copy) NSString *videoAbsolutePath;
/// 缩略图 路径
@property (nonatomic, copy) NSString *thumAbsolutePath;
// 录制时间
@property (nonatomic, strong) NSDate *recordTime;

@end
