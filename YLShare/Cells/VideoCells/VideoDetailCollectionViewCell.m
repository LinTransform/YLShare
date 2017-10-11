//
//  VideoDetailCollectionViewCell.m
//  YLShare
//
//  Created by wyl on 2017/6/23.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "VideoDetailCollectionViewCell.h"
#import "NSString+Test.h"


@interface VideoDetailCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *backImg;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *playCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentBtnTrailConstraints;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIView *coverView;

@end

@implementation VideoDetailCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.titleLabel.textColor = ColorWithHexRGB(0xffffff);
//    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.playCountLabel.textColor = ColorWithHexRGB(0xa5a3ae);
    self.playCountLabel.font = [UIFont systemFontOfSize:14];
    self.commentLabel.textColor = ColorWithHexRGB(0xa5a3ae);

    self.timeLabel.textColor = ColorWithHexRGB(0xffffff);
    self.timeLabel.backgroundColor = ColorWithHexRGBA(0x000000, 0.5);
    self.timeLabel.layer.cornerRadius = 10;
    self.timeLabel.layer.masksToBounds = YES;
    [self.playBtn addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.backImg.contentMode = UIViewContentModeScaleAspectFit;
    self.backImg.clipsToBounds = YES;
    self.backImg.backgroundColor = [UIColor blackColor];
    self.coverView.backgroundColor = ColorWithHexRGBA(0x000000, 0.2);
}




- (void) playButtonClick {
    if ([self.delegate respondsToSelector:@selector(videoDetailCollectionViewCellPlayButtonClickWithCell:)]) {
        [self.delegate videoDetailCollectionViewCellPlayButtonClickWithCell:self];
    }
}

- (void)setModel:(VideoItemModel *)model{
    _model = model;
    self.titleLabel.text = model.screen_name;
    self.playCountLabel.text = [NSString stringWithFormat:@"%@次播放",[NSString getLegalPlayCountStringWithString:[NSString stringWithFormat:@"%ld",(long)[model.playcount integerValue]]]];
    self.timeLabel.text = [NSString getLegalVideoDurationWithFloatTime:[model.videotime integerValue]];
    self.commentLabel.text = [NSString stringWithFormat:@" %ld",(long)[model.comment integerValue]];
    [self.backImg sd_setImageWithURL:[NSURL URLWithString:model.image1] placeholderImage:[UIImage imageNamed:@"defaultPlaceholderImg"]];
}


@end
