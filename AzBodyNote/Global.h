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

// Key-Value-Store ------------------------------------- Settings		【注意】リリース後は変更厳禁！
//0.9//#define GUD_bPaid									@"GUD_bPaid"
//0.9//#define GUD_bUnlock								@"GUD_bUnlock"
#define KVS_Calc_Method						@"KVS_Calc_Method"		// 0=電卓式(2+2x2=8)　　1=計算式(2+2x2=6)
#define KVS_Calc_RoundBankers			@"KVS_Calc_RoundBankers"
#define KVS_bTweet								@"KVS_bTweet"
#define KVS_bGoal									@"KVS_bGoal"
#define KVS_bCalender							@"KVS_bCalender"
#define KVS_bGSpread							@"KVS_bGSpread"
#define KVS_CalendarID							@"KVS_CalendarID"
#define KVS_CalendarTitle						@"KVS_CalendarTitle"
#define KVS_SettGraphs						@"KVS_SettGraphs"	//UserDef保存につき変更禁止 NSArrey型 
#define KVS_SettStatType					@"KVS_SettStatType"
#define KVS_SettStatDays					@"KVS_SettStatDays"
#define KVS_SettStatAvgShow				@"KVS_SettStatAvgShow"
#define KVS_SettStatTimeLine				@"KVS_SettStatTimeLine"
#define KVS_SettStat24H_Line			@"KVS_SettStat24H_Line"

//この時刻の前後2時間を判定している
#define KVS_DateOptWake_HOUR		@"KVS_DateOptWake_HOUR"
#define KVS_DateOptRest_HOUR			@"KVS_DateOptRest_HOUR"
#define KVS_DateOptDown_HOUR		@"KVS_DateOptDown_HOUR"
#define KVS_DateOptSleep_HOUR		@"KVS_DateOptSleep_HOUR"


// iCloud-KVS UserDefault ------------------------------------- Settings
// Goal_nBpHi_mmHg 関係は、"MocEntity.h" にて定義


//----------------------------------------------- Global.m グローバル関数
NSString *strValue( NSInteger val,  NSInteger dec );


//END

