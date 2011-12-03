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


@end
