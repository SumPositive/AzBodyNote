//
//  Global.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive. All rights reserved.
//

#import "AZClass.h"

#define AdMobID_BodyNote				@"a14ece23da85f5e";		// 体調日記 パブリッシャー ID

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
#define GUD_bGoal									@"GUD_bGoal"
#define GUD_bCalender							@"GUD_bCalender"
#define GUD_bGSpread							@"GUD_bGSpread"
#define GUD_CalendarID						@"GUD_CalendarID"
#define GUD_CalendarTitle					@"GUD_CalendarTitle"


// iCloud-KVS UserDefault ------------------------------------- Settings
// Goal_nBpHi_mmHg 関係は、"MocEntity.h" にて定義


//----------------------------------------------- Global.m グローバル関数
NSString *strValue( NSInteger val,  NSInteger dec );


//END

