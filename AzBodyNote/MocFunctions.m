//
//  MocFunctions.m
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive @Azukid.com. All rights reserved.
//
#import "MocFunctions.h"

#define ManagedObjectModelFileName @"AzBodyNote"	//AzBodyNote.xcdatamodeld//【重要】リリース後変更禁止
//iCloud Parameters
//#define UBIQUITY_CONTAINER_IDENTIFIER @"5C2UYK6F45.com.azukid.AzBodyNote"
#define UBIQUITY_CONTENT_NAME_KEY @"com.azukid.AzBodyNote.CoreData"


@implementation MocFunctions

//static NSManagedObjectContext *scMoc = nil;

#pragma mark - ＋ クラスメソッド
static MocFunctions	*staticMocFunctions= nil;
+ (MocFunctions *)sharedMocFunctions 
{
	@synchronized(self)
	{	//シングルトン：selfに対する処理が、この間は別のスレッドから行えないようになる。
		if (staticMocFunctions==nil) {
			staticMocFunctions = [[MocFunctions alloc] init];
		}
		return staticMocFunctions;
	}
	return nil;
}

static NSDate *dateGoal_ = nil;
+ (NSDate*)dateGoal
{	// .dateTime のための 固有日付(dateGoal)を求める
	@synchronized(self)
	{	//シングルトン：selfに対する処理が、この間は別のスレッドから行えないようになる。
		if (dateGoal_==nil) {
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			//[df setTimeStyle:NSDateFormatterFullStyle];
			[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss ZZZZ"];
			dateGoal_ = [df dateFromString: E2_dateTime_GOAL];
		}
		NSLog(@"MocFunction: dateGoal_=%@", dateGoal_);
		assert(dateGoal_);
		return dateGoal_;
	}
	return nil;
}


#pragma mark - ー インスタンスメソッド
/*- (void)setMoc:(NSManagedObjectContext *)moc
{
	assert(moc);
	mContext = moc;
}*/
- (void)initialize
{
	//Test for iCloud availability
	if (CoreData_iCloud_SYNC) {
		[[NSBundle mainBundle] bundleIdentifier];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		//miCloudContentURL= [fileManager URLForUbiquityContainerIdentifier:UBIQUITY_CONTAINER_IDENTIFIER];
		miCloudContentURL = [fileManager URLForUbiquityContainerIdentifier:nil]; //=nilで自動取得されるようになった。
		if (miCloudContentURL==nil) {
			GA_TRACK_ERROR(@"miCloudContentURL==nil");
		}
	} else {
		miCloudContentURL = nil;
	}

	mContext = [self managedObjectContext];
	if (mContext==nil) {
		GA_TRACK_ERROR(@"mContext==nil");
	}
}

- (NSManagedObjectContext*)getMoc
{
	return mContext;
}

- (id)insertAutoEntity:(NSString *)zEntityName	// autorelease
{
	assert(mContext);
	// Newが含まれているが、自動解放インスタンスが生成される。
	// 即commitされる。つまり、rollbackやcommitの対象外である。 ＜＜そんなことは無い！ roolback可能 save必要
	return [NSEntityDescription insertNewObjectForEntityForName:zEntityName inManagedObjectContext:mContext];
	// ここで生成されたEntityは、rollBack では削除されない。　Cancel時には、deleteEntityが必要。 ＜＜そんなことは無い！ roolback可能 save必要
}	

- (void)deleteEntity:(NSManagedObject *)entity
{
	if (entity) {
		[mContext deleteObject:entity];	// 即commitされる。つまり、rollbackやcommitの対象外である。 ＜＜そんなことは無い！ roolback可能 save必要
	}
}

- (BOOL)hasChanges		// YES=commit以後に変更あり
{
	return [mContext hasChanges];
}

- (BOOL)commit
{
	assert(mContext);
	// SAVE
	NSError *err = nil;
	if ([mContext hasChanges] && ![mContext  save:&err])
	{
		GA_TRACK_EVENT_ERROR([err description],0);
		//exit(-1);  // Fail
		azAlertBox(NSLocalizedString(@"MOC CommitErr",nil),
				   NSLocalizedString(@"MOC CommitErrMsg",nil),
				   NSLocalizedString(@"Roger",nil));
		return NO;
	}
	return YES;
}


#pragma mark - Undo/Redo Operations
- (void)undo{
    [mContext undo];
	
}
- (void)redo{
    [mContext redo];
}
- (void)rollBack{
    [mContext rollback];
}
- (void)reset{
    [mContext reset];
}


#pragma mark - Search

- (NSUInteger)e2record_count
{
	assert(mContext);
	NSFetchRequest *req = nil;
	@try {
		req = [[NSFetchRequest alloc] init];
		
		// select
		NSEntityDescription *entity = [NSEntityDescription entityForName:E2_ENTITYNAME 
												  inManagedObjectContext:mContext];
		[req setEntity:entity];
		
		// where
		[req setPredicate: [NSPredicate predicateWithFormat: E2_nYearMM @" > 200000"]];
		
		NSError *error = nil;
		NSUInteger count = [mContext countForFetchRequest:req error:&error];
		if (error) {
			NSLog(@"count: Error %@, %@", error, [error userInfo]);
			GA_TRACK_EVENT_ERROR([error localizedDescription],0);
			return 0;
		}
		return count;
	}
	@catch (NSException *errEx) {
		NSLog(@"count @catch:NSException: %@ : %@", [errEx name], [errEx reason]);
		GA_TRACK_EVENT_ERROR([errEx description],0);
	}
	return 0;
}

- (NSArray *)select:(NSString *)zEntity
			  limit:(NSUInteger)iLimit
			 offset:(NSUInteger)iOffset
			  where:(NSPredicate *)predicate
			   sort:(NSArray *)arSort 
{
	assert(mContext);
	NSFetchRequest *req = nil;
	@try {
		req = [[NSFetchRequest alloc] init];
		
		// select
		NSEntityDescription *entity = [NSEntityDescription entityForName:zEntity 
												  inManagedObjectContext:mContext];
		[req setEntity:entity];
		
		// limit	抽出件数制限
		if (0 < iLimit) {
			[req setFetchLimit:iLimit];
		}
		
		// offset
		if (iOffset != 0) {
			[req setFetchOffset:iOffset];
		}
		
		// where
		if (predicate) {
			//NSLog(@"MocFunction: select: where: %@", predicate);
			[req setPredicate:predicate];
		}
		
		// order by
		if (arSort) {
			[req setSortDescriptors:arSort];
		}

		NSError *error = nil;
		NSArray *arFetch = [mContext executeFetchRequest:req error:&error];
		//[req release], req = nil;
		if (error) {
			NSLog(@"select: Error %@, %@", error, [error userInfo]);
			GA_TRACK_EVENT_ERROR([error localizedDescription],0);
			return nil;
		}
		return arFetch; // autorelease
	}
	@catch (NSException *errEx) {
		NSLog(@"select @catch:NSException: %@ : %@", [errEx name], [errEx reason]);
		GA_TRACK_EVENT_ERROR([errEx description],0);
	}
	@finally {
		//[req release], req = nil;
	}
	return nil;
}


- (void)e2delete:(E2record *)e2node
{
	assert(mContext);
	if (e2node==nil) return;
	[mContext deleteObject:e2node]; // 削除
}


// 全データ削除する
- (void)deleteAllCoreData
{
	NSUInteger count = 0;
	
	for (NSEntityDescription *entity in [[[mContext persistentStoreCoordinator] managedObjectModel] entities]) 
	{
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:[NSEntityDescription entityForName:[entity name] inManagedObjectContext:mContext]];
		
		NSArray *temp = [mContext executeFetchRequest:request error:NULL];
		
		if (temp) {
			count += [temp count];
		}
		
		//[request release];
		
		for (NSManagedObject *object in temp) {
			[mContext deleteObject:object];
		}
	}
	NSLog(@"deleteAllCoreData: count=%d", count);
	[self commit];
}


#pragma mark - JSON
#define TYPE_NSDate		@"#date#"

// JSON変換できるようにするため、NSManagedObject を NSDictionary に変換する。 ＜＜関連（リレーション）非対応
- (NSDictionary*)dictionaryObject:(NSManagedObject*)mobj
{
    //self.traversed = YES;　　<<<--配下に自身があるとき無限ループしないためのフラグ　＜＜ありえないので未対応
	NSArray* attributes = [[[mobj entity] attributesByName] allKeys];
    //関連（リレーション）非対応
	//NSArray* relationships = [[[mobj entity] relationshipsByName] allKeys];
    //NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity: [attributes count] + [relationships count] + 1];
	NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity: [attributes count] + 1];

    //[dict setObject:[[mobj class] description] forKey:@"class"]; ＜＜ "NSManagedObject" になる
    [dict setObject:[[mobj entity] name] forKey:@"#class"];
	
	// 属性
    for (NSString* attr in attributes) {
        NSObject* value = [mobj valueForKey:attr];
		
        if ([value isKindOfClass:[NSDate class]]) {		// JSON未定義型に対応するため
			NSDate *dt = (NSDate*)value;
			// NSDate ---> NSString
			// utcFromDate: デフォルトタイムゾーンのNSDate型 を UTC協定世界時 文字列 "2010-12-31T00:00:00" にする
			// Key に Prefix: TYPE_NSDate を付ける
			[dict setObject:utcFromDate(dt) forKey:[TYPE_NSDate stringByAppendingString:attr]];
		}
		else if (value != nil) {
            [dict setObject:value forKey:attr];
        }
    }
    return dict;
	
    /***　関連（リレーション）非対応
    for (NSString* relationship in relationships) {	// 配下を再帰的にdict化する
        NSObject* value = [mobj valueForKey:relationship];
		
        if ([value isKindOfClass:[NSSet class]]) {
            // 対多
            // The core data set holds a collection of managed objects
            NSSet* relatedObjects = (NSSet*) value;
			
            // Our set holds a collection of dictionaries
            NSMutableSet* dictSet = [NSMutableSet setWithCapacity:[relatedObjects count]];
			
            for (NSManagedObject* relatedObject in relatedObjects) {
				[dictSet addObject:[self dictionaryObject:relatedObject]];
            }

            [dict setObject:dictSet forKey:relationship];
        }
        else if ([value isKindOfClass:[NSManagedObject class]]) {
            // 対1
            NSManagedObject* relatedObject = (NSManagedObject*) value;
            [dict setObject:[self dictionaryObject:relatedObject] forKey:relationship];
        }
    }
	***/
}


// JSON変換した NSDictionary から NSManagedObject を生成する。
- (NSManagedObject*)insertNewObjectForDictionary:(NSDictionary*)dict
{
    NSString* class = [dict objectForKey:@"#class"];
	NSManagedObject* newObject;
	@try {
		newObject = [NSEntityDescription insertNewObjectForEntityForName:class inManagedObjectContext:mContext];
	}
	@catch (NSException *exception) {
		NSLog(@"insertNewObjectForDictionary: No class={%@}", class);
		return nil;
	}
	//NSLog(@"#class=%@,  newObject=%@", class, newObject);

    for (NSString* key in dict) 
	{
        NSObject* value = [dict objectForKey:key];
		NSLog(@"key=%@,  value=%@", key, value);
		if (value==nil) {
			continue;
		}
		
		if ([key hasPrefix:@"#"]) {	// JSON未定義型に対応するため
			if ([key isEqualToString:@"#class"]) {
				continue;
			}
			else if ([key hasPrefix:TYPE_NSDate]) {
				// UTC日付文字列 ---> NSDate
				NSString *str = (NSString*)value;
				// dateFromUTC: UTC協定世界時 文字列 "2010-12-31T00:00:00" を デフォルトタイムゾーンのNSDate型にする
				// Prefix: TYPE_NSDate を取り除いてKeyにする
				//ok//NSLog(@"*** dateFromUTC(%@) ==> %@", str, [dateFromUTC(str) description]);  //設定が和暦でも正しい西暦になることを確認した。
				[newObject  setValue:dateFromUTC(str) forKey: [key substringFromIndex:[TYPE_NSDate length]]];
				//ok//NSLog(@"*** newObject.DATE=%@", [newObject valueForKey:[key substringFromIndex:[TYPE_NSDate length]]]);
			}
			else {
				assert(NO);	// 未定義の型
			}
		}
        else if ([value isKindOfClass:[NSDictionary class]]) {
			/***　関連（リレーション）非対応
            // This is a to-one relationship
            NSManagedObject* childObject = [MocFunctions insertNewObjectFromDictionary:(NSDictionary*)value  inContext:mContext];
            [mobj setValue:childObject forKey:key];　***/
        }
        else if ([value isKindOfClass:[NSSet class]]) {
			/***　関連（リレーション）非対応
            // This is a to-many relationship
            NSSet* relatedObjectDictionaries = (NSSet*) value;
            // Get a proxy set that represents the relationship, and add related objects to it.
            // (Note: this is provided by Core Data)
            NSMutableSet* relatedObjects = [mobj mutableSetValueForKey:key];
			
            for (NSDictionary* relatedObjectDict in relatedObjectDictionaries) {
                NSManagedObject* childObject = [MocFunctions insertNewObjectFromDictionary:relatedObjectDict  inContext:mContext];
                [relatedObjects addObject:childObject];
            }***/
        }
        else {  // This is an attribute
			@try {
				[newObject setValue:value forKey:key];
			}
			@catch (NSException *exception) {
				NSLog(@"insertNewObjectForDictionary: No key={%@}", key);
			}
        }
    }
	return newObject;
}




#pragma mark - iCloud

// iCloud完全クリアする　＜＜＜同期矛盾が生じたときや構造変更時に使用
- (void)iCloudAllClear
{
	// iCloudサーバー上のゴミデータ削除
	NSURL *icloudURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
	NSError *err;
	[[NSFileManager defaultManager] removeItemAtURL:icloudURL error:&err];
	if (err) {
		GA_TRACK_ERROR([err localizedDescription])
	} else {
		NSLog(@"iCloud: Removed %@", icloudURL);
	}
}

// NSNotifications are posted synchronously on the caller's thread
// make sure to vector this back to the thread we want, in this case
// the main thread for our views & controller
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification
{
	NSManagedObjectContext* moc = [self managedObjectContext];
	// this only works if you used NSMainQueueConcurrencyType
	// otherwise use a dispatch_async back to the main thread yourself
	//[moc performBlock:^{
	[moc performBlockAndWait:^(void){
		[moc mergeChangesFromContextDidSaveNotification:notification]; //CoreData更新
		
		NSNotification* refreshNotification = [NSNotification notificationWithName:NFM_REFETCH_ALL_DATA
																			object:self  userInfo:[notification userInfo]];
		[[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
    }];
}


#pragma mark - Core Data stack

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (mMocModel) {
        return mMocModel;
    }
	
	//mMocModel = [NSManagedObjectModel mergedModelFromBundles:nil];

	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:ManagedObjectModelFileName withExtension:@"momd"];
    mMocModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	
	return mMocModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (mMocPsc) {
        return mMocPsc;
    }
    
    //NSURL *storeUrl = [[self applicationDocumentsDirectory]
	//				   URLByAppendingPathComponent:@"AzBodyNote.sqlite"];	//【重要】リリース後変更禁止
    NSURL *storeUrl = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:
					   [NSString stringWithFormat:@"%@.sqlite",ManagedObjectModelFileName]];
	NSLog(@"storeUrl=%@", storeUrl);
	
    mMocPsc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:
			   [self managedObjectModel]];
	
	if (CoreData_iCloud_SYNC  && miCloudContentURL) {
		// do this asynchronously since if this is the first time this particular device is syncing with preexisting
		// iCloud content it may take a long long time to download
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			//[[NSBundle mainBundle] bundleIdentifier];
			//NSFileManager *fileManager = [NSFileManager defaultManager];

			//NSURL *contentURL = [fileManager URLForUbiquityContainerIdentifier:UBIQUITY_CONTAINER_IDENTIFIER];
			//=nil : .entitlementsから自動取得されるようになった。
			//NSURL *contentURL = [fileManager URLForUbiquityContainerIdentifier:nil];
			NSLog(@"miCloudContentURL=1=%@", miCloudContentURL);
			
			NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
					   [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
					   [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
					   UBIQUITY_CONTENT_NAME_KEY, NSPersistentStoreUbiquitousContentNameKey,	//【重要】リリース後変更禁止
					   miCloudContentURL, NSPersistentStoreUbiquitousContentURLKey,								//【重要】リリース後変更禁止
					   nil];
			NSLog(@"options=%@", options);
			
			// prep the store path and bundle stuff here since NSBundle isn't totally thread safe
			NSPersistentStoreCoordinator* psc = mMocPsc;
			NSError *error = nil;
			[psc lock];
			if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
			{
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
				GA_TRACK_ERROR([error description]);
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
	else {	//iCloudなし　　iOS5より前
		NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
								 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
								 nil];
		NSError *error = nil;
		if (![mMocPsc addPersistentStoreWithType:NSSQLiteStoreType
								   configuration:nil  URL:storeUrl  options:options  error:&error])
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			GA_TRACK_EVENT_ERROR([error description],0);
			abort();
		}
	}
    return mMocPsc;
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 **/
- (NSManagedObjectContext *)managedObjectContext
{
	if (mContext) {
		return mContext;
	}
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	NSManagedObjectContext* moc = nil;
	
    if (coordinator != nil) {
		if (CoreData_iCloud_SYNC  && IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
			moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
			
			[moc performBlockAndWait:^(void){
				// Set up an undo manager, not included by default
				NSUndoManager *undoManager = [[NSUndoManager alloc] init];
				[undoManager setGroupsByEvent:NO];
				[moc setUndoManager:undoManager];
				
				
				// Set persistent store
				[moc setPersistentStoreCoordinator:coordinator];
				
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
    return	moc;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
												   inDomains:NSUserDomainMask] lastObject];
}



@end
