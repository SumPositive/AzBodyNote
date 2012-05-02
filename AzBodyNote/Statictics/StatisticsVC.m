//
//  StatisticsVC.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StatisticsVC.h"

@interface StatisticsVC ()

@end

@implementation StatisticsVC

/*** XIB利用時には呼ばれません。
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
	GA_TRACK_PAGE(@"StatisticsVC");
	
	self.title = NSLocalizedString(@"TabStatistics",nil);
	
	mAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	assert(mAppDelegate);
	mMocFunc = mAppDelegate.mocBase; // Read Only
	assert(mMocFunc);
	
	// listen to our app delegates notification that we might want to refresh our detail view
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(refreshAllViews:) 
												 name:NFM_REFRESH_ALL_VIEWS 
											   object:nil];
	
	ibScrollView.delegate = self; // <UIScrollViewDelegate>
	ibScrollView.directionalLockEnabled = NO;
	ibScrollView.pagingEnabled = NO;

/*	// ズーム：　ピンチアウト操作
	UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]
											  initWithTarget:self action:@selector(handlePinchGesture:)];
	[ibScrollView addGestureRecognizer:pinchGesture];*/
}


- (void)labelGraphRect:(CGRect)rect  text:(NSString*)text
{
	CGFloat fx = rect.origin.x+rect.size.width;
	
	UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(fx, rect.origin.y+rect.size.height-25, 100,20)];
	lb.text = text;
	lb.backgroundColor = [UIColor clearColor];
	lb.textColor = [UIColor darkGrayColor];
	lb.font = [UIFont systemFontOfSize:14];
	lb.numberOfLines = 1;
	lb.adjustsFontSizeToFitWidth = YES;
	lb.minimumFontSize = 10;
	[ibScrollView addSubview:lb];
}

- (void)graphViewPage:(NSUInteger)page //section:(NSUInteger)section
{
	CGRect rcContent = ibScrollView.bounds;
//	rcContent.size.width *= ZOOM_MAX;
//	rcContent.size.height *= ZOOM_MAX;

	[ibScrollView setContentSize:rcContent.size];
	[ibScrollView setZoomScale:1.0];
	[ibScrollView setMinimumZoomScale:1.0];
	[ibScrollView setMaximumZoomScale:ZOOM_MAX];
	
/*	CGFloat fw = ibScrollView.frame.size.width / rcContent.size.width;
	CGFloat fh = ibScrollView.frame.size.height / rcContent.size.height;
	NSLog(@"fw=%0.2f  fh=%0.2f", fw, fh);
	if (fw < fh) {
		[ibScrollView setMinimumZoomScale:fw];
		[ibScrollView setZoomScale:fw];
	} else {
		[ibScrollView setMinimumZoomScale:fh];
		[ibScrollView setZoomScale:fh];
	}
	//ibScrollView.contentSize = rcContent.size;
	[ibScrollView setContentSize:rcContent.size];
*/
	
	// グラフ原点表示
	ibScrollView.contentOffset = CGPointMake(0, 0);

	// Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:NO];
	NSArray *sortDesc = [NSArray arrayWithObjects: sort1,nil]; // 日付降順：Limit抽出に使用
	
	NSArray *e2recs = [mMocFunc select: E2_ENTITYNAME
								 limit: (mStatDays * 3)		//1日時間違いが平均3回と仮定した
								offset: 0
								 where: [NSPredicate predicateWithFormat: E2_nYearMM @" > 200000"] // 未保存を除外する
								  sort: sortDesc]; // 最新日付から抽出
	
	//------------------------------------------------------
	switch (ibSegment.selectedSegmentIndex) 
	{
		case 0:	// 起床後／就寝前の日推移
		case 1:	// 安静時／運動後の日推移
/*			if (mSvBp==nil) {
				mSvBp = [[SViewBp alloc] initWithFrame: rcScrollContent];
				mSvBp.ppE2records = e2recs;
				mSvBp.ppSelectedSegmentIndex = ibSegment.selectedSegmentIndex;
				[ibScrollView addSubview:mSvBp];
			} else {
				mSvBp.ppE2records = e2recs;
				mSvBp.ppSelectedSegmentIndex = ibSegment.selectedSegmentIndex;
				[mSvBp setNeedsDisplay]; //drawRect:が呼び出される
			}*/
			break;

		case 2:	// 24時間 分布図

			break;
		
		default:
			break;
	}

	if (mSvBp==nil) {
		mSvBp = [[SViewBp alloc] initWithFrame: rcContent];
		mSvBp.ppE2records = e2recs;
		[ibScrollView addSubview:mSvBp];
	} else {
		mSvBp.ppE2records = e2recs;
		[mSvBp setFrame: rcContent];
		[mSvBp setNeedsDisplay]; //drawRect:が呼び出される
	}
}

- (void)animation_after
{
	//[mActIndicator stopAnimating];
	
	// アニメ準備
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration: 0.7];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; //Slow at End.
	
	ibScrollView.alpha = 1;
	
	// アニメ実行
	[UIView commitAnimations];
}

- (void)graphViewPage:(NSUInteger)page animated:(BOOL)animated
{
	if (animated) {
		ibScrollView.alpha = 0.1;
		// アニメ準備
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:1.2];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; //Slow at End.
		//[UIView setAnimationDelegate:self];
		//[UIView setAnimationDidStopSelector:@selector(animation_after)]; //アニメーション終了後に呼び出す＜＜setAnimationDelegate必要
	}
	// アニメ終了状態
	ibScrollView.alpha = 1.0;
	[self graphViewPage:page];// この中で、uiActivePage_が更新される
	
	if (animated) {
		// アニメ実行
		[UIView commitAnimations];
	} else {
		//[mActIndicator stopAnimating];
		//[self animation_after]; //アニメーション終了後に呼び出す
	}
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	mStatDays = [[kvs objectForKey:GUD_SettStatDays] integerValue];
	if (mStatDays<1 OR STAT_DAYS_MAX<mStatDays) {
		mStatDays = 1;
		[kvs setObject:[NSNumber numberWithInteger:mStatDays] forKey:GUD_SettStatDays];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self graphViewPage:0  animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	//return YES; //[0.9]ヨコにすると「血圧の日変動分布」グラフ表示する
}

- (void)viewDidDisappear:(BOOL)animated
{	// Called after the view was dismissed, covered or otherwise hidden. Default does nothing
	// クリアする
	mSvBp = nil;
	NSLog(@"ibScrollView.subviews={%@}", ibScrollView.subviews);
	for (id  sv in ibScrollView.subviews) {
		if ([sv isMemberOfClass:[UILabel class]]) {
			UILabel *lb = sv;
			[lb removeFromSuperview];
		}
/*		else if ([sv isMemberOfClass:[SViewBp class]]) {
			SViewBp *sv = sv;
			[sv removeFromSuperview];
		}*/
	}
	NSLog(@"ibScrollView.subviews={%@}", ibScrollView.subviews);
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}


#pragma mark - iCloud
- (void)refreshAllViews:(NSNotification*)note 
{	// iCloud-CoreData に変更があれば呼び出される
    if (note) {
		//[self.tableView reloadData];
		[self viewWillAppear:NO]; // NO によりrefreshであることを知らせている。
		// この後、viewDidAppear: は呼ばれないことに注意！
    }
}


#pragma mark - <UIScrollViewDelegate> Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	// スクロール中に呼ばれる
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{	// スクロール終了時（指を離した時）に呼ばれる
	if (scrollView.contentSize.width - ibScrollView.bounds.size.width + 70 < scrollView.contentOffset.x) {
		// 右へ　　グラフ設定
		SettGraphTVC *vc = [[SettGraphTVC alloc] init];
		vc.hidesBottomBarWhenPushed = YES; //以降のタブバーを消す
		vc.ppBackGraph = YES;
		
		UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:vc];
		//nc.modalPresentationStyle = UIModalPresentationFormSheet;
		nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		[self presentModalViewController:nc animated:YES];
	}
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{	// Zoom対象となるViewを知らせる
	return mSvBp;
}
/*
#pragma mark - <UIGestureRecognizer>
- (IBAction)handlePinchGesture:(UIGestureRecognizer *)sender 
{
	CGFloat factor = [(UIPinchGestureRecognizer *)sender scale];
	ibScrollView.zoomScale = factor;
}*/

@end
