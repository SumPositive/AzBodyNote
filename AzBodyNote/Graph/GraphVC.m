//
//  GraphVC.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//
#import "GraphVC.h"


@implementation GraphVC


#pragma mark - Refresh
- (void)refreshAllViews:(NSNotification*)note 
{	// iCloud-CoreData に変更があれば呼び出される
	//mReDraw = YES;
	[self viewWillAppear:NO]; // NO によりrefreshであることを知らせている。
	// この後、viewDidAppear: は呼ばれないことに注意！
}


#pragma mark - Graph Draw
- (void)drawClear
{	// Called after the view was dismissed, covered or otherwise hidden. Default does nothing
	// クリアする
	mGvDate = nil;
	mGvBp = nil;
	mGvPuls = nil;
	mGvTemp = nil;
	mGvWeight = nil;
	mGvPedo = nil;
	mGvFat = nil;
	mGvSkm = nil;
	NSLog(@"ibScrollView.subviews={%@}", ibScrollView.subviews);
	for (id  sv in ibScrollView.subviews) {
		if ([sv isMemberOfClass:[UILabel class]]) {
			UILabel *lb = sv;
			[lb removeFromSuperview];
		}
		else if ([sv isMemberOfClass:[GViewDate class]]) {
			GViewDate *gv = sv;
			[gv removeFromSuperview];
		}
		else if ([sv isMemberOfClass:[GViewBp class]]) {
			GViewBp *gv = sv;
			[gv removeFromSuperview];
		}
		else if ([sv isMemberOfClass:[GViewLine class]]) {
			GViewLine *gv = sv;
			[gv removeFromSuperview];
		}
	}
	NSLog(@"ibScrollView.subviews={%@}", ibScrollView.subviews);
}

- (void)labelGraphRect:(CGRect)rect  text:(NSString*)text
{
	CGFloat fx = rect.origin.x+rect.size.width;
	if (mGoalDisp==NO) fx -= (RECORD_WIDTH/2); 	//Goal非表示につき左に寄せる
	
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

- (void)graphViewPageChange:(NSInteger)pageChange //section:(NSUInteger)section
{
	//NSLog(@"graphViewPage: page=%d  section=%d", page, section);
	if (mPageMax < mPage + pageChange) return;
	//if (mPage + pageChange < 0) return;
	mPage += pageChange;
	
	// Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:NO];
	NSArray *sortDesc = [NSArray arrayWithObjects: sort1,nil]; // 日付降順：Limit抽出に使用
	
	NSInteger iOverLeft = 1;  // iPad対応時に調整が必要
	NSInteger iOverRight = 1;  // GOAL列が常に+1される
	NSInteger iOffset = 0;
	
	if (mPage==0) {
		iOverRight = 0;
		iOffset = 0;
	} else {
		iOffset = (GRAPH_PAGE_LIMIT * mPage) - iOverRight;
	}
	mLimit = iOverLeft + GRAPH_PAGE_LIMIT + iOverRight;
	NSLog(@"mPage=%ld  iOffset=%ld  iOverLeft=%ld  iOverRight=%ld  mLimit=%ld",
					(long)mPage, (long)iOffset, (long)iOverLeft, (long)iOverRight, (long)mLimit);
	
	NSArray *e2recs = [mMocFunc select: E2_ENTITYNAME
								 limit:  mLimit
								offset: iOffset
								 where: [NSPredicate predicateWithFormat: E2_nYearMM @" > 200000"] // 未保存を除外する
								  sort: sortDesc]; // 最新日付から抽出
	
	if ([e2recs count] <= iOverLeft + iOverRight) { // 次ページなし
		mPageMax = mPage;  // 最終ページ判明
		return;
	}
	else if ([e2recs count] < mLimit) {
		mPageMax = mPage;  // 最終ページ判明
		iOverLeft = 0;
	}
	
	// GraphView サイズを決める
	CGRect rcScrollContent = ibScrollView.bounds;
	CGFloat fWhalf = rcScrollContent.size.width / 2.0; // 表示幅の半分（画面中央）
	int iCount = [e2recs count];
	if (iCount < 2) iCount = 2; // 1だとスクロール出来なくなる
	
	// スクロール領域				   (                 左余白                 ) + (               レコード               ) + (                 右余白                 ); 
	rcScrollContent.size.width = (fWhalf - RECORD_WIDTH/2) + (RECORD_WIDTH * iCount) + (fWhalf - RECORD_WIDTH/2);
	ibScrollView.contentSize = CGSizeMake(rcScrollContent.size.width - RECORD_WIDTH, rcScrollContent.size.height);
	
	// 描画領域
	rcScrollContent.origin.x = (fWhalf - RECORD_WIDTH/2) - (RECORD_WIDTH * iOverLeft);  
	rcScrollContent.size.width = RECORD_WIDTH * iCount;
	if (mPage==0 && 0 < mPageMax) {		//0ページ目 かつ 51件以上(&& 0 < mPageMax)のとき
		rcScrollContent.size.width += RECORD_WIDTH;	//＋Goal列
	}
	
	
	//------------------------------------------------------日付
	CGRect rcgv = rcScrollContent;
	rcgv.origin.y = 10;
	rcgv.size.height = 40;
	if (mGvDate==nil) {
		mGvDate = [[GViewDate alloc] initWithFrame: rcgv]; // 日付専用
		mGvDate.ppE2records = e2recs;
		mGvDate.ppPage = mPage;
		[ibScrollView addSubview:mGvDate];
	} else {
		mGvDate.ppE2records = e2recs;
		mGvDate.ppPage = mPage;
		[mGvDate setFrame:rcgv];
		[mGvDate setNeedsDisplay]; //drawRect:が呼び出される
	}

	if (mPage==0) {
		if (mIvSetting==nil) {
			mIvSetting = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon32-Sett_Right"]];
			[ibScrollView addSubview:mIvSetting];
		}
		mIvSetting.frame = CGRectMake(ibScrollView.contentSize.width-30, 20, 32, 32);
		mIvSetting.hidden = NO;
	} else {
		mIvSetting.hidden = YES;
	}
	
	//------------------------------------------------------ グラフ
	rcgv.origin.y += rcgv.size.height;
	CGFloat fHeight = ibScrollView.bounds.size.height - rcgv.origin.y - 8;  // 日付と下の余白を除く
	NSInteger iPs = [mPanelGraphs count];
	assert(0<iPs);
	fHeight /= iPs;	// 1パネルあたりの高さ
	
	for (NSNumber *num in mPanelGraphs) 
	{
		rcgv.size.height = fHeight;
		switch ([num integerValue] * (-1)) 
		{
			case AzConditionBpHi:
				rcgv.size.height *= 2.0;
				if (mGvBp==nil) {
					mGvBp = [[GViewBp alloc] initWithFrame: rcgv]; // 1値汎用
					mGvBp.ppE2records = e2recs;
					mGvBp.ppPage = mPage;
					[ibScrollView addSubview:mGvBp];
					CGRect rc = rcgv;
					rc.size.height = 30; //上ラベル位置
					[self labelGraphRect:rc  text:NSLocalizedString(@"Graph BpHi",nil)];
					[self labelGraphRect:rcgv  text:NSLocalizedString(@"Graph BpLo",nil)];
				} else {
					mGvBp.ppE2records = e2recs;
					mGvBp.ppPage = mPage;
					[mGvBp setFrame:rcgv];
					[mGvBp setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
			case AzConditionBpLo:
				//この後、rcgv.origin.y += fHeight; のみ通す
				break; //AzConditionBpHi:にて処理済み
				
			case AzConditionPuls:
				if (mGvPuls==nil) {
					mGvPuls = [[GViewLine alloc] initWithFrame: rcgv]; // 1値汎用
					mGvPuls.ppE2records = e2recs;
					mGvPuls.ppPage = mPage;
					mGvPuls.ppEntityKey = E2_nPulse_bpm;
					mGvPuls.ppGoalKey = Goal_nPulse_bpm;
					mGvPuls.ppDec = 0;
					mGvPuls.ppMin = E2_nPuls_MIN;
					mGvPuls.ppMax = E2_nPuls_MAX;
					[ibScrollView addSubview:mGvPuls];
					[self labelGraphRect:rcgv  text:NSLocalizedString(@"Graph Pulse",nil)];
				} else {
					mGvPuls.ppE2records = e2recs;
					mGvPuls.ppPage = mPage;
					[mGvPuls setFrame:rcgv];
					[mGvPuls setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
				
			case AzConditionWeight:		//------------------------------------------------------体重
				if (mGvWeight==nil) {
					mGvWeight = [[GViewLine alloc] initWithFrame: rcgv]; // 1値汎用
					mGvWeight.ppE2records = e2recs;
					mGvWeight.ppPage = mPage;
					mGvWeight.ppEntityKey = E2_nWeight_10Kg;
					mGvWeight.ppGoalKey = Goal_nWeight_10Kg;
					mGvWeight.ppDec = 1;
					mGvWeight.ppMin = E2_nWeight_MIN;
					mGvWeight.ppMax = E2_nWeight_MAX;
					[ibScrollView addSubview:mGvWeight];
					[self labelGraphRect:rcgv  text:NSLocalizedString(@"Graph Weight",nil)];
				} else {
					mGvWeight.ppE2records = e2recs;
					mGvWeight.ppPage = mPage;
					[mGvWeight setFrame:rcgv];
					[mGvWeight setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
				
			case AzConditionTemp:			//------------------------------------------------------体温
				if (mGvTemp==nil) {
					mGvTemp = [[GViewLine alloc] initWithFrame: rcgv]; // 1値汎用
					mGvTemp.ppE2records = e2recs;
					mGvTemp.ppPage = mPage;
					mGvTemp.ppEntityKey = E2_nTemp_10c;
					mGvTemp.ppGoalKey = Goal_nTemp_10c;
					mGvTemp.ppDec = 1;
					mGvTemp.ppMin = E2_nTemp_MIN;
					mGvTemp.ppMax = E2_nTemp_MAX;
					[ibScrollView addSubview:mGvTemp];
					[self labelGraphRect:rcgv  text:NSLocalizedString(@"Graph Temp",nil)];
				} else {
					mGvTemp.ppE2records = e2recs;
					mGvTemp.ppPage = mPage;
					[mGvTemp setFrame:rcgv];
					[mGvTemp setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
				
			case AzConditionPedo:		//------------------------------------------------------歩数
				if (mGvPedo==nil) {
					mGvPedo = [[GViewLine alloc] initWithFrame: rcgv]; // 1値汎用
					mGvPedo.ppE2records = e2recs;
					mGvPedo.ppPage = mPage;
					mGvPedo.ppEntityKey = E2_nPedometer;
					mGvPedo.ppGoalKey = Goal_nPedometer;
					mGvPedo.ppDec = 0;
					mGvPedo.ppMin = E2_nPedometer_MIN;
					mGvPedo.ppMax = E2_nPedometer_MAX;
					[ibScrollView addSubview:mGvPedo];
					[self labelGraphRect:rcgv  text:NSLocalizedString(@"Graph Pedo",nil)];
				} else {
					mGvPedo.ppE2records = e2recs;
					mGvPedo.ppPage = mPage;
					[mGvPedo setFrame:rcgv];
					[mGvPedo setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
				
			case AzConditionFat:			//------------------------------------------------------体脂肪率
				if (mGvFat==nil) {
					mGvFat = [[GViewLine alloc] initWithFrame: rcgv]; // 1値汎用
					mGvFat.ppE2records = e2recs;
					mGvFat.ppPage = mPage;
					mGvFat.ppEntityKey = E2_nBodyFat_10p;
					mGvFat.ppGoalKey = Goal_nBodyFat_10p;
					mGvFat.ppDec = 1;
					mGvFat.ppMin = E2_nBodyFat_MIN;
					mGvFat.ppMax = E2_nBodyFat_MAX;
					[ibScrollView addSubview:mGvFat];
					[self labelGraphRect:rcgv  text:NSLocalizedString(@"Graph Fat",nil)];
				} else {
					mGvFat.ppE2records = e2recs;
					mGvFat.ppPage = mPage;
					[mGvFat setFrame:rcgv];
					[mGvFat setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
				
			case AzConditionSkm:			//------------------------------------------------------骨格筋率
				if (mGvSkm==nil) {
					mGvSkm = [[GViewLine alloc] initWithFrame: rcgv]; // 1値汎用
					mGvSkm.ppE2records = e2recs;
					mGvSkm.ppPage = mPage;
					mGvSkm.ppEntityKey = E2_nSkMuscle_10p;
					mGvSkm.ppGoalKey = Goal_nSkMuscle_10p;
					mGvSkm.ppDec = 1;
					mGvSkm.ppMin = E2_nSkMuscle_MIN;
					mGvSkm.ppMax = E2_nSkMuscle_MAX;
					[ibScrollView addSubview:mGvSkm];
					[self labelGraphRect:rcgv  text:NSLocalizedString(@"Graph Skm",nil)];
				} else {
					mGvSkm.ppE2records = e2recs;
					mGvSkm.ppPage = mPage;
					[mGvSkm setFrame:rcgv];
					[mGvSkm setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
				
			default: //ERROR
				GA_TRACK_EVENT_ERROR(@"LOGIC ERROR No AzConditionItems",0);
				assert(NO);
				break;
		}
		rcgv.origin.y += fHeight;
	}
	// スクロール初期位置	// animation_after:にて処理
}

NSInteger afterPageChange = 0;
- (void)animation_after
{
	[mActIndicator stopAnimating];

	// スクロール初期位置
	if (0 < afterPageChange) {
		//＋次ページなので右端へ移動
		if (mPage==0 OR mPage==mPageMax) {
			ibScrollView.contentOffset = 
			CGPointMake(ibScrollView.contentSize.width - ibScrollView.bounds.size.width, 0);
		} else {
			ibScrollView.contentOffset = 
			CGPointMake(ibScrollView.contentSize.width - ibScrollView.bounds.size.width - RECORD_WIDTH, 0);
		}
	} 
	else if (afterPageChange < 0) {
		//ー前ページなので左端へ移動
		ibScrollView.contentOffset = CGPointMake(0, 0);
	}

	// アニメ準備
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration: 0.7];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; //Slow at End.
	
	ibScrollView.alpha = 1;

	// アニメ実行
	[UIView commitAnimations];
}

- (void)graphViewPageChange:(NSInteger)pageChange animated:(BOOL)animated
{
	afterPageChange = pageChange;
	if (animated) {
		// アニメ準備
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration: 0.7];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; //Slow at End.
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animation_after)]; //アニメーション終了後に呼び出す＜＜setAnimationDelegate必要
	}
	// アニメ終了状態
	ibScrollView.alpha = 0.1;
	[self graphViewPageChange:pageChange];// この中で、mPageが更新される
	
	if (animated) {
		// アニメ実行
		[UIView commitAnimations];
	} else {
		[mActIndicator stopAnimating];
		[self animation_after]; //アニメーション終了後に呼び出す
	}
}


#pragma mark - View lifecycle

/*** XIB利用時には呼ばれません。
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		appDelegate_ = [[UIApplication sharedApplication] delegate];
		assert(appDelegate_);
		mocFunc_ = appDelegate_.mocBase; // Read Only
		assert(mocFunc_);
    }
    return self;
}
*/

/*XIB
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	GA_TRACK_PAGE(@"GraphVC");

	self.title = NSLocalizedString(@"TabGraph",nil);

	mAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	assert(mAppDelegate);
	mMocFunc = mAppDelegate.mocBase; // Read Only
	assert(mMocFunc);
	//mReDraw = YES;
	
	// listen to our app delegates notification that we might want to refresh our detail view
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(refreshAllViews:) 
												 name:NFM_REFRESH_ALL_VIEWS 
											   object:nil];
	
	ibScrollView.delegate = self; // <UIScrollViewDelegate>
	ibScrollView.directionalLockEnabled = YES;
	ibScrollView.pagingEnabled = NO;
	
	if (mActIndicator==nil) {
		mActIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		mActIndicator.frame = CGRectMake(0, 0, 50, 50);
		[mActIndicator stopAnimating];
		[ibScrollView addSubview:mActIndicator];
	}
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];

/*	mAppDelegate.app_is_AdShow = NO; //これは広告表示しないViewである。 viewWillAppear:以降で定義すること
	if (mAppDelegate.adWhirlView) {	// Ad OFF
		//mAppDelegate.adWhirlView.frame = CGRectMake(0, self.view.frame.size.height+100, 320, 50);  //下へ隠す
		mAppDelegate.adWhirlView.hidden = YES;
	}*/

	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	// パネル順序読み込み ⇒ グラフON(-)のパネルだけ抽出する
	NSMutableArray *mua = [NSMutableArray new];
	NSArray *ar = [kvs objectForKey:KVS_SettGraphs];
	for (NSNumber *num in ar) {
		if ([num integerValue]<0) { //(-)負値ならばグラフＯＮ
			[mua addObject:num];
		}
	}
	if ([mPanelGraphs isEqualToArray:mua]==NO) {
		mPanelGraphs = [NSArray arrayWithArray:mua]; //グラフON(-)のパネルだけ
		//mReDraw = YES; //=YES:設定に変化あり ⇒ クリアして再描画する
	}
	if (mGoalDisp != [kvs boolForKey:KVS_bGoal]) {
		mGoalDisp = [kvs boolForKey:KVS_bGoal];
		//mReDraw = YES; //=YES:設定に変化あり ⇒ クリアして再描画する
	}
	//if (mReDraw) {
		//mReDraw = NO;
		//[self drawClear];  viewDidDisappear:にてクリア処理
		
		mPageMax = 999; // この時点で最終ページは不明
		mPage = 0;
		[self graphViewPageChange:0  animated:NO];
		//右端へ移動
		ibScrollView.contentOffset = 
		CGPointMake(ibScrollView.contentSize.width - ibScrollView.bounds.size.width, 0);
	//}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[mAppDelegate adShow:0];
	
	if ([mPanelGraphs count]<1) {
		azAlertBox(NSLocalizedString(@"Graph NoPanel",nil), NSLocalizedString(@"Graph NoPanel detail",nil), @"OK");
		self.navigationController.tabBarController.selectedIndex = 3; // Setting画面へ
		return;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	//return YES; //[0.9]ヨコにすると「血圧の日変動分布」グラフ表示する
}

- (void)viewDidDisappear:(BOOL)animated
{
	[self drawClear];
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}


#pragma mark - <UIScrollViewDelegate> Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	// スクロール中に呼ばれる
	//NSLog(@"scrollViewDidScroll: .contentOffset.x=%f  .y=%f", scrollView.contentOffset.x, scrollView.contentOffset.y);
//	if (mAppDelegate.app_is_unlock) {
		if (scrollView.contentOffset.x < -70) {
			// PREV（過去）ページへ
			if (mPage < mPageMax) {
				// 画面左側にインジケータ表示
				if (![mActIndicator isAnimating]) {
					[mActIndicator setFrame:CGRectMake(-50, ibScrollView.frame.size.height/2-25, 50, 50)];
					[mActIndicator startAnimating];
				}
			}
		}
		else if (scrollView.contentSize.width - ibScrollView.bounds.size.width + 70 < scrollView.contentOffset.x) {
			// NEXT（未来）ページへ
			if (0 < mPage) {
				// 画面右側にインジケータ表示
				if (![mActIndicator isAnimating]) {
					[mActIndicator setFrame:CGRectMake(ibScrollView.contentSize.width, ibScrollView.frame.size.height/2-25, 50, 50)];
					[mActIndicator startAnimating];
				}
			}
		}
		else {
			if ([mActIndicator isAnimating]) {
				[mActIndicator stopAnimating];
			}
		}
//	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{	// スクロール終了時（指を離した時）に呼ばれる
	//NSLog(@"scrollViewDidEndDragging: .contentOffset.x=%f  .y=%f / height=%f", 
	//	  scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.frame.size.height);
	if (scrollView.contentOffset.x < -70) {
		// PREV（過去）ページへ
		if (mAppDelegate.app_is_unlock==NO) {
			azAlertBox(NSLocalizedString(@"FreeLock",nil), 
							NSLocalizedString(@"FreeLock GraphLimit",nil), @"OK");
			return;
		}
		NSLog(@"mPage=%ld < mPageMax=%ld", (long)mPage, (long)mPageMax);
		if (mPage < mPageMax) {
			NSLog(@"scrollViewDidEndDragging: PREV mPage=%d + 1", mPage);
			[self graphViewPageChange:+1  animated:YES];
			return;
		}
	}
	else if (scrollView.contentSize.width - ibScrollView.bounds.size.width + 70 < scrollView.contentOffset.x) {
		// NEXT（未来）ページへ
		if (0 < mPage) {
			NSLog(@"scrollViewDidEndDragging: NEXT mPage=%d - 1", mPage);
			[self graphViewPageChange:-1  animated:YES];
			return;
		} 
		else {
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
}


@end
