//
//  GraphVC.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//
#import "GraphVC.h"


@implementation GraphVC

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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

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
	
	//if (mAppDelegate.app_is_unlock==NO) {
	//	uiActivePageMax_ = 0; // 0ページ制限
	//}

	// listen to our app delegates notification that we might want to refresh our detail view
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(refreshAllViews:) 
												 name:NFM_REFRESH_ALL_VIEWS 
											   object:nil];
	
	ibScrollView.delegate = self; // <UIScrollViewDelegate>
	ibScrollView.directionalLockEnabled = YES;
	ibScrollView.pagingEnabled = NO;
	
	if (actIndicator_==nil) {
		actIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		actIndicator_.frame = CGRectMake(0, 0, 50, 50);
		[actIndicator_ stopAnimating];
		[ibScrollView addSubview:actIndicator_];
	}
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

- (void)graphViewPage:(NSUInteger)page //section:(NSUInteger)section
{
	//NSLog(@"graphViewPage: page=%d  section=%d", page, section);
	//if (uiActivePageMax_ < page) return;

	// Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:NO];
	NSArray *sortDesc = [NSArray arrayWithObjects: sort1,nil]; // 日付降順：Limit抽出に使用
	
	//NSInteger iOverLeft = 0;  // iPad対応時に調整が必要
	//NSInteger iOverRight = 0;  // GOAL列が常に+1される
	//NSInteger iOffset = 0;

/*	if (page==0) {
		iOverRight = 0;
		iOffset = 0;
	} else {
		iOffset -= iOverRight;
	}*/

	NSArray *e2recs = [mMocFunc select: E2_ENTITYNAME
									limit: (mGraphDays * 3)		//1日時間違いが平均3回と仮定した
									offset: 0
									where: [NSPredicate predicateWithFormat: E2_nYearMM @" > 200000"] // 未保存を除外する
									sort: sortDesc]; // 最新日付から抽出

/*	if (0 < uiActivePage_ && [e2recs count] <= iOverLeft + iOverRight) { // 次ページなし
		uiActivePageMax_ = uiActivePage_;  // 最終ページ判明
		return;
	}
	else if ([e2recs count] < iOverLeft + GRAPH_PAGE_LIMIT + iOverRight) {
		uiActivePageMax_ = page;  // 最終ページ判明
	}*/
	
	// GraphView サイズを決める
	CGRect rcScrollContent = ibScrollView.bounds;
	CGFloat fWhalf = rcScrollContent.size.width / 2.0; // 表示幅の半分（画面中央）
	//int iCount = [e2recs count] - iOverLeft - iOverRight;
	int iCount = mGraphDays; // - iOverLeft - iOverRight;
	if (iCount < 2) iCount = 2; // 1だとスクロール出来なくなる
	//                     (                 左余白                 ) + (               レコード               ) + (                 右余白                 ); 
	rcScrollContent.size.width = (fWhalf - RECORD_WIDTH/2) + (RECORD_WIDTH * iCount) + (fWhalf - RECORD_WIDTH/2);
	
	ibScrollView.contentSize = CGSizeMake(rcScrollContent.size.width, rcScrollContent.size.height);
	
	rcScrollContent.origin.x = (fWhalf - RECORD_WIDTH/2); // - (RECORD_WIDTH * iOverLeft);  // 左余白
	//rcScrollContent.size.width = RECORD_WIDTH * (iCount + iOverLeft + iOverRight + 2);	// +2はGoal,Avg列
	rcScrollContent.size.width = RECORD_WIDTH * (iCount + 2);	// +2はGoal,Avg列

	//------------------------------------------------------日付
	CGRect rcgv = rcScrollContent;
	rcgv.origin.y = 10;
	rcgv.size.height = 20;
	if (mGvDate==nil) {
		mGvDate = [[GViewDate alloc] initWithFrame: rcgv]; // 日付専用
		mGvDate.ppE2records = e2recs;
		//mGvDate.ppSectionHeight = ibScrollView.bounds.size.height; //下段を描くため
		[ibScrollView addSubview:mGvDate];
	} else {
		mGvDate.ppE2records = e2recs;
		[mGvDate setNeedsDisplay]; //drawRect:が呼び出される
	}
	//------------------------------------------------------ グラフ
	rcgv.origin.y += rcgv.size.height;
	CGFloat fHeight = ibScrollView.bounds.size.height - rcgv.origin.y - 8;  // 日付と下の余白を除く
	NSInteger iPs = [mPanelGraphs count];
	assert(0<iPs);
	fHeight /= iPs;	// 1パネルあたりの高さ
	
	rcgv.size.height = fHeight;
	for (NSNumber *num in mPanelGraphs) 
	{
		switch ([num integerValue] * (-1)) 
		{
			case AzConditionBpHi:
				if (mGvBpHi==nil) {
					mGvBpHi = [[GViewLine alloc] initWithFrame: rcgv]; // 1値汎用
					mGvBpHi.ppE2records = e2recs;
					mGvBpHi.ppEntityKey = E2_nBpHi_mmHg;
					mGvBpHi.ppGoalKey = Goal_nBpHi_mmHg;
					mGvBpHi.ppDec = 0;
					mGvBpHi.ppMin = E2_nBpHi_MIN;
					mGvBpHi.ppMax = E2_nBpHi_MAX;
					[ibScrollView addSubview:mGvBpHi];
					[self labelGraphRect:rcgv  text:NSLocalizedString(@"Graph BpHi",nil)];
				} else {
					mGvBpHi.ppE2records = e2recs;
					[mGvBpHi setFrame:rcgv];
					[mGvBpHi setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
			case AzConditionBpLo:
				if (mGvBpLo==nil) {
					mGvBpLo = [[GViewLine alloc] initWithFrame: rcgv]; // 1値汎用
					mGvBpLo.ppE2records = e2recs;
					mGvBpLo.ppEntityKey = E2_nBpLo_mmHg;
					mGvBpLo.ppGoalKey = Goal_nBpLo_mmHg;
					mGvBpLo.ppDec = 0;
					mGvBpLo.ppMin = E2_nBpLo_MIN;
					mGvBpLo.ppMax = E2_nBpLo_MAX;
					[ibScrollView addSubview:mGvBpLo];
					[self labelGraphRect:rcgv  text:NSLocalizedString(@"Graph BpLo",nil)];
				} else {
					mGvBpLo.ppE2records = e2recs;
					[mGvBpLo setFrame:rcgv];
					[mGvBpLo setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
			case AzConditionPuls:
				if (mGvPuls==nil) {
					mGvPuls = [[GViewLine alloc] initWithFrame: rcgv]; // 1値汎用
					mGvPuls.ppE2records = e2recs;
					mGvPuls.ppEntityKey = E2_nPulse_bpm;
					mGvPuls.ppGoalKey = Goal_nPulse_bpm;
					mGvPuls.ppDec = 0;
					mGvPuls.ppMin = E2_nPuls_MIN;
					mGvPuls.ppMax = E2_nPuls_MAX;
					[ibScrollView addSubview:mGvPuls];
					[self labelGraphRect:rcgv  text:NSLocalizedString(@"Graph Pulse",nil)];
				} else {
					mGvPuls.ppE2records = e2recs;
					[mGvPuls setFrame:rcgv];
					[mGvPuls setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;

			case AzConditionWeight:		//------------------------------------------------------体重
				if (mGvWeight==nil) {
					mGvWeight = [[GViewLine alloc] initWithFrame: rcgv]; // 1値汎用
					mGvWeight.ppE2records = e2recs;
					mGvWeight.ppEntityKey = E2_nWeight_10Kg;
					mGvWeight.ppGoalKey = Goal_nWeight_10Kg;
					mGvWeight.ppDec = 1;
					mGvWeight.ppMin = E2_nWeight_MIN;
					mGvWeight.ppMax = E2_nWeight_MAX;
					[ibScrollView addSubview:mGvWeight];
					[self labelGraphRect:rcgv  text:NSLocalizedString(@"Graph Weight",nil)];
				} else {
					mGvWeight.ppE2records = e2recs;
					[mGvWeight setFrame:rcgv];
					[mGvWeight setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
				
			case AzConditionTemp:			//------------------------------------------------------体温
				if (mGvTemp==nil) {
					mGvTemp = [[GViewLine alloc] initWithFrame: rcgv]; // 1値汎用
					mGvTemp.ppE2records = e2recs;
					mGvTemp.ppEntityKey = E2_nTemp_10c;
					mGvTemp.ppGoalKey = Goal_nTemp_10c;
					mGvTemp.ppDec = 1;
					mGvTemp.ppMin = E2_nTemp_MIN;
					mGvTemp.ppMax = E2_nTemp_MAX;
					[ibScrollView addSubview:mGvTemp];
					[self labelGraphRect:rcgv  text:NSLocalizedString(@"Graph Temp",nil)];
				} else {
					mGvTemp.ppE2records = e2recs;
					[mGvTemp setFrame:rcgv];
					[mGvTemp setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
				
			case AzConditionPedo:		//------------------------------------------------------歩数
				if (mGvPedo==nil) {
					mGvPedo = [[GViewLine alloc] initWithFrame: rcgv]; // 1値汎用
					mGvPedo.ppE2records = e2recs;
					mGvPedo.ppEntityKey = E2_nPedometer;
					mGvPedo.ppGoalKey = Goal_nPedometer;
					mGvPedo.ppDec = 0;
					mGvPedo.ppMin = E2_nPedometer_MIN;
					mGvPedo.ppMax = E2_nPedometer_MAX;
					[ibScrollView addSubview:mGvPedo];
					[self labelGraphRect:rcgv  text:NSLocalizedString(@"Graph Pedo",nil)];
				} else {
					mGvPedo.ppE2records = e2recs;
					[mGvPedo setFrame:rcgv];
					[mGvPedo setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
				
			case AzConditionFat:			//------------------------------------------------------体脂肪率
				if (mGvFat==nil) {
					mGvFat = [[GViewLine alloc] initWithFrame: rcgv]; // 1値汎用
					mGvFat.ppE2records = e2recs;
					mGvFat.ppEntityKey = E2_nBodyFat_10p;
					mGvFat.ppGoalKey = Goal_nBodyFat_10p;
					mGvFat.ppDec = 1;
					mGvFat.ppMin = E2_nBodyFat_MIN;
					mGvFat.ppMax = E2_nBodyFat_MAX;
					[ibScrollView addSubview:mGvFat];
					[self labelGraphRect:rcgv  text:NSLocalizedString(@"Graph Fat",nil)];
				} else {
					mGvFat.ppE2records = e2recs;
					[mGvFat setFrame:rcgv];
					[mGvFat setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
				
			case AzConditionSkm:			//------------------------------------------------------骨格筋率
				if (mGvSk==nil) {
					mGvSk = [[GViewLine alloc] initWithFrame: rcgv]; // 1値汎用
					mGvSk.ppE2records = e2recs;
					mGvSk.ppEntityKey = E2_nSkMuscle_10p;
					mGvSk.ppGoalKey = Goal_nSkMuscle_10p;
					mGvSk.ppDec = 1;
					mGvSk.ppMin = E2_nSkMuscle_MIN;
					mGvSk.ppMax = E2_nSkMuscle_MAX;
					[ibScrollView addSubview:mGvSk];
					[self labelGraphRect:rcgv  text:NSLocalizedString(@"Graph Skm",nil)];
				} else {
					mGvSk.ppE2records = e2recs;
					[mGvSk setFrame:rcgv];
					[mGvSk setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
				
			default: //ERROR
				GA_TRACK_EVENT_ERROR(@"Graph mPanelGraphs",0);
				assert(NO);
				break;
		}
		rcgv.origin.y += fHeight;
	}

/*	//-------------------------------------------
	if (page < uiActivePage_) {	// [ibGraphView setNeedsDisplay]より先にスクロールさせること
		// 左端を画面中央に表示する
		pointNext_ = CGPointMake(0, 0); 
	} else {
		// 右端を画面中央に表示する
		pointNext_ = CGPointMake(ibScrollView.contentSize.width - ibScrollView.bounds.size.width, 0);
	}
	ibScrollView.contentOffset = pointNext_;
	uiActivePage_ = page;
 */
	// 右端を画面中央に表示する
	ibScrollView.contentOffset = CGPointMake(ibScrollView.contentSize.width - ibScrollView.bounds.size.width, 0);

}

- (void)animation_after
{
	[actIndicator_ stopAnimating];
	
	//ibScrollView.contentOffset = pointNext_;
}

- (void)graphViewPage:(NSUInteger)page animated:(BOOL)animated
{
	if (animated) {
		// アニメ準備
		CGContextRef context = UIGraphicsGetCurrentContext();
		[UIView beginAnimations:@"Graph" context:context];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; //Slow at End.
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animation_after)]; //アニメーション終了後に呼び出す＜＜setAnimationDelegate必要
	}
	// アニメ終了状態
	[self graphViewPage:page];// この中で、uiActivePage_が更新される

	if (animated) {
		// アニメ実行
		[UIView commitAnimations];
	} else {
		[actIndicator_ stopAnimating];
		[self animation_after]; //アニメーション終了後に呼び出す
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

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	// パネル順序読み込み ⇒ グラフON(-)のパネルだけ抽出する
	NSMutableArray *mua = [NSMutableArray new];
	NSArray *ar = [userDefaults objectForKey:GUD_SettGraphs];
	for (NSNumber *num in ar) {
		if ([num integerValue]<0) { //(-)負値ならばグラフＯＮ
			[mua addObject:num];
		}
	}
	mPanelGraphs = [NSArray arrayWithArray:mua]; //グラフON(-)のパネルだけ
	
	mGraphDays = [[userDefaults objectForKey:GUD_SettGraphDays] integerValue];
	if (mGraphDays<1 OR GRAPH_DAYS_MAX<mGraphDays) {
		mGraphDays = 1;
		[userDefaults setObject:[NSNumber numberWithInteger:mGraphDays] forKey:GUD_SettGraphDays];
	}

	mGoalDisp = [userDefaults boolForKey:GUD_bGoal];
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

/*
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) { // ロールグラフ
		uiActivePageMax_ = 999; // この時点で最終ページは不明
		[self graphViewPage:0 animated:YES];
		// 最初、GOALを画面中央に表示する
		//ibScrollView.contentOffset = CGPointMake(ibScrollView.contentSize.width - ibScrollView.bounds.size.width, 0);  
	}
	else {	// 「血圧の日変動分布」グラフ
		
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	
}
*/

- (void)viewDidDisappear:(BOOL)animated
{	// Called after the view was dismissed, covered or otherwise hidden. Default does nothing
	// クリアする
	mGvDate = nil;
	mGvBpHi = nil;
	mGvBpLo = nil;
	mGvPuls = nil;
	mGvTemp = nil;
	mGvWeight = nil;
	mGvPedo = nil;
	mGvFat = nil;
	mGvSk = nil;
	NSLog(@"ibScrollView.subviews={%@}", ibScrollView.subviews);
	for (id  sv in ibScrollView.subviews) {
		if ([sv isMemberOfClass:[UILabel class]]) {
			UILabel *lb = sv;
			[lb removeFromSuperview];
		}
		else if ([sv isMemberOfClass:[GViewLine class]]) {
			GViewLine *gv = sv;
			[gv removeFromSuperview];
		}
		else if ([sv isMemberOfClass:[GViewDate class]]) {
			GViewDate *gv = sv;
			[gv removeFromSuperview];
		}
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
	//NSLog(@"scrollViewDidScroll: .contentOffset.x=%f  .y=%f", scrollView.contentOffset.x, scrollView.contentOffset.y);
/*	if (mAppDelegate.app_is_unlock) {
		if (scrollView.contentOffset.x < -70) {
			// PREV（過去）ページへ
			if (uiActivePage_ < uiActivePageMax_) {
				// 画面左側にインジケータ表示
				if (![actIndicator_ isAnimating]) {
					[actIndicator_ setFrame:CGRectMake(-50, ibScrollView.frame.size.height/2-25, 50, 50)];
					[actIndicator_ startAnimating];
				}
			}
		}
		else if (scrollView.contentSize.width - ibScrollView.bounds.size.width + 70 < scrollView.contentOffset.x) {
			// NEXT（未来）ページへ
			if (0 < uiActivePage_) {
				// 画面右側にインジケータ表示
				if (![actIndicator_ isAnimating]) {
					[actIndicator_ setFrame:CGRectMake(ibScrollView.contentSize.width, ibScrollView.frame.size.height/2-25, 50, 50)];
					[actIndicator_ startAnimating];
				}
			}
		}
		else {
			if ([actIndicator_ isAnimating]) {
				[actIndicator_ stopAnimating];
			}
		}
	}*/
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{	// スクロール終了時（指を離した時）に呼ばれる
	//NSLog(@"scrollViewDidEndDragging: .contentOffset.x=%f  .y=%f / height=%f", 
	//	  scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.frame.size.height);
/*	if (mAppDelegate.app_is_unlock) {
		if (scrollView.contentOffset.x < -70) {
			// PREV（過去）ページへ
			if (uiActivePage_ < uiActivePageMax_) {
				NSLog(@"scrollViewDidEndDragging: PREV uiActivePage_=%d + 1", uiActivePage_);
				[self graphViewPage:uiActivePage_ + 1  animated:YES];
			}
		}
		else if (scrollView.contentSize.width - ibScrollView.bounds.size.width + 70 < scrollView.contentOffset.x) {
			// NEXT（未来）ページへ
			if (0 < uiActivePage_) {
				NSLog(@"scrollViewDidEndDragging: NEXT uiActivePage_=%d - 1", uiActivePage_);
				[self graphViewPage:uiActivePage_ - 1 animated:YES];
			}
		}
	}*/

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
