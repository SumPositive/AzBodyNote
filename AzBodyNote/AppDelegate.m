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
//#import "DropboxVC.h"


#define CoreData_iCloud_SYNC		NO		// YES or NO

//@interface AppDelegate (PrivateMethods)
//- (NSManagedObjectContext *)managedObjectContext;
//@end

@implementation AppDelegate
@synthesize window = __window;
@synthesize mocBase = __mocBase;
@synthesize tabBarController = __tabBarController;
//@synthesize adWhirlView = __pAdWhirlView;
//@synthesize app_is_sponsor = __app_is_sponsor;
@synthesize app_is_unlock = __app_is_unlock;
@synthesize app_e2record_count = __app_e2record_count;
//@synthesize app_is_AdShow = __app_is_AdShow;
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
	
	/**[0.9.0]以降、kvsへ移行統一する
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
							[NSNumber numberWithInt:14],	GUD_SettGraphDays,
							 nil];
	[userDefaults registerDefaults:dicDef];	// 未定義のKeyのみ更新される

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
  **/	
	
	// Moc初期化
	if (__mocBase==nil) {
		__mocBase = [[MocFunctions alloc] initWithMoc:[self	 managedObjectContext]]; //iCloud同期に使用される
	}
	// TabBar画面毎にMOCを生成して個別にrollbackしたかったが、MOC間の変更反映が面倒だったので単一に戻した。
	
	// デバイス、ＯＳ確認
	if ([[[UIDevice currentDevice] systemVersion] compare:@"5.0"]==NSOrderedAscending) { // ＜ "5.0"
		// iOS5.0より前
		azAlertBox(@"! STOP !", @"Need more iOS 5.0", nil);
		exit(0);
	}
	//NG//app_is_iPad_ = [[[UIDevice currentDevice] model] hasPrefix:@"iPad"];	// iPad
	//app_is_iPad_ = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
	//NSLog(@"app_is_iPad_=%d,  app_is_Ad_=%d,  __app_is_unlock=%d", app_is_iPad_, app_is_Ad_, __app_is_unlock);

	//  iCloud KVS     [0.9.0]以降、userDefaultsを廃して、kvsへ移行統一
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	if (kvs==nil) {
		GA_TRACK_EVENT_ERROR(@"KVS==nil",0);
	}
	[kvs synchronize]; // 最新同期
	if ([[kvs objectForKey:Goal_nBpHi_mmHg] integerValue] < E2_nBpHi_MIN) {
		// 初期データ追加
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
	
	if ([kvs objectForKey:KVS_SettGraphs]==nil)		//[0.9.0]NEW
	{	// 測定パネル順序設定の初期値				※BpHiの次がBpLoになること。
		NSArray *aPanels = [[NSArray alloc] initWithObjects:
							[NSNumber numberWithInteger: EnumConditionBpHi	* (-1)],		//*(-1):Graph表示する
							[NSNumber numberWithInteger: EnumConditionBpLo	* (-1)],		//*(-1):Graph表示する
							[NSNumber numberWithInteger: EnumConditionPuls	* (-1)],		//*(-1):Graph表示する
							[NSNumber numberWithInteger: EnumConditionNote],
							[NSNumber numberWithInteger: EnumConditionTemp],
							[NSNumber numberWithInteger: EnumConditionWeight],
							[NSNumber numberWithInteger: EnumConditionPedo],
							[NSNumber numberWithInteger: EnumConditionFat],
							[NSNumber numberWithInteger: EnumConditionSkm],
							nil];
		[kvs setObject:aPanels	forKey:KVS_SettGraphs];
		[kvs setBool:NO		forKey:KVS_bTweet];		// YES=新規保存後ツイート
		[kvs setBool:NO		forKey:KVS_bCalender];	// YES=カレンダーへ記録
		[kvs setBool:YES		forKey:KVS_bGoal];			// YES=GOAL表示する
		[kvs setObject:[NSNumber numberWithInt:0]	forKey:KVS_SettStatType];
		[kvs setObject:[NSNumber numberWithInt:5]	forKey:KVS_SettStatDays]; // Free制限:Max=7
		[kvs setBool:YES		forKey:KVS_SettStatAvgShow];	// YES=平均±標準偏差を表示する
		[kvs setBool:NO		forKey:KVS_SettStatTimeLine];	// YES=時系列線で結ぶ
		[kvs setBool:NO		forKey:KVS_SettStat24H_Line];	// YES=24Hourタテ結線する
	}
	
	if (![kvs objectForKey:KVS_Calc_Method])		[kvs setObject:@"0" forKey:KVS_Calc_Method];
	if (![kvs boolForKey:KVS_Calc_Method])			[kvs setBool:YES		forKey:KVS_Calc_Method];

	if (![kvs objectForKey:KVS_SettGraphOneWid])		//[0.10]Graph1本の幅(iPhoneサイズ基準)の初期値
			[kvs setObject:[NSNumber numberWithInt:40] forKey:KVS_SettGraphOneWid];
	
	[kvs synchronize];
	
	if (__app_is_unlock==NO) {
		__app_is_unlock = [kvs boolForKey:STORE_PRODUCTID_UNLOCK];
		//[0.8]以前に対応するため
		if (__app_is_unlock==NO) {
			__app_is_unlock = [kvs boolForKey:@"GUD_bPaid"];  //[0.8]以前の定義
			if (__app_is_unlock==NO) {
				__app_is_unlock = [kvs boolForKey:@"GUD_bUnlock"];  //[0.8]以前の定義
				if (__app_is_unlock==NO) {
					NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
					if (__app_is_unlock==NO) {
						__app_is_unlock = [userDefaults boolForKey:@"GUD_bPaid"];  //[0.8]以前の定義
						if (__app_is_unlock==NO) {
							__app_is_unlock = [userDefaults boolForKey:@"GUD_bUnlock"];  //[0.8]以前の定義
						}
					}
				}
			}
		}
#ifdef DEBUG
		__app_is_unlock = YES;
#endif
		if (__app_is_unlock) {	//登録
			[kvs setBool:YES forKey:STORE_PRODUCTID_UNLOCK];
			[kvs synchronize]; // plistへ書き出す
		}
	}

	//-------------------------------------------------デバイス、ＯＳ確認
	if ([[[UIDevice currentDevice] systemVersion] compare:@"5.0"]==NSOrderedAscending) { // ＜ "5.0"
		// iOS5.0より前
		GA_TRACK_EVENT_ERROR(@"Need more iOS 5.0",0);
		azAlertBox(@"! STOP !", @"Need more iOS 5.0", nil);
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
	
/*** AZDropboxへ
	// Dropbox
	DBSession* dbSession = [[DBSession alloc]
							 initWithAppKey: DBOX_KEY
							 appSecret: DBOX_SECRET
							 root:kDBRootAppFolder]; // either kDBRootAppFolder or kDBRootDropbox
	if (dbSession==nil) {
		GA_TRACK_EVENT_ERROR(@"dbSession==nil",0);
	}
	[DBSession setSharedSession:dbSession];*/

	if (__app_is_unlock==NO) {
		@try {
			CGRect rc = self.window.rootViewController.view.frame;
			rc.origin.x = 0;
			rc.origin.y = rc.size.height - 50 - 48;
			rc.size.height = 50;
			rc.size.width = 320;
			//--------------------------------------------------------------------------------------------------------- AdMob
			//iPhone//320x50//extern GADAdSize const kGADAdSizeBanner;
			//iPad//468x60//extern GADAdSize const kGADAdSizeFullBanner;
			if (RoAdMobView==nil) {
				RoAdMobView = [[GADBannerView alloc] init];
				RoAdMobView.rootViewController = self.window.rootViewController;
				if (iS_iPAD) {
					RoAdMobView.adUnitID = @"0dc4518b212344a8";	//iPad//体調メモ iPad
				} else {
					RoAdMobView.adUnitID = @"a14ece23da85f5e";	//iPhone//体調メモ
				}
				RoAdMobView.frame = rc;
				RoAdMobView.alpha = 0;
				GADRequest *request = [GADRequest request];
				//[request setTesting:YES];
				[RoAdMobView loadRequest:request];	
				[self.window.rootViewController.view addSubview:RoAdMobView];
			}
			//--------------------------------------------------------------------------------------------------------- iAd
			//iPhone//320x50//480x32//
			//iPad//768x66//1024x66//
			// iOS5.0以降のみ
			assert(NSClassFromString(@"ADBannerView"));
			RiAdBanner = [[ADBannerView alloc] initWithFrame:CGRectZero];
			RiAdBanner.delegate = self;
			RiAdBanner.requiredContentSizeIdentifiers = [NSSet setWithObjects:
														 ADBannerContentSizeIdentifierPortrait,
														 ADBannerContentSizeIdentifierLandscape, nil];
			RiAdBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
			RiAdBanner.frame = rc;
			RiAdBanner.alpha = 0;
			[self.window.rootViewController.view addSubview:RiAdBanner];
			bADbannerIsVisible = NO;
			mAdShow = 0;
		}
		@catch (NSException *exception) {
			NSLog(@"Ad Exception: %@: %@", [exception name], [exception reason]);
			GA_TRACK_EVENT_ERROR([exception description],0);
		}
	}
	
	if (__eventStore==nil) {
		__eventStore = [[EKEventStore alloc] init];
		//NSLog(@"[__eventStore calendars]={%@}", [__eventStore calendars]);
		if (__eventStore==nil) {
			GA_TRACK_EVENT_ERROR(@"__eventStore==nil",0);
		}
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
/*	NSString* msg = [NSString stringWithFormat:@"[URL]%@\n[schame]%@\n[Query]%@", 
                     [url absoluteString], [url scheme], [url query]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"debug"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];*/
	
	// Dropbox OAuth 認証キーを取得する
	if ([[DBSession sharedSession] handleOpenURL:url]) { //OAuth結果：urlに認証キーが含まれる
	/*	if ([[DBSession sharedSession] isLinked]) 
		{	// Dropbox 認証成功
            NSLog(@"App linked successfully!");
			// DropboxTVC を開ける
			[self dropboxView];
        }*/
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{	//iOS4: アプリケーションがアクティブでなくなる直前に呼ばれる
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{	//iOS4: アプリケーションがバックグラウンドになったら呼ばれる
	//[self adShow:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{	//iOS4: アプリケーションがバックグラウンドから復帰する直前に呼ばれる
	//[self adShow:YES];
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

- (void)dealloc
{
	__eventStore = nil;

	if (RiAdBanner) {
		[RiAdBanner cancelBannerViewAction];	// 停止
		RiAdBanner.delegate = nil;							// 解放メソッドを呼び出さないように　　　[0.4.1]メモリ不足時に落ちた原因
		[RiAdBanner removeFromSuperview];		// UIView解放		retainCount -1
		RiAdBanner = nil;	// alloc解放			retainCount -1
	}
	
	if (RoAdMobView) {
		RoAdMobView.delegate = nil;  //[0.4.20]受信STOP  ＜＜これが無いと破棄後に呼び出されて落ちる
		RoAdMobView = nil;
	}
}


- (void)awakeFromNib
{
    //E2listTVC *rootViewController = (E2listTVC *)[self.navigationController topViewController];
    //rootViewController.managedObjectContext = self.managedObjectContext;
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
**/
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



#pragma mark - Ad
// iAd取得できたときに呼ばれる　⇒　表示する
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	NSLog(@"=== iAd: bannerViewDidLoadAd ===");
	bADbannerIsVisible = YES; // iAd取得成功（広告内容あり）
	[self adRefresh];
}

// iAd取得できなかったときに呼ばれる　⇒　非表示にする
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	NSLog(@"=== iAd: didFailToReceiveAdWithError ===");
	bADbannerIsVisible = NO; // iAd取得失敗（広告内容なし）
	[self adRefresh];
}

// これは、applicationDidEnterBackground:からも呼び出される
- (void)adShow:(NSInteger)iShow;
{
	NSLog(@"=== adShow: %ld ===", (long)iShow);
	mAdShow = iShow;
	[self adRefresh];
}

- (void)adRefresh
{
	if (__app_is_unlock  OR  RoAdMobView==nil  OR  RiAdBanner==nil) {
		return;  //Adなし
	}
	//NSLog(@"=== adRefresh ===");
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0];

	if (RiAdBanner) {
		if (UIInterfaceOrientationIsPortrait(self.window.rootViewController.interfaceOrientation)) {
			RiAdBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
		} else {
			RiAdBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
		}
	}
	CGRect rc = RiAdBanner.frame;

	if (mAdShow==1) {		// tabBarの上部に表示
		if (UIInterfaceOrientationIsPortrait(self.window.rootViewController.interfaceOrientation)) {
			rc.origin.y = self.window.rootViewController.view.frame.size.height - 48 - RiAdBanner.frame.size.height;
		} else {
			rc.origin.y = self.window.rootViewController.view.frame.size.width - 48 - RiAdBanner.frame.size.height;
		}
	}
	else if (mAdShow==2) {	// 最下部に表示
		if (UIInterfaceOrientationIsPortrait(self.window.rootViewController.interfaceOrientation)) {
			rc.origin.y = self.window.rootViewController.view.frame.size.height - RiAdBanner.frame.size.height;
		} else {
			rc.origin.y = self.window.rootViewController.view.frame.size.width - RiAdBanner.frame.size.height;
		}
	}
	NSLog(@"=== adRefresh === rc.origin.y=%.2f", rc.origin.y);
	
	//iAd
	//iPhone//320x50//480x32//
	//iPad//768x66//1024x66//
	if (RiAdBanner) {
		RiAdBanner.frame = rc;
		if (0<mAdShow && bADbannerIsVisible) {
			RiAdBanner.alpha = 1;
		} else {
			RiAdBanner.alpha = 0;
		}
	}
	
	//AdMob
	//iPhone//320x50//GAD_SIZE_320x50
	//iPad//468x60//GAD_SIZE_468x60
	if (RoAdMobView) {
		if (iS_iPAD) {
			rc.size = GAD_SIZE_468x60;
		} else {
			rc.size = GAD_SIZE_320x50;
		}
		RoAdMobView.frame = rc;
		if (0<mAdShow && (RiAdBanner==nil OR RiAdBanner.alpha==0)) {
			RoAdMobView.alpha = 1;
		} else {
			RoAdMobView.alpha = 0;
		}
	}
	
	[UIView commitAnimations];
}


@end
