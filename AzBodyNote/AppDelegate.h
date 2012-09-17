//
//  AppDelegate.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <eventkit/EventKit.h>

// マイナー広告廃止
// iAd優先 AdMob補助 方式に戻した。 iAdは30秒以上表示するだけでも収益あり
//#import <iAd/iAd.h>
//#import "GADBannerView.h"

#import "Global.h"
#import "MocEntity.h"
#import "MocFunctions.h"


@interface AppDelegate : NSObject <UIApplicationDelegate>
{
@private
	NSManagedObjectContext				*mMoc;
	
	UIAlertView									*mAlertProgress;
	UIActivityIndicatorView				*mAlertIndicator;
	BOOL											mAzukiUnlock;	// YES=購入意思ありと見なしてUnlockする
	
	//ADBannerView						*RiAdBanner;
	//GADBannerView						*RoAdMobView;
	//BOOL				bADbannerIsVisible;		// iAd 広告内容があればYES
	//NSInteger		mAdShow;						// (0)非表示 (1)tabBar上 (2)最下部  (-1)破棄
}

@property (nonatomic, strong) UIWindow *window; //Rename禁止
@property (nonatomic, strong) UITabBarController *ppTabBarController;
@property (nonatomic, strong, readonly) EKEventStore		*ppEventStore;

// app_ Global paramaters
@property (nonatomic, assign) BOOL			ppApp_is_unlock;				// In App Purchese = 広告なし ＆ 制限解除
@property (nonatomic, assign) NSInteger	ppApp_e2record_count;		// Trial制限に使用。　 コメント投稿情報に表示。
@property (nonatomic, assign, readonly) BOOL	ppApp_is_iPad;	// YES=iPad


- (void)alertProgressOn:(NSString*)zTitle;
- (void)alertProgressOff;

//- (void)adShow:(NSInteger)iShow;
//- (void)adRefresh;  //回転時に呼び出すため

@end
