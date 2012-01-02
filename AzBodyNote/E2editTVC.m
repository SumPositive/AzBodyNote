//
//  E2editTVC.m
//  AzBodyNote
//
//  Created by 松山 和正 on 11/10/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AzBodyNoteAppDelegate.h"
#import "MocEntity.h"
#import "MocFunctions.h"
#import "E2editTVC.h"
#import "E2editCellDial.h"
#import "E2editCellNote.h"

#define ALERT_TAG_DeleteE2		901

@implementation E2editTVC
{
	AzBodyNoteAppDelegate		*appDelegate_;
	MocFunctions				*mocFunc_;
	
	//BOOL			bAddNew_;  >>>>>>>>>  editMode_==0
	BOOL			bEditDate_;
	float				fADBannerY_;	//iAd表示位置のY座標
	
	NSInteger	iPrevBpHi_;
	NSInteger	iPrevBpLo_;
	NSInteger	iPrevPuls_;
	NSInteger	iPrevWeight_;
	NSInteger	iPrevTemp_;
	UIButton		*buDelete_;		// Edit時のみ使用
	NSUbiquitousKeyValueStore *kvsGoal_;

	ADBannerView		*iAdBanner_;
	GADBannerView		*adMobView_;
}
@synthesize editMode = editMode_;
@synthesize moE2edit = moE2edit_;


#pragma mark - IBAction

- (void)setE2recordPrev
{	// .dateTime より前の値を初期値としてセットする
	assert(moE2edit_);
	E2record	*e2prev;	// 直前のレコード
	// Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:NO];
	NSArray *sortDesc = [[NSArray alloc] initWithObjects:sort1,nil]; // 日付降順：Limit抽出に使用
	//[sort1 release];
	
	// 直前のレコードを取得
	NSDate *dateNow = moE2edit_.dateTime;	 // 現在編集中の日付
	if (dateNow==nil) dateNow = [NSDate date];
	
	if (moE2edit_.nBpHi_mmHg==nil) {
		NSArray *arFetch = [mocFunc_ select:@"E2record" limit:1 offset:0
									  where:[NSPredicate predicateWithFormat: 
											 E2_nYearMM @" > 200000 AND " 
											 E2_nBpHi_mmHg @" > 0 AND " 
											 E2_dateTime @" < %@", dateNow]
									   sort:sortDesc]; // 日付降順の先頭から1件抽出
		if ([arFetch count]==1) {
			e2prev = [arFetch objectAtIndex:0];
			NSLog(@"Re2prev.nBpHi_mmHg=%d", [e2prev.nBpHi_mmHg integerValue]);
			iPrevBpHi_ = [e2prev.nBpHi_mmHg integerValue];
		} else {
			iPrevBpHi_ = E2_nBpHi_INIT;
		}
	}
	
	if (moE2edit_.nBpLo_mmHg==nil) {
		NSArray *arFetch = [mocFunc_ select:@"E2record" limit:1 offset:0
									  where:[NSPredicate predicateWithFormat: 
											 E2_nYearMM @" > 200000 AND " 
											 E2_nBpLo_mmHg @" > 0 AND " 
											 E2_dateTime @" < %@", dateNow]
									   sort:sortDesc]; // 日付降順の先頭から1件抽出
		if ([arFetch count]==1) {
			e2prev = [arFetch objectAtIndex:0];
			iPrevBpLo_ = [e2prev.nBpLo_mmHg integerValue];
		} else {
			iPrevBpLo_ = E2_nBpLo_INIT;
		}
	}
	
	if (moE2edit_.nPulse_bpm==nil) {
		NSArray *arFetch = [mocFunc_ select:@"E2record" limit:1 offset:0
									  where:[NSPredicate predicateWithFormat: 
											 E2_nYearMM @" > 200000 AND " 
											 E2_nPulse_bpm @" > 0 AND " 
											 E2_dateTime @" < %@", dateNow]
									   sort:sortDesc]; // 日付降順の先頭から1件抽出
		if ([arFetch count]==1) {
			e2prev = [arFetch objectAtIndex:0];
			iPrevPuls_ = [e2prev.nPulse_bpm integerValue];
		} else {
			iPrevPuls_ = E2_nPuls_INIT;
		}
	}

	if (moE2edit_.nWeight_10Kg==nil) {
		NSArray *arFetch = [mocFunc_ select:@"E2record" limit:1 offset:0
									  where:[NSPredicate predicateWithFormat: 
											 E2_nYearMM @" > 200000 AND " 
											 E2_nWeight_10Kg @" > 0 AND " 
											 E2_dateTime @" < %@", dateNow]
									   sort:sortDesc]; // 日付降順の先頭から1件抽出
		if ([arFetch count]==1) {
			e2prev = [arFetch objectAtIndex:0];
			iPrevWeight_ = [e2prev.nWeight_10Kg integerValue];
		} else {
			iPrevWeight_ = E2_nWeight_INIT;
		}
	}

	if (moE2edit_.nTemp_10c==nil) {
		NSArray *arFetch = [mocFunc_ select:@"E2record" limit:1 offset:0
									  where:[NSPredicate predicateWithFormat: 
											 E2_nYearMM @" > 200000 AND " 
											 E2_nTemp_10c @" > 0 AND " 
											 E2_dateTime @" < %@", dateNow]
									   sort:sortDesc]; // 日付降順の先頭から1件抽出
		if ([arFetch count]==1) {
			e2prev = [arFetch objectAtIndex:0];
			iPrevTemp_= [e2prev.nTemp_10c integerValue];
		} else {
			iPrevTemp_ = E2_nTemp_INIT;
		}
	}
}

- (void)actionClear
{
	assert(editMode_==0);
	assert(moE2edit_);
	assert(kvsGoal_==nil);

	moE2edit_.dateTime = [NSDate date];
	moE2edit_.nYearMM = [NSNumber numberWithInteger:196300]; // < 200000 : 未確定（AddNew途中）
	moE2edit_.sNote1 = nil;
	moE2edit_.sNote2 = nil;
	moE2edit_.nBpHi_mmHg = nil;
	moE2edit_.nBpLo_mmHg = nil;
	moE2edit_.nPulse_bpm = nil;
	moE2edit_.nWeight_10Kg = nil;
	moE2edit_.nTemp_10c = nil;
	[self setE2recordPrev];	// .dateTime より前の値を初期値としてセットする
	
	self.navigationItem.rightBarButtonItem.enabled = NO; // 変更あればYESにする
	[self.tableView reloadData];
}

- (void)actionSave
{
	self.navigationItem.rightBarButtonItem.enabled = NO; // 変更あればYESにする

	if (kvsGoal_) {
		[kvsGoal_ setObject:moE2edit_.sNote1				forKey:Goal_sNote1];
		[kvsGoal_ setObject:moE2edit_.sNote2				forKey:Goal_sNote2];
		[kvsGoal_ setObject:moE2edit_.nBpHi_mmHg	forKey:Goal_nBpHi_mmHg];
		[kvsGoal_ setObject:moE2edit_.nBpLo_mmHg	forKey:Goal_nBpLo_mmHg];
		[kvsGoal_ setObject:moE2edit_.nPulse_bpm		forKey:Goal_nPulse_bpm];
		[kvsGoal_ setObject:moE2edit_.nTemp_10c		forKey:Goal_nTemp_10c];
		[kvsGoal_ setObject:moE2edit_.nWeight_10Kg	forKey:Goal_nWeight_10Kg];
		[kvsGoal_ synchronize];
		[mocFunc_ rollBack], moE2edit_ = nil;
		[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
	}
	else {
		assert(moE2edit_.dateTime);
		// データ整合処理
		// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
		NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDateComponents* comp = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit
											 fromDate:moE2edit_.dateTime];
		moE2edit_.nYearMM = [NSNumber numberWithInteger:([comp year] * 100 + [comp month])];
		
		// Save & Commit
		[mocFunc_ commit];

		if (editMode_==1) { // Edit mode
			// moE2edit_ ＜＜　Edit mode だから = nil ダメ！
			[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
		} 
		else {
			moE2edit_ = nil;	// viewWillAppear:にて新規生成される
			// List画面に切り替えて、追加行を一時ハイライトする
			self.navigationController.tabBarController.selectedIndex = 1; // List画面へ
		}
	}
}

- (void)actionCancel
{	// Edit mode ONLY
	assert(editMode_ !=0);
	if (kvsGoal_) {
		[mocFunc_ rollBack], moE2edit_ = nil;  // 一時エンティティ
	} else {
		[mocFunc_ rollBack];
		// moE2edit_ ＜＜　Edit mode だから = nil ダメ！
	}
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}

- (void)actionDelete:(UIButton *)button
{
	if (kvsGoal_) return;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Delete E2",nil)
													message: nil
												   delegate: self		// clickedButtonAtIndexが呼び出される
										  cancelButtonTitle: NSLocalizedString(@"Cancel",nil)
										  otherButtonTitles: NSLocalizedString(@"DELETE",nil), nil];
	alert.tag = ALERT_TAG_DeleteE2;
	[alert show];
}


#pragma mark - View lifecycle

//- (id)initWithStyle:(UITableViewStyle)style　　＜＜呼び出されません
//- (id)init　　＜＜呼び出されません

- (void)viewDidLoad
{
    [super viewDidLoad];

	if (!appDelegate_) {
		appDelegate_ = (AzBodyNoteAppDelegate*)[[UIApplication sharedApplication] delegate];
	}
	assert(appDelegate_);
	
	if (!mocFunc_) {
		//  AddNew と Edit が別々に発する rollback の影響を避けるため、別々のContext上で処理する。
		//mocFunc_ = [[MocFunctions alloc] initWithMoc:[appDelegate_ managedObjectContext]];
		mocFunc_ = appDelegate_.mocBase; // Read Only
	}
	assert(mocFunc_);
	
	// listen to our app delegates notification that we might want to refresh our detail view
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(refreshAllViews:) 
												 name:NFM_REFRESH_ALL_VIEWS
											   object:[[UIApplication sharedApplication] delegate]];

	kvsGoal_ = nil;
	switch (editMode_) 
	{
		case 0: //-------------------------------------------------------------------- AddNew
		{
			self.title = NSLocalizedString(@"TabAdd",nil);
			// TableView 背景
			UIImage *imgTile = [UIImage imageNamed:@"Tx-LzBeige320"];
			self.tableView.backgroundColor = [UIColor colorWithPatternImage:imgTile];
			assert(moE2edit_==nil);
			// moE2edit_ は、viewWillAppear:にて生成する。
			// [Clear]ボタンを左側に追加する
			self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
													 initWithTitle:NSLocalizedString(@"Clear",nil)
													 style:UIBarButtonItemStyleBordered 
													 target:self action:@selector(actionClear)];
		}	break;

		case 1: //-------------------------------------------------------------------- Edit
		{
			self.title = NSLocalizedString(@"Modify",nil);
			// TableView 背景
			UIImage *imgTile = [UIImage imageNamed:@"Tx-WdWhite320"];
			self.tableView.backgroundColor = [UIColor colorWithPatternImage:imgTile];
			assert(moE2edit_); // 必須
			
			// [<Back]ボタン表示: 修正あるのにBackしたときはアラート表示してからRollback処理する。
			// [Cancel]ボタンを左側に追加する
			self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
													 initWithTitle:NSLocalizedString(@"Cancel",nil)
													 style:UIBarButtonItemStyleBordered 
													 target:self action:@selector(actionCancel)];
			
			if (!buDelete_) { // [Delete]ボタンを 余白セルに置く
				buDelete_ = [UIButton buttonWithType:UIButtonTypeRoundedRect];
				[buDelete_ setTitle:NSLocalizedString(@"Delete E2",nil) forState:UIControlStateNormal];
				[buDelete_ setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
				[buDelete_ addTarget:self action:@selector(actionDelete:) forControlEvents:UIControlEventTouchUpInside];
				
				NSIndexPath* indexPath = [NSIndexPath indexPathForRow:7 inSection:0];
				CGRect rc = [self.tableView rectForRowAtIndexPath:indexPath];
				rc.size.width /= 2;
				rc.origin.x = rc.size.width / 2;
				rc.origin.y += 10;  //((rc.size.height - 30) / 2);
				rc.size.height = 30;
				buDelete_.frame = rc;
				[self.tableView addSubview:buDelete_];
			}
		}	break;

		case 2: //-------------------------------------------------------------------- Goal Edit
		{
			self.title = NSLocalizedString(@"Modify",nil);
			// TableView 背景
			UIImage *imgTile = [UIImage imageNamed:@"Tx-WdWhite320"];
			self.tableView.backgroundColor = [UIColor colorWithPatternImage:imgTile];
			assert(moE2edit_==nil);
			kvsGoal_ = [NSUbiquitousKeyValueStore defaultStore];
			//moE2edit_ = [[E2record alloc] init]; // MOCで無い！ 一時エンティティ
			moE2edit_ = [mocFunc_ insertAutoEntity:@"E2record"]; // 一時利用なので後で破棄すること ＜＜SAVEしない
			[kvsGoal_ synchronize]; // iCloud最新同期（取得）
			moE2edit_.sNote1 =				toNil([kvsGoal_ objectForKey:Goal_sNote1]);
			moE2edit_.sNote2 =				toNil([kvsGoal_ objectForKey:Goal_sNote2]);
			moE2edit_.nBpHi_mmHg =	toNil([kvsGoal_ objectForKey:Goal_nBpHi_mmHg]);
			moE2edit_.nBpLo_mmHg =	toNil([kvsGoal_ objectForKey:Goal_nBpLo_mmHg]);
			moE2edit_.nPulse_bpm =		toNil([kvsGoal_ objectForKey:Goal_nPulse_bpm]);
			moE2edit_.nWeight_10Kg = toNil([kvsGoal_ objectForKey:Goal_nWeight_10Kg]);
			moE2edit_.nTemp_10c =		toNil([kvsGoal_ objectForKey:Goal_nTemp_10c]);
		}	break;
			
		default:
			assert(NO);
			break;
	}
	
	// SAVEボタンを右側に追加する
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
											  target:self action:@selector(actionSave)];// autorelease];
	self.navigationItem.rightBarButtonItem.enabled = NO; // 変更あればYESにする

	// TableView
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // セル区切り線なし
	
	 NSArray *aTab = self.tabBarController.childViewControllers;
	 [[aTab objectAtIndex:0] setTitle: NSLocalizedString(@"TabAdd",nil)];
	 [[aTab objectAtIndex:1] setTitle: NSLocalizedString(@"TabList",nil)];
	 [[aTab objectAtIndex:2] setTitle: NSLocalizedString(@"TabGraph",nil)];
	 [[aTab objectAtIndex:3] setTitle: NSLocalizedString(@"TabInfo",nil)];
	

	if (appDelegate_.gud_bPaid==NO) {
		//CGRect rcAd = CGRectMake(0, self.view.frame.size.height-self.tabBarController.view.frame.size.height-50, 320, 50);
		CGRect rcAd = CGRectMake(0, self.view.frame.size.height-28-50, 320, 50);  // GAD_SIZE_320x50
		//--------------------------------------------------------------------------------------------------------- AdMob
		if (adMobView_==nil) {
			adMobView_ = [[GADBannerView alloc] init];
			adMobView_.delegate = nil;  // viewWillAppear:から開始するため
			adMobView_.rootViewController = self; //.navigationController;
			adMobView_.adUnitID = AdMobID_BodyNote;
			adMobView_.frame = rcAd;
			// 以上は、GADRequest より先に指定すること。
			GADRequest *request = [GADRequest request];
			//[request setTesting:YES];
			[adMobView_ loadRequest:request];
			adMobView_.alpha = 0;	// 0=非表示　　1=表示　　　// viewWillAppear:から開始するため、ここでは非表示
			adMobView_.tag = 0;		// 0=広告なし　　1=あり　　（iAdを優先表示するために必要）
			//[self.view addSubview:adMobView_];
			[self.navigationController.view addSubview:adMobView_];
		}
		
		//--------------------------------------------------------------------------------------------------------- iAd
		// iAd
		if (iAdBanner_==nil) {
			iAdBanner_ = [[ADBannerView alloc] init];
			// iOS 4.2 以上限定　＜＜以前のOSでは落ちる！！！
			iAdBanner_.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, nil];
			iAdBanner_.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
			iAdBanner_.frame = rcAd;
			iAdBanner_.delegate = nil;  // viewWillAppear:から開始するため
			iAdBanner_.alpha = 0;		// viewWillAppear:から開始するため、ここでは非表示
			//[self.view addSubview:iAdBanner_];
			[self.navigationController.view addSubview:iAdBanner_];
		}
	}
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	if (bEditDate_) {
		// 日付修正から戻ったとき
		bEditDate_ = NO;
	}
	else if (editMode_==0) { // AddNew
		if (moE2edit_==nil) {
			//
			NSArray *e2recs = [mocFunc_ select: @"E2record"		 limit: 0	offset: 0
										 where: [NSPredicate predicateWithFormat: E2_nYearMM @" <= 200000"] // 未確定レコード
										  sort: nil];
			if (0 < [e2recs count]) {
				NSLog(@"AddNew: *** E2_nYearMM <= 200000 *** [e2recs count]=%d", (int)[e2recs count]);
				moE2edit_ = [e2recs objectAtIndex:0]; // AddNew途中のレコードを復帰させる
			} else {
				moE2edit_ = [mocFunc_ insertAutoEntity:@"E2record"]; // 新規追加
				[self actionClear];
			}
		}
		//self.view.alpha = 0; //AddNewのときだけディゾルブ
	}
	else if (kvsGoal_==nil) {
		[self setE2recordPrev];
	}
	
	if (appDelegate_.gud_bPaid==NO && editMode_==0) {	// Editのとき、Ａｄなし
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:1.2];
		if (iAdBanner_.tag==1) {
			iAdBanner_.alpha = 1;
		}
		else if (adMobView_.tag==1) {
			adMobView_.alpha = 1;
		}
		[UIView commitAnimations];
		iAdBanner_.delegate = self;
		adMobView_.delegate = self;
	}
}


#ifdef DEBUGxxxxxx				// テストデータ生成
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// 全データを削除する
	//[mocBase deleteAllCoreData];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		// テストデータを追加する
		// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
		static NSDate *dt = nil;
		if (dt==nil) {
			dt =[NSDate date];
		}
		NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		static int iTotal = 1;
		for (int i=1; i<=100; i++, iTotal++) {
			E2record *e2 = [mocFunc_ insertAutoEntity:@"E2record"];
			
			e2.dateTime = dt;
			NSDateComponents* comp = [calendar components: NSYearCalendarUnit | NSMonthCalendarUnit fromDate:dt];
			e2.nYearMM = [NSNumber numberWithInteger:([comp year] * 100 + [comp month])];
			dt = [dt initWithTimeInterval:-1*24*60*60 sinceDate:dt]; // 1日前
			
			e2.sNote1 = [NSString stringWithFormat:@"(%d)", i];
			e2.sNote2 = [NSString stringWithFormat:@"(%d)", iTotal];
			e2.nBpHi_mmHg =		[NSNumber numberWithInteger:120 - 10 + (rand() % 21)];
			e2.nBpLo_mmHg =	[NSNumber numberWithInteger:  80 - 10 + (rand() % 21)];
			e2.nPulse_bpm =		[NSNumber numberWithInteger:  65 - 10 + (rand() % 21)];
			e2.nWeight_10Kg =	[NSNumber numberWithInteger: 10*i ];
			e2.nTemp_10c =		[NSNumber numberWithInteger:365 -   5 + (rand() % 11)];
		}
		// Save & Commit
		[mocFunc_ commit];
		
		NSLog(@"Test data added!");
		[[NSNotificationCenter defaultCenter] postNotificationName: NFM_REFETCH_ALL_DATA object:self userInfo:nil];
	});
}
#endif

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait); // タテ正面のみ
}

- (void)viewWillDisappear:(BOOL)animated
{	// 非表示になる前に呼び出される
	
	if (bEditDate_) {
		// 日付修正へ遷移
	}
	else if (editMode_==0) {
		// TabBar切替により隠されたとき、中断し、戻ったときに復帰できるようにする
		[mocFunc_ commit]; // 未確定のまま保存し、復帰継続できるようにする
		moE2edit_ = nil; //autorelease
	}
	else if (kvsGoal_) {
		// TabBar切替により隠されたとき、中止してList画面に戻す
		[mocFunc_ rollBack];  // GOAL!用のダミーなので破棄する
		moE2edit_ = nil;
		[self.navigationController popViewControllerAnimated:NO];	// < 前のViewへ戻る
	}
	else {
		// TabBar切替により隠されたとき、中止してList画面に戻す
		[mocFunc_ rollBack];
		// moE2edit_ ＜＜　Edit mode だから = nil ダメ！
		[self.navigationController popViewControllerAnimated:NO];	// < 前のViewへ戻る
	}

    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{	// 非表示になった後に呼び出される
	// TabBar切替では遷移時に消す必要なし。別の NaviView だから。
	if (appDelegate_.gud_bPaid==NO && bEditDate_==NO) {	// EditDateならば隠さない
		iAdBanner_.delegate = nil;
		adMobView_.delegate = nil;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.8];
		iAdBanner_.alpha = 0;
		adMobView_.alpha = 0;
		[UIView commitAnimations];
	}
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoadで生成したObjを解放する。
	//NSLog(@"--- viewDidUnload ---"); 
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if (appDelegate_.gud_bPaid==NO) {
		// ARCによりrelease不要になったが、delegateの解放は必須。
		if (iAdBanner_) {
			[iAdBanner_ cancelBannerViewAction];	// 停止
			iAdBanner_.delegate = nil;							// 解放メソッドを呼び出さないように　　　
			[iAdBanner_ removeFromSuperview];		// UIView解放		retainCount -1
			//[iAdBanner_ release]
			iAdBanner_ = nil;	// alloc解放			retainCount -1
		}
		
		if (adMobView_) {
			adMobView_.delegate = nil;  //受信STOP  ＜＜これが無いと破棄後に呼び出されて落ちる
			//[adMobView_ release], 
			adMobView_ = nil;
		}
	}
	
	[super viewDidUnload];
	// この後に loadView ⇒ viewDidLoad ⇒ viewWillAppear がコールされる
}

/*
- (void)dealloc
{
	[Re2edit_ release], Re2edit_ = nil;
	[super dealloc];
}*/


#pragma mark - iCloud
- (void)refreshAllViews:(NSNotification*)note 
{	// iCloud-CoreData に変更があれば呼び出される
    //if (note) {
		[self.tableView reloadData];
    //}
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{	// Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	// Return the number of rows in the section.
	return 7 + 1;  // +1:末尾の余白セル
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row==0) {
		return 44; // DateTime
	}
    return 88; // Default
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section 
{	// セクションフッタを応答
	if (section==0) {
		return @"(C)2011 Azukid";
	}
	return nil;
} */

- (UITableViewCell *)cellDate:(UITableView *)tableView
{
	static NSString *Cid = @"E2editCellDate";  //== Class名
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cid];
	if (cell == nil) {
		UINib *nib = [UINib nibWithNibName:Cid   bundle:nil];
		[nib instantiateWithOwner:self options:nil];
		cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:Cid];
		assert(cell);
	}
	
	if (kvsGoal_) {  	//if ([moE2edit_.nYearMM integerValue]==E2_nYearMM_GOAL)
		cell.textLabel.text = NSLocalizedString(@"TheGoal Section",nil);
		cell.textLabel.font = [UIFont boldSystemFontOfSize:22];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.userInteractionEnabled = NO; // 操作なし
	}
	else {
		cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.userInteractionEnabled = YES; // 操作あり
		
		NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
		// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
		NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		[fmt setCalendar:calendar];
		if ([[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode] isEqualToString:@"ja"]) 
		{ // 「書式」で変わる。　「言語」でない
			[fmt setDateFormat:@"yyyy年M月d日 EE  HH:mm"];
		}
		else {
			[fmt setDateFormat:@"EE, MMM d, yyyy  HH:mm"];
		}
		if (moE2edit_.dateTime==nil) {
			moE2edit_.dateTime = [NSDate date];
		}
		cell.textLabel.text = [NSString stringWithFormat:@"%@   %@", NSLocalizedString(@"DateTime",nil), 
							   [fmt stringFromDate:moE2edit_.dateTime]];
	}
	return cell;
}

- (E2editCellNote *)cellNote:(UITableView *)tableView
{
	static NSString *Cid = @"E2editCellNote";  //== Class名
	E2editCellNote *cell = (E2editCellNote*)[tableView dequeueReusableCellWithIdentifier:Cid];
	if (cell == nil) {
		UINib *nib = [UINib nibWithNibName:Cid   bundle:nil];
		[nib instantiateWithOwner:self options:nil];
		cell = (E2editCellNote*)[tableView dequeueReusableCellWithIdentifier:Cid];
		assert(cell);
	}
	cell.delegate = self;
	return cell;
}

- (E2editCellDial *)cellDial:(UITableView *)tableView
{
	static NSString *Cid = @"E2editCellDial";  //== Class名
	E2editCellDial *cell = (E2editCellDial*)[tableView dequeueReusableCellWithIdentifier:Cid];
	if (cell == nil) {
		UINib *nib = [UINib nibWithNibName:Cid   bundle:nil];
		[nib instantiateWithOwner:self options:nil];
		cell = (E2editCellDial*)[tableView dequeueReusableCellWithIdentifier:Cid];
		assert(cell);
	}
	cell.delegate = self;
	cell.viewParent = self.navigationController.view;  // CalcをaddSubviewするため
	return cell;
}

- (UITableViewCell *)cellBlank:(UITableView *)tableView
{	// 余白セル
	static NSString *Cid = @"CellBlank";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cid];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cid];// autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    assert(indexPath.section==0);
	switch (indexPath.row) {
		case 0: {
			UITableViewCell *cell = [self cellDate:tableView];
			return cell;
		}	break;
			
		case 1: {
			E2editCellNote *cell = [self cellNote:tableView];
			cell.Re2record = moE2edit_;
			[cell drawRect:cell.frame]; // コンテンツ描画
			return cell;
		}	break;
			
		case 2: {
			E2editCellDial *cell = [self cellDial:tableView];
			cell.ibLbName.text = NSLocalizedString(@"BpHi Name",nil);
			cell.ibLbDetail.text = NSLocalizedString(@"BpHi Detail",nil);
			cell.ibLbUnit.text = @"mmHg";
			cell.Re2record = moE2edit_;
			cell.RzKey = E2_nBpHi_mmHg;
			cell.mValueMin = E2_nBpHi_MIN;
			cell.mValueMax = E2_nBpHi_MAX;
			cell.mValueDec = 0;
			cell.mValueStep = 1;
			cell.mValuePrev = iPrevBpHi_;
			[cell drawRect:cell.frame]; // コンテンツ描画
			return cell;
		}	break;

		case 3: {
			E2editCellDial *cell = [self cellDial:tableView];
			cell.ibLbName.text = NSLocalizedString(@"BpLo Name",nil);
			cell.ibLbDetail.text = NSLocalizedString(@"BpLo Detail",nil);
			cell.ibLbUnit.text = @"mmHg";
			cell.Re2record = moE2edit_;
			cell.RzKey = E2_nBpLo_mmHg;
			cell.mValueMin = E2_nBpLo_MIN;
			cell.mValueMax = E2_nBpLo_MAX;
			cell.mValueDec = 0;
			cell.mValueStep = 1;
			cell.mValuePrev = iPrevBpLo_;
			[cell drawRect:cell.frame]; // コンテンツ描画
			return cell;
		}	break;

		case 4: {
			E2editCellDial *cell = [self cellDial:tableView];
			cell.ibLbName.text = NSLocalizedString(@"Pulse Name",nil);
			cell.ibLbDetail.text = NSLocalizedString(@"Pulse Detail",nil);
			cell.ibLbUnit.text = NSLocalizedString(@"Pulse unit",nil);
			cell.Re2record = moE2edit_;
			cell.RzKey = E2_nPulse_bpm;
			cell.mValueMin = E2_nPuls_MIN;
			cell.mValueMax = E2_nPuls_MAX;
			cell.mValueDec = 0;
			cell.mValueStep = 1;
			cell.mValuePrev = iPrevPuls_;
			[cell drawRect:cell.frame]; // コンテンツ描画
			return cell;
		}	break;

		case 5: {
			E2editCellDial *cell = [self cellDial:tableView];
			cell.ibLbName.text = NSLocalizedString(@"Weight Name",nil);
			cell.ibLbDetail.text = NSLocalizedString(@"Weight Detail",nil);
			cell.ibLbUnit.text = @"Kg";
			cell.Re2record = moE2edit_;
			cell.RzKey = E2_nWeight_10Kg;
			cell.mValueMin = E2_nWeight_MIN;
			cell.mValueMax = E2_nWeight_MAX;
			cell.mValueDec = 1;
			cell.mValueStep = 1;
			cell.mValuePrev = iPrevWeight_;
			[cell drawRect:cell.frame]; // コンテンツ描画
			return cell;
		}	break;
			
		case 6: {
			E2editCellDial *cell = [self cellDial:tableView];
			cell.ibLbName.text = NSLocalizedString(@"Temp Name",nil);
			cell.ibLbDetail.text = NSLocalizedString(@"Temp Detail",nil);
			cell.ibLbUnit.text = @"℃";
			cell.Re2record = moE2edit_;
			cell.RzKey = E2_nTemp_10c;
			cell.mValueMin = E2_nTemp_MIN;
			cell.mValueMax = E2_nTemp_MAX;
			cell.mValueDec = 1;
			cell.mValueStep = 1;
			cell.mValuePrev = iPrevTemp_;
			[cell drawRect:cell.frame]; // コンテンツ描画
			return cell;
		}	break;
}
	return [self cellBlank:tableView];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する
	
    // Navigation logic may go here. Create and push another view controller.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{	// 画面遷移のとき、didSelectRowAtIndexPath:よりも先に呼び出される
	NSLog(@"prepareForSegue: sender=%@", sender);
	NSLog(@"prepareForSegue: segue=%@", segue);
	NSLog(@"prepareForSegue: [segue identifier]=%@", [segue identifier]);
	NSLog(@"prepareForSegue: [segue sourceViewController]=%@", [segue sourceViewController]);
	NSLog(@"prepareForSegue: [segue destinationViewController]=%@", [segue destinationViewController]);
	
	if ([[segue identifier] isEqualToString:@"pushDate"]) // EditDateVC
	{
		EditDateVC *editDate = [segue destinationViewController];
		editDate.delegate = self;	// [Done]にて editDateDone: を呼び出すため
		editDate.CdateSource = moE2edit_.dateTime;
		bEditDate_ = YES;
	}
}


#pragma mark - <EditDateDelegate>
- (void)editDateDone:(id)sender  date:(NSDate*)date
{
	if (date) {
		NSLog(@"editDateDone: date=%@", date);
		moE2edit_.dateTime = date;
		[self setE2recordPrev]; // .dateTime より前の値を初期値としてセットする
		[self.tableView reloadData];
		self.navigationItem.rightBarButtonItem.enabled = YES; // 変更あればYESにする
	}
}

#pragma mark - <delegate>
/*
- (void)buttonSave:(BOOL)pop
{
	static BOOL prev = NO;
	if (pop) {
		self.navigationItem.rightBarButtonItem.enabled = prev;
	} else {
		prev = self.navigationItem.rightBarButtonItem.enabled;
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}*/

- (void)editUpdate
{
	self.navigationItem.rightBarButtonItem.enabled = YES; // 変更あればYESにする
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != 1) return; // Cancel
	// OK
	switch (alertView.tag) 
	{
		case ALERT_TAG_DeleteE2: {	// この記録を削除する
			[mocFunc_ deleteEntity:moE2edit_];
			[mocFunc_ commit];
			[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
		}	break;
	}
}


#pragma mark - iAd <ADBannerViewDelegate>

// iAd取得できたときに呼ばれる　⇒　表示する
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	//if (banner.frame.origin.y < self.view.frame.size.height) return; // 既に表示中
	if (banner.alpha==1) return; // 既に表示中
	NSLog(@"iAd - DidReceive");
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:2.0];
	
	banner.alpha = 1;				// iAd優先
	adMobView_.alpha = 0;
	
	[UIView commitAnimations];
}

// iAd取得できなかったときに呼ばれる　⇒　非表示にする
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	//if (self.view.frame.size.height <= banner.frame.origin.y) return; // 既に隠れている
	if (banner.alpha==0) return; // 既に隠れている
	NSLog(@"iAd - FailToReceive　Error:%@", [error localizedDescription]);
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:2.0];
	
	banner.alpha = 0;
	adMobView_.alpha = adMobView_.tag;
	
	[UIView commitAnimations];
}


#pragma mark - AdMob <GADBannerViewDelegate>

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView 
{	// AdMob 広告あり
	adMobView_.tag = 1;
	if (adMobView_.alpha==1 OR iAdBanner_.alpha==1) return; // 既に非表示 または iAd表示中
	NSLog(@"AdMob - DidReceive");
	// iAd非表示ならば、AdMob表示する
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:2.0];
	adMobView_.alpha = 1;
	[UIView commitAnimations];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error 
{	// AdMob 広告なし
	adMobView_.tag = 0;
	if (adMobView_.alpha==0) return; // 既に非表示
	NSLog(@"AdMob - FailToReceive　Error:%@", [error localizedDescription]);
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:2.0];
	adMobView_.alpha = 0;
	[UIView commitAnimations];
}

@end
