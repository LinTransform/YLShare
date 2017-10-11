//
//  YLVideoData.m
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "YLVideoData.h"
#import "VideoItemModel.h"

@implementation YLVideoData

- (void)ylGetVideoListWithParameters: (VideoListRequestModel *)requestModel httpBlock:(HttpCompliteBlock)httpBlock {
    
    @weakObj(self);
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"a"] = @"list";
    parameters[@"c"] = @"data";
    parameters[@"type"] = @(41);
    parameters[@"page"] = @(requestModel.page);
    if (requestModel.maxtime) {
        parameters[@"maxtime"] = requestModel.maxtime;
    }

    [self.netEngine startGetAsyncRequestWithUrl:YLVideoListRequestURL param:parameters completionHandler:^(NSURLSessionDataTask *operation, NSDictionary *responseDict) {
        if (![responseDict[@"status"] integerValue]) {
            NSArray *array = [VideoItemModel mj_objectArrayWithKeyValuesArray:responseDict[@"list"]];
            NSString *maxTime = responseDict[@"info"][@"maxtime"];
            for (VideoItemModel *video in array) {
                video.maxtime = maxTime;
            }
            httpBlock(array,maxTime,nil,YES);
        }
        else {
            requestModel.recentTime = nil;
            requestModel.remoteTime = nil;
            httpBlock(nil,@"",nil,NO);
        }
    } errorHandler:^(NSURLSessionDataTask *operation, NSError *error) {
        httpBlock(nil,@"",error,NO);
    }];

}

@end
