//
//  MocFunctions.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//
//  マルチＭＯＣ対応のため、インスタンスメソッドにした。

#import <Foundation/Foundation.h>
#import "MocEntity.h"

@interface MocFunctions : NSObject {
@private
	NSManagedObjectContext		*moc_;
}

// ＋ クラスメソッド
+ (NSDate*)dateGoal;

// − インスタンスメソッド
- (id)initWithMoc:(NSManagedObjectContext*)moc;
- (void)setMoc:(NSManagedObjectContext *)moc;
- (NSManagedObjectContext*)getMoc;
- (AZManagedObject*)insertAutoEntity:(NSString *)zEntityName;
- (void)deleteEntity:(AZManagedObject *)entity;
- (BOOL)hasChanges;
- (BOOL)commit;
- (void)rollBack;

- (NSArray *)select:(NSString *)zEntity
			  limit:(NSInteger)iLimit
			 offset:(NSInteger)iOffset
			  where:(NSPredicate *)predicate
			   sort:(NSArray *)arSort;

- (void)e2delete:(E2record *)e2node;


@end
