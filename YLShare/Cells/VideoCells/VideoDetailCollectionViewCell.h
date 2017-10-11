//
//  VideoDetailCollectionViewCell.h
//  YLShare
//
//  Created by wyl on 2017/6/23.
//  Copyright © 2017年 Future. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoItemModel.h"

@class VideoDetailCollectionViewCell;
@protocol VideoDetailCollectionViewCellDelegate <NSObject>

- (void) videoDetailCollectionViewCellPlayButtonClickWithCell:(VideoDetailCollectionViewCell *)cell;

@end

@interface VideoDetailCollectionViewCell : UICollectionViewCell

@property (nonatomic , strong) NSIndexPath * indexPath;
@property (weak, nonatomic) IBOutlet UIView *videoContainerView;
@property (nonatomic , weak) id<VideoDetailCollectionViewCellDelegate> delegate;
@property (nonatomic , strong) VideoItemModel * model;


@end
