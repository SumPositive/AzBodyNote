//
//  Global.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive. All rights reserved.
//
#import "AZClass.h"

#define GD_PRODUCTNAME	@"AzBodyNote"  // IMPORTANT PRODUCT NAME  和名「健康日記」
													//↑↑変更禁止！！Keychainの'ServiceName'に使っているので読み出せなくなる。

// AppStore In-App Purchase ProductIdentifier
#define STORE_PRODUCTID_UNLOCK		@"com.azukid.AzBodyNote.Unlock"

// NSNotification messages
#define NFM_REFRESH_ALL_VIEWS			@"RefreshAllViews"
#define NFM_REFETCH_ALL_DATA			@"RefetchAllDatabaseData"
#define NFM_AppDidBecomeActive			@"AppDidBecomeActive"

// typedef
enum {
    AzConditionNote		= 0,
    AzConditionBpHi		= 1,
    AzConditionBpLo	= 2,
    AzConditionPuls		= 3,
    AzConditionTemp	= 4,
    AzConditionWeight	= 5,
    AzConditionPedo		= 6,
    AzConditionFat		= 7,
    AzConditionSkm		= 8,
    AzConditionCount	= 9 //End count
};
typedef NSUInteger AzConditionItems;

#define TABBAR_CHANGE_TIME				0.5		// TabBar切替時のディゾルブ時間(s)
#define DateOpt_AroundHOUR						2			// 前後許容時間

// UserDefault ------------------------------------- Settings		【注意】リリース後は変更厳禁！
//0.9//#define GUD_bPaid									@"GUD_bPaid"
//0.9//#define GUD_bUnlock								@"GUD_bUnlock"
#define GUD_Calc_Method					@"GUD_Calc_Method"		// 0=電卓式(2+2x2=8)　　1=計算式(2+2x2=6)
#define GUD_Calc_RoundBankers			@"GUD_Calc_RoundBankers"
#define GUD_bTweet								@"GUD_bTweet"
#define GUD_bGoal									@"GUD_bGoal"
#define GUD_bCalender							@"GUD_bCalender"
#define GUD_bGSpread							@"GUD_bGSpread"
#define GUD_CalendarID						@"GUD_CalendarID"
#define GUD_CalendarTitle					@"GUD_CalendarTitle"
#define GUD_SettGraphs						@"GUD_SettGraphs"	//UserDef保存につき変更禁止 NSArrey型 
#define GUD_SettStatDays					@"GUD_SettStatDays"

//この時刻の前後2時間を判定している
#define GUD_DateOptWake_HOUR		@"GUD_DateOptWake_HOUR"
#define GUD_DateOptRest_HOUR			@"GUD_DateOptRest_HOUR"
#define GUD_DateOptDown_HOUR		@"GUD_DateOptDown_HOUR"
#define GUD_DateOptSleep_HOUR		@"GUD_DateOptSleep_HOUR"


// iCloud-KVS UserDefault ------------------------------------- Settings
// Goal_nBpHi_mmHg 関係は、"MocEntity.h" にて定義


//----------------------------------------------- Global.m グローバル関数
NSString *strValue( NSInteger val,  NSInteger dec );


//END

