//
//  MocFunctions.m
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//

//#import "SFHFKeychainUtils.h"
#import "Global.h"
#import "AzBodyNoteAppDelegate.h"
#import "MocEntity.h"
#import "MocFunctions.h"


@implementation MocFunctions

//static NSManagedObjectContext *scMoc = nil;

#pragma mark - ＋ クラスメソッド

static NSDate *dateGoal_ = nil;
+ (NSDate*)dateGoal
{	// .dateTime のための 固有日付(dateGoal)を求める
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


#pragma mark - ー インスタンスメソッド

- (id)initWithMoc:(NSManagedObjectContext*)moc
{
	self = [super init];
	if (self==nil) return nil; // ERROR
	
	assert(moc);
	moc_ = moc;
	return self;
}

- (void)setMoc:(NSManagedObjectContext *)moc
{
	assert(moc);
	moc_ = moc;
}	

- (NSManagedObjectContext*)getMoc
{
	return moc_;
}

- (id)insertAutoEntity:(NSString *)zEntityName	// autorelease
{
	assert(moc_);
	// Newが含まれているが、自動解放インスタンスが生成される。
	// 即commitされる。つまり、rollbackやcommitの対象外である。 ＜＜そんなことは無い！ roolback可能 save必要
	return [NSEntityDescription insertNewObjectForEntityForName:zEntityName inManagedObjectContext:moc_];
	// ここで生成されたEntityは、rollBack では削除されない。　Cancel時には、deleteEntityが必要。 ＜＜そんなことは無い！ roolback可能 save必要
}	

- (void)deleteEntity:(NSManagedObject *)entity
{
	@synchronized(moc_)
	{
		if (entity) {
			[moc_ deleteObject:entity];	// 即commitされる。つまり、rollbackやcommitの対象外である。 ＜＜そんなことは無い！ roolback可能 save必要
		}
	}
}	

- (BOOL)hasChanges		// YES=commit以後に変更あり
{
	return [moc_ hasChanges];
}

- (BOOL)commit
{
	assert(moc_);
	@synchronized(moc_)
	{
		// SAVE
		NSError *err = nil;
		if (![moc_  save:&err]) {
			NSLog(@"*** MOC commit error ***\n%@\n%@\n***\n", err, [err userInfo]);
			//exit(-1);  // Fail
			alertBox(NSLocalizedString(@"MOC CommitErr",nil),
					 NSLocalizedString(@"MOC CommitErrMsg",nil),
					 NSLocalizedString(@"Roger",nil));
			return NO;
		}
	}
	return YES;
}


- (void)rollBack
{
	assert(moc_);
	@synchronized(moc_)
	{
		// ROLLBACK
		[moc_ rollback]; // 前回のSAVE以降を取り消す
	}
}


#pragma mark - Search

- (NSArray *)select:(NSString *)zEntity
			  limit:(NSInteger)iLimit
			 offset:(NSInteger)iOffset
			  where:(NSPredicate *)predicate
			   sort:(NSArray *)arSort 
{
	assert(moc_);
	NSFetchRequest *req = nil;
	@try {
		req = [[NSFetchRequest alloc] init];
		
		// select
		NSEntityDescription *entity = [NSEntityDescription entityForName:zEntity 
												  inManagedObjectContext:moc_];
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
			NSLog(@"MocFunction: select: where: %@", predicate);
			[req setPredicate:predicate];
		}
		
		// order by
		if (arSort) {
			[req setSortDescriptors:arSort];
		}

		NSError *error = nil;
		NSArray *arFetch = [moc_ executeFetchRequest:req error:&error];
		//[req release], req = nil;
		if (error) {
			NSLog(@"select: Error %@, %@", error, [error userInfo]);
			return nil;
		}
		return arFetch; // autorelease
	}
	@catch (NSException *errEx) {
		NSLog(@"select @catch:NSException: %@ : %@", [errEx name], [errEx reason]);
	}
	@finally {
		//[req release], req = nil;
	}
	return nil;
}


- (void)e2delete:(E2record *)e2node
{
	assert(moc_);
	if (e2node==nil) return;
	[moc_ deleteObject:e2node]; // 削除
}


// 全データ削除する
- (void)deleteAllCoreData
{
	NSUInteger count = 0;
	
	for (NSEntityDescription *entity in [[[moc_ persistentStoreCoordinator] managedObjectModel] entities]) 
	{
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:[NSEntityDescription entityForName:[entity name] inManagedObjectContext:moc_]];
		
		NSArray *temp = [moc_ executeFetchRequest:request error:NULL];
		
		if (temp) {
			count += [temp count];
		}
		
		//[request release];
		
		for (NSManagedObject *object in temp) {
			[moc_ deleteObject:object];
		}
	}
	NSLog(@"Entity = %d", count);
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
    //NSManagedObjectContext* context = [self managedObjectContext];

    NSString* class = [dict objectForKey:@"#class"];

    NSManagedObject* newObject = [NSEntityDescription insertNewObjectForEntityForName:class inManagedObjectContext:moc_];
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
				[newObject setValue:dateFromUTC(str) forKey: [key substringFromIndex:[TYPE_NSDate length]]];
			}
			else {
				assert(NO);	// 未定義の型
			}
		}
        else if ([value isKindOfClass:[NSDictionary class]]) {
			/***　関連（リレーション）非対応
            // This is a to-one relationship
            NSManagedObject* childObject = [MocFunctions insertNewObjectFromDictionary:(NSDictionary*)value  inContext:moc_];
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
                NSManagedObject* childObject = [MocFunctions insertNewObjectFromDictionary:relatedObjectDict  inContext:moc_];
                [relatedObjects addObject:childObject];
            }***/
        }
        else {  // This is an attribute
			[newObject setValue:value forKey:key];
        }
    }
	return newObject;
}


@end
