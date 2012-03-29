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

#import <iAd/iAd.h>
#import "AdWhirlView.h"
#import "AdWhirlDelegateProtocol.h"
#define GAD_SIZE_320x50     CGSizeMake(320, 50)
#import "MasManagerViewController.h"
#import "NADView.h"  //AppBank nend


@interface AzBodyNoteAppDelegate : NSObject <UIApplicationDelegate, SKPaymentTransactionObserver,
															AdWhirlDelegate, NADViewDelegate, ADBannerViewDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain, readonly) NSManagedObjectContext			*managedObjectContext;
@property (nonatomic, retain, readonly) MocFunctions		*mocBase;
@property (nonatomic, retain, readonly) AdWhirlView			*pAdWhirlView;

// app_ Global paramaters
@property (nonatomic, assign) BOOL			app_is_sponsor;				// In App Purchese = 広告なし ＆ 制限解除
@property (nonatomic, assign) BOOL			app_is_unlock;				// 制限解除
@property (nonatomic, assign) NSInteger	app_e2record_count;		// Trial制限に使用。　 コメント投稿情報に表示。



- (void)alertProgressOn:(NSString*)zTitle;
- (void)alertProgressOff;

- (void)dropboxView;
- (NSString*)tmpFilePath;
- (NSString*)tmpFileSave;
- (NSString*)tmpFileLoad;

- (NSString *)applicationDocumentsDirectory;

@end
