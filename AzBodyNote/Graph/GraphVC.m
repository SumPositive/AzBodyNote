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

- (void)labelGraphRect:(CGRect)rect  text:(NSString*)text  color:(UIColor*)color
{
	CGFloat fx = rect.origin.x+rect.size.width;
	if (mGoalDisp==NO) fx -= (ibViewRecord.frame.size.width/2); 	//Goal非表示につき左に寄せる
	
	UILabel *lb = [[UILabel alloc] initWithFrame:
				   CGRectMake(fx, rect.origin.y+rect.size.height-25*mPadScale, 100*mPadScale,20*mPadScale)];
	lb.text = text;
	lb.textColor = color;
	lb.backgroundColor = [UIColor clearColor];
	lb.font = [UIFont systemFontOfSize:14*mPadScale];
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
	
	// 既存オブジェクト クリア
	[self drawClear];
	
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
	
	CGFloat fRw = ibViewRecord.frame.size.width;
	// スクロール領域				   (        余白         ) + (    レコード     ) + (      右余白        ); 
	rcScrollContent.size.width = (fWhalf - fRw/2) + (fRw * iCount) + (fWhalf - fRw/2);
	ibScrollView.contentSize = CGSizeMake(rcScrollContent.size.width - fRw, rcScrollContent.size.height);
	
	// 描画領域
	rcScrollContent.origin.x = (fWhalf - fRw/2) - (fRw * iOverLeft);  
	rcScrollContent.size.width = fRw * iCount;
	if (mPage==0 && 0 < mPageMax) {		//0ページ目 かつ 51件以上(&& 0 < mPageMax)のとき
		rcScrollContent.size.width += fRw;	//＋Goal列
	}
	
	//--------------------------------------------------------------------------------------- iCloud KVS GOAL!
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	BOOL bBpMean = [kvs boolForKey:@"KVS_SettGraphBpMean"];	//平均
	BOOL bBpPress = [kvs boolForKey:@"KVS_SettGraphBpPress"];	//脈圧
	
	//------------------------------------------------------日付
	CGRect rcgv = rcScrollContent;
	rcgv.origin.y = 3;
	rcgv.size.height = 60;
	if (mGvDate==nil) {
		mGvDate = [[GViewDate alloc] initWithFrame: rcgv]; // 日付専用
		mGvDate.ppE2records = e2recs;
		mGvDate.ppPage = mPage;
		mGvDate.ppRecordWidth = fRw;
		//mGvDate.ppFont = ibLbFont.font;
		[ibScrollView addSubview:mGvDate];
	} else {
		mGvDate.ppE2records = e2recs;
		mGvDate.ppPage = mPage;
		mGvDate.ppRecordWidth = fRw;
		//mGvDate.ppFont = ibLbFont.font;
		[mGvDate setFrame:rcgv];
		[mGvDate setNeedsDisplay]; //drawRect:が呼び出される
	}

	if (mPage==0) {
		if (mIvSetting==nil) {
			mIvSetting = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon32-Sett_Right"]];
			[ibScrollView addSubview:mIvSetting];
		}
		mIvSetting.frame = CGRectMake(ibScrollView.contentSize.width-30, 10, 32, 32);
		mIvSetting.hidden = NO;
	} else {
		mIvSetting.hidden = YES;
	}
	
	//------------------------------------------------------ グラフ
	CGRect rcGraphFrame = rcgv;
	rcGraphFrame.origin.y += rcGraphFrame.size.height;
	CGFloat fHeight = ibScrollView.bounds.size.height - rcGraphFrame.origin.y - 8;  // 日付と下の余白を除く
	NSInteger iPs = [mPanelGraphs count];
	assert(0<iPs);
	fHeight /= iPs;	// 1パネルあたりの高さ
	
	for (NSNumber *num in mPanelGraphs) 
	{
		rcGraphFrame.size.height = fHeight;
		switch ([num integerValue] * (-1)) 
		{
			case EnumConditionBpHi:
				rcGraphFrame.size.height *= 2.0;
				if (mGvBp==nil) {
					mGvBp = [[GViewBp alloc] initWithFrame: rcGraphFrame]; // 1値汎用
					mGvBp.ppE2records = e2recs;
					mGvBp.ppPage = mPage;
					mGvBp.ppRecordWidth = fRw;
					//mGvBp.ppFont = ibLbFont.font;
					[ibScrollView addSubview:mGvBp];
					CGRect rc = rcGraphFrame;
					NSLog(@"rcGraphFrame.size.height=%.02f", rcGraphFrame.size.height);
					//上ラベル
					rc.origin.y += 5;
					rc.size.height = 30;
					[self labelGraphRect:rc  text:NSLocalizedString(@"Graph BpHi",nil) color:[UIColor redColor]];
					if (bBpMean) {	//平均血圧
						rc.origin.y += (rcGraphFrame.size.height/4.0);
						if (95 < rcGraphFrame.size.height) {  //衝突回避
							[self labelGraphRect:rc  text:NSLocalizedString(@"Graph BpMean",nil) color:[UIColor whiteColor]];
						}
					}
					//下ラベル
					rc.origin.y = rcGraphFrame.origin.y + rcGraphFrame.size.height - 35;
					if (bBpPress) {	//脈圧
						if (70 < rcGraphFrame.size.height) {  //衝突回避
							[self labelGraphRect:rc  text:NSLocalizedString(@"Graph BpPress",nil) color:[UIColor whiteColor]];
						}
						rc.origin.y -= (rcGraphFrame.size.height/4.0);
					}
					[self labelGraphRect:rc  text:NSLocalizedString(@"Graph BpLo",nil) color:[UIColor blueColor]];
				} else {
					mGvBp.ppE2records = e2recs;
					mGvBp.ppPage = mPage;
					mGvBp.ppRecordWidth = fRw;
					//mGvBp.ppFont = ibLbFont.font;
					[mGvBp setFrame:rcgv];
					[mGvBp setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
			case EnumConditionBpLo:
				//この後、rcGraphFrame.origin.y += fHeight; のみ通す
				break; //EnumConditionBpHi:にて処理済み
				
			case EnumConditionPuls:
				if (mGvPuls==nil) {
					mGvPuls = [[GViewLine alloc] initWithFrame: rcGraphFrame]; // 1値汎用
					mGvPuls.ppE2records = e2recs;
					mGvPuls.ppPage = mPage;
					mGvPuls.ppRecordWidth = fRw;
					//mGvPuls.ppFont = ibLbFont.font;
					mGvPuls.ppEntityKey = E2_nPulse_bpm;
					mGvPuls.ppGoalKey = Goal_nPulse_bpm;
					mGvPuls.ppDec = 0;
					mGvPuls.ppMin = E2_nPuls_MIN;
					mGvPuls.ppMax = E2_nPuls_MAX;
					[ibScrollView addSubview:mGvPuls];
					[self labelGraphRect:rcGraphFrame  text:NSLocalizedString(@"Graph Pulse",nil) color:[UIColor darkGrayColor]];
				} else {
					mGvPuls.ppE2records = e2recs;
					mGvPuls.ppPage = mPage;
					mGvPuls.ppRecordWidth = fRw;
					//mGvPuls.ppFont = ibLbFont.font;
					[mGvPuls setFrame:rcGraphFrame];
					[mGvPuls setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
				
			case EnumConditionWeight:		//------------------------------------------------------体重
				if (mGvWeight==nil) {
					mGvWeight = [[GViewLine alloc] initWithFrame: rcGraphFrame]; // 1値汎用
					mGvWeight.ppE2records = e2recs;
					mGvWeight.ppPage = mPage;
					mGvWeight.ppRecordWidth = fRw;
					mGvWeight.ppEntityKey = E2_nWeight_10Kg;
					mGvWeight.ppGoalKey = Goal_nWeight_10Kg;
					mGvWeight.ppDec = 1;
					mGvWeight.ppMin = E2_nWeight_MIN;
					mGvWeight.ppMax = E2_nWeight_MAX;
					mGvWeight.ppBMI_Tall = mBMI_Tall;
					[ibScrollView addSubview:mGvWeight];
					CGRect rc = rcGraphFrame;
					if (0 < mBMI_Tall) {	//BMI
						if (70 < rcGraphFrame.size.height) {  //衝突回避
							[self labelGraphRect:rc  text:NSLocalizedString(@"Graph BMI",nil) color:[UIColor whiteColor]];
							rc.origin.y -= (rcGraphFrame.size.height/4.0);
						}
					}
					[self labelGraphRect:rc text:NSLocalizedString(@"Graph Weight",nil) color:[UIColor darkGrayColor]];
				} else {
					mGvWeight.ppE2records = e2recs;
					mGvWeight.ppPage = mPage;
					mGvWeight.ppRecordWidth = fRw;
					mGvWeight.ppBMI_Tall = mBMI_Tall;
					//mGvWeight.ppFont = ibLbFont.font;
					[mGvWeight setFrame:rcGraphFrame];
					[mGvWeight setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
				
			case EnumConditionTemp:			//------------------------------------------------------体温
				if (mGvTemp==nil) {
					mGvTemp = [[GViewLine alloc] initWithFrame: rcGraphFrame]; // 1値汎用
					mGvTemp.ppE2records = e2recs;
					mGvTemp.ppPage = mPage;
					mGvTemp.ppRecordWidth = fRw;
					//mGvTemp.ppFont = ibLbFont.font;
					mGvTemp.ppEntityKey = E2_nTemp_10c;
					mGvTemp.ppGoalKey = Goal_nTemp_10c;
					mGvTemp.ppDec = 1;
					mGvTemp.ppMin = E2_nTemp_MIN;
					mGvTemp.ppMax = E2_nTemp_MAX;
					[ibScrollView addSubview:mGvTemp];
					[self labelGraphRect:rcGraphFrame  text:NSLocalizedString(@"Graph Temp",nil) color:[UIColor darkGrayColor]];
				} else {
					mGvTemp.ppE2records = e2recs;
					mGvTemp.ppPage = mPage;
					mGvTemp.ppRecordWidth = fRw;
					//mGvTemp.ppFont = ibLbFont.font;
					[mGvTemp setFrame:rcGraphFrame];
					[mGvTemp setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
				
			case EnumConditionPedo:		//------------------------------------------------------歩数
				if (mGvPedo==nil) {
					mGvPedo = [[GViewLine alloc] initWithFrame: rcGraphFrame]; // 1値汎用
					mGvPedo.ppE2records = e2recs;
					mGvPedo.ppPage = mPage;
					mGvPedo.ppRecordWidth = fRw;
					//mGvPedo.ppFont = ibLbFont.font;
					mGvPedo.ppEntityKey = E2_nPedometer;
					mGvPedo.ppGoalKey = Goal_nPedometer;
					mGvPedo.ppDec = 0;
					mGvPedo.ppMin = E2_nPedometer_MIN;
					mGvPedo.ppMax = E2_nPedometer_MAX;
					[ibScrollView addSubview:mGvPedo];
					[self labelGraphRect:rcGraphFrame  text:NSLocalizedString(@"Graph Pedo",nil) color:[UIColor darkGrayColor]];
				} else {
					mGvPedo.ppE2records = e2recs;
					mGvPedo.ppPage = mPage;
					mGvPedo.ppRecordWidth = fRw;
					//mGvPedo.ppFont = ibLbFont.font;
					[mGvPedo setFrame:rcGraphFrame];
					[mGvPedo setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
				
			case EnumConditionFat:			//------------------------------------------------------体脂肪率
				if (mGvFat==nil) {
					mGvFat = [[GViewLine alloc] initWithFrame: rcGraphFrame]; // 1値汎用
					mGvFat.ppE2records = e2recs;
					mGvFat.ppPage = mPage;
					mGvFat.ppRecordWidth = fRw;
					//mGvFat.ppFont = ibLbFont.font;
					mGvFat.ppEntityKey = E2_nBodyFat_10p;
					mGvFat.ppGoalKey = Goal_nBodyFat_10p;
					mGvFat.ppDec = 1;
					mGvFat.ppMin = E2_nBodyFat_MIN;
					mGvFat.ppMax = E2_nBodyFat_MAX;
					[ibScrollView addSubview:mGvFat];
					[self labelGraphRect:rcGraphFrame  text:NSLocalizedString(@"Graph Fat",nil) color:[UIColor darkGrayColor]];
				} else {
					mGvFat.ppE2records = e2recs;
					mGvFat.ppPage = mPage;
					mGvFat.ppRecordWidth = fRw;
					//mGvFat.ppFont = ibLbFont.font;
					[mGvFat setFrame:rcGraphFrame];
					[mGvFat setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
				
			case EnumConditionSkm:			//------------------------------------------------------骨格筋率
				if (mGvSkm==nil) {
					mGvSkm = [[GViewLine alloc] initWithFrame: rcGraphFrame]; // 1値汎用
					mGvSkm.ppE2records = e2recs;
					mGvSkm.ppPage = mPage;
					mGvSkm.ppRecordWidth = fRw;
					//mGvSkm.ppFont = ibLbFont.font;
					mGvSkm.ppEntityKey = E2_nSkMuscle_10p;
					mGvSkm.ppGoalKey = Goal_nSkMuscle_10p;
					mGvSkm.ppDec = 1;
					mGvSkm.ppMin = E2_nSkMuscle_MIN;
					mGvSkm.ppMax = E2_nSkMuscle_MAX;
					[ibScrollView addSubview:mGvSkm];
					[self labelGraphRect:rcGraphFrame  text:NSLocalizedString(@"Graph Skm",nil) color:[UIColor darkGrayColor]];
				} else {
					mGvSkm.ppE2records = e2recs;
					mGvSkm.ppPage = mPage;
					mGvSkm.ppRecordWidth = fRw;
					[mGvSkm setFrame:rcGraphFrame];
					[mGvSkm setNeedsDisplay]; //drawRect:が呼び出される
				}
				break;
				
			default: //ERROR
				GA_TRACK_EVENT_ERROR(@"LOGIC ERROR No EnumConditions",0);
				assert(NO);
				break;
		}
		rcGraphFrame.origin.y += fHeight;
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
			CGPointMake(ibScrollView.contentSize.width - ibScrollView.bounds.size.width
																					-  ibViewRecord.frame.size.width, 0);
		}
	} 
	else if (afterPageChange < 0) {
		//ー前ページなので左端へ移動
		ibScrollView.contentOffset = CGPointMake(0, 0);
	}

	// アニメ準備
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration: 0.8];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; //Slow at End.
	
	ibScrollView.alpha = 1;

	// アニメ実行
	[UIView commitAnimations];
}

- (void)graphViewPageChange:(NSInteger)pageChange animated:(BOOL)animated
{	// アニメ： 消してから書く
	afterPageChange = pageChange;
	if (animated) {
		ibScrollView.alpha = 0;
		// アニメ準備
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration: 0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; //Slow at End.
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animation_after)]; //アニメーション終了後に呼び出す＜＜setAnimationDelegate必要
	}
	
	// アニメ終了状態
	ibScrollView.alpha = 0;
	[self graphViewPageChange:pageChange];// この中で、mPageが更新される

	if (animated) {
		// アニメ実行
		[UIView commitAnimations];
	} else {
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
	mMocFunc = [MocFunctions sharedMocFunctions]; //mAppDelegate.mocBase; // Read Only
	assert(mMocFunc);
	
	if (iS_iPAD) {
		mPadScale = 1.4;
	} else {
		mPadScale = 1.0;
	}
	
	// listen to our app delegates notification that we might want to refresh our detail view
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(refreshAllViews:) 
												 name:NFM_REFRESH_ALL_VIEWS 
											   object:nil];
	
	ibScrollView.delegate = self; // <UIScrollViewDelegate>
	ibScrollView.directionalLockEnabled = YES;
	ibScrollView.pagingEnabled = NO;
	ibScrollView.alpha = 0;
	
	if (mActIndicator==nil) {
		mActIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		mActIndicator.frame = CGRectMake(0, 0, 50, 50);
		[mActIndicator stopAnimating];
		[ibScrollView addSubview:mActIndicator];
	}

	if (mSliderOneWidth==nil) {
		mSliderOneWidth = [[UISlider alloc] init];
		mSliderOneWidth.minimumValue = ONE_WID_MIN;
		mSliderOneWidth.maximumValue = ONE_WID_MAX;
		mSliderOneWidth.continuous = NO; //移動が終わったときだけ通知
		[mSliderOneWidth addTarget:self action:@selector(sliderOneWidth:) 
				  forControlEvents:UIControlEventValueChanged];
		[self.view addSubview:mSliderOneWidth];
	}
}

- (void)sliderOneWidth:(UISlider*)sender
{
	CGRect rc = ibViewRecord.frame;
	rc.size.width = sender.value * mPadScale;
	rc.origin.x = (self.view.frame.size.width - rc.size.width) / 2.0;
	ibViewRecord.frame = rc;
	// 再描画
	[self graphViewPageChange:0  animated:YES];
	//
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	[kvs setObject:[NSNumber numberWithInteger:(NSInteger)sender.value] forKey:KVS_SettGraphOneWid];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];

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

	// BMI
	mBMI_Tall = [[kvs objectForKey:KVS_SettGraphBMITall] integerValue];
	if (mBMI_Tall < Graph_BMI_Tall_MIN OR Graph_BMI_Tall_MAX < mBMI_Tall) {
		mBMI_Tall = 0;		//BMI非表示
	}

	if (mSliderOneWidth) {
		//注意// 回転対応のため、同じものが didRotateFromInterfaceOrientation:にもある
		mSliderOneWidth.frame =
					CGRectMake(-14+(self.view.frame.size.width+ONE_WID_MIN*mPadScale)/2.0,
				   0,
				   (ONE_WID_MAX-ONE_WID_MIN)*2.0*mPadScale,
					20);		//幅2倍にして操作しやすくした
		NSInteger iVal = [[kvs objectForKey:KVS_SettGraphOneWid] integerValue];
		if (iVal<ONE_WID_MIN OR ONE_WID_MAX<iVal) {
			iVal = ONE_WID_MIN;
		}
		mSliderOneWidth.value = iVal;
	}
	
	if (mAppDelegate.ppApp_is_unlock==NO) {
		CGRect rc = ibScrollView.frame;	//繰り返し通っても大丈夫なようにすること。
		if (iS_iPAD) {
			rc.size.height = self.view.frame.size.height - rc.origin.y - (66+3);
		} else {
			rc.size.height = self.view.frame.size.height - rc.origin.y - (50+3);
		}
		ibScrollView.frame = rc;
	}
	//NSLog(@"*** self.view.frame.size.width=%.2f", self.view.frame.size.width);
	
	mPageMax = 999; // この時点で最終ページは不明
	mPage = 0;
	[self graphViewPageChange:0  animated:YES];
	//右端へ移動
	ibScrollView.contentOffset = 
	CGPointMake(ibScrollView.contentSize.width - ibScrollView.bounds.size.width, 0);
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	//[mAppDelegate adShow:1];	//[1.0]ScrollView下端を上げてAd表示する
	
	if ([mPanelGraphs count]<1) {
		azAlertBox(NSLocalizedString(@"Graph NoPanel",nil), NSLocalizedString(@"Graph NoPanel detail",nil), @"OK");
		self.navigationController.tabBarController.selectedIndex = 3; // Setting画面へ
		return;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return iS_iPAD OR (interfaceOrientation == UIInterfaceOrientationPortrait);
	//return YES; //[0.9]ヨコにすると「血圧の日変動分布」グラフ表示する
}

- (void)slowHide
{
	// アニメ準備
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration: 0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];	//Slow start.
	// アニメ終了状態
	ibScrollView.alpha = 0;
	
	// アニメ実行
	[UIView commitAnimations];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{	// 回転開始、表示を消す
	[self slowHide];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{	// 回転した後に呼び出される
	//[mAppDelegate adRefresh];
	if (mSliderOneWidth) {
		mSliderOneWidth.frame = CGRectMake(-14+(self.view.frame.size.width+ONE_WID_MIN*mPadScale)/2.0, 10,
										   (ONE_WID_MAX-ONE_WID_MIN)*2.0*mPadScale, 20);		//幅2倍にして操作しやすくした
	}
	[self graphViewPageChange:0 animated:YES];	//再描画
}


- (void)viewDidDisappear:(BOOL)animated
{
	[self slowHide];
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
		if (mAppDelegate.ppApp_is_unlock==NO) {
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
			nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
			[self presentModalViewController:nc animated:YES];
			//この呼び出しだと広告が表示されない。多分、下に隠れているのではないかと思う
		}
	}
}


@end
