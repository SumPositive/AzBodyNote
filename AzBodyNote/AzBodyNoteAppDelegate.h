//
//  AzBodyNoteAppDelegate.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MocFunctions.h"

@interface AzBodyNoteAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain, readonly) NSManagedObjectContext			*managedObjectContext;
//@property (nonatomic, retain, readonly) NSManagedObjectModel				*managedObjectModel;
//@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator		*persistentStoreCoordinator;

@property (nonatomic, retain, readonly) MocFunctions		*mocBase;


//@property (nonatomic, assign) BOOL		mIsUpdate;


//- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
