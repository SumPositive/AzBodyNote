//
//  E2editTVC.m
//  AzBodyNote
//
//  Created by 松山 和正 on 11/10/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "MocEntity.h"
#import "MocFunctions.h"
#import "E2editTVC.h"
#import "E2editCellDial.h"
#import "E2editCellNote.h"
#import <Twitter/TWTweetComposeViewController.h>


#define ALERT_TAG_DeleteE2		901

@implementation E2editTVC
{
	AppDelegate		*appDelegate_;
	MocFunctions				*mocFunc_;
	
	//BOOL			bAddNew_;  >>>>>>>>>  editMode_==0
	BOOL			bEditDate_;
	float				fADBannerY_;	//iAd表示位置のY座標
	
	NSInteger	iPrevBpHi_;
	NSInteger	iPrevBpLo_;
	NSInteger	iPrevPuls_;
	NSInteger	iPrevWeight_;
	NSInteger	iPrevTemp_;
	NSInteger	iPrevPedometer_;
	NSInteger	iPrevBodyFat_;
	NSInteger	iPrevSkMuscle_;
	UIButton		*buDelete_;		// Edit時のみ使用
	NSUbiquitousKeyValueStore *kvsGoal_;

	//ADBannerView		*iAdBanner_;
	//GADBannerView		*adMobView_;
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
		NSArray *arFetch = [mocFunc_ select:E2_ENTITYNAME limit:1 offset:0
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
		NSArray *arFetch = [mocFunc_ select:E2_ENTITYNAME limit:1 offset:0
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
		NSArray *arFetch = [mocFunc_ select:E2_ENTITYNAME limit:1 offset:0
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
		NSArray *arFetch = [mocFunc_ select:E2_ENTITYNAME limit:1 offset:0
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
		NSArray *arFetch = [mocFunc_ select:E2_ENTITYNAME limit:1 offset:0
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
	
	if (moE2edit_.nPedometer==nil) {
		NSArray *arFetch = [mocFunc_ select:E2_ENTITYNAME limit:1 offset:0
									  where:[NSPredicate predicateWithFormat: 
											 E2_nYearMM @" > 200000 AND " 
											 E2_nPedometer @" > 0 AND " 
											 E2_dateTime @" < %@", dateNow]
									   sort:sortDesc]; // 日付降順の先頭から1件抽出
		if ([arFetch count]==1) {
			e2prev = [arFetch objectAtIndex:0];
			iPrevPedometer_= [e2prev.nPedometer integerValue];
		} else {
			iPrevPedometer_ = E2_nPedometer_INIT;
		}
	}
	
	if (moE2edit_.nBodyFat_10p==nil) {
		NSArray *arFetch = [mocFunc_ select:E2_ENTITYNAME limit:1 offset:0
									  where:[NSPredicate predicateWithFormat: 
											 E2_nYearMM @" > 200000 AND " 
											 E2_nBodyFat_10p @" > 0 AND " 
											 E2_dateTime @" < %@", dateNow]
									   sort:sortDesc]; // 日付降順の先頭から1件抽出
		if ([arFetch count]==1) {
			e2prev = [arFetch objectAtIndex:0];
			iPrevBodyFat_= [e2prev.nBodyFat_10p integerValue];
		} else {
			iPrevBodyFat_ = E2_nBodyFat_INIT;
		}
	}
	
	if (moE2edit_.nSkMuscle_10p==nil) {
		NSArray *arFetch = [mocFunc_ select:E2_ENTITYNAME limit:1 offset:0
									  where:[NSPredicate predicateWithFormat: 
											 E2_nYearMM @" > 200000 AND " 
											 E2_nSkMuscle_10p @" > 0 AND " 
											 E2_dateTime @" < %@", dateNow]
									   sort:sortDesc]; // 日付降順の先頭から1件抽出
		if ([arFetch count]==1) {
			e2prev = [arFetch objectAtIndex:0];
			iPrevSkMuscle_= [e2prev.nSkMuscle_10p integerValue];
		} else {
			iPrevSkMuscle_ = E2_nSkMuscle_INIT;
		}
	}
}

- (void)actionClear
{	// 直前値なければ初期値をセットする
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
	moE2edit_.nPedometer = nil;
	moE2edit_.nBodyFat_10p = nil;
	moE2edit_.nSkMuscle_10p = nil;
	[self setE2recordPrev];	// .dateTime より前の値を初期値としてセットする
	
	self.navigationItem.rightBarButtonItem.enabled = NO; // 変更あればYESにする
	[self.tableView reloadData];
}

- (void)actionTweet:(NSString*)message
{
	NSLog(@"actionTweet: message=%@", message);
	TWTweetComposeViewController *tweetVC = [[TWTweetComposeViewController alloc] init];
    [tweetVC setInitialText:message];
    //[tweetVC addImage: [UIImage imageNamed:@"Icon57"]];
    [tweetVC addURL:[NSURL URLWithString: NSLocalizedString(@"Tweet URL",nil)]];
    [self presentModalViewController:tweetVC animated:YES];
	
    tweetVC.completionHandler = ^(TWTweetComposeViewControllerResult res) {
        if (res == TWTweetComposeViewControllerResultDone) {
            NSLog(@"Tweet done");
			GA_TRACK_EVENT(@"E2edit",@"Tweet",@"Done", 0);
        } else if (res == TWTweetComposeViewControllerResultCancelled) {
            NSLog(@"Tweet cancel");
			GA_TRACK_EVENT(@"E2edit",@"Tweet",@"Cancel", 0);
        }
		[self dismissModalViewControllerAnimated:YES]; //これが無いと固まる
	};
}

- (void)actionSave
{
	self.navigationItem.rightBarButtonItem.enabled = NO; // 変更あればYESにする

	if (editMode_==0) { // AddNewのとき
		appDelegate_.app_e2record_count = [mocFunc_ e2record_count];
	/*	if (appDelegate_.app_is_unlock==NO) {
			if (50 < appDelegate_.app_e2record_count) {
				// 告知
				alertBox(	NSLocalizedString(@"Trial Limit",nil), 
								NSLocalizedString(@"Trial Limit msg",nil), 
								NSLocalizedString(@"Roger",nil));
				//if (55 < appDelegate_.app_e2record_count) {
				//	// 禁止
				//	return;  // Cancel しかできない
				//}
			}
		}*/
	}
	
	if (kvsGoal_) {
		[kvsGoal_ setObject:moE2edit_.sNote1				forKey:Goal_sNote1];
		[kvsGoal_ setObject:moE2edit_.sNote2				forKey:Goal_sNote2];
		[kvsGoal_ setObject:moE2edit_.nBpHi_mmHg	forKey:Goal_nBpHi_mmHg];
		[kvsGoal_ setObject:moE2edit_.nBpLo_mmHg	forKey:Goal_nBpLo_mmHg];
		[kvsGoal_ setObject:moE2edit_.nPulse_bpm		forKey:Goal_nPulse_bpm];
		[kvsGoal_ setObject:moE2edit_.nWeight_10Kg	forKey:Goal_nWeight_10Kg];
		[kvsGoal_ setObject:moE2edit_.nTemp_10c		forKey:Goal_nTemp_10c];
		[kvsGoal_ setObject:moE2edit_.nPedometer			forKey:Goal_nPedometer];
		[kvsGoal_ setObject:moE2edit_.nBodyFat_10p		forKey:Goal_nBodyFat_10p];
		[kvsGoal_ setObject:moE2edit_.nSkMuscle_10p	forKey:Goal_nSkMuscle_10p];
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
		
		// TweetおよびEvent用の本文作成
		NSString *zBody = @"";
		if (moE2edit_.nBpHi_mmHg) {
			zBody = [zBody stringByAppendingFormat:@"(%@ %@) ",
					  NSLocalizedString(@"Event BpHi",nil),
					  strValue([moE2edit_.nBpHi_mmHg integerValue], 0)];
		}
		if (moE2edit_.nBpLo_mmHg) {
			zBody = [zBody stringByAppendingFormat:@"(%@ %@) ",
					 NSLocalizedString(@"Event BpLo",nil),
					 strValue([moE2edit_.nBpLo_mmHg integerValue], 0)];
		}
		if (moE2edit_.nPulse_bpm) {
			zBody = [zBody stringByAppendingFormat:@"(%@ %@) ",
					 NSLocalizedString(@"Event Puls",nil),
					 strValue([moE2edit_.nPulse_bpm integerValue], 0)];
		}
		if (moE2edit_.nWeight_10Kg) {
			zBody = [zBody stringByAppendingFormat:@"(%@ %@) ",
					  NSLocalizedString(@"Event Weight",nil),
					  strValue([moE2edit_.nWeight_10Kg integerValue], 1)];
		}
		if (moE2edit_.nTemp_10c) {
			zBody = [zBody stringByAppendingFormat:@"(%@ %@) ",
					  NSLocalizedString(@"Event Temp",nil),
					  strValue([moE2edit_.nTemp_10c integerValue], 1)];
		}
		if (moE2edit_.nPedometer) {
			zBody = [zBody stringByAppendingFormat:@"(%@ %@) ",
					  NSLocalizedString(@"Event Pedo",nil),
					  strValue([moE2edit_.nPedometer integerValue], 0)];
		}
		if (moE2edit_.nBodyFat_10p) {
			zBody = [zBody stringByAppendingFormat:@"(%@ %@) ",
					  NSLocalizedString(@"Event BodyFat",nil),
					  strValue([moE2edit_.nBodyFat_10p integerValue], 1)];
		}
		if (moE2edit_.nSkMuscle_10p) {
			zBody = [zBody stringByAppendingFormat:@"(%@ %@) ",
					  NSLocalizedString(@"Event SkMuscle",nil),
					  strValue([moE2edit_.nSkMuscle_10p integerValue], 1)];
		}
		NSLog(@"actionSave: zBody={%@}", zBody);
		
		// Tweet
/*		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		if ([userDefaults boolForKey:GUD_bTweet]) {
			// Tweet メッセージ作成
			NSString *zTweet = NSLocalizedString(@"Tweet head",nil);
			zTweet = [zTweet stringByAppendingString: zBody];
			zTweet = [zTweet stringByAppendingString: NSLocalizedString(@"Tweet foot",nil)];
			[self actionTweet: zTweet];
		}*/
		
		if (appDelegate_.eventStore) {
			EKEvent *event = nil;
			if (10<[moE2edit_.sEventID length]) {	// 既存につき更新する
				// ID検索  見つからなければ nil
				event = [appDelegate_.eventStore eventWithIdentifier:moE2edit_.sEventID];
			}
			if (event==nil) {	
				// 新規
				event = [EKEvent eventWithEventStore:appDelegate_.eventStore];
			}
			event.title = NSLocalizedString(@"Event Title",nil);
			event.location = moE2edit_.sEquipment;
			event.startDate = moE2edit_.dateTime;
			event.endDate = moE2edit_.dateTime;
			event.notes = zBody;
			// 即保存する
			NSError *error;
			//削除 [appDelegate_.eventStore removeEvent:event span:EKSpanThisEvent error:&error];
			[appDelegate_.eventStore saveEvent:event span:EKSpanThisEvent error:&error]; // 保存
			if (error) {
				GA_TRACK_EVENT_ERROR([error description],0);
				NSLog(@"saveEvent: error={%@}", [error localizedDescription]);
			} else {
				NSLog(@"eventIdentifier={%@}", event.eventIdentifier);
				moE2edit_.sEventID = event.eventIdentifier;
				[mocFunc_ commit];
			}
		}
		
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
		appDelegate_ = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	}
	assert(appDelegate_);
	
	if (!mocFunc_) {
		//  AddNew と Edit が別々に発する rollback の影響を避けるため、別々のContext上で処理する。
		mocFunc_ = appDelegate_.mocBase; // Read Only
	}
	assert(mocFunc_);
	
	// listen to our app delegates notification that we might want to refresh our detail view
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(refreshAllViews:) 
												 name:NFM_REFRESH_ALL_VIEWS
											   object:[[UIApplication sharedApplication] delegate]];

	// iCloud KVS 変更通知を受け取る
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshAllViews:) 
												 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification 
											   object:nil];

	// アクティブになったとき、未保存ならば日時更新する
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(refreshDateTime:) 
												 name:NFM_AppDidBecomeActive
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
				
				NSIndexPath* indexPath = [NSIndexPath indexPathForRow:10 inSection:0];
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
			moE2edit_ = [mocFunc_ insertAutoEntity:E2_ENTITYNAME]; // 一時利用なので後で破棄すること ＜＜SAVEしない
			[kvsGoal_ synchronize]; // iCloud最新同期（取得）
			moE2edit_.sNote1 =				toNil([kvsGoal_ objectForKey:Goal_sNote1]);
			moE2edit_.sNote2 =				toNil([kvsGoal_ objectForKey:Goal_sNote2]);
			moE2edit_.nBpHi_mmHg =	toNil([kvsGoal_ objectForKey:Goal_nBpHi_mmHg]);
			moE2edit_.nBpLo_mmHg =	toNil([kvsGoal_ objectForKey:Goal_nBpLo_mmHg]);
			moE2edit_.nPulse_bpm =		toNil([kvsGoal_ objectForKey:Goal_nPulse_bpm]);
			moE2edit_.nWeight_10Kg = toNil([kvsGoal_ objectForKey:Goal_nWeight_10Kg]);
			moE2edit_.nTemp_10c =		toNil([kvsGoal_ objectForKey:Goal_nTemp_10c]);
			moE2edit_.nPedometer =			toNil([kvsGoal_ objectForKey:Goal_nPedometer]);
			moE2edit_.nBodyFat_10p =		toNil([kvsGoal_ objectForKey:Goal_nBodyFat_10p]);
			moE2edit_.nSkMuscle_10p =	toNil([kvsGoal_ objectForKey:Goal_nSkMuscle_10p]);
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
	 [[aTab objectAtIndex:3] setTitle: NSLocalizedString(@"TabSettings",nil)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	appDelegate_.app_is_AdShow = YES; //これは広告表示可能なViewである。 viewWillAppear:以降で定義すること
	
	if (bEditDate_) {
		// 日付修正から戻ったとき
		bEditDate_ = NO;
	}
	else if (editMode_==0) {
		if (moE2edit_==nil) {
			//
			NSArray *e2recs = [mocFunc_ select: E2_ENTITYNAME		 limit: 0	offset: 0
										 where: [NSPredicate predicateWithFormat: E2_nYearMM @" <= 200000"] // 未確定レコード
										  sort: nil];
			if (0 < [e2recs count]) {
				NSLog(@"AddNew: *** E2_nYearMM <= 200000 *** [e2recs count]=%d", (int)[e2recs count]);
				moE2edit_ = [e2recs objectAtIndex:0]; // AddNew途中のレコードを復帰させる
				GA_TRACK_PAGE(@"E2edit-AddEdit");
				[self refreshDateTime:nil]; // 未保存ならば最新日時にする
				[self setE2recordPrev];		// .dateTime より前の値を初期値としてセットする
			}
			else {
				moE2edit_ = [mocFunc_ insertAutoEntity:E2_ENTITYNAME]; // 新規追加
				GA_TRACK_PAGE(@"E2edit-AddNew");
				// 初期値セット
				[self actionClear];
			}
		}
	}
	else if (kvsGoal_==nil) {
		[self setE2recordPrev];
	}
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if (appDelegate_.adWhirlView) {	// Ad ON
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:1.2];
		if (editMode_) {
			appDelegate_.adWhirlView.frame = CGRectMake(0, 480-50, 320, 50);  // GAD_SIZE_320x50
		} else {
			appDelegate_.adWhirlView.frame = CGRectMake(0, 480-49-50, 320, 50);  // GAD_SIZE_320x50
		}
		appDelegate_.adWhirlView.hidden = NO;
		[UIView commitAnimations];
	}
	
#ifdef DEBUGxxxxxx				// テストデータ生成
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
			E2record *e2 = [mocFunc_ insertAutoEntity:E2_ENTITYNAME];
			
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
#endif
}

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
		if (self.navigationItem.rightBarButtonItem.enabled) {
			alertBox(NSLocalizedString(@"NotSaved",nil), NSLocalizedString(@"NotSaved AddNew",nil), @"OK");
		}
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
/*
- (void)viewDidDisappear:(BOOL)animated
{	// 非表示になった後に呼び出される
    [super viewDidDisappear:animated];
}
*/
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
	
	[super viewDidUnload];
	// この後に loadView ⇒ viewDidLoad ⇒ viewWillAppear がコールされる
}


#pragma mark - refresh
- (void)refreshDateTime:(NSNotification*)note 
{
	if (editMode_==0 && moE2edit_) { // AddNew
		if (self.navigationItem.rightBarButtonItem.enabled==NO) { // 未登録ならば最新日時にする
			moE2edit_.dateTime = [NSDate date];
			[self.tableView reloadData];
		}
	}
}

- (void)refreshAllViews:(NSNotification*)note 
{	// iCloud-CoreData に変更があれば呼び出される
	if ([appDelegate_ app_is_sponsor]==NO) {
		NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
		[kvs synchronize]; // 最新同期
		appDelegate_.app_is_sponsor = [kvs boolForKey:GUD_bPaid];
		if (appDelegate_.app_is_sponsor && appDelegate_.app_is_unlock==NO) {
			appDelegate_.app_is_unlock = YES;
		}
	}
	[self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{	// Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	// Return the number of rows in the section.
	return 10 + 1;  // +1:末尾の余白セル
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
	static NSString *Cid = @"E2editCellNote";  //== Class名に一致させること
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
	static NSString *Cid = @"E2editCellDial";  //== Class名に一致させること
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

/*
- (E2editCellTweet *)cellTweet:(UITableView *)tableView
{
	static NSString *Cid = @"E2editCellTweet";  //== Class名に一致させること
	E2editCellTweet *cell = (E2editCellTweet*)[tableView dequeueReusableCellWithIdentifier:Cid];
	if (cell == nil) {
		UINib *nib = [UINib nibWithNibName:Cid   bundle:nil];
		[nib instantiateWithOwner:self options:nil];
		cell = (E2editCellTweet*)[tableView dequeueReusableCellWithIdentifier:Cid];
		assert(cell);
	}
	return cell;
}
*/

- (UITableViewCell *)cellBlank:(UITableView *)tableView
{	// 余白セル
	static NSString *Cid = @"CellBlank";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cid];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cid];// autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.userInteractionEnabled = NO; // 操作なし
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
			cell.mDialStep = 1;
			cell.mStepperStep = 1;
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
			cell.mDialStep = 1;
			cell.mStepperStep = 1;
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
			cell.mDialStep = 1;
			cell.mStepperStep = 1;
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
			cell.mDialStep = 1;
			cell.mStepperStep = 1;
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
			cell.mDialStep = 1;
			cell.mStepperStep = 1;
			cell.mValuePrev = iPrevTemp_;
			[cell drawRect:cell.frame]; // コンテンツ描画
			return cell;
		}	break;
			
		case 7: {
			E2editCellDial *cell = [self cellDial:tableView];
			cell.ibLbName.text = NSLocalizedString(@"Pedometer Name",nil);
			cell.ibLbDetail.text = NSLocalizedString(@"Pedometer Detail",nil);
			cell.ibLbUnit.text = NSLocalizedString(@"Pedometer Unit",nil);
			cell.Re2record = moE2edit_;
			cell.RzKey = E2_nPedometer;
			cell.mValueMin = E2_nPedometer_MIN;
			cell.mValueMax = E2_nPedometer_MAX;
			cell.mValueDec = 0;
			cell.mDialStep = 10;
			cell.mStepperStep = 1;
			cell.mValuePrev = iPrevPedometer_;
			[cell drawRect:cell.frame]; // コンテンツ描画
			return cell;
		}	break;
			
		case 8: {
			E2editCellDial *cell = [self cellDial:tableView];
			cell.ibLbName.text = NSLocalizedString(@"BodyFat Name",nil);
			cell.ibLbDetail.text = NSLocalizedString(@"BodyFat Detail",nil);
			cell.ibLbUnit.text = @"％";
			cell.Re2record = moE2edit_;
			cell.RzKey = E2_nBodyFat_10p;
			cell.mValueMin = E2_nBodyFat_MIN;
			cell.mValueMax = E2_nBodyFat_MAX;
			cell.mValueDec = 1;
			cell.mDialStep = 1;
			cell.mStepperStep = 1;
			cell.mValuePrev = iPrevBodyFat_;
			[cell drawRect:cell.frame]; // コンテンツ描画
			return cell;
		}	break;
			
		case 9: {
			E2editCellDial *cell = [self cellDial:tableView];
			cell.ibLbName.text = NSLocalizedString(@"SkMuscle Name",nil);
			cell.ibLbDetail.text = NSLocalizedString(@"SkMuscle Detail",nil);
			cell.ibLbUnit.text = @"％";
			cell.Re2record = moE2edit_;
			cell.RzKey = E2_nSkMuscle_10p;
			cell.mValueMin = E2_nSkMuscle_MIN;
			cell.mValueMax = E2_nSkMuscle_MAX;
			cell.mValueDec = 1;
			cell.mDialStep = 1;
			cell.mStepperStep = 1;
			cell.mValuePrev = iPrevSkMuscle_;
			[cell drawRect:cell.frame]; // コンテンツ描画
			return cell;
		}	break;
			
/*		case 10: 
			if (editMode_==0) { // AddNew
				E2editCellTweet *cell = [self cellTweet:tableView];
				[cell drawRect:cell.frame]; // コンテンツ描画
				return cell;
			}
			break;*/
	}
	// 余白部
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
	//NG//self.hidesBottomBarWhenPushed = YES; //以降のタブバーを消す
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


@end
