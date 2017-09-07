//
//  UIImage+Additions.h
//  YLShare
//
//  Created by wyl on 2017/9/7.
//  Copyright © 2017年 Future. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)
/**
 *  创建纯色的图片
 */
+(UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size;
/**
 *  将图片等比缩放到指定尺寸
 */
+(UIImage*)resizedImage:(UIImage*)image maxSize:(CGSize)maxSize;
/**
 *  将图片缩放到指定尺寸
 */
-(UIImage*)scaleToSize:(CGSize)size;

- (UIImage *)imageByScalingToMaxSize;


- (BOOL)saveImageToLocalPath:(NSString *)pathString;

- (CGSize)sizeImageThatFits:(CGSize)size;

- (UIImage *)fixOrientation:(UIImage *)aImage;

//截取图片 (目前针对于长图片)
- (UIImage *)clipImageInRect:(CGRect)rect;

@end
