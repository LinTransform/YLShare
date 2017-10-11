//
//  GlobalFunction.h
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalFunction : NSObject
void YLLog(NSString * log, ...);


/**
 *  计算自适应label的高度
 * font:字体大小  size:将要放到的size，宽/高为MAXFloat labelString:label.text
 */
+ (CGSize)getTextSizeWithSystemFont:(UIFont *)font ConstrainedToSize:(CGSize)size string:(NSString *)labelString lineSpace:(CGFloat)lineSpace;
//不带行间距
+ (CGSize)getTextSizeWithOutLineSystemFont:(UIFont *)font ConstrainedToSize:(CGSize)size string:(NSString *)labelString;

@end
