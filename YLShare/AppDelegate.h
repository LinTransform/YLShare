//
//  AppDelegate.h
//  YLShare
//
//  Created by Future on 2017/9/4.
//  Copyright © 2017年 Future. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic)  YLTabBarController * tabBarViewController;

+ (AppDelegate *)sharedAppDelegate;

@end

