//
//  Global.h
//  AzSplitIt
//
//  Created by 松山 和正 on 09/22/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

//#define NO_AD	// AppStore画面撮影用に「広告なし」にするため

#define OR  ||

#ifdef AzDEBUG	//--------------------------------------------- DEBUG
//#define AzLOG(...) NSLog(__VA_ARGS__)
#define AzRETAIN_CHECK(zName,pObj,iAns)  { if ([pObj retainCount] > iAns) NSLog(@"AzRETAIN_CHECK> %@ %d > %d", zName, [pObj retainCount], iAns); }

#else	//----------------------------------------------------- RELEASE
		// その他のフラグ：-DNS_BLOCK_ASSERTIONS=1　（NSAssertが除去される）
//#define AzLOG(...) 
#define NSLog(...) 
#define AzRETAIN_CHECK(...) 
#endif


#define GD_PRODUCTNAME	@"AzSplitIt"  // IMPORTANT PRODUCT NAME  和名「わりかん」
													//↑↑変更禁止！！Keychainの'ServiceName'に使っているので読み出せなくなる。
//#define GD_KEY_LOGINPASS  @"AzCreditLoginPass"  //←変更禁止！！Keychainの'Username'に使っているので読み出せなくなる。

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

