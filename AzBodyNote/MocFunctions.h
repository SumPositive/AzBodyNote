//
//  MocFunctions.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MocEntity.h"

@interface MocFunctions : NSObject {
}


// クラスメソッド（グローバル関数）
+ (void)setMoc:(NSManagedObjectContext *)moc;
+ (id)insertAutoEntity:(NSString *)zEntityName;
+ (void)deleteEntity:(NSManagedObject *)entity;
+ (BOOL)hasChanges;
+ (BOOL)commit;
+ (void)rollBack;
+ (NSArray *)select:(NSString *)zEntity
			  limit:(NSInteger)iLimit
			 offset:(NSInteger)iOffset
			  where:(NSPredicate *)predicate
			   sort:(NSArray *)arSort;

+ (void)e2delete:(E2record *)e2node;


@end
