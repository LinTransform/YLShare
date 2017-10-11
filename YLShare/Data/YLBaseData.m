//
//  YLBaseData.m
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "YLBaseData.h"


@implementation YLBaseData
- (void)cancelRequest
{
    [self.netEngine cancelRequest];
}


- (GlobalNetworkEngine *)netEngine
{
    if (!_netEngine) {
        _netEngine = [[GlobalNetworkEngine alloc]init];
    }
    return _netEngine;
}

@end
