//
//  UtilityMacro.h
//  YLShare
//
//  Created by wyl on 2017/9/6.
//  Copyright © 2017年 Future. All rights reserved.
//

#ifndef MmiaHD_UtilityMacro_h
#define MmiaHD_UtilityMacro_h
// app尺寸
#define Main_Screen_Height [[UIScreen mainScreen] bounds].size.height
#define Main_Screen_Width  [[UIScreen mainScreen] bounds].size.width
#define App_Frame_Height   [[UIScreen mainScreen] applicationFrame].size.height
#define App_Frame_Width    [[UIScreen mainScreen] applicationFrame].size.width

// 系统控件
#define kStatusBarHeight        (20.f)
#define kNavigationBarHeight    (44.f)

// 颜色
#define ColorWithRGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define ColorWithRGB(r,g,b) ColorWithRGBA(r,g,b,1)
#define ColorWithHexRGBA(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]
#define ColorWithHexRGB(rgbValue) ColorWithHexRGBA(rgbValue,1.0)
#define UIColorWhite [UIColor whiteColor]
#define UIColorClear [UIColor clearColor]

// 字体
#define UIFontSystem(x)     [UIFont systemFontOfSize:x]
#define UIFontBoldSystem(x) [UIFont boldSystemFontOfSize:x]

// 图片
#define UIImageNamed(x)     [UIImage imageNamed:x]
#define UIImageViewNamed(x) [[UIImageView alloc] initWithImage:UIImageNamed(x)]
#define UIImageViewImage(x) [[UIImageView alloc] initWithImage:x]

// 其他
#define BlockSelf(x)        __block typeof(self) x = self
#define WeakSelf(x)         __weak typeof(self) x = self
#define weakObj(x) autoreleasepool{} __weak typeof(x) weakSelf = x;
#define strongObj(x) autoreleasepool{} __strong typeof(x) strongSelf = weakSelf;


#endif
