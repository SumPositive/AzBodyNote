//
//  Global.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive. All rights reserved.
//

//#define NO_AD	// AppStore画面撮影用に「広告なし」にするため
#if !defined(NO_AD)
#define GD_Ad_ENABLED
#define AdMobID_BodyNote				@"a14ece23da85f5e";		// 体調日記 パブリッシャー ID
#endif

#define OR  ||

#ifdef DEBUG	//--------------------------------------------- DEBUG
//#define AzLOG(...) NSLog(__VA_ARGS__)
#define AzRETAIN_CHECK(zName,pObj,iAns)  { if ([pObj retainCount] > iAns) NSLog(@"AzRETAIN_CHECK> %@ %d > %d", zName, [pObj retainCount], iAns); }

#else	//----------------------------------------------------- RELEASE
		// その他のフラグ：-DNS_BLOCK_ASSERTIONS=1　（NSAssertが除去される）
//#define AzLOG(...) 
#define NSLog(...) 
#define AzRETAIN_CHECK(...) 
#endif

#define ENABLE_iCloud
// iOS VERSION		http://goddess-gate.com/dc2/index.php/post/452
#define IOS_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define IOS_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IOS_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define IOS_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#define GD_PRODUCTNAME	@"AzBodyNote"  // IMPORTANT PRODUCT NAME  和名「カラダ日記」
													//↑↑変更禁止！！Keychainの'ServiceName'に使っているので読み出せなくなる。
//#define GD_KEY_LOGINPASS  @"AzCreditLoginPass"  //←変更禁止！！Keychainの'Username'に使っているので読み出せなくなる。

#define TABBAR_CHANGE_TIME			0.5		// TabBar切替時のディゾルブ時間(s)

// UserDefault
#define GD_OptRoundBankers					@"GD_OptRoundBankers"		// 偶数丸め

// UserDefault  Settings
#define GD_SetName0								@"GD_SetName0"
#define GD_SetName1								@"GD_SetName1"
#define GD_SetName2								@"GD_SetName2"
#define GD_SetUnit1									@"GD_SetUnit1"
#define GD_SetUnit2									@"GD_SetUnit2"
#define GD_SetCalcMethod						@"GD_SetCalcMethod"

// UserDefault  UseData
#define GD_UseSplitIt									@"GD_UseSplitIt"
#define GD_UsePersons0							@"GD_UsePersons0"
#define GD_UsePersons1							@"GD_UsePersons1"
#define GD_UsePersons2							@"GD_UsePersons2"
#define GD_UseSplit0									@"GD_UseSplit0"
#define GD_UseSplit1									@"GD_UseSplit1"
#define GD_UseSplit2									@"GD_UseSplit2"


//----------------------------------------------- Global.m グローバル関数
void alertBox( NSString *zTitle, NSString *zMsg, NSString *zButton );
