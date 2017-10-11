//
//  YLVideoViewController.m
//  YLShare
//
//  Created by wyl on 2017/9/7.
//  Copyright © 2017年 Future. All rights reserved.
//

#import "YLVideoViewController.h"
#import "VideoDetailCollectionViewCell.h"
#import "YLVideoDetailViewController.h"
#import "YLVideoPlayerView.h"
#import "YLVideoData.h"
#import "UIScrollView+YLTopHud.h"
#import "NSString+Test.h"
#import "YLNavigationController.h"
#import "VideoListRequestModel.h"
#import "VideoItemModel.h"

#define CellRatio (266.0 / 375)
#define CellMargin 7.5
static NSString * VideoListCollectionViewCellKey = @"videoDetailCollectionViewCellKey";

@interface YLVideoViewController ()<VideoDetailCollectionViewCellDelegate,YLVideoPlayerViewDelegate>


@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NSString *maxtime;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic , strong) YLVideoPlayerView * videoPlayView;
@property (nonatomic , strong) VideoDetailCollectionViewCell * currentSelectedCell;
@property (nonatomic , strong) NSIndexPath * playerIndexPath;
@property (nonatomic, strong) YLVideoData *listData;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) UIButton *searchButton;

@end

@implementation YLVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"视频";
    self.currentPage = 0;
    self.listData = [[YLVideoData alloc]init];
    self.listArray = [[NSMutableArray alloc] init];
    [self initNav];
    [self configCollectionView];
    [self setupMJRefresh];
    
}

- (void)dealloc
{
    self.collectionView.delegate = nil;
    NSLog(@"HSVideoViewController dealloc");
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[AppDelegate sharedAppDelegate].tabBarViewController hideOrNotTabBar:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self destoryVideoPlayer];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void) configCollectionView {
    CHTCollectionViewWaterfallLayout * layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumColumnSpacing = CellMargin;
    layout.minimumInteritemSpacing = CellMargin;
    layout.columnCount = 1;
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerNib:[UINib nibWithNibName:@"VideoDetailCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:VideoListCollectionViewCellKey];
    self.collectionView.frame = CGRectMake(0, 64, Main_Screen_Width, Main_Screen_Height - 64 - kTabbarHeight);
    
    MJRefreshNormalHeader *header = (MJRefreshNormalHeader *)self.collectionView.mj_header;
    [header setTitle:@"正在刷新..." forState:MJRefreshStateRefreshing];
}

- (void)tryAgain:(UIButton *)button {
    [self requestMoreListDataIsRefresh:YES];
}

#pragma mark - data methods

- (void) setupMJRefresh {
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.collectionView.mj_header.automaticallyChangeAlpha = YES;
    [self.collectionView.mj_header beginRefreshing];
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];

}

// 刷新数据处理
- (void)loadNewData{
    [self requestMoreListDataIsRefresh:YES];
}

- (void)loadMoreData{
    [self requestMoreListDataIsRefresh:NO];
}

- (void)requestMoreListDataIsRefresh: (BOOL) isRefresh{
    VideoListRequestModel *parammeters = [[VideoListRequestModel alloc] init];
    if (isRefresh) {
        VideoItemModel *firstVideo = self.listArray.firstObject;
        parammeters.recentTime = firstVideo.created_at;
        parammeters.page = 0;
        parammeters.maxtime = nil;
    }else{
        VideoItemModel *lastVideo = self.listArray.lastObject;
        self.currentPage ++;
        parammeters.page = self.currentPage;
        parammeters.remoteTime = lastVideo.created_at;
        parammeters.maxtime = self.maxtime;
    }
    
    @weakObj(self);
    [self.listData ylGetVideoListWithParameters:parammeters httpBlock:^(id data, NSString *maxtime, NSError *error, BOOL success) {
        @strongObj(self);
        if (success) {
            if (isRefresh) {
                [strongSelf.listArray removeAllObjects];
            }
            [strongSelf.listArray addObjectsFromArray:(NSArray *)data];
            strongSelf.maxtime = maxtime;
            [strongSelf.collectionView reloadData];
            [strongSelf.collectionView.mj_header endRefreshing];
            [strongSelf.collectionView.mj_footer endRefreshing];
        }else{
            strongSelf.currentPage = self.currentPage-1;
            [strongSelf netWorkError:error andMessage:nil];
        }
    }];
}

#pragma mark - view related methods
- (void)searchClicked:(UIButton *)btn
{
}



#pragma mark - HSVideoPlayerViewDelegate

#pragma mark - VideoDetailCollectionViewCellDelegate
- (void) videoDetailCollectionViewCellPlayButtonClickWithCell:(VideoDetailCollectionViewCell *)cell{
    [self.videoPlayView resetPlayView];
    if (!self.videoPlayView) {
        self.videoPlayView = [[YLVideoPlayerView alloc] initPlayerViewWithContainerView:cell.videoContainerView scrollView:self.collectionView  delegate:self];
    }else{
        [self.videoPlayView convertPlayerViewToContainerView:cell.videoContainerView scrollView:self.collectionView delegate:self];
    }
    self.videoPlayView.videoTitle = cell.model.text;
    self.videoPlayView.videoPlayCount = [cell.model.playcount integerValue];
    self.currentSelectedCell = cell;
    self.playerIndexPath = cell.indexPath;
    
    self.videoPlayView.videoUrl = cell.model.videouri;
    [self.videoPlayView play];
    
    
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat itemH = self.view.bounds.size.width * CellRatio + CellMargin;
    CGFloat playerCellBottom = (self.playerIndexPath.row + 1) * (itemH) - CellMargin - CellMargin;
    CGFloat playerCellTop = self.playerIndexPath.row * (itemH) - CellMargin;
    if (self.collectionView.contentOffset.y >= playerCellBottom ||
        self.collectionView.contentOffset.y <= playerCellTop - self.collectionView.height ) {
        [self destoryVideoPlayer];
    }
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listArray.count;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    VideoItemModel * model = self.listArray[indexPath.row];
    VideoDetailCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:VideoListCollectionViewCellKey forIndexPath:indexPath];
    cell.delegate = self;
    cell.model = model;
    cell.indexPath = indexPath;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoItemModel * model = self.listArray[indexPath.row];
    YLVideoDetailViewController * detailVC = [[YLVideoDetailViewController alloc] init];
    
    VideoDetailCollectionViewCell * cell = (VideoDetailCollectionViewCell * )[collectionView cellForItemAtIndexPath:indexPath];
    if (([self.currentSelectedCell isEqual: cell]) &&
        self.videoPlayView) {
        detailVC.videoPlayView = self.videoPlayView;
        [self.videoPlayView removeFromSuperview];
        self.videoPlayView.delegate = nil;
        self.videoPlayView = nil;
    }else{
        detailVC.videoUrl = model.videouri;
    }
    
    [self destoryVideoPlayer];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.bounds.size.width,self.view.bounds.size.width * CellRatio);
}

#pragma mark -- private

- (void) initNav {

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchButton];
    
}

- (void) destoryVideoPlayer {
    if (self.videoPlayView) {
        [self.videoPlayView destoryVideoPlayer];
    }
    self.videoPlayView = nil;
    self.currentSelectedCell = nil;
    self.playerIndexPath = nil;
}


- (void) homeVCShowPanelAction {
    [self destoryVideoPlayer];
}

- (void) homeVCScrollViewDidEndScrollingAnimationAction {
    [self destoryVideoPlayer];
}

- (BOOL)isCurrentViewControllerVisible
{
    return (self.isViewLoaded && self.view.window);
}


#pragma mark - getter

- (UIButton *)searchButton
{
    if (!_searchButton) {
        _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _searchButton.contentMode = UIViewContentModeScaleAspectFit;
        [_searchButton setAdjustsImageWhenHighlighted:NO];
        _searchButton.frame = CGRectMake(0, 0, 52, 44);
        [_searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
        [_searchButton addTarget:self action:@selector(searchClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchButton;
}


@end
