//
//  NSString+Size.h
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Size)
- (CGSize)getTextSizeWithSystemFont:(UIFont *)font ConstrainedToSize:(CGSize)size  lineSpace:(CGFloat)lineSpace;

- (CGSize)getTextSizeWithOutLineSystemFont:(UIFont *)font ConstrainedToSize:(CGSize)size;

@end
