//
//  YLVideoData.h
//  YLShare
//
//  Created by wyl on 2017/10/10.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "YLBaseData.h"
#import "VideoListRequestModel.h"

@interface YLVideoData : YLBaseData

- (void)ylGetVideoListWithParameters: (VideoListRequestModel *)requestModel httpBlock:(HttpCompliteBlock)httpBlock;

@end
