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
	
	ibScrollView.delegate = nil; // <UIScrollViewDelegate>
	ibScrollView.directionalLockEnabled = YES;
	ibScrollView.pagingEnabled = NO;
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
	// Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:NO];
	NSArray *sortDesc = [NSArray arrayWithObjects: sort1,nil]; // 日付降順：Limit抽出に使用
	
	NSArray *e2recs = [mMocFunc select: E2_ENTITYNAME
								 limit: (mStatDays * 3)		//1日時間違いが平均3回と仮定した
								offset: 0
								 where: [NSPredicate predicateWithFormat: E2_nYearMM @" > 200000"] // 未保存を除外する
								  sort: sortDesc]; // 最新日付から抽出
	
	// GraphView サイズを決める
	CGRect rcScrollContent = ibScrollView.bounds;
	CGFloat fWhalf = rcScrollContent.size.width / 2.0; // 表示幅の半分（画面中央）
	int iCount = mStatDays;
	if (iCount < 2) iCount = 2; // 1だとスクロール出来なくなる
	//                     (                 左余白                 ) + (               レコード               ) + (                 右余白                 ); 
	rcScrollContent.size.width = (fWhalf - RECORD_WIDTH/2) + (RECORD_WIDTH * iCount) + (fWhalf - RECORD_WIDTH/2);
	
	ibScrollView.contentSize = CGSizeMake(rcScrollContent.size.width, rcScrollContent.size.height);
	
	rcScrollContent.origin.x = (fWhalf - RECORD_WIDTH/2); //左余白
	rcScrollContent.size.width = RECORD_WIDTH * (iCount + 2);	// +2はGoal,Avg列
	
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
	// 右端を画面中央に表示する
	ibScrollView.contentOffset = CGPointMake(ibScrollView.contentSize.width - ibScrollView.bounds.size.width, 0);
}

- (void)graphViewPage:(NSUInteger)page animated:(BOOL)animated
{
	if (animated) {
		// アニメ準備
		CGContextRef context = UIGraphicsGetCurrentContext();
		[UIView beginAnimations:@"Graph" context:context];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; //Slow at End.
	}
	// アニメ終了状態
	[self graphViewPage:page];// この中で、uiActivePage_が更新される
	
	if (animated) {
		// アニメ実行
		[UIView commitAnimations];
	}
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
	mAppDelegate.app_is_AdShow = NO; //これは広告表示しないViewである。 viewWillAppear:以降で定義すること
	if (mAppDelegate.adWhirlView) {	// Ad OFF
		//mAppDelegate.adWhirlView.frame = CGRectMake(0, self.view.frame.size.height+100, 320, 50);  //下へ隠す
		mAppDelegate.adWhirlView.hidden = YES;
	}
	
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
	
	if ([mPanelGraphs count]<1) {
		alertBox(NSLocalizedString(@"Graph NoPanel",nil), NSLocalizedString(@"Graph NoPanel detail",nil), @"OK");
		self.navigationController.tabBarController.selectedIndex = 3; // Setting画面へ
		return;
	}
	
	//uiActivePageMax_ = 999; // この時点で最終ページは不明
	[self graphViewPage:0  animated:YES];
	// 最初、GOALを画面中央に表示する
	//ibScrollView.contentOffset = CGPointMake(ibScrollView.contentSize.width - ibScrollView.bounds.size.width, 0);  
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

@end
