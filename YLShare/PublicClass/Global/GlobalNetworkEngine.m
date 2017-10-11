//
//  GlobalNetworkEngine.m
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "GlobalNetworkEngine.h"

@implementation GlobalNetworkEngine

- (void)startPostAsyncRequestWithUrl:(NSString *)url param:(id)param completionHandler:(JsonObjectResponseBlock)handleDataBlock errorHandler:(ErrorBlock)errorBlock
{
    
    AFSecurityPolicy * securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    
    //AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    [self setSecurityPolicy:securityPolicy];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json", @"text/javascript", nil];
    
    NSMutableString * httpURL = [YLHostURL mutableCopy];
    [httpURL appendString:url];
    
    [self POST:httpURL parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        handleDataBlock(task,responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorBlock(task, error);
    }];
    
}

- (void)startGetAsyncRequestWithUrl:(NSString *)url param:(id)param completionHandler:(JsonObjectResponseBlock)handleDataBlock errorHandler:(ErrorBlock)errorBlock
{
    AFSecurityPolicy * securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json", @"text/javascript", nil];
    
    [manager setSecurityPolicy:securityPolicy];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary * _param = [[NSMutableDictionary alloc] init];
    if (param) {
        if ([param isKindOfClass:[NSDictionary class]]) {
            [_param addEntriesFromDictionary:param];
        }
    }
    
    NSMutableString * httpURL = [YLHostURL mutableCopy];
    [httpURL appendString:url];
    
    [manager GET:httpURL parameters:_param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        handleDataBlock(task, dict);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorBlock(task, error);
    }];
}




- (void)cancelRequest
{
    [self.operationQueue cancelAllOperations];
    
    [self invalidateSessionCancelingTasks:YES];
}


@end
