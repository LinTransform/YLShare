//
//  GlobalNetworkEngine.h
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef void (^  JsonObjectResponseBlock)(NSURLSessionDataTask *operation, NSDictionary * responseDict);
typedef void (^  ErrorBlock)(NSURLSessionDataTask * operation, NSError * error);


@interface GlobalNetworkEngine : AFHTTPSessionManager

// 发起post类型网络请求公共入口
- (void)startPostAsyncRequestWithUrl:(NSString *)url param:(id)param completionHandler:(JsonObjectResponseBlock)handleDataBlock errorHandler:(ErrorBlock)errorBlock;

// 发起get类型网络请求公共入口
- (void)startGetAsyncRequestWithUrl:(NSString *)url param:(id)param completionHandler:(JsonObjectResponseBlock)handleDataBlock errorHandler:(ErrorBlock)errorBlock;

- (void)cancelRequest;

@end
