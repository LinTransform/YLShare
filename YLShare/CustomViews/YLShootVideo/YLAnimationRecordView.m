//
//  YLAnimationRecordView.m
//  YLShare
//
//  Created by wyl on 2017/7/3.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "YLAnimationRecordView.h"
#import "GlobalDef.h"
#import "YLShootVideoManager.h"

#define kCircleLineWidth 7.
//开启录像各方面的误差兼容 0.1 秒

#define kTopNorWidth  54.5
#define kTopPressWidth  45
#define kBottomNorWidth 80
#define kBottomPressWidth 115

@interface YLAnimationRecordView ()<CAAnimationDelegate>

@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UIImageView *bottomImageView;
@property (nonatomic, strong) MASConstraint *bottomWidthConstraint;
@property (nonatomic, strong) MASConstraint *bottomHeightConstraint;
@property (nonatomic, strong) MASConstraint *topWidthConstraint;
@property (nonatomic, strong) MASConstraint *topHeightConstraint;

@property (nonatomic, assign) CFTimeInterval startTime;

@property (nonatomic, strong) CAShapeLayer *arcLayer;

@property (nonatomic , strong) UILongPressGestureRecognizer *longpress;


@end

@implementation YLAnimationRecordView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self makeUI];
    }
    return self;
}

- (void)makeUI
{
    [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        self.bottomWidthConstraint = make.width.equalTo(@kBottomNorWidth);
        self.bottomHeightConstraint = make.height.equalTo(@kBottomNorWidth);
        make.center.equalTo(self);
    }];
    
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        self.topWidthConstraint = make.width.equalTo(@kTopNorWidth);
        self.topHeightConstraint = make.height.equalTo(@kTopNorWidth);
        make.center.equalTo(self);
    }];
    
    
    self.longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self addGestureRecognizer:self.longpress];
}

- (void)addCircleLayer
{
    UIBezierPath *path=[UIBezierPath bezierPath];
    CGRect rect = CGRectMake(0, 0, kBottomPressWidth, kBottomPressWidth);
    [path addArcWithCenter:CGPointMake(kBottomPressWidth * 0.5, kBottomPressWidth * 0.5) radius:((rect.size.height - kCircleLineWidth)/2.) startAngle:-M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
    if (self.arcLayer) {
        [self.arcLayer removeAnimationForKey:@"CircleAnimantion"];
        [self.arcLayer removeFromSuperlayer];
        self.arcLayer = nil;
    }
    self.arcLayer = [CAShapeLayer layer];
    self.arcLayer.path = path.CGPath;
    self.arcLayer.fillColor = [UIColor clearColor].CGColor;
    self.arcLayer.strokeColor = ColorWithHexRGB(0xb91223).CGColor;
    self.arcLayer.lineWidth = kCircleLineWidth;
    self.arcLayer.frame = rect;
    [self.bottomImageView.layer addSublayer:self.arcLayer];
    [self drawLineAnimation];
}
//定义动画过程
-(void)drawLineAnimation
{
    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    bas.duration = YLRecordTime;
    bas.delegate=self;
    bas.fromValue=[NSNumber numberWithInteger:0];
    bas.toValue=[NSNumber numberWithInteger:1];
    [self.arcLayer addAnimation:bas forKey:@"CircleAnimantion"];
}

- (void)handleGesture:(UIGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"longpress began");
            [self startAnimation];
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"longpress end");
            [self endAnimation];
            break;
        case UIGestureRecognizerStateCancelled:
            NSLog(@"longpress cancel");
            break;
            
        default:
            break;
    }
}

- (void)startAnimation
{
    self.bottomWidthConstraint.equalTo(@kBottomPressWidth);
    self.bottomHeightConstraint.equalTo(@kBottomPressWidth);
    self.topWidthConstraint.equalTo(@kTopPressWidth);
    self.topHeightConstraint.equalTo(@kTopPressWidth);
    [UIView animateWithDuration:0.2 animations:^{
        //        self.readyImageView.alpha = 0.;
        //        self.startImageView.alpha = 1.0;
        [self layoutIfNeeded];
    }completion:^(BOOL finished) {
        [self addCircleLayer];
    }];
}

- (void)endAnimation
{
    self.bottomWidthConstraint.equalTo(@kBottomNorWidth);
    self.bottomHeightConstraint.equalTo(@kBottomNorWidth);
    self.topWidthConstraint.equalTo(@kTopNorWidth);
    self.topHeightConstraint.equalTo(@kTopNorWidth);
    [self.arcLayer removeAnimationForKey:@"CircleAnimantion"];
    [self.arcLayer removeFromSuperlayer];
    [UIView animateWithDuration:0.2 animations:^{
        //        self.readyImageView.alpha = 1.;
        //        self.startImageView.alpha = 0.;
        [self layoutIfNeeded];
    }completion:^(BOOL finished) {
        [self.arcLayer removeAnimationForKey:@"CircleAnimantion"];
        [self.arcLayer removeFromSuperlayer];
        self.arcLayer = nil;
    }];
}

//MARK: CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim
{
    self.startTime = CACurrentMediaTime();
    
    if (self.startRecord) {
        self.startRecord();
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CFTimeInterval didStopTime = CACurrentMediaTime() - self.startTime;
    [self endAnimation];
    NSLog(@"start %f end %f CFTimeInterval %f",self.startTime,CACurrentMediaTime(),didStopTime);
    if (self.completeRecord) {
        self.completeRecord(didStopTime);
    }
}


- (void)setLongPressMin:(CGFloat)longPressMin {
    _longPressMin = longPressMin;
    self.longpress.minimumPressDuration = _longPressMin;
}

- (UIImageView *)topImageView
{
    if(!_topImageView){
        _topImageView = [[UIImageView alloc] init];
        _topImageView.image = YLImageNamed(@"record_shootTop");
        _topImageView.userInteractionEnabled = YES;
        [self addSubview:_topImageView];
    }
    return _topImageView;
}

- (UIImageView *)bottomImageView
{
    if(!_bottomImageView){
        _bottomImageView = [[UIImageView alloc] init];
        _bottomImageView.image = YLImageNamed(@"record_shootBottom");
        _bottomImageView.userInteractionEnabled = YES;
        [self addSubview:_bottomImageView];
    }
    return _bottomImageView;
}

@end
