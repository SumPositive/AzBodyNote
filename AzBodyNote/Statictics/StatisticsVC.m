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
	// View 背景
	UIImage *imgTile = [UIImage imageNamed:@"Tx-LzBeige320"];
	self.view.backgroundColor = [UIColor colorWithPatternImage:imgTile];
	
	mAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	assert(mAppDelegate);
	mMocFunc = mAppDelegate.mocBase; // Read Only
	assert(mMocFunc);
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	
	// listen to our app delegates notification that we might want to refresh our detail view
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(refreshAllViews:) 
												 name:NFM_REFRESH_ALL_VIEWS 
											   object:nil];
	
	ibScrollView.delegate = self; // <UIScrollViewDelegate>
	ibScrollView.directionalLockEnabled = NO;
	ibScrollView.pagingEnabled = NO;

	[ibSegment setTitle:NSLocalizedString(@"Stat Seg0 Hi-Lo",nil) forSegmentAtIndex:0];
	[ibSegment setTitle:NSLocalizedString(@"Stat Seg1 24H",nil) forSegmentAtIndex:1];
	ibSegment.selectedSegmentIndex = [[kvs objectForKey:KVS_SettStatType] integerValue];

	ibSpDays.maximumValue = STAT_DAYS_MAX;
	ibSpDays.value = [[kvs objectForKey:KVS_SettStatDays] integerValue];
	
	[ibSpDays addTarget:self action:@selector(actionStepperChange:) forControlEvents:UIControlEventValueChanged];
}


- (void)graphView
{
	// グラフ リセット
	ibScrollView.contentOffset = CGPointMake(0, 0); //ここで原点をリセットしなければ、前回の移動先が原点になってしまう。
	CGRect rcContent = ibScrollView.bounds;
	[ibScrollView setContentSize:rcContent.size];
	[ibScrollView setZoomScale:1.0];
	[ibScrollView setMinimumZoomScale:1.0];
	[ibScrollView setMaximumZoomScale:ZOOM_MAX];

	// Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:NO];
	NSArray *sortDesc = [NSArray arrayWithObjects: sort1,nil]; // 日付降順：Limit抽出に使用
	
	NSArray *e2recs = [mMocFunc select: E2_ENTITYNAME
								 limit: (ibSpDays.value * 5)		//1日の測定回数をDateOpt全種+1回と仮定した
								offset: 0
								 where: [NSPredicate predicateWithFormat: E2_nYearMM @" > 200000"] // 未保存を除外する
								  sort: sortDesc]; // 最新日付から抽出
	

	[mSvBp removeFromSuperview]; //クリア
	mSvBp = nil;
	mSvBp = [[SViewBp alloc] initWithFrame: rcContent];
	mSvBp.ppE2records = e2recs;
	mSvBp.ppStatType = ibSegment.selectedSegmentIndex; //= statType
	mSvBp.ppDays = ibSpDays.value;
	[ibScrollView addSubview:mSvBp];
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

- (void)graphViewAnimated:(BOOL)animated
{
	if (animated) {
		ibScrollView.alpha = 0.2;
		// アニメ準備
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:1.2];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; //Slow at End.
		//[UIView setAnimationDelegate:self];
		//[UIView setAnimationDidStopSelector:@selector(animation_after)]; //アニメーション終了後に呼び出す＜＜setAnimationDelegate必要
	}
	// アニメ終了状態
	ibScrollView.alpha = 1.0;
	[self graphView];// この中で、uiActivePage_が更新される
	
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
	NSInteger iDays = [[kvs objectForKey:KVS_SettStatDays] integerValue];
	if (iDays<1 OR STAT_DAYS_MAX<iDays) {
		iDays = 1;
		[kvs setObject:[NSNumber numberWithInteger:iDays] forKey:KVS_SettStatDays];
	}
	ibSpDays.value = iDays;
	ibLbDays.text = [NSString stringWithFormat:NSLocalizedString(@"Stat Last %ld days",nil), iDays];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[mAppDelegate adShow:0];
	
	[self graphViewAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	//return YES; //[0.9]ヨコにすると「血圧の日変動分布」グラフ表示する
}

- (void)viewDidDisappear:(BOOL)animated
{	// Called after the view was dismissed, covered or otherwise hidden. Default does nothing
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	[kvs synchronize];

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

#pragma mark - IBAction
- (IBAction)ibSegmentChange:(UISegmentedControl *)sender
{
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	[kvs setObject:[NSNumber numberWithInteger:ibSegment.selectedSegmentIndex]
			forKey:KVS_SettStatType];

	// 再描画
	[self graphViewAnimated:YES];
}


#pragma mark - Action
- (void)actionStepperChange:(UIStepper *)sender
{	// iOS5以降
	NSLog(@"actionStepperChange: sender.value=%.2lf  (.stepValue=%.2lf)", sender.value, sender.stepValue);

	if (mAppDelegate.app_is_unlock==NO && STAT_DAYS_FREE < ibSpDays.value) {
		ibSpDays.value = STAT_DAYS_FREE;
		azAlertBox(NSLocalizedString(@"FreeLock",nil), 
				 NSLocalizedString(@"FreeLock StatLimit",nil), @"OK");
		return;
	}

	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	[kvs setObject:[NSNumber numberWithInteger:ibSpDays.value]	forKey:KVS_SettStatDays];

	ibLbDays.text = [NSString stringWithFormat:NSLocalizedString(@"Stat Last %ld days",nil), (long)sender.value];
	// 再描画
	[self graphViewAnimated:YES];
}


#pragma mark - <UIScrollViewDelegate> Methods

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{	// Zoom対象となるViewを知らせる
	return mSvBp;
}

@end
