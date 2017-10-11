//
//  GlobalFunction.m
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "GlobalFunction.h"

@implementation GlobalFunction
void YLLog(NSString * log, ...)
{
#if DEBUG
    va_list args;
    va_start(args, log);
    
    NSLogv(log, args);
    
    va_end(args);
#else
#endif
}


+ (CGSize)getTextSizeWithSystemFont:(UIFont *)font ConstrainedToSize:(CGSize)size string:(NSString *)labelString lineSpace:(CGFloat)lineSpace
{
    CGSize fitSize = CGSizeMake(0, 0);
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [paragraphStyle setLineSpacing:lineSpace];
    NSDictionary * attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    if (labelString.length > 0) {
        fitSize = [labelString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
    }
    
    return fitSize;
}

//不带行间距的
+ (CGSize)getTextSizeWithOutLineSystemFont:(UIFont *)font ConstrainedToSize:(CGSize)size string:(NSString *)labelString
{
    CGSize fitSize = CGSizeMake(0, 0);
    
    if (labelString.length > 0) {
        fitSize = [labelString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    }
    
    return fitSize;
}

@end
