//
//  NSString+Test.h
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Test)

- (NSString *)md5;

- (NSArray *)seperateLabelButton;

- (BOOL)isEmailNumber;

- (BOOL)isTelephoneNumber;

- (BOOL)heigherThanNumOfLines:(NSInteger) num StringWithWidth: (CGFloat)width andFont: (CGFloat) fontSize;
// 给手机插入*号
- (NSString *)insertStarIntoPhone;
// 给邮箱插入*号
- (NSString *)insertStarIntoEmail;

- (NSInteger)isLegalNickName;

- (NSString *)shortenString;

- (BOOL)isLegalTitleWithMinimum: (NSInteger) minLen andMaximum: (NSInteger) maxLen;
- (NSInteger) getCharacterNumber;
- (NSInteger) getBeyondIndexWithMaximum:(NSInteger) num;

//对播放次数的处理
+ (NSString *) getLegalPlayCountStringWithString: (NSString *) string ;
//对 点赞数 评论数 的处理
+ (NSString *) getLegalPraiseOrCommentStringWithCount:(NSInteger) count;

- (BOOL)isContainsEmoji;

// 得到 月日 时间串
- (NSString *)getTimeMonthStringWithYear:(BOOL)year;

- (UIFont *)getAvailableFontWithSize:(CGSize)size orginalFont:(CGFloat)font;

- (BOOL)isToday;
- (NSString *)getTodayString;

// 获取相对时间
//1）1分钟以内显示“刚刚”，
//2）1小时内显示“XX分钟前”
//3）24小时以内显示“XX小时前”
//4）24小时之后显示年月日，如：2017-02-22
- (NSString *)getRelativeTimeWithYear:(BOOL)isContain;

//获取视频时长的显示
+ (NSString *) getLegalVideoDurationWithFloatTime: (CGFloat) timeDuration;

// json 转 字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;


@end
