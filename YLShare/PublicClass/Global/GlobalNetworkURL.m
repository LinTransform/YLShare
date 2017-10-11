//
//  GlobalNetworkURL.m
//  YLShare
//
//  Created by wyl on 2017/9/25.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "GlobalNetworkURL.h"


#ifdef DEBUG
NSString * const YLHostURL = @"http://api.budejie.com/";
#else
NSString * const YLHostURL = @"http://api.budejie.com/";
#endif

NSString * const YLVideoListRequestURL = @"api/api_open.php";

@implementation GlobalNetworkURL

@end
