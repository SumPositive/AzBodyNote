//
//  MocFunctions.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive @Azukid.com. All rights reserved.
//
//  マルチＭＯＣ対応のため、インスタンスメソッドにした。

#import <Foundation/Foundation.h>

//#import "AppDelegate.h" この.hがAppDelegate.hに#importされるため不適切
#import "Global.h"
#import "MocEntity.h"

#define CoreData_iCloud_SYNC				YES		// YES or NO


@interface MocFunctions : NSObject 
{
@private
	NSManagedObjectContext			*mContext;
	NSManagedObjectModel			*mMocModel;
	NSPersistentStoreCoordinator	*mMocPsc;
	NSURL											*miCloudContentURL;
}


// ＋ クラスメソッド
+ (MocFunctions *)sharedMocFunctions;
+ (NSDate*)dateGoal;

// − インスタンスメソッド
//- (id)initWithMoc:(NSManagedObjectContext*)moc;
//- (void)setMoc:(NSManagedObjectContext *)moc;
- (void)initialize;
- (NSManagedObjectContext*)getMoc;
- (id)insertAutoEntity:(NSString *)zEntityName;
- (void)deleteEntity:(NSManagedObject *)entity;
- (BOOL)hasChanges;
- (BOOL)commit;
- (void)rollBack;

- (NSUInteger)e2record_count;

- (NSArray *)select:(NSString *)zEntity
			  limit:(NSUInteger)iLimit
			 offset:(NSUInteger)iOffset
			  where:(NSPredicate *)predicate
			   sort:(NSArray *)arSort;

- (void)e2delete:(E2record *)e2node;
- (void)deleteAllCoreData;

- (NSDictionary*)dictionaryObject:(NSManagedObject*)mobj;
- (NSManagedObject*)insertNewObjectForDictionary:(NSDictionary*)dict;

- (void)iCloudAllClear;
//- (NSString *)applicationDocumentsDirectory;

@end
