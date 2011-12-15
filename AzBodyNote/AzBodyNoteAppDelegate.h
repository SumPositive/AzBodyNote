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
@property (nonatomic, retain, readonly) MocFunctions		*mocBase;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

// Global User Defaults - Settings
@property (nonatomic, assign) BOOL		gud_iCloud;


- (void)dropboxView;
- (NSString*)tmpFilePath;
- (NSString*)tmpFileSave;
- (NSString*)tmpFileLoad;

- (NSURL *)applicationDocumentsDirectory;

@end
