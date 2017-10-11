//
//  YLBaseData.h
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalNetworkEngine.h"
typedef void (^HttpCompliteBlock) (id data,NSString *maxtime,NSError *error,BOOL success);

@interface YLBaseData : NSObject

@property (nonatomic, strong) GlobalNetworkEngine *netEngine;
- (void)cancelRequest;

@end
