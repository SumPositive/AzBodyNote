//
//  Global.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive. All rights reserved.
//

//#define AZClass_GoogleAnalytics
#import "AZClass.h"

#define COPYRIGHT		@"©2012 Azukid"

#define GD_PRODUCTNAME	@"AzBodyNote"  // IMPORTANT PRODUCT NAME  和名「健康日記」
													//↑↑変更禁止！！Keychainの'ServiceName'に使っているので読み出せなくなる。

// AppStore In-App Purchase ProductIdentifier
#define STORE_PRODUCTID_UNLOCK		@"com.azukid.AzBodyNote.Unlock"

// NSNotification messages
#define NFM_REFRESH_ALL_VIEWS			@"RefreshAllViews"					//表示のみ更新要求
#define NFM_REFETCH_ALL_DATA			@"RefetchAllDatabaseData"		//リロード更新要求
#define NFM_AppDidBecomeActive			@"AppDidBecomeActive"			//バックグランドから戻った

// Base Color
#define COLOR_AZUKI     [UIColor colorWithRed:151.0/255.0 green: 80.0/255.0 blue: 77.0/255.0 alpha:1.0]
#define COLOR_AZBK      [UIColor colorWithRed: 70.0/255.0 green: 70.0/255.0 blue: 70.0/255.0 alpha:1.0]
#define COLOR_AZWH      [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0]


// typedef
enum {
    EnumConditionNote		= 0,
    EnumConditionBpHi		= 1,
    EnumConditionBpLo		= 2,
    EnumConditionPuls			= 3,
    EnumConditionTemp		= 4,
    EnumConditionWeight	= 5,
    EnumConditionPedo		= 6,
    EnumConditionFat			= 7,
    EnumConditionSkm			= 8,
    EnumConditionCount		= 9 //End count
};
typedef NSUInteger EnumConditions;

enum {
    EnumGraphBp			= 0,
    EnumGraphBpAvg	= 1,
    EnumGraphPuls		= 2,
    EnumGraphTemp	= 3,
    EnumGraphWeight	= 4,
    EnumGraphPedo		= 5,
    EnumGraphFat		= 6,
    EnumGraphSkm		= 7,
    EnumGraphCount	= 8 //End count
};
typedef NSUInteger EnumGraphs;

#define TABBAR_CHANGE_TIME				0.5		// TabBar切替時のディゾルブ時間(s)
#define DateOpt_AroundHOUR						2			// 前後許容時間


// User Default : デバイス別 ------------------------------------- Settings		【注意】リリース後は変更厳禁！
#define UDEF_CalendarID						@"UDEF_CalendarID"	//同じカレンダーでもデバイス毎にIDが異なる
#define UDEF_CalendarTitle					@"UDEF_CalendarTitle"


// Key-Value-Store : 全デバイス共通 ----------------------------- Settings		【注意】リリース後は変更厳禁！
#define KVS_Calc_Method						@"KVS_Calc_Method"	// 0=電卓式(2+2x2=8)　　1=計算式(2+2x2=6)
#define KVS_Calc_RoundBankers			@"KVS_Calc_RoundBankers"
#define KVS_bTweet								@"KVS_bTweet"
#define KVS_bGoal									@"KVS_bGoal"
#define KVS_bCalender							@"KVS_bCalender"
#define KVS_bGSpread							@"KVS_bGSpread"
#define KVS_CalendarID							@"KVS_CalendarID"		//1.0.1//UDEF_CalendarIDへ移行
#define KVS_CalendarTitle						@"KVS_CalendarTitle"	//1.0.1//UDEF_CalendarTitleへ移行

#define KVS_SettGraphs						@"KVS_SettGraphs"	//UserDef保存につき変更禁止 NSArrey型 
#define KVS_SettGraphOneWid				@"KVS_SettGraphOneWid"
#define KVS_SettGraphBpMean				@"KVS_SettGraphBpMean"	// 平均血圧　　Mean blood pressure
#define KVS_SettGraphBpPress				@"KVS_SettGraphBpPress"	// 脈圧	Pulse pressure
#define KVS_SettGraphBMITall				@"KVS_SettGraphBMITall"		// 身長(cm)

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

