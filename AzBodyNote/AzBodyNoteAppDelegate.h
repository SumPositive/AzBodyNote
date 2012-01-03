//
//  AzBodyNoteAppDelegate.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MocFunctions.h"

#import <StoreKit/StoreKit.h>
#define STORE_PRODUCTID_UNLOCK		@"com.azukid.AzBodyNote.Unlock"		// In-App Purchase ProductIdentifier


@interface AzBodyNoteAppDelegate : NSObject <UIApplicationDelegate, SKPaymentTransactionObserver>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain, readonly) NSManagedObjectContext			*managedObjectContext;
@property (nonatomic, retain, readonly) MocFunctions		*mocBase;

@property (nonatomic, assign) BOOL		gud_bPaid;	// In App Purchese



- (void)alertProgressOn:(NSString*)zTitle;
- (void)alertProgressOff;

- (void)dropboxView;
- (NSString*)tmpFilePath;
- (NSString*)tmpFileSave;
- (NSString*)tmpFileLoad;

- (NSString *)applicationDocumentsDirectory;

@end
