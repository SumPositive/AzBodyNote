//
//  AzBodyNoteAppDelegate.m
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//

#import "Global.h"
#import "AzBodyNoteAppDelegate.h"
#import "MocFunctions.h"
#import "E2editTVC.h"
#import "E2listTVC.h"
#import "DropboxVC.h"

//@interface AzBodyNoteAppDelegate (PrivateMethods)
//- (NSManagedObjectContext *)managedObjectContext;
//@end

@implementation AzBodyNoteAppDelegate
{
@private
	NSManagedObjectModel				*moModel_;
	NSPersistentStoreCoordinator		*persistentStoreCoordinator_;
	NSManagedObjectContext				*managedObjectContext_;
	
	BOOL			gud_iCloud_;
}

@synthesize window = window_;
//@synthesize managedObjectContext = managedObjectContext_;
@synthesize mocBase;
@synthesize tabBarController = _tabBarController;
//@synthesize gud_iCloud = gud_iCloud_;

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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	// Override point for customization after application launch.
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	//-------------------------------------------------Setting Defult
	// User Defaultsを使い，キー値を変更したり読み出す前に，NSUserDefaultsクラスのインスタンスメソッド
	// registerDefaultsメソッドを使い，初期値を指定します。
	// ここで，appDefaultsは環境設定で初期値となるキー・バリューペアのNSDictonaryオブジェクトです。
	// このメソッドは，すでに同じキーの環境設定が存在する場合，上書きしないので，環境設定の初期値を定めることに使えます。
	NSDictionary *dicDef = [[NSDictionary alloc] initWithObjectsAndKeys: // 直後にreleaseしている
							@"YES",			GUD_iCloud,
							@"0",				GUD_Calc_Method,					// 0=電卓式(2+2x2=8)　　1=計算式(2+2x2=6)
							@"YES",			GUD_Calc_RoundBankers,		// YES=偶数丸め  NO=四捨五入
							 nil];
	[userDefaults registerDefaults:dicDef];	// 未定義のKeyのみ更新される
	[userDefaults synchronize]; // plistへ書き出す
	//[dicDef release];

	// 画面表示に関係する Option Setting を取得する
	gud_iCloud_ = [userDefaults boolForKey:GUD_iCloud];

	
/*	UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc]
									initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	aiv.frame = CGRectMake(0,0, 50, 50);
	aiv.center = self.window.center;
	[self.window addSubview:aiv];
	[aiv startAnimating];
 */
	
	// Moc初期化
	mocBase = [[MocFunctions alloc] initWithMoc:[self managedObjectContext]]; //iCloud同期に使用される
	// TabBar画面毎にMOCを生成して個別にrollbackしたかったが、MOC間の変更反映が面倒だったので単一に戻した。
	
	// Dropbox
	DBSession* dbSession = [[DBSession alloc]
							 initWithAppKey: DBOX_KEY
							 appSecret: DBOX_SECRET
							 root:kDBRootAppFolder]; // either kDBRootAppFolder or kDBRootDropbox
	[DBSession setSharedSession:dbSession];

    return YES;
}

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
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Saves changes in the application's managed object context before the application terminates.
	//[self saveContext];
}

- (void)dealloc
{
	//[_window release];
	//[__managedObjectContext release];
	//[__managedObjectModel release];
	//[__persistentStoreCoordinator release];
	//[_tabBarController release];
    //[super dealloc];
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
		[self.window.rootViewController presentModalViewController:vc animated:YES];
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
	// E2record 取得
	// Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:NO];
	NSArray *sortDesc = [NSArray arrayWithObjects: sort1,nil]; // 日付降順：Limit抽出に使用
	NSArray *aE2records = [mocBase select: @"E2record"
									limit: 100
								   offset: 0
									where: [NSPredicate predicateWithFormat:E2_nYearMM @" > 200000"] // 未保存を除外する
									 sort: sortDesc]; // 最新日付から抽出
	// NSManagedObject を NSDictionary変換する。　JSON変換できるようにするため
	NSMutableArray *maE2 = [NSMutableArray new];
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
						  @"Header",									@"#class",
						  FILE_HEADER_PREFIX,					@"#header",
						  utcFromDate([NSDate date]),	@"#update",
						  @"1",												@"#version",
						  nil];
	[maE2 addObject:dict];
	// E2record
	for (E2record *e2 in aE2records) {
		//NSLog(@"----- e2=%@", e2);
		@autoreleasepool {
			NSDictionary *dic = [mocBase dictionaryObject:e2];
			if (dic) {
				//NSLog(@"----- ----- dic=%@", dic);
				[maE2 addObject:dic];
			}
		}
	}
	// JSON
	SBJSON	*js = [SBJSON new];
	NSError *err = nil;
	NSString *zJson = [js stringWithObject:maE2 error:&err];
	if (err) {
		NSLog(@"tmpFileSave: SBJSON: stringWithObject: (err=%@) zJson=%@", [err description], zJson);
		return [err description];
	}
	NSLog(@"tmpFileSave: zJson=%@", zJson);
	// 書き出す
	//[zJson writeToFile:zPath atomically:YES]; NG//非推奨になった。
	[zJson writeToFile:[self tmpFilePath] atomically:YES encoding:NSUTF8StringEncoding error:&err];
	if (err) {
		NSLog(@"tmpFileSave: writeToFile: (err=%@)", [err description]);
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
		return [err description];
	}
	NSLog(@"tmpFileLoad: zJson=%@", zJson);
	// JSON
	SBJSON	*js = [SBJSON new];
	NSArray *ary = [js objectWithString:zJson error:&err];
	if (err) {
		NSLog(@"tmpFileLoad: SBJSON: objectWithString: (err=%@) zJson=%@", [err description], zJson);
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
	// E2record 全クリア
	[mocBase deleteAllCoreData];
	// E2record 生成
	for (NSDictionary *dict in ary)
	{
		NSString *zClass = [dict objectForKey:@"#class"];

		if ([zClass isEqualToString:@"E2record"]) {
			[mocBase insertNewObjectForDictionary:dict];
		}
		//else if ([zClass isEqualToString:@"E1body"]) {
		//	[mocBase insertNewObjectForDictionary:dict];
		//}
	}
	// コミット
	[mocBase commit];
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
    if (moModel_ != nil) {
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
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
/*    NSURL *storeUrl = [[self applicationDocumentsDirectory] 
					   URLByAppendingPathComponent:@"azbodynote.sqlite"];	//【重要】リリース後変更禁止
	NSLog(@"storeUrl=%@", storeUrl);*/
	
	NSString *storePath = [[self applicationDocumentsDirectory]
						   stringByAppendingPathComponent:@"azbodynote.sqlite"];	//【重要】リリース後変更禁止
	NSLog(@"storePath=%@", storePath);

	// assign the PSC to our app delegate ivar before adding the persistent store in the background
	// this leverages a behavior in Core Data where you can create NSManagedObjectContext and fetch requests
	// even if the PSC has no stores.  Fetch requests return empty arrays until the persistent store is added
	// so it's possible to bring up the UI and then fill in the results later
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	
	if (gud_iCloud_  &&  IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
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
				//cloudURL = [cloudURL URLByAppendingPathComponent:@"coredata"];
				NSString* coreDataCloudContent = [[cloudURL path] stringByAppendingPathComponent:@"coredata"];
				cloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
				NSLog(@"cloudURL=2=%@", cloudURL);

				options = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
						   [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
						   @"com.azukid.azbodynote.sqlog", NSPersistentStoreUbiquitousContentNameKey,		//【重要】リリース後変更禁止
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
	if (managedObjectContext_ != nil) {
		return managedObjectContext_;
	}
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	NSManagedObjectContext* moc = nil;

    if (coordinator != nil) {
		if (gud_iCloud_  &&  IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
			moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
			
			[moc performBlockAndWait:^{
				// even the post initialization needs to be done within the Block
				[moc setPersistentStoreCoordinator: coordinator];
				
				//[moc setMergePolicy:NSOverwriteMergePolicy]; // 上書き
				//[moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy]; // 変更した方を優先(Def.)
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

@end
