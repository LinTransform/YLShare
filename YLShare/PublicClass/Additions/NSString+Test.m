//
//  NSString+Test.m
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "NSString+Test.h"
#import "NSString+Size.h"
#import <CommonCrypto/CommonDigest.h>
#import "GlobalFunction.h"

@implementation NSString (Test)
- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int) strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSArray *)seperateLabelButton
{
    NSMutableString * newString = [NSMutableString new];
    
    for (int i = 0; i < self.length; i++) {
        NSString * charcater = [self substringWithRange:NSMakeRange(i, 1)];
        
        if ([charcater isEqualToString:@","]) {
            charcater = @"，";
        }
        
        [newString appendString:charcater];
    }
    NSArray * array = [newString componentsSeparatedByString:@"，"];
    return array;
}

// 判断是否为邮箱
- (BOOL)isEmailNumber
{
    NSString * emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:self];
}

// 判断是否为手机号
- (BOOL)isTelephoneNumber
{
    NSString * regex = @"^1[34578]{1}[\\d]{9}";
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:self];
}


- (BOOL)heigherThanNumOfLines:(NSInteger) num StringWithWidth: (CGFloat)width andFont: (CGFloat) fontSize{
    NSMutableString * newStr = [[NSMutableString alloc ] init];
    [newStr appendString:@"1"];
    if (num >= 2) {
        for (int i = 0; i < num - 1; i++) {
            [newStr appendString:@"\n|"];
        }
    }
    
    CGSize size1 = [GlobalFunction getTextSizeWithOutLineSystemFont:[UIFont systemFontOfSize:fontSize] ConstrainedToSize:CGSizeMake(width, MAXFLOAT) string:newStr];
    
    CGSize size2 = [GlobalFunction getTextSizeWithOutLineSystemFont:[UIFont systemFontOfSize:fontSize] ConstrainedToSize:CGSizeMake(width, MAXFLOAT) string:self];
    
    if (size2.height > size1.height) {
        return YES;
    }
    
    return NO;
    
    
}


- (NSString *)insertStarIntoPhone
{
    NSMutableString * phoneStr = [NSMutableString stringWithString:self];
    
    if (phoneStr.length != 0) {
        [phoneStr replaceCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
    
    return phoneStr;
}

- (NSString *)insertStarIntoEmail
{
    NSMutableString * emailStr = [NSMutableString stringWithString:self];
    
    if (emailStr.length != 0) {
        for (int i = 2; i < emailStr.length; i++) {
            unichar c = [emailStr characterAtIndex:i];
            
            if (c == '@') {
                break;
            }
            
            c = '*';
            [emailStr replaceCharactersInRange:NSMakeRange(i, 1) withString:[NSString stringWithCharacters:&c length:1]];
        }
    }
    
    return emailStr;
}

// 编辑昵称
- (NSInteger)isLegalNickName
{
    int chineseCount = 0;
    int letterCount = 0;
    
    for (int i = 0; i < self.length; i++) {
        int a = [self characterAtIndex:i];
        
        if ((a >= 0x4e00) && (a < 0x9fff)) {
            chineseCount++;
        } else {
            letterCount++;
        }
    }
    
    return chineseCount * 2 + letterCount;
}

//判断字符串是否包含有连续空格
- (BOOL)isHaveContinuousSpace {
    
    NSRange spaceRange = NSMakeRange(0, 0);
    for (int i = 0; i < self.length; i++) {
        
        NSString * word = [self substringWithRange:NSMakeRange(i, 1)];
        if ([word isEqualToString:@" "]) {
            
            if (i == (spaceRange.location + 1 ) && (spaceRange.length != 0 )) {
                
                return YES;
                
            }else{
                spaceRange = NSMakeRange(i, 1);
            }
            
        }
    }
    
    return NO;
}

//判断字符串是否包含有连续回车
- (BOOL) isHaveContinuousEnter{
    
    NSRange enterRange = NSMakeRange(0, 0);
    for (int i = 0; i < self.length; i++) {
        
        NSString * word = [self substringWithRange:NSMakeRange(i, 1)];
        if ([word isEqualToString:@"\n"]) {
            
            if (i == (enterRange.location + 1 ) && (enterRange.length != 0 )) {
                
                return YES;
                
            }else{
                enterRange = NSMakeRange(i, 1);
            }
            
        }
    }
    
    return NO;
}

//判断首尾是否还有 空格 或者 换行
- (BOOL) isHaveSpaceOrEnterInLeaderOrTrail {
    
    if ([[self substringToIndex:1] isEqualToString:@" "] ||
        [[self substringFromIndex:self.length - 1] isEqualToString:@" "]||
        [[self substringToIndex:1] isEqualToString:@"\n"] ||
        [[self substringFromIndex:self.length - 1] isEqualToString:@"\n\n"]
        ) {
        return YES;
    }else{
        return NO;
    }
    
}

//判断中间有可能出现空格或者回车
- (BOOL) isHaveRepeatEnterOrSpace {
    
    if ([self isHaveContinuousSpace] || [self isHaveContinuousEnter]) {
        
        return YES;
        
    }else{
        
        return NO;
    }
    
}

/**
 *  去掉连续空格，连续回车，去掉首尾空格和回车
 */

- (NSString *)shortenString
{
    NSString *newString = [NSString stringWithString:self];
    
    while ([newString rangeOfString:@"\n \n"].length) {
        newString = [newString stringByReplacingOccurrencesOfString:@"\n \n" withString:@"\n"];
    }
    
    while ([newString isHaveRepeatEnterOrSpace]) {
        //1.处理回车
        while ([newString isHaveContinuousEnter]) {
            newString = [newString stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
        }
        
        //2.处理空格
        while ([newString isHaveContinuousSpace]) {
            newString = [newString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
        }
        
        while ([newString rangeOfString:@"\n \n"].length) {
            newString = [newString stringByReplacingOccurrencesOfString:@"\n \n" withString:@"\n"];
        }
        
        
    }
    while ([newString isHaveSpaceOrEnterInLeaderOrTrail]) {
        if ([[newString substringToIndex:1] isEqualToString:@"\n"]) {
            newString = [newString substringFromIndex:1];
        }
        if ([[newString substringFromIndex:newString.length - 1] isEqualToString:@"\n"]) {
            newString = [newString substringToIndex:newString.length - 1];
        }
        
        if ([[newString substringToIndex:1] isEqualToString:@" "]) {
            newString = [newString substringFromIndex:1];
        }
        if ([[newString substringFromIndex:newString.length - 1] isEqualToString:@" "]) {
            newString = [newString substringToIndex:newString.length - 1];
        }
    }
    
    return newString;
}

- (BOOL)isLegalTitleWithMinimum: (NSInteger) minLen andMaximum: (NSInteger) maxLen
{
    int chineseCount = 0;
    int letterCount = 0;
    
    for (int i = 0; i < self.length; i++) {
        int a = [self characterAtIndex:i];
        
        if ((a >= 0x4e00) && (a < 0x9fff)) {
            chineseCount++;
        } else {
            letterCount++;
        }
    }
    int count = chineseCount * 2 + letterCount;
    if (count < minLen * 2 || count > maxLen * 2) {
        return NO;
    }
    
    return YES;
}

- (NSInteger) getCharacterNumber {
    NSInteger chineseCount = 0;
    NSInteger letterCount = 0;
    
    for (int i = 0; i < self.length; i++) {
        int a = [self characterAtIndex:i];
        
        if ((a >= 0x4e00) && (a < 0x9fff)) {
            chineseCount++;
        } else {
            letterCount++;
        }
    }
    NSInteger count = chineseCount * 2 + letterCount;
    return count;
}

- (NSInteger) getBeyondIndexWithMaximum:(NSInteger) num {
    
    NSInteger index = 0;
    NSInteger numCount = 0;
    for (int i = 0; i < self.length; i++) {
        int a = [self characterAtIndex:i];
        
        if ((a >= 0x4e00) && (a < 0x9fff)) {
            numCount += 2;
        } else {
            numCount ++;
        }
        if (numCount > num * 2) {
            break;
        }
        index ++;
    }
    return index;
    
}


//对播放次数的处理
+ (NSString *) getLegalPlayCountStringWithString: (NSString *) string{
    
    
    NSInteger playCount = [string integerValue] / 10000;
    if (playCount >= 1) {
        string = [NSString stringWithFormat:@"%tu万",playCount];
    }
    return string;
}

//对 点赞数 评论数 的处理
+ (NSString *) getLegalPraiseOrCommentStringWithCount:(NSInteger) count{
    NSInteger legalCount = count / 10000;
    if (legalCount) {
        if (count % 10000) {
            return [NSString stringWithFormat:@"%tu万+",legalCount];
        }else{
            return [NSString stringWithFormat:@"%tu万",legalCount];
        }
    }else{
        return [NSString stringWithFormat:@"%tu",count];
    }
}

/*
 *第二种方法，利用Emoji表情最终会被编码成Unicode，因此，只要知道Emoji表情的Unicode编码的范围，
 *就可以判断用户是否输入了Emoji表情。
 */
- (BOOL)isContainsEmoji
{
    // 过滤所有表情。returnValue为NO表示不含有表情，YES表示含有表情
    __block BOOL returnValue = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        const unichar hs = [substring characterAtIndex:0];
        // surrogate pair
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    returnValue = YES;
                }
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3) {
                returnValue = YES;
            }
        } else {
            // non surrogate
            if (0x2100 <= hs && hs <= 0x27ff) {
                returnValue = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                returnValue = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                returnValue = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                returnValue = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                returnValue = YES;
            }
        }
    }];
    return returnValue;
}


- (NSString *)getTimeMonthStringWithYear:(BOOL)year
{
    NSAssert(self.length, @"时间不存在");
    NSString *oldString = self;
    if (![oldString containsString:@"-"]) {
        NSDate *nsDate = [NSDate dateWithTimeIntervalSince1970:[self doubleValue] / 1000];
        NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
        fmt.locale = [NSLocale systemLocale];
        fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        oldString = [fmt stringFromDate:nsDate ];
    }
    NSString *newString = [[oldString componentsSeparatedByString:@" "] firstObject];
    NSArray *timeArray = [newString componentsSeparatedByString:@"-"];
    if (year) {
        
        NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
        fmt.locale = [NSLocale systemLocale];
        fmt.dateFormat = @"yyyy";
        NSDate *today = [NSDate date];
        NSString *todayString = [fmt stringFromDate:today];
        
        if ([todayString integerValue] != [timeArray[0] integerValue]) {
            newString = [NSString stringWithFormat:@"%@年%@月%@日",timeArray[0],timeArray[1],timeArray[2]];
        }
        else {
            newString = [NSString stringWithFormat:@"%@月%@日",timeArray[1],timeArray[2]];
        }
    }
    else {
        newString = [NSString stringWithFormat:@"%@月%@日",timeArray[1],timeArray[2]];
    }
    
    return newString;
}

//- (UIFont *)getAvailableFontWithSize:(CGSize)size orginalFont:(CGFloat)font
//{
//    CGFloat newWidth = 0;
//    CGFloat newFont = font;
//    do {
//        newFont --;
//        newWidth = [GlobalFunction getTextSizeWithOutLineSystemFont:UIFontSystem(newFont) ConstrainedToSize:CGSizeMake(MAXFLOAT, size.height) string:self].width;
//    } while (newWidth > size.width);
//    return UIFontSystem(newFont);
//}

- (BOOL)isToday
{
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [NSLocale systemLocale];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *today = [NSDate date];
    NSString *todayString = [fmt stringFromDate:today];
    
    NSDate *nsDate = [NSDate dateWithTimeIntervalSince1970:[self doubleValue] / 1000];
    NSString* dateString = [fmt stringFromDate:nsDate ];
    
    NSString *day1 = [[dateString componentsSeparatedByString:@" "] firstObject];
    NSString *day2 = [[todayString componentsSeparatedByString:@" "] firstObject];
    
    if ([day1 isEqualToString:day2]) {
        return YES;
    }
    return NO;
    
}

- (NSString *)getTodayString
{
    NSDate *nsDate = [NSDate dateWithTimeIntervalSince1970:[self doubleValue] / 1000];
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [NSLocale systemLocale];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString* dateString = [fmt stringFromDate:nsDate ];
    
    dateString = [[dateString componentsSeparatedByString:@" "] lastObject];
    NSArray *timeArr = [dateString componentsSeparatedByString:@":"];
    dateString = [NSString stringWithFormat:@"今天 %@:%@",timeArr[0],timeArr[1]];
    return dateString;
}

// 获取相对时间
//1）1分钟以内显示“刚刚”，
//2）1小时内显示“XX分钟前”
//3）24小时以内显示“XX小时前”
//4）24小时之后显示年月日，如：2017-02-22
- (NSString *)getRelativeTimeWithYear:(BOOL)isContain{
    NSDate * nowDate = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[nowDate timeIntervalSince1970]];
    NSTimeInterval timeInterval = [timeSp doubleValue] - [self doubleValue] / 1000;
    long temp = 0;
    NSString * relativeTime;
    if (timeInterval<60) {
        relativeTime = [NSString stringWithFormat:@"刚刚"];
    }else if ((temp = timeInterval/60)<60){
        relativeTime = [NSString stringWithFormat:@"%ld分钟前",temp];
    }else if ((temp = timeInterval/(60*60))<24){
        relativeTime = [NSString stringWithFormat:@"%ld小时前",temp];
    }else{
        NSDate *nsDate = [NSDate dateWithTimeIntervalSince1970:[self doubleValue] / 1000];
        NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
        fmt.locale = [NSLocale systemLocale];
        if (isContain) {
            fmt.dateFormat = @"yyyy-MM-dd";
        }else{
            fmt.dateFormat = @"MM-dd";
        }
        relativeTime = [fmt stringFromDate:nsDate ];
    }
    return relativeTime;
}

//获取视频时长的显示
+ (NSString *) getLegalVideoDurationWithFloatTime: (CGFloat) timeDuration {
    
    NSString * minStr = nil;
    NSString * scoStr = nil;
    NSInteger minute = 0;
    NSInteger second = 0;
    NSInteger timeInt = (NSInteger)timeDuration;
    second = timeInt % 60;
    minute = timeInt / 60;
    //判断是一位数还是两位数
    if (minute / 10) {
        minStr = [NSString stringWithFormat:@"%ld",(long)minute];
    }else{
        minStr = [NSString stringWithFormat:@"0%ld",(long)minute];
    }
    
    if (second / 10) {
        scoStr = [NSString stringWithFormat:@"%ld",(long)second];
    }else{
        scoStr = [NSString stringWithFormat:@"0%ld",(long)second];
    }
    
    return [NSString stringWithFormat:@"%@:%@",minStr,scoStr];
}

// json 转 字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"HS json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
