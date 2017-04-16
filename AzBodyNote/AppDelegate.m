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


@implementation AppDelegate

@synthesize window = __Window;
@synthesize ppTabBarController = __TabBarController;
@synthesize ppApp_is_unlock = __App_is_unlock;
@synthesize ppApp_e2record_count = __App_e2record_count;
@synthesize ppApp_is_iPad = __App_is_iPad;	//readonlyを更新するため
@synthesize ppEventStore = __EventStore;

//考察// self.ppEventStore: set,getが使用される
//考察// __EventStore: 直接アクセス



#pragma mark - alertProgressOn/Off

- (void)alertProgressOff
{
	[mAlertIndicator stopAnimating];
	[mAlertProgress dismissWithClickedButtonIndex:mAlertProgress.cancelButtonIndex animated:YES];
}

- (void)alertProgressOn:(NSString*)zTitle
{
	if (mAlertProgress==nil) {
		// alertIndicatorOn/Off: のための準備
		mAlertProgress = [[UIAlertView alloc] initWithTitle:zTitle  message:@" " delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
		mAlertIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		//alertIndicator_.frame = CGRectMake(320/2, 0, 50, 50);
		[mAlertProgress  addSubview:mAlertIndicator];
	}

	[mAlertProgress setTitle:zTitle];
	[mAlertProgress show];
	
	/*
	NSLog(@"*** frame  x=%f  y=%f  width=%f  height=%f", alertProgress_.frame.origin.x, alertProgress_.frame.origin.y,
		  alertProgress_.frame.size.width, alertProgress_.frame.size.height);
	*/
	 NSLog(@"*** bounds  x=%f  y=%f  width=%f  height=%f", mAlertProgress.bounds.origin.x, mAlertProgress.bounds.origin.y,
		  mAlertProgress.bounds.size.width, mAlertProgress.bounds.size.height);

	// タイトルが変わるとサイズが変わり、インジケータの位置が変わるため、毎回以下の処理する必要あり
	[mAlertIndicator setFrame:CGRectMake((	mAlertProgress.bounds.size.width-50)/2, 
																		mAlertProgress.bounds.size.height-75, 50, 50)];
	[mAlertIndicator startAnimating];
}



#pragma mark - Application

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	// Override point for customization after application launch.
//	GA_INIT_TRACKER(@"UA-30305032-4", 10, nil);	//-4:Condition
//	GA_TRACK_EVENT(@"Device", @"model", [[UIDevice currentDevice] model], 0);
//	GA_TRACK_EVENT(@"Device", @"systemVersion", [[UIDevice currentDevice] systemVersion], 0);

	mAzukiUnlock = NO;	// YES=購入意思ありと見なしてUnlockする
	
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
							[NSNumber numberWithInteger: EnumConditionPuls],
							[NSNumber numberWithInteger: EnumConditionNote],
							[NSNumber numberWithInteger: EnumConditionWeight	* (-1)],	 //*(-1):Graph表示する
							[NSNumber numberWithInteger: EnumConditionTemp],
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
	
	if (![kvs boolForKey:KVS_SettGraphBpMean])	[kvs setBool:YES		forKey:KVS_SettGraphBpMean]; //平均
	if (![kvs boolForKey:KVS_SettGraphBpPress])	[kvs setBool:YES		forKey:KVS_SettGraphBpPress]; //脈圧
	
	[kvs synchronize];
	
	if (__App_is_unlock==NO) {
		__App_is_unlock = [kvs boolForKey:STORE_PRODUCTID_UNLOCK];
		//[0.8]以前に対応するため
		if (__App_is_unlock==NO) {
			__App_is_unlock = [kvs boolForKey:@"GUD_bPaid"];  //[0.8]以前の定義
			if (__App_is_unlock==NO) {
				__App_is_unlock = [kvs boolForKey:@"GUD_bUnlock"];  //[0.8]以前の定義
				if (__App_is_unlock==NO) {
					NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
					if (__App_is_unlock==NO) {
						__App_is_unlock = [userDefaults boolForKey:@"GUD_bPaid"];  //[0.8]以前の定義
						if (__App_is_unlock==NO) {
							__App_is_unlock = [userDefaults boolForKey:@"GUD_bUnlock"];  //[0.8]以前の定義
						}
					}
				}
			}
		}
#ifdef DEBUG
		__App_is_unlock = YES;
		[kvs setBool:__App_is_unlock forKey:STORE_PRODUCTID_UNLOCK];
		[kvs synchronize]; // plistへ書き出す
#endif
		if (__App_is_unlock) {	//登録
			[kvs setBool:YES forKey:STORE_PRODUCTID_UNLOCK];
			[kvs synchronize]; // plistへ書き出す
		}
	}
	
	// NSUserDefaults
	NSUserDefaults *udef = [NSUserDefaults standardUserDefaults];
	if ([udef objectForKey:UDEF_CalendarID]==nil && [kvs objectForKey:KVS_CalendarID]) 
	{ //1.0.0以前からの移行//CalendarIDはデバイス固有値であるため、UDEF記録に変更
		[udef setObject:[kvs objectForKey:KVS_CalendarID] forKey:UDEF_CalendarID];
		[udef setObject:[kvs objectForKey:KVS_CalendarTitle] forKey:UDEF_CalendarTitle];
		[udef synchronize];
		[kvs removeObjectForKey:KVS_CalendarID];
		[kvs removeObjectForKey:KVS_CalendarTitle];
		[kvs synchronize]; // plistへ書き出す
	}

	
	//-------------------------------------------------デバイス、ＯＳ確認
//	if ([[[UIDevice currentDevice] systemVersion] compare:@"5.0"]==NSOrderedAscending) { // ＜ "5.0"
//		// iOS5.0より前
//		GA_TRACK_EVENT_ERROR(@"Need more iOS 5.0",0);
//		azAlertBox(@"! STOP !", @"Need more iOS 5.0", nil);
//		exit(0);
//	}
	//self.ppApp_is_iPad = これはreadonly属性により更新できない。
	__App_is_iPad = [[[UIDevice currentDevice] model] hasPrefix:@"iPad"];	// iPad


	//-------------------------------------------------カレンダー
	if (__EventStore==nil) {
		//self.ppEventStore = これはreadonly属性により更新できない。
		__EventStore = [[EKEventStore alloc] init];
		if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0"]==NSOrderedAscending) { // ＜ "6.0"
			NSLog(@"[__EventStore calendars]={%@}", [__EventStore calendars]);
		} else {
			NSLog(@"[__EventStore calendarsForEntityType:EKEntityTypeEvent]={%@}", [__EventStore calendarsForEntityType:EKEntityTypeEvent]);
		}
	}
	if (__EventStore==nil) {
		GA_TRACK_ERROR(@"__EventStore==nil");
	}
	
	//-------------------------------------------------Moc初期化	//[1.0]shard化
	[[MocFunctions sharedMocFunctions] initialize];
	
	
#ifdef DEBUGxxxxxxxx
	// DEBUG : 購入テストするため、強制的にFreeモードにする。
	gud_bPaid_ = NO;
	[userDefaults setBool:gud_bPaid_ forKey:GUD_bPaid];
	[userDefaults synchronize]; // plistへ書き出す
	[kvs setBool:gud_bPaid_ forKey:GUD_bPaid];
	[kvs synchronize];
#endif

#ifdef xxxxxxxxxxxxNoAddxxxxxxxxxxxx
	if (__App_is_unlock==NO) {
		@try {
			//--------------------------------------------------------------------------------------------------------- AdMob
			//iPhone//320x50//extern GADAdSize const kGADAdSizeBanner;
			//iPad//468x60//extern GADAdSize const kGADAdSizeFullBanner;
			if (RoAdMobView==nil) {
				if (iS_iPAD) {
					RoAdMobView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeFullBanner];	//468x60
					RoAdMobView.adUnitID = @"0dc4518b212344a8";	//iPad//体調メモ iPad
				} else {
					RoAdMobView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];		//320x50
					RoAdMobView.adUnitID = @"a14ece23da85f5e";	//iPhone//体調メモ
				}
				RoAdMobView.rootViewController = __Window.rootViewController;
				//rc.origin.x = (rc.size.width - RoAdMobView.frame.size.width) / 2.0;
				//RoAdMobView.frame = rc;
				RoAdMobView.alpha = 0;
				GADRequest *request = [GADRequest request];
				//[request setTesting:YES];
				[RoAdMobView loadRequest:request];	
				[__Window.rootViewController.view addSubview:RoAdMobView];
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
			//rc.origin.x = 0;
			//RiAdBanner.frame = rc;
			RiAdBanner.alpha = 0;
			[_Window.rootViewController.view addSubview:RiAdBanner];
			bADbannerIsVisible = NO;
			mAdShow = 0;
		}
		@catch (NSException *exception) {
			NSLog(@"Ad Exception: %@: %@", [exception name], [exception reason]);
			GA_TRACK_EVENT_ERROR([exception description],0);
		}
	}
#endif

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

/*
- (void)adUnload
{
	if (RiAdBanner) {
		RiAdBanner.alpha = 0;
		[RiAdBanner cancelBannerViewAction];	// 停止
		RiAdBanner.delegate = nil;							// 解放メソッドを呼び出さないように　　　[0.4.1]メモリ不足時に落ちた原因
		[RiAdBanner removeFromSuperview];		// UIView解放		retainCount -1
		RiAdBanner = nil;	// alloc解放			retainCount -1
	}
	
	if (RoAdMobView) {
		RoAdMobView.alpha = 0;
		RoAdMobView.delegate = nil;  //[0.4.20]受信STOP  ＜＜これが無いと破棄後に呼び出されて落ちる
		RoAdMobView = nil;
	}
}*/

- (void)dealloc
{
	__EventStore = nil;
	//[self adUnload];
}

- (void)awakeFromNib
{
    //E2listTVC *rootViewController = (E2listTVC *)[self.navigationController topViewController];
    //rootViewController.managedObjectContext = self.managedObjectContext;
}


/**** 件数制限で十分！！！！！　Ad完全撤廃
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
	
	if (iShow < 0) {	// 破棄　　＜＜購入後の処理
		[self adUnload];
	}
}

- (void)adRefresh
{
	if (__App_is_unlock  OR  (RoAdMobView==nil  &&  RiAdBanner==nil)) {
		return;  //Adなし
	}
	//NSLog(@"=== adRefresh ===");
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0];

	CGFloat fHeight;
	CGFloat fWidth;
	if (UIInterfaceOrientationIsPortrait(self.window.rootViewController.interfaceOrientation)) {
		fWidth = self.window.rootViewController.view.frame.size.width;
		fHeight = self.window.rootViewController.view.frame.size.height;
	} else {
		fWidth = self.window.rootViewController.view.frame.size.height;
		fHeight = self.window.rootViewController.view.frame.size.width;
	}

	if (RiAdBanner) {
		//iAd
		//iPhone//320x50//480x32//
		//iPad//768x66//1024x66//
		if (UIInterfaceOrientationIsPortrait(self.window.rootViewController.interfaceOrientation)) {
			RiAdBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
		} else {
			RiAdBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
		}
		CGRect rc = RiAdBanner.frame;
		rc.origin.x = 0;
		switch (mAdShow) {
			case -1:	// 破棄
			case 0:	// 非表示		画面下部へ隠す
				rc.origin.y = fHeight + 100;
				break;
			case 1:	// tabBarの上部に表示
				rc.origin.y = fHeight - 48 - RiAdBanner.frame.size.height;
				break;
			case 2:	// tabBarの最下部に表示
				rc.origin.y = fHeight - RiAdBanner.frame.size.height;
				break;
		}
		RiAdBanner.frame = rc;
		if (0<mAdShow && bADbannerIsVisible) {
			RiAdBanner.alpha = 1;
		} else {
			RiAdBanner.alpha = 0;
		}
	}
	
	if (RoAdMobView) {
		//AdMob
		//iPhone//320x50//GAD_SIZE_320x50
		//iPad//468x60//GAD_SIZE_468x60
		CGRect rc = CGRectZero;
		if (iS_iPAD) {
			rc.size = GAD_SIZE_468x60;
			rc.origin.x = (fWidth - rc.size.width)/2.0;		//中央寄せ
		} else {
			rc.size = GAD_SIZE_320x50;
			rc.origin.x = 0;
		}
		switch (mAdShow) {
			case -1:	// 破棄
			case 0:	// 非表示		画面下部へ隠す
				rc.origin.y = fHeight + 100;
				break;
			case 1:	// tabBarの上部に表示
				rc.origin.y = fHeight - 48 - rc.size.height;
				break;
			case 2:	// tabBarの最下部に表示
				rc.origin.y = fHeight - rc.size.height;
				break;
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
*/

@end
