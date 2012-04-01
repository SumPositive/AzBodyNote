//
//  Global.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive. All rights reserved.
//
#define OR  ||

#define AdMobID_BodyNote				@"a14ece23da85f5e";		// 体調日記 パブリッシャー ID

#ifdef DEBUG	//--------------------------------------------- DEBUG
//#define AzLOG(...) NSLog(__VA_ARGS__)
#define AzRETAIN_CHECK(zName,pObj,iAns)  { if ([pObj retainCount] > iAns) NSLog(@"AzRETAIN_CHECK> %@ %d > %d", zName, [pObj retainCount], iAns); }

#else	//----------------------------------------------------- RELEASE
		// その他のフラグ：-DNS_BLOCK_ASSERTIONS=1　（NSAssertが除去される）
//#define AzLOG(...) 
#define NSLog(...) 
#define AzRETAIN_CHECK(...) 
#endif


// iOS VERSION		http://goddess-gate.com/dc2/index.php/post/452
#define IOS_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define IOS_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IOS_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define IOS_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#define GD_PRODUCTNAME	@"AzBodyNote"  // IMPORTANT PRODUCT NAME  和名「健康日記」
													//↑↑変更禁止！！Keychainの'ServiceName'に使っているので読み出せなくなる。

#define TABBAR_CHANGE_TIME				0.5		// TabBar切替時のディゾルブ時間(s)

// NSNotification messages
#define NFM_REFRESH_ALL_VIEWS			@"RefreshAllViews"
#define NFM_REFETCH_ALL_DATA			@"RefetchAllDatabaseData"
#define NFM_AppDidBecomeActive			@"AppDidBecomeActive"


// UserDefault ------------------------------------- Settings		【注意】リリース後は変更厳禁！
#define GUD_bPaid									@"GUD_bPaid"					// KVSにも記録する
#define GUD_bUnlock								@"GUD_bUnlock"
#define GUD_Calc_Method					@"GUD_Calc_Method"		// 0=電卓式(2+2x2=8)　　1=計算式(2+2x2=6)
#define GUD_Calc_RoundBankers			@"GUD_Calc_RoundBankers"
#define GUD_bTweet								@"GUD_bTweet"

// iCloud-KVS UserDefault ------------------------------------- Settings
// Goal_nBpHi_mmHg 関係は、"MocEntity.h" にて定義


//----------------------------------------------- Global.m グローバル関数
void alertBox( NSString *zTitle, NSString *zMsg, NSString *zButton );
id toNSNull( id obj );
id toNil( id obj );
NSString *strValue( NSInteger val,  NSInteger dec );




//
// Google Analytics
//
#import "GANTracker.h"

#define __GA_INIT_TRACKER(ACCOUNT, PERIOD, DELEGATE) \
[[GANTracker sharedTracker] startTrackerWithAccountID:ACCOUNT \
dispatchPeriod:PERIOD delegate:DELEGATE];
#ifdef DEBUGxxxxxxx
#define GA_INIT_TRACKER(ACCOUNT, PERIOD, DELEGATE) { \
__GA_INIT_TRACKER(ACCOUNT, PERIOD, DELEGATE); \
[GANTracker sharedTracker].debug = YES; \
[GANTracker sharedTracker].dryRun = YES; }
#else
#define GA_INIT_TRACKER(ACCOUNT, PERIOD, DELEGATE) __GA_INIT_TRACKER(ACCOUNT, PERIOD, DELEGATE);
#endif

#define GA_TRACK_PAGE(PAGE) { NSError *error; if (![[GANTracker sharedTracker] \
trackPageview:[NSString stringWithFormat:@"/%@", PAGE] \
withError:&error]) { NSLog(@"GA_TRACK_PAGE: error: %@",error.helpAnchor);  } }

#define GA_TRACK_EVENT(EVENT,ACTION,LABEL,VALUE) { \
NSError *error; if (![[GANTracker sharedTracker] trackEvent:EVENT action:ACTION label:LABEL value:VALUE withError:&error]) \
{ NSLog(@"GA_TRACK_EVENT: error: %@",error.helpAnchor); }  }

#define GA_TRACK_EVENT_ERROR(LABEL,VALUE)  { \
NSString *_zAction_ = [NSString stringWithFormat:@"%@:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd)]; \
GA_TRACK_EVENT(@"ERROR",_zAction_,LABEL,VALUE); }

#define GA_TRACK_CLASS  { GA_TRACK_PAGE(NSStringFromClass([self class])) }

#define GA_TRACK_METHOD { GA_TRACK_EVENT(NSStringFromClass([self class]),NSStringFromSelector(_cmd),@"",0); }


//END

