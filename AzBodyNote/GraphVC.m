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
	
	if (mAppDelegate.app_is_unlock==NO) {
		uiActivePageMax_ = 0; // 0ページ制限
	}

	// listen to our app delegates notification that we might want to refresh our detail view
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(refreshAllViews:) 
												 name:NFM_REFRESH_ALL_VIEWS 
											   object:[[UIApplication sharedApplication] delegate]];
	
	ibScrollView.delegate = self; // <UIScrollViewDelegate>
	ibScrollView.directionalLockEnabled = YES;
	ibScrollView.pagingEnabled = YES;
	
	if (actIndicator_==nil) {
		actIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		actIndicator_.frame = CGRectMake(0, 0, 50, 50);
		[actIndicator_ stopAnimating];
		[ibScrollView addSubview:actIndicator_];
	}
}

- (void)labelGraphRect:(CGRect)rect  text:(NSString*)text
{
	UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x+rect.size.width-30, rect.origin.y+3, 100,20)];
	lb.text = text;
	lb.backgroundColor = [UIColor clearColor];
	lb.textColor = [UIColor grayColor];
	lb.font = [UIFont systemFontOfSize:16];
	lb.adjustsFontSizeToFitWidth = YES;
	lb.minimumFontSize = 10;
	[ibScrollView addSubview:lb];
}

- (void)graphViewPage:(NSUInteger)page //section:(NSUInteger)section
{
	//NSLog(@"graphViewPage: page=%d  section=%d", page, section);
	if (uiActivePageMax_ < page) return;

	// Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:NO];
	NSArray *sortDesc = [NSArray arrayWithObjects: sort1,nil]; // 日付降順：Limit抽出に使用
	
	NSInteger iOverLeft = 3;  // iPad対応時に調整が必要
	NSInteger iOverRight = 2;  // GOAL列が常に+1される
	NSInteger iOffset = (GRAPH_PAGE_LIMIT * page);

	if (page==0) {
		iOverRight = 0;
		iOffset = 0;
	} else {
		iOffset -= iOverRight;
	}

	NSArray *e2recs = [mMocFunc select: E2_ENTITYNAME
									limit: iOverLeft + GRAPH_PAGE_LIMIT + iOverRight
									offset: iOffset
									where: [NSPredicate predicateWithFormat: E2_nYearMM @" > 200000"] // 未保存を除外する
									sort: sortDesc]; // 最新日付から抽出

	if (0 < uiActivePage_ && [e2recs count] <= iOverLeft + iOverRight) { // 次ページなし
		uiActivePageMax_ = uiActivePage_;  // 最終ページ判明
		return;
	}
	else if ([e2recs count] < iOverLeft + GRAPH_PAGE_LIMIT + iOverRight) {
		uiActivePageMax_ = page;  // 最終ページ判明
	}
	
	// GraphView サイズを決める
	CGRect rc = ibScrollView.bounds;
	CGFloat fWhalf = rc.size.width / 2.0; // 表示幅の半分（画面中央）
	int iCount = [e2recs count] - iOverLeft - iOverRight;
	if (iCount < 2) iCount = 2; // 1だとスクロール出来なくなる
	//                     (                 左余白                 ) + (               レコード               ) + (                 右余白                 ); 
	rc.size.width = (fWhalf - RECORD_WIDTH/2) + (RECORD_WIDTH * iCount) + (fWhalf - RECORD_WIDTH/2);
	
	ibScrollView.contentSize = CGSizeMake(rc.size.width, rc.size.height*2.0); //[0.9]上下2段
	
	rc.origin.x = (fWhalf - RECORD_WIDTH/2) - (RECORD_WIDTH * iOverLeft);  // 左余白
	rc.size.width = RECORD_WIDTH * (iCount + iOverLeft + iOverRight + 1);	// +1はGOAL列
/*	
	ibGraphView.frame = rc;
	ibGraphView.RaE2records = e2recs;
	//ibGraphView.iOverLeft = iOverLeft;
	//ibGraphView.iOverRight = iOverRight;
	
	//[ibGraphView drawRect:self.view.frame];  NG//これだと不具合発生する
	[ibGraphView setNeedsDisplay]; //drawRect:が呼び出される
*/
	// rc = 原点左上
	CGFloat fHeight = ibScrollView.bounds.size.height - 3 - 15;  // 上下の余白を除いた有効な高さ
	CGRect rcgv = rc;
	//-------------------------------------------------------------------上段
	rcgv.origin.y = 10;
	//------------------------------------------------------日付
	rcgv.size.height = fHeight * 1/8;
	if (mGvDate==nil) {
		mGvDate = [[GViewDate alloc] initWithFrame: rcgv]; // 日付専用
		mGvDate.ppE2records = e2recs;
		//mGvDate.ppSectionHeight = ibScrollView.bounds.size.height; //下段を描くため
		[ibScrollView addSubview:mGvDate];
	} else {
		mGvDate.ppE2records = e2recs;
		[mGvDate setNeedsDisplay]; //drawRect:が呼び出される
	}
	
	//------------------------------------------------------血圧
	rcgv.origin.y += rcgv.size.height;
	rcgv.size.height = fHeight * 3/8;
	if (mGvBp==nil) {
		mGvBp = [[GViewBp alloc] initWithFrame: rcgv]; // 血圧専用
		mGvBp.ppE2records = e2recs;
		[ibScrollView addSubview:mGvBp];
		[self labelGraphRect:rcgv  text:NSLocalizedString(@"BpHi Name",nil)];
	} else {
		mGvBp.ppE2records = e2recs;
		[mGvBp setNeedsDisplay]; //drawRect:が呼び出される
	}
	//------------------------------------------------------脈拍
	rcgv.origin.y += rcgv.size.height;
	rcgv.size.height = fHeight * 2/8;
	if (mGvPuls==nil) {
		mGvPuls = [[GViewPuls alloc] initWithFrame: rcgv]; // 1値汎用
		mGvPuls.ppE2records = e2recs;
		mGvPuls.ppEntityKey = E2_nPulse_bpm;
		mGvPuls.ppGoalKey = Goal_nPulse_bpm;
		mGvPuls.ppDec = 0;
		mGvPuls.ppMin = E2_nPuls_MIN;
		mGvPuls.ppMax = E2_nPuls_MAX;
		[ibScrollView addSubview:mGvPuls];
		[self labelGraphRect:rcgv  text:NSLocalizedString(@"Puls Name",nil)];
	} else {
		mGvPuls.ppE2records = e2recs;
		[mGvPuls setNeedsDisplay]; //drawRect:が呼び出される
	}
	//------------------------------------------------------体温
	rcgv.origin.y += rcgv.size.height;
	rcgv.size.height = fHeight * 2/8;
	if (mGvTemp==nil) {
		mGvTemp = [[GViewPuls alloc] initWithFrame: rcgv]; // 1値汎用
		mGvTemp.ppE2records = e2recs;
		mGvTemp.ppEntityKey = E2_nTemp_10c;
		mGvTemp.ppGoalKey = Goal_nTemp_10c;
		mGvTemp.ppDec = 1;
		mGvTemp.ppMin = E2_nTemp_MIN;
		mGvTemp.ppMax = E2_nTemp_MAX;
		[ibScrollView addSubview:mGvTemp];
		[self labelGraphRect:rcgv  text:NSLocalizedString(@"Temp Name",nil)];
	} else {
		mGvTemp.ppE2records = e2recs;
		[mGvTemp setNeedsDisplay]; //drawRect:が呼び出される
	}
	//-------------------------------------------------------------------下段
	rcgv.origin.y = rc.size.height + 10;
	//------------------------------------------------------日付
	rcgv.size.height = fHeight * 1/8;
	if (mGvDate2==nil) {
		mGvDate2 = [[GViewDate alloc] initWithFrame: rcgv]; // 日付専用
		mGvDate2.ppE2records = e2recs;
		[ibScrollView addSubview:mGvDate2];
	} else {
		mGvDate2.ppE2records = e2recs;
		[mGvDate2 setNeedsDisplay]; //drawRect:が呼び出される
	}
	//------------------------------------------------------体重
	rcgv.origin.y += rcgv.size.height;
	rcgv.size.height = fHeight * 2/8;	// 体重高さ
	if (mGvWeight==nil) {
		mGvWeight = [[GViewPuls alloc] initWithFrame: rcgv]; // 1値汎用
		mGvWeight.ppE2records = e2recs;
		mGvWeight.ppEntityKey = E2_nWeight_10Kg;
		mGvWeight.ppGoalKey = Goal_nWeight_10Kg;
		mGvWeight.ppDec = 1;
		mGvWeight.ppMin = E2_nWeight_MIN;
		mGvWeight.ppMax = E2_nWeight_MAX;
		[ibScrollView addSubview:mGvWeight];
		[self labelGraphRect:rcgv  text:NSLocalizedString(@"Weight Name",nil)];
	} else {
		mGvWeight.ppE2records = e2recs;
		[mGvWeight setNeedsDisplay]; //drawRect:が呼び出される
	}
	//------------------------------------------------------歩数
	rcgv.origin.y += rcgv.size.height;
	rcgv.size.height = fHeight * 1.8/8;
	if (mGvPedo==nil) {
		mGvPedo = [[GViewPuls alloc] initWithFrame: rcgv]; // 1値汎用
		mGvPedo.ppE2records = e2recs;
		mGvPedo.ppEntityKey = E2_nPedometer;
		mGvPedo.ppGoalKey = Goal_nPedometer;
		mGvPedo.ppDec = 0;
		mGvPedo.ppMin = E2_nPedometer_MIN;
		mGvPedo.ppMax = E2_nPedometer_MAX;
		[ibScrollView addSubview:mGvPedo];
		[self labelGraphRect:rcgv  text:NSLocalizedString(@"Pedo Name",nil)];
	} else {
		mGvPedo.ppE2records = e2recs;
		[mGvPedo setNeedsDisplay]; //drawRect:が呼び出される
	}
	//------------------------------------------------------体脂肪率
	rcgv.origin.y += rcgv.size.height;
	rcgv.size.height = fHeight * 1.6/8;
	if (mGvFat==nil) {
		mGvFat = [[GViewPuls alloc] initWithFrame: rcgv]; // 1値汎用
		mGvFat.ppE2records = e2recs;
		mGvFat.ppEntityKey = E2_nBodyFat_10p;
		mGvFat.ppGoalKey = Goal_nBodyFat_10p;
		mGvFat.ppDec = 1;
		mGvFat.ppMin = E2_nBodyFat_MIN;
		mGvFat.ppMax = E2_nBodyFat_MAX;
		[ibScrollView addSubview:mGvFat];
		[self labelGraphRect:rcgv  text:NSLocalizedString(@"BodyFat Name",nil)];
	} else {
		mGvFat.ppE2records = e2recs;
		[mGvFat setNeedsDisplay]; //drawRect:が呼び出される
	}
	//------------------------------------------------------骨格筋率
	rcgv.origin.y += rcgv.size.height;
	rcgv.size.height = fHeight * 1.6/8;
	if (mGvSk==nil) {
		mGvSk = [[GViewPuls alloc] initWithFrame: rcgv]; // 1値汎用
		mGvSk.ppE2records = e2recs;
		mGvSk.ppEntityKey = E2_nSkMuscle_10p;
		mGvSk.ppGoalKey = Goal_nSkMuscle_10p;
		mGvSk.ppDec = 1;
		mGvSk.ppMin = E2_nSkMuscle_MIN;
		mGvSk.ppMax = E2_nSkMuscle_MAX;
		[ibScrollView addSubview:mGvSk];
		[self labelGraphRect:rcgv  text:NSLocalizedString(@"SkMuscle Name",nil)];
	} else {
		mGvSk.ppE2records = e2recs;
		[mGvSk setNeedsDisplay]; //drawRect:が呼び出される
	}

	//-------------------------------------------
	if (page < uiActivePage_) {	// [ibGraphView setNeedsDisplay]より先にスクロールさせること
		// 左端を画面中央に表示する
		pointNext_ = CGPointMake(0, 0); 
	} else {
		// 右端を画面中央に表示する
		pointNext_ = CGPointMake(ibScrollView.contentSize.width - ibScrollView.bounds.size.width, 0);
	}
	ibScrollView.contentOffset = pointNext_;
	uiActivePage_ = page;
}

- (void)animation_after
{
	[actIndicator_ stopAnimating];
	
	ibScrollView.contentOffset = pointNext_;
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
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	uiActivePageMax_ = 999; // この時点で最終ページは不明
	[self graphViewPage:0  animated:YES];
	// 最初、GOALを画面中央に表示する
	//ibScrollView.contentOffset = CGPointMake(ibScrollView.contentSize.width - ibScrollView.bounds.size.width, 0);  
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
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
	
/*	static int iPage = 0;
	if (iPage==0) {
		if (100 < scrollView.contentOffset.y) {
			scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.bounds.size.height);
			iPage = 1;
			return;
		}
		else if (scrollView.contentOffset.y != 0) {
			scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
			return;
		}
	} else {
		if (scrollView.contentOffset.y < scrollView.bounds.size.height-100) {
			scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
			iPage = 0;
			return;
		}
		else if (scrollView.contentOffset.y != scrollView.bounds.size.height) {
			scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.bounds.size.height);
			return;
		}
	}*/

/*	static CGFloat fx = 0;
	if (fx != scrollView.contentOffset.x) {
		fx = scrollView.contentOffset.x;
		scrollView.pagingEnabled = NO; // ヨコはフリー
	} else {
		scrollView.pagingEnabled = YES; // タテはページング
		//ページング復活によりヨコもグリッドされてしまうが、しょうがない？
		//scrollView.contentOffset = CGPointMake(fx, scrollView.contentOffset.y);
	}*/
	
	if (mAppDelegate.app_is_unlock) {
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
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{	// スクロール終了時（指を離した時）に呼ばれる
	NSLog(@"scrollViewDidEndDragging: .contentOffset.x=%f  .y=%f / height=%f", 
		  scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.frame.size.height);

/*	static NSUInteger staticSection = 0;
	NSUInteger iSection = (scrollView.contentOffset.y / scrollView.frame.size.height);
	assert(iSection==0 OR iSection==1);
	if (staticSection != iSection) {
		[self graphViewPage:uiActivePage_  section:iSection  animated:YES];
		staticSection = iSection;
	}
	else */

	if (mAppDelegate.app_is_unlock) {
		if (scrollView.contentOffset.x < -70) {
			// PREV（過去）ページへ
			if (uiActivePage_ < uiActivePageMax_) {
				NSLog(@"scrollViewDidEndDragging: PREV uiActivePage_=%d + 1", uiActivePage_);
				// 画面左側にインジケータ表示
				//[actIndicator_ setFrame:CGRectMake(80, ibScrollView.frame.size.height/2-25, 50, 50)];
				//[actIndicator_ startAnimating];
				[self graphViewPage:uiActivePage_ + 1  animated:YES];
			}
		}
		else if (scrollView.contentSize.width - ibScrollView.bounds.size.width + 70 < scrollView.contentOffset.x) {
			// NEXT（未来）ページへ
			if (0 < uiActivePage_) {
				NSLog(@"scrollViewDidEndDragging: NEXT uiActivePage_=%d - 1", uiActivePage_);
				// 画面右側にインジケータ表示
				//[actIndicator_ setFrame:CGRectMake(ibScrollView.contentSize.width-80-50, ibScrollView.frame.size.height/2-25, 50, 50)];
				//[actIndicator_ startAnimating];
				[self graphViewPage:uiActivePage_ - 1 animated:YES];
			}
		}
	/*	else {
			NSLog(@"scrollViewDidEndDragging: scrollView.contentSize.width=%f  scrollView.contentSize.width=%f", 
												scrollView.contentSize.width, scrollView.contentSize.width);
		}*/
	}
}



@end
