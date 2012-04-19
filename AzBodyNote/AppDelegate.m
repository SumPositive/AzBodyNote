//
//  AppDelegate.m
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//
#ifdef DEBUG
#import <stdlib.h>		//これをAppDelegate.h 側へ入れるとAppDelegate name 未定義エラー発生した。
#endif

#import "AppDelegate.h"

#import "E2editTVC.h"
#import "E2listTVC.h"
#import "DropboxVC.h"


#define CoreData_iCloud_SYNC		NO	// YES or NO

//@interface AppDelegate (PrivateMethods)
//- (NSManagedObjectContext *)managedObjectContext;
//@end

@implementation AppDelegate
@synthesize window = __window;
@synthesize mocBase = __mocBase;
@synthesize tabBarController = __tabBarController;
@synthesize adWhirlView = __pAdWhirlView;
//@synthesize app_is_sponsor = __app_is_sponsor;
@synthesize app_is_unlock = __app_is_unlock;
@synthesize app_e2record_count = __app_e2record_count;
@synthesize app_is_AdShow = __app_is_AdShow;
@synthesize app_is_iPad = __app_is_iPad;
@synthesize eventStore = __eventStore;

/*
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}
*/

#pragma mark - alertProgressOn/Off

- (void)alertProgressOff
{
	[alertIndicator_ stopAnimating];
	[alertProgress_ dismissWithClickedButtonIndex:alertProgress_.cancelButtonIndex animated:YES];
}

- (void)alertProgressOn:(NSString*)zTitle
{
	if (alertProgress_==nil) {
		// alertIndicatorOn/Off: のための準備
		alertProgress_ = [[UIAlertView alloc] initWithTitle:zTitle  message:@" " delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
		alertIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		//alertIndicator_.frame = CGRectMake(320/2, 0, 50, 50);
		[alertProgress_  addSubview:alertIndicator_];
	}

	[alertProgress_ setTitle:zTitle];
	[alertProgress_ show];
	
	/*
	NSLog(@"*** frame  x=%f  y=%f  width=%f  height=%f", alertProgress_.frame.origin.x, alertProgress_.frame.origin.y,
		  alertProgress_.frame.size.width, alertProgress_.frame.size.height);
	*/
	 NSLog(@"*** bounds  x=%f  y=%f  width=%f  height=%f", alertProgress_.bounds.origin.x, alertProgress_.bounds.origin.y,
		  alertProgress_.bounds.size.width, alertProgress_.bounds.size.height);

	// タイトルが変わるとサイズが変わり、インジケータの位置が変わるため、毎回以下の処理する必要あり
	[alertIndicator_ setFrame:CGRectMake((	alertProgress_.bounds.size.width-50)/2, 
																		alertProgress_.bounds.size.height-75, 50, 50)];
	[alertIndicator_ startAnimating];
}



#pragma mark - Application

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	// Override point for customization after application launch.
	GA_INIT_TRACKER(@"UA-30305032-4", 10, nil);	//-4:Condition
	GA_TRACK_EVENT(@"Device", @"model", [[UIDevice currentDevice] model], 0);
	GA_TRACK_EVENT(@"Device", @"systemVersion", [[UIDevice currentDevice] systemVersion], 0);

	mAzukiUnlock = NO;	// YES=購入意思ありと見なしてUnlockする
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	//-------------------------------------------------Setting Defult
	// User Defaultsを使い，キー値を変更したり読み出す前に，NSUserDefaultsクラスのインスタンスメソッド
	// registerDefaultsメソッドを使い，初期値を指定します。
	// ここで，appDefaultsは環境設定で初期値となるキー・バリューペアのNSDictonaryオブジェクトです。
	// このメソッドは，すでに同じキーの環境設定が存在する場合，上書きしないので，環境設定の初期値を定めることに使えます。
	NSDictionary *dicDef = [[NSDictionary alloc] initWithObjectsAndKeys: // 直後にreleaseしている
							@"0",				GUD_Calc_Method,					// 0=電卓式(2+2x2=8)　　1=計算式(2+2x2=6)
							@"YES",			GUD_Calc_RoundBankers,		// YES=偶数丸め  NO=四捨五入
							@"NO",			STORE_PRODUCTID_UNLOCK,		// YES=AppStore In-App Purchase ProductIdentifier
							@"NO",			GUD_bTweet,							// YES=新規保存後ツイート
							@"YES",			GUD_bGoal,								// YES=GOAL表示する
							@"NO",			GUD_bCalender,						// YES=カレンダーへ記録
							@"NO",			GUD_bGSpread,						// YES=Googleスプレッドへ記録
							 nil];
	[userDefaults registerDefaults:dicDef];	// 未定義のKeyのみ更新される
	
	if ([userDefaults objectForKey:GUD_SettPanels]==nil) 
	{	// 測定パネル順序設定の初期値
		NSArray *aPanels = [[NSArray alloc] initWithObjects:
				   [NSNumber numberWithInteger: AzConditionNote],
				   [NSNumber numberWithInteger: AzConditionBpHi		* (-1)],		//*(-1):Graph表示する
				   [NSNumber numberWithInteger: AzConditionBpLo		* (-1)],
				   [NSNumber numberWithInteger: AzConditionPuls			* (-1)],
				   [NSNumber numberWithInteger: AzConditionTemp		* (-1)],
				   [NSNumber numberWithInteger: AzConditionWeight	* (-1)],
				   [NSNumber numberWithInteger: AzConditionPedo],
				   [NSNumber numberWithInteger: AzConditionFat],
				   [NSNumber numberWithInteger: AzConditionSkm],
				   nil];
		[userDefaults setObject:aPanels forKey:GUD_SettPanels];
	}

	// 画面表示に関係する Option Setting を取得する
	//__app_is_sponsor = [userDefaults boolForKey:STORE_PRODUCTID_UNLOCK]; //GUD_bPaid
	__app_is_unlock = [userDefaults boolForKey:STORE_PRODUCTID_UNLOCK];  //GUD_bUnlock

	//[0.8]以前に対応するため
	if (__app_is_unlock==NO) {
		__app_is_unlock = [userDefaults boolForKey:@"GUD_bPaid"];  //[0.8]以前の定義
		if (__app_is_unlock==NO) {
			__app_is_unlock = [userDefaults boolForKey:@"GUD_bUnlock"];  //[0.8]以前の定義
		}
		// UDへ登録
		[userDefaults setBool:__app_is_unlock forKey:STORE_PRODUCTID_UNLOCK];
	}
	[userDefaults synchronize]; // plistへ書き出す
	
	// Moc初期化
	if (__mocBase==nil) {
		__mocBase = [[MocFunctions alloc] initWithMoc:[self	 managedObjectContext]]; //iCloud同期に使用される
	}
	// TabBar画面毎にMOCを生成して個別にrollbackしたかったが、MOC間の変更反映が面倒だったので単一に戻した。
	
	// デバイス、ＯＳ確認
	if ([[[UIDevice currentDevice] systemVersion] compare:@"5.0"]==NSOrderedAscending) { // ＜ "5.0"
		// iOS5.0より前
		alertBox(@"! STOP !", @"Need more iOS 5.0", nil);
		exit(0);
	}
	//app_is_iPad_ = [[[UIDevice currentDevice] model] hasPrefix:@"iPad"];	// iPad
	//NSLog(@"app_is_iPad_=%d,  app_is_Ad_=%d,  __app_is_unlock=%d", app_is_iPad_, app_is_Ad_, __app_is_unlock);

	//  iCloud KVS 
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	[kvs synchronize]; // 最新同期
	if ([[kvs objectForKey:Goal_nBpHi_mmHg] integerValue] < E2_nBpHi_MIN) {
		// 初期データ追加
		//[kvs setObject:[NSNull null]	forKey:Goal_sNote1]; // Attempt to insert non-property value '<null>' of class 'NSNull'.
		//[kvs setObject:[NSNull null]	forKey:Goal_sNote2];
		[kvs setObject:[NSNumber numberWithInt:120] forKey:Goal_nBpHi_mmHg];
		[kvs setObject:[NSNumber numberWithInt:  80] forKey:Goal_nBpLo_mmHg];
		[kvs setObject:[NSNumber numberWithInt:  65] forKey:Goal_nPulse_bpm];
		[kvs setObject:[NSNumber numberWithInt:650] forKey:Goal_nWeight_10Kg];
		[kvs setObject:[NSNumber numberWithInt:365] forKey:Goal_nTemp_10c];
		[kvs setObject:[NSNumber numberWithInt:E2_nPedometer_INIT] forKey:Goal_nPedometer];
		[kvs setObject:[NSNumber numberWithInt:E2_nBodyFat_INIT] forKey:Goal_nBodyFat_10p];
		[kvs setObject:[NSNumber numberWithInt:E2_nSkMuscle_INIT] forKey:Goal_nSkMuscle_10p];
		[kvs synchronize];
	}
	if (__app_is_unlock==NO) {
		__app_is_unlock = [kvs boolForKey:STORE_PRODUCTID_UNLOCK];
		//[0.8]以前に対応するため
		if (__app_is_unlock==NO) {
			__app_is_unlock = [kvs boolForKey:@"GUD_bPaid"];  //[0.8]以前の定義
			if (__app_is_unlock==NO) {
				__app_is_unlock = [kvs boolForKey:@"GUD_bUnlock"];  //[0.8]以前の定義
			}
		}
		if (__app_is_unlock) {	// UDへ登録
			[userDefaults setBool:YES forKey:STORE_PRODUCTID_UNLOCK];
			[userDefaults synchronize]; // plistへ書き出す
			//[kvs setBool:YES forKey:STORE_PRODUCTID_UNLOCK];  KVSには保存しない ＜＜再インスト時にリセットさせるため
		}
	}

	//-------------------------------------------------デバイス、ＯＳ確認
	if ([[[UIDevice currentDevice] systemVersion] compare:@"5.0"]==NSOrderedAscending) { // ＜ "5.0"
		// iOS5.0より前
		alertBox(@"! STOP !", @"Need more iOS 5.0", nil);
		exit(0);
	}
	__app_is_iPad = [[[UIDevice currentDevice] model] hasPrefix:@"iPad"];	// iPad

	
#ifdef DEBUGxxxxxxxx
	// DEBUG : 購入テストするため、強制的にFreeモードにする。
	gud_bPaid_ = NO;
	[userDefaults setBool:gud_bPaid_ forKey:GUD_bPaid];
	[userDefaults synchronize]; // plistへ書き出す
	[kvs setBool:gud_bPaid_ forKey:GUD_bPaid];
	[kvs synchronize];
#endif
	
	// Dropbox
	DBSession* dbSession = [[DBSession alloc]
							 initWithAppKey: DBOX_KEY
							 appSecret: DBOX_SECRET
							 root:kDBRootAppFolder]; // either kDBRootAppFolder or kDBRootDropbox
	[DBSession setSharedSession:dbSession];

	if (__app_is_unlock==NO) {
		//CGRect rcAd = CGRectMake(0, self.view.frame.size.height-28-50, 320, 50);  // GAD_SIZE_320x50
		//--------------------------------------------------------------------------------------------------------- AdWirl
		if (__pAdWhirlView==nil) {
			__pAdWhirlView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
			__pAdWhirlView.frame = CGRectMake(0, 0, 320, 50);
			//[pTabBarController_.view addSubview:pAdWhirlView_];
			//[self.window addSubview:pAdWhirlView_];
			[__window.rootViewController.view addSubview:__pAdWhirlView];
		}
		
		if ([NSLocalizedString(@"Country2code",nil) isEqualToString:@"ja"])
		{	// これにより ja 以外はパスする
			if (mNendView==nil) {	// AppBank nend
				mNendView = [[NADView alloc] initWithFrame:CGRectMake(0,0,
																	  NAD_ADVIEW_SIZE_320x50.width, NAD_ADVIEW_SIZE_320x50.height)];
				//[nadview setNendID:@"apiKeyを入れてね" spotID:@"広告枠IDを入れてね"];
				[mNendView setNendID:@"f905d0b348963ffc8834ac59465cfd9488ee646e" spotID:@"6949"]; // Condition
				[mNendView setDelegate:self];
				[mNendView setRootViewController:__window.rootViewController];
				[mNendView load:nil];
			}
			if (mMedibaAd==nil) {	// Mediba Ad
				mMedibaAd = [[MasManagerViewController alloc] init];
				//[self.view addSubview:pMedibaAd_.view];
				[mMedibaAd setPosition:kMasMVPosition_bottom];
				mMedibaAd.view.frame = __pAdWhirlView.bounds; //これが無ければ変にスクロールする
				mMedibaAd.auID = @"165123";  // Condition
				[mMedibaAd loadRequest];
			}
		}
	}
	
	if (__eventStore==nil) {
		__eventStore = [[EKEventStore alloc] init];
		//NSLog(@"[__eventStore calendars]={%@}", [__eventStore calendars]);
	}
	
    return YES;
}
/*
- (void)icloud_KvsNotification:(NSNotification*)notification
{
	NSDictionary *dic = [notification userInfo];
	NSLog(@"iCloud KVS userInfo=%@", [dic description]);
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
}*/

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{	// Free と Stable が共存している場合、Free から戻ったとき Stableが呼ばれる。

/*** DEBUG
	NSString* msg = [NSString stringWithFormat:@"[URL]%@\n[schame]%@\n[Query]%@", 
                     [url absoluteString], [url scheme], [url query]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"debug"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show]; */
	
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) 
		{	// Dropbox 認証成功
            NSLog(@"App linked successfully!");
			// DropboxTVC を開ける
			[self dropboxView];
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	//[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	//[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSNotification* refreshNotification = [NSNotification notificationWithName:NFM_AppDidBecomeActive
																		object:self  userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// iCloud KVS 変更通知の待ち受け解放
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)adDealloc
{
	if (mNendView) {
		mNendView.delegate = nil;
		mNendView = nil;
	}
	if (mMedibaAd) {
		mMedibaAd.delegate = nil;
		mMedibaAd = nil;
	}
	if (__pAdWhirlView) {
		__pAdWhirlView.delegate = nil;
		__pAdWhirlView = nil;
	}
}

- (void)dealloc
{
	[self adDealloc];
	__eventStore = nil;
}


- (void)awakeFromNib
{
    //E2listTVC *rootViewController = (E2listTVC *)[self.navigationController topViewController];
    //rootViewController.managedObjectContext = self.managedObjectContext;
}


#pragma mark - Dropbox

- (void)dropboxView
{	// 未認証の場合、認証処理後、AzCalcAppDelegate:handleOpenURL:から呼び出される
	if ([[DBSession sharedSession] isLinked]) 
	{	// Dropbox 認証済み
		// DropboxVC 表示
		DropboxVC *vc = [[DropboxVC alloc] initWithNibName:@"DropboxVC" bundle:nil];
		vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		vc.delegate = self;
		[__window.rootViewController presentModalViewController:vc animated:YES];
	}
	else {
		// Dropbox 未認証
		[[DBSession sharedSession] link];
	}
}


#pragma mark - delegate /tmp/file

- (NSString*)tmpFilePath
{
	NSString *zPath = NSHomeDirectory();
	zPath = [zPath stringByAppendingPathComponent:@"tmp"];	//NG//@"Documents"
	zPath = [zPath stringByAppendingPathComponent:@"json.condition"];
	NSLog(@"zPath=%@", zPath);
	return zPath;
}

#define FILE_HEADER_PREFIX		@"Condition(C)Azukid"

- (NSString*)tmpFileSave;
{	// NSManagedObject を [self tmpFilePath] へ書き出す
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	[kvs synchronize]; // iCloud最新同期（取得）
	// E2record 取得
	// Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:NO];
	NSArray *sortDesc = [NSArray arrayWithObjects: sort1,nil]; // 日付降順：Limit抽出に使用
	NSArray *aE2records = [__mocBase select: E2_ENTITYNAME
									limit: 0
								   offset: 0
									where: [NSPredicate predicateWithFormat:E2_nYearMM @" > 200000"] // 未保存を除外する
									 sort: sortDesc]; // 最新日付から抽出
	// NSManagedObject を NSDictionary変換する。　JSON変換できるようにするため
	NSMutableArray *maE2 = [NSMutableArray new];
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
						  @"Header",									@"#class",
						  FILE_HEADER_PREFIX,					@"#header",
						  utcFromDate([NSDate date]),	@"#update",
						  @"2",												@"#version",
						 //----------------------------------------------------------------------------------  iCloud-KVS
						  toNSNull([kvs objectForKey:Goal_nBpHi_mmHg]),		Goal_nBpHi_mmHg,
						  toNSNull([kvs objectForKey:Goal_nBpLo_mmHg]),		Goal_nBpLo_mmHg,
						  toNSNull([kvs objectForKey:Goal_nPulse_bpm]),			Goal_nPulse_bpm,
						  toNSNull([kvs objectForKey:Goal_nTemp_10c]),			Goal_nTemp_10c,
						  toNSNull([kvs objectForKey:Goal_nWeight_10Kg]),		Goal_nWeight_10Kg,
						  toNSNull([kvs objectForKey:Goal_sEquipment]),			Goal_sEquipment,
						  toNSNull([kvs objectForKey:Goal_sNote1]),					Goal_sNote1,
						  toNSNull([kvs objectForKey:Goal_sNote2]),					Goal_sNote2,
						  //----------[0.9]以下追加
						  toNSNull([kvs objectForKey:Goal_nPedometer]),			Goal_nPedometer,
						  toNSNull([kvs objectForKey:Goal_nBodyFat_10p]),		Goal_nBodyFat_10p,
						  toNSNull([kvs objectForKey:Goal_nSkMuscle_10p]),	Goal_nSkMuscle_10p,
						  //---------------------------------------------------------------------------------- 
						  nil];
	[maE2 addObject:dict];	// #class = "Header"
	// E2record
	for (E2record *e2 in aE2records) {
		//NSLog(@"----- e2=%@", e2);
		@autoreleasepool {
			NSDictionary *dic = [__mocBase dictionaryObject:e2];
			if (dic) {
				//NSLog(@"----- ----- dic=%@", dic);
				[maE2 addObject:dic];	// #class = "E2record"
			}
		}
	}

	// NSArray --> JSON
	DBJSON	*js = [DBJSON new];
	NSError *err = nil;
	NSString *zJson = [js stringWithObject:maE2 error:&err];
	if (err) {
		NSLog(@"tmpFileSave: SBJSON: stringWithObject: (err=%@) zJson=%@", [err description], zJson);
		GA_TRACK_EVENT_ERROR([err description],0);
		return [err description];
	}
	NSLog(@"tmpFileSave: zJson=%@", zJson);
	// 書き出す
	//[zJson writeToFile:zPath atomically:YES]; NG//非推奨になった。
	[zJson writeToFile:[self tmpFilePath] atomically:YES encoding:NSUTF8StringEncoding error:&err];
	if (err) {
		NSLog(@"tmpFileSave: writeToFile: (err=%@)", [err description]);
		GA_TRACK_EVENT_ERROR([err description],0);
		return [err description];
	}
	return nil;
}

- (NSString*)tmpFileLoad;
{	// [self tmpFilePath] から NSManagedObject を読み込む
	NSError *err = nil;
	// 読み込む
	NSString *zJson = [NSString stringWithContentsOfFile:[self tmpFilePath] encoding:NSUTF8StringEncoding error:&err];
	if (err OR zJson==nil) {
		NSLog(@"tmpFileLoad: stringWithContentsOfFile: (err=%@)", [err description]);
		GA_TRACK_EVENT_ERROR([err description],0);
		return [err description];
	}
	NSLog(@"tmpFileLoad: zJson=%@", zJson);
	// JSON --> NSArray
	DBJSON	*js = [DBJSON new];
	NSArray *ary = [js objectWithString:zJson error:&err];
	if (err) {
		NSLog(@"tmpFileLoad: SBJSON: objectWithString: (err=%@) zJson=%@", [err description], zJson);
		GA_TRACK_EVENT_ERROR([err description],0);
		return [err description];
	}
	NSLog(@"tmpFileLoad: ary=%@", ary);
	//
	NSDictionary *dict = [ary objectAtIndex:0]; // Header
	if (![[dict objectForKey:@"#class"] isEqualToString:@"Header"]) {
		NSLog(@"tmpFileLoad: #class ERR: %@", dict);
		return @"NG #class";
	}
	if (![[dict objectForKey:@"#header"] isEqualToString:FILE_HEADER_PREFIX]) {
		NSLog(@"tmpFileLoad: #header ERR: %@", dict);
		return @"NG #header";
	}
	//----------------------------------------------------------------------------------  iCloud-KVS
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	[kvs setObject: toNSNull([dict objectForKey:Goal_nBpHi_mmHg])		forKey:Goal_nBpHi_mmHg];
	[kvs setObject: toNSNull([dict objectForKey:Goal_nBpLo_mmHg])		forKey:Goal_nBpLo_mmHg];
	[kvs setObject: toNSNull([dict objectForKey:Goal_nPulse_bpm])			forKey:Goal_nPulse_bpm];
	[kvs setObject: toNSNull([dict objectForKey:Goal_nTemp_10c])			forKey:Goal_nTemp_10c];
	[kvs setObject: toNSNull([dict objectForKey:Goal_nWeight_10Kg])		forKey:Goal_nWeight_10Kg];
	[kvs setObject: toNSNull([dict objectForKey:Goal_sEquipment])			forKey:Goal_sEquipment];
	[kvs setObject: toNSNull([dict objectForKey:Goal_sNote1])					forKey:Goal_sNote1];
	[kvs setObject: toNSNull([dict objectForKey:Goal_sNote2])					forKey:Goal_sNote2];
	//----------[0.9]以下追加
	[kvs setObject: toNSNull([dict objectForKey:Goal_nPedometer])			forKey:Goal_nPedometer];
	[kvs setObject: toNSNull([dict objectForKey:Goal_nBodyFat_10p])		forKey:Goal_nBodyFat_10p];
	[kvs setObject: toNSNull([dict objectForKey:Goal_nSkMuscle_10p])	forKey:Goal_nSkMuscle_10p];
	[kvs synchronize]; // iCloud最新同期（取得）
	//---------------------------------------------------------------------------------- 

	// E2record 全クリア
	[__mocBase deleteAllCoreData];
	// E2record 生成
	for (NSDictionary *dict in ary)
	{
		NSString *zClass = [dict objectForKey:@"#class"];

		if ([zClass isEqualToString:E2_ENTITYNAME]) {
			[__mocBase insertNewObjectForDictionary:dict];
		}
		//else if ([zClass isEqualToString:@"E1body"]) {
		//	[mocBase insertNewObjectForDictionary:dict];
		//}
	}
	// コミット
	[__mocBase commit];
	// E2 件数
	__app_e2record_count = [__mocBase e2record_count];
	// リフレッシュ通知
    NSNotification* refreshNotification = [NSNotification notificationWithName:NFM_REFRESH_ALL_VIEWS
																		object:self  userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
	return nil;
}


#pragma mark - iCloud

- (void)mergeiCloudChanges:(NSNotification*)notification forContext:(NSManagedObjectContext*)moc 
{
	NSLog(@"mergeiCloudChanges: notification=%@", notification);
    [moc mergeChangesFromContextDidSaveNotification:notification]; 
	
    NSNotification* refreshNotification = [NSNotification notificationWithName:NFM_REFRESH_ALL_VIEWS
																		object:self  userInfo:[notification userInfo]];
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
}

// NSNotifications are posted synchronously on the caller's thread
// make sure to vector this back to the thread we want, in this case
// the main thread for our views & controller
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification
{
	NSManagedObjectContext* moc = [self managedObjectContext];
	// this only works if you used NSMainQueueConcurrencyType
	// otherwise use a dispatch_async back to the main thread yourself
	[moc performBlock:^{
        [self mergeiCloudChanges:notification forContext:moc];
    }];
}


#pragma mark - Core Data stack

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (moModel_) {
        return moModel_;
    }
	
	moModel_ = [NSManagedObjectModel mergedModelFromBundles:nil];
	
	return moModel_;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator_) {
        return persistentStoreCoordinator_;
    }
    
/*    NSURL *storeUrl = [[self applicationDocumentsDirectory] 
					   URLByAppendingPathComponent:@"azbodynote.sqlite"];	//【重要】リリース後変更禁止
	NSLog(@"storeUrl=%@", storeUrl);*/
	
	NSString *storePath = [[self applicationDocumentsDirectory]
						   stringByAppendingPathComponent:@"AzBodyNote.sqlite"];	//【重要】リリース後変更禁止
	NSLog(@"storePath=%@", storePath);

	// assign the PSC to our app delegate ivar before adding the persistent store in the background
	// this leverages a behavior in Core Data where you can create NSManagedObjectContext and fetch requests
	// even if the PSC has no stores.  Fetch requests return empty arrays until the persistent store is added
	// so it's possible to bring up the UI and then fill in the results later
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	
	if (CoreData_iCloud_SYNC  && IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
		// do this asynchronously since if this is the first time this particular device is syncing with preexisting
		// iCloud content it may take a long long time to download
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSFileManager *fileManager = [NSFileManager defaultManager];
			// Migrate datamodel
			NSDictionary *options = nil;
			NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
			// this needs to match the entitlements and provisioning profile
			//@"<individual ID>.<project bundle identifier>"	 
			//@"5C2UYK6F45.com.azukid.*"  ＜＜＜<individual ID>は、<Company ID>と同じ契約固有コード。
			NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil]; //.entitlementsから自動取得されるようになった。
			NSLog(@"cloudURL=1=%@", cloudURL);
			if (cloudURL) {
				// アプリ内のコンテンツ名付加：["coredata"]　＜＜＜変わると共有できない。
				//NSString* coreDataCloudContent = [[cloudURL path] stringByAppendingPathComponent:@"coredata"];
				//cloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
				cloudURL = [cloudURL URLByAppendingPathComponent:@"coredata"];
				NSLog(@"cloudURL=2=%@", cloudURL);

				options = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
						   [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
						   @"com.azukid.AzBodyNote.sqlog", NSPersistentStoreUbiquitousContentNameKey,		//【重要】リリース後変更禁止
						   cloudURL, NSPersistentStoreUbiquitousContentURLKey,													//【重要】リリース後変更禁止
						   nil];
			} else {
				// iCloud is not available
				options = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,	// 自動移行
						   [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,			// 自動マッピング推論して処理
						   nil];																									// NO ならば、「マッピングモデル」を使って移行処理される。
			}			 
			NSLog(@"options=%@", options);
			
			// prep the store path and bundle stuff here since NSBundle isn't totally thread safe
			NSPersistentStoreCoordinator* psc = persistentStoreCoordinator_;
			NSError *error = nil;
			[psc lock];
			if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) 
			{
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
				GA_TRACK_EVENT_ERROR([error description],0);
				abort();
			}
			[psc unlock];
			
			// tell the UI on the main thread we finally added the store and then
			// post a custom notification to make your views do whatever they need to such as tell their
			// NSFetchedResultsController to -performFetch again now there is a real store
			dispatch_async(dispatch_get_main_queue(), ^{
				NSLog(@"asynchronously added persistent store!");
				[[NSNotificationCenter defaultCenter] postNotificationName: NFM_REFETCH_ALL_DATA
																	object:self userInfo:nil];
			});
		});
	} 
	else {	// iOS5より前
		NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
		NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
								 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
								 nil];
		
		NSError *error = nil;
		if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType
														configuration:nil  URL:storeUrl  options:options  error:&error])
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			GA_TRACK_EVENT_ERROR([error description],0);
			abort();
		}
	}
    return persistentStoreCoordinator_;
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
	if (managedObjectContext_) {
		return managedObjectContext_;
	}
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	NSManagedObjectContext* moc = nil;

    if (coordinator != nil) {
		if (CoreData_iCloud_SYNC  && IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
			moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
			
			[moc performBlockAndWait:^{
				// even the post initialization needs to be done within the Block
				[moc setPersistentStoreCoordinator: coordinator];
				
				// 同期がおかしくなったときには、[設定]-[iCloud]-[ストレージとバックアップ]-[ストレージを管理]-[健康日記]-[編集]-[すべて削除] する。
				//[moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy]; // 変更した方を優先(Default)
				//[moc setMergePolicy:NSOverwriteMergePolicy]; // 上書き
				//[moc setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy]; // ストアを優先　＜＜＜ＯＫ
				
				[[NSNotificationCenter defaultCenter]addObserver:self 
														selector:@selector(mergeChangesFrom_iCloud:) 
															name:NSPersistentStoreDidImportUbiquitousContentChangesNotification 
														  object:coordinator];
			}];
        }
		else {	// iOS5より前
            moc = [[NSManagedObjectContext alloc] init];
            [moc setPersistentStoreCoordinator:coordinator];
        }
    }
	//
	managedObjectContext_ = moc;
    return	managedObjectContext_;
}



#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}*/
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark - Ads <AdWhirlDelegate>
- (NSString *)adWhirlApplicationKey
{	//return @"ここにAdwhirl管理画面のアプリのページ上部に記載されているSDK Keyをコピペ";
	return @"68f2b24bfca64225a1553bdbc0b31edc"; // Condition
}

- (UIViewController *)viewControllerForPresentingModalView
{	//return UIWindow.rootViewController;
	NSLog(@"AdWhirl - viewControllerForPresentingModalView");
    return __window.rootViewController;
}

- (void)adWhirlDidReceiveAd:(AdWhirlView *)adWhirlView
{	// 広告を受信したとき
	NSLog(@"AdWhirl - adWhirlDidReceiveAd");
}

- (void)adWhirlDidFailToReceiveAd:(AdWhirlView *)adWhirlView usingBackup:(BOOL)yesOrNo
{	// 広告が無いとき
	NSLog(@"AdWhirl - adWhirlDidFailToReceiveAd");
	//adWhirlView.alpha = 0;
	//adWhirlView.hidden = YES;
}

- (void)performEventAppBank:(AdWhirlView *)adWhirlView 
{	// AppBank nend
	NSLog(@"AdWhirl - performEventAppBank");
	if (mNendView && __app_is_AdShow) {
		[adWhirlView replaceBannerViewWith:mNendView];
	}
}
- (void)nadViewDidFinishLoad:(NADView *)adView
{
	NSLog(@"AppBank nend - nadViewDidFinishLoad");
}

- (void)performEventMedibaAd:(AdWhirlView *)adWhirlView 
{	// Mediba Ad
	NSLog(@"AdWhirl - performEventMedibaAd");
	if (mMedibaAd && __app_is_AdShow) { // これにより ja 以外は、MedibaAd をパスする
		[adWhirlView replaceBannerViewWith:mMedibaAd.view];
	}
}


@end
