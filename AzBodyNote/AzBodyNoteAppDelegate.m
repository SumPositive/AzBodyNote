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

@implementation AzBodyNoteAppDelegate
{
	
}
@synthesize window = window_;
@synthesize managedObjectContext = moc_;
@synthesize managedObjectModel = moModel_;
@synthesize persistentStoreCoordinator = persistentStoreCoordinator_;
//@synthesize navigationController = _navigationController;
@synthesize tabBarController = _tabBarController;
//@synthesize mIsUpdate;


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	// Override point for customization after application launch.
/*    UITabBarController *tbc = (UITabBarController *)self.window.rootViewController;
	E2editTVC *e2edit = (E2editTVC *)[tbc.childViewControllers objectAtIndex:0];
	e2edit.managedObjectContext = self.managedObjectContext;

	E2listTVC *e2list = (E2listTVC *)[tbc.childViewControllers objectAtIndex:1];
	e2list.managedObjectContext = self.managedObjectContext;*/
	
/*-----------NG-----
	NSArray *aTab = self.tabBarController.childViewControllers;
	[[aTab objectAtIndex:0] setTitle: NSLocalizedString(@"TabAdd",nil)];
	[[aTab objectAtIndex:1] setTitle: NSLocalizedString(@"TabList",nil)];
	[[aTab objectAtIndex:2] setTitle: NSLocalizedString(@"TabGraph",nil)];
	[[aTab objectAtIndex:3] setTitle: NSLocalizedString(@"TabInfo",nil)];
*/
	
	// Moc初期化
	[MocFunctions setMoc:self.managedObjectContext];
	
	// E2 目標値固有レコードが無ければ追加する
	// E2_nBpHi_mmHg
	NSArray *arFetch = [MocFunctions select:@"E2record" limit:1 offset:0
									  where: [NSPredicate predicateWithFormat: E2_dateTime @" = %@", [MocFunctions dateGoal]]
									   sort: nil];
	if ([arFetch count] != 1) { // 無いので追加する
		E2record *moE2goal = [MocFunctions insertAutoEntity:@"E2record"];
		// 固有日付をセット
		moE2goal.dateTime = [MocFunctions dateGoal];
		moE2goal.nYearMM = [NSNumber numberWithInteger: E2_nYearMM_GOAL];	// 主に、こちらで比較チェックする
		// Save & Commit
		[MocFunctions commit];
	}

    return YES;
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
	[self saveContext];
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



#pragma mark - iCloud

- (void)mergeiCloudChanges:(NSNotification*)note forContext:(NSManagedObjectContext*)moc 
{
    [moc mergeChangesFromContextDidSaveNotification:note]; 
	
    NSNotification* refreshNotification = [NSNotification notificationWithName:@"RefreshAllViews" object:self  userInfo:[note userInfo]];
    
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
}

// NSNotifications are posted synchronously on the caller's thread
// make sure to vector this back to the thread we want, in this case
// the main thread for our views & controller
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification {
	NSManagedObjectContext* moc = [self managedObjectContext];
	
	// this only works if you used NSMainQueueConcurrencyType
	// otherwise use a dispatch_async back to the main thread yourself
	[moc performBlock:^{
        [self mergeiCloudChanges:notification forContext:moc];
    }];
}


#pragma mark - Core Data stack

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
#ifdef ENABLE_iCloud
    NSURL *storeUrl = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AzBodyNote.sqlite"];
	//NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"AzBodyNote.sqlite"];
	//NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	NSLog(@"storeUrl=%@", storeUrl);
	
	// assign the PSC to our app delegate ivar before adding the persistent store in the background
	// this leverages a behavior in Core Data where you can create NSManagedObjectContext and fetch requests
	// even if the PSC has no stores.  Fetch requests return empty arrays until the persistent store is added
	// so it's possible to bring up the UI and then fill in the results later
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	
	if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
		// do this asynchronously since if this is the first time this particular device is syncing with preexisting
		// iCloud content it may take a long long time to download
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSFileManager *fileManager = [NSFileManager defaultManager];
			// Migrate datamodel
			NSDictionary *options = nil;
			// this needs to match the entitlements and provisioning profile
			//@"<individual ID>.<project bundle identifier>"											5C2UYK6F45
			//NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:@"5C2UYK6F45.com.azukid.AzPacking"];
			NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil]; // 自動取得されるようになった。
			NSLog(@"cloudURL=%@", cloudURL);
			NSString* coreDataCloudContent = [[cloudURL path] stringByAppendingPathComponent:@"test"];
			NSLog(@"coreDataCloudContent=%@", coreDataCloudContent);
			
			if (0 < [coreDataCloudContent length]) {
				// iCloud is available
				cloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
				NSLog(@"-- cloudURL=%@", cloudURL);
				
				options = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
						   [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
						   @"AzBodyNote.store", NSPersistentStoreUbiquitousContentNameKey,
						   cloudURL, NSPersistentStoreUbiquitousContentURLKey,
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
				[[NSNotificationCenter defaultCenter] postNotificationName:@"RefetchAllDatabaseData" object:self userInfo:nil];
			});
		});
	} 
	else {	// iOS5より前
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
	
#else
	
    NSURL *storeUrl = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AzBodyNote.sqlite"];
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	/*	options = [NSDictionary dictionaryWithObjectsAndKeys:
	 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,	// 自動移行
	 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,			// 自動マッピング推論して処理
	 nil];																									// NO ならば、「マッピングモデル」を使って移行処理される。
	 */
	
	NSError *error = nil;
	if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
													configuration:nil  URL:storeUrl  options:nil  error:&error])
	{
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
#endif
	
    return persistentStoreCoordinator_;
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (moc_ != nil) {
        return moc_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];

#ifdef ENABLE_iCloud
    if (coordinator != nil) {
		if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
			NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
			
			[moc performBlockAndWait:^{
				// even the post initialization needs to be done within the Block
				[moc setPersistentStoreCoordinator: coordinator];
				[[NSNotificationCenter defaultCenter]addObserver:self 
														selector:@selector(mergeChangesFrom_iCloud:) 
															name:NSPersistentStoreDidImportUbiquitousContentChangesNotification 
														  object:coordinator];
			}];
			[moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy]; // メモリを優先(Def.)
			//[moc setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy]; // ストアを優先
			//[moc setMergePolicy:NSOverwriteMergePolicy]; // 上書き
			moc_ = moc;
        }
		else {	// iOS5より前
            moc_ = [[NSManagedObjectContext alloc] init];
            [moc_ setPersistentStoreCoordinator:coordinator];
        }		
    }
#else
	__managedObjectContext = [[NSManagedObjectContext alloc] init];
	[__managedObjectContext setPersistentStoreCoordinator:coordinator];
#endif
    return moc_;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (moModel_ != nil) {
        return moModel_;
    }

#ifdef ENABLE_iCloud
	moModel_ = [NSManagedObjectModel mergedModelFromBundles:nil];
#else
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AzBodyNote" withExtension:@"momd"];
	 __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
#endif

	return moModel_;
}


#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
