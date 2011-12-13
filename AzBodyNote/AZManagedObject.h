//
//  AZManagedObject.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/12/10.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import <Foundation/Foundation.h>

// 出典
// http://vladimir.zardina.org/2010/03/serializing-archivingunarchiving-an-nsmanagedobject-graph/
//

@interface AZManagedObject : NSManagedObject
{
    BOOL traversed;
}

@property (nonatomic, assign) BOOL traversed;

- (NSDictionary*) toDictionary;
- (void) fromDictionary:(NSDictionary*)dict;
+ (AZManagedObject*) insertNewObjectFromDictionary:(NSDictionary*)dict
										 inContext:(NSManagedObjectContext*)context;

@end


