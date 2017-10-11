//
//  UIScrollView+YLTopHud.m
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "UIScrollView+YLTopHud.h"
#define TAG_HUD 9999
@implementation UIScrollView (YLTopHud)
- (void)showRefreshHUDWithString:(NSString *)string
{
    UIView *view = [self.superview viewWithTag:TAG_HUD];
    if (!view) {
        CGFloat height = 32;
        UILabel *hudView = [[UILabel alloc]initWithFrame:CGRectMake(0, self.top-height, Main_Screen_Width, height)];
        hudView.backgroundColor = ColorWithHexRGB(Color_Red);
        hudView.text = string;
        hudView.textColor = UIColorWhite;
        hudView.font = UIFontSystem(14);
        hudView.tag = TAG_HUD;
        hudView.textAlignment = NSTextAlignmentCenter;
        [self.superview addSubview:hudView];
        [self.superview insertSubview:hudView belowSubview:self];
        
        CGPoint original = self.frame.origin;
        @weakObj(self);
        [UIView animateWithDuration:0.3 animations:^{
            @strongObj(self);
            hudView.top += height;
            strongSelf.top += height;
        } completion:^(BOOL finished) {
            [UIView  animateWithDuration:0.3 delay:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
                @strongObj(self);
                hudView.top -= height;
                strongSelf.top = original.x;
            } completion:^(BOOL finished) {
                [hudView removeFromSuperview];
            }];
            
        }];
    }
}

- (void)hideScrollRefreshHUD
{
    UIView *view = [self.superview viewWithTag:TAG_HUD];
    if (view) {
        [view removeFromSuperview];
        self.top -= 32;
        
    }
    
}

@end
