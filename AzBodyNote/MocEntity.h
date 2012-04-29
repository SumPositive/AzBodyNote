//
//  MocEntity.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//
#import <Foundation/Foundation.h>
//#import "AZManagedObject.h"



#define AzDataModelVersion			0
/*
//---------------------------------------------------------------------------------------E1
@interface E1body : NSManagedObject 
@property (nonatomic, retain) NSDate			*dBirthday;		// NSDate-->JSON文字列は、UTC協定時刻にする。
@property (nonatomic, retain) NSNumber   *nMkBpHi_mmHg;
@property (nonatomic, retain) NSNumber   *nMkBpLo_mmHg;
@property (nonatomic, retain) NSNumber   *nMkWeight_g;
@property (nonatomic, retain) NSString		*sName;
@property (nonatomic, retain) NSString		*sNote;
//@property (nonatomic, retain) NSSet			*e2records;		// E1 <-->> E2  ＜＜関連を無くした
@end
#define E1_ENTITYNAME			@"E1body"
#define E1_dBirthday					@"dBirthday"
#define E1_nMkBpHi_mmHg		@"nMkBpHi_mmHg"
#define E1_nMkBpLo_mmHg	@"nMkBpLo_mmHg"
#define E1_nMkWeight_g			@"nMkWeight_g"
#define E1_sName						@"sName"
#define E1_sNote						@"sNote"
//#define E1_e2records				@"e2records"
*/

//---------------------------------------------------------------------------------------E2
@interface E2record : NSManagedObject 
@property (nonatomic, retain) NSString		*bCaution;			// BOOL　YES=注意
@property (nonatomic, retain) NSDate			*dateTime;			// NSDate型ならば定義名のPrefix(先頭)を"date"にする！JSON変換のため
@property (nonatomic, retain) NSNumber   *nDateOpt;			//2// (optType)
@property (nonatomic, retain) NSNumber   *nYearMM;			// セクション表示のため「年月」を記録
@property (nonatomic, retain) NSString		*sEventID;			// カレンダー
@property (nonatomic, retain) NSString		*sGSpreadID;		// Google Spread
@property (nonatomic, retain) NSString		*sNote1;
@property (nonatomic, retain) NSString		*sNote2;
@property (nonatomic, retain) NSString		*sEquipment;		// 場所や測定装置
@property (nonatomic, retain) NSNumber   *nBpHi_mmHg;
@property (nonatomic, retain) NSNumber   *nBpLo_mmHg;
@property (nonatomic, retain) NSNumber   *nPulse_bpm;
@property (nonatomic, retain) NSNumber   *nWeight_10Kg;
@property (nonatomic, retain) NSNumber   *nTemp_10c;
@property (nonatomic, retain) NSNumber   *nPedometer;			//2//歩数 max.99,999
@property (nonatomic, retain) NSNumber   *nBodyFat_10p;		//2//体脂肪率
@property (nonatomic, retain) NSNumber   *nSkMuscle_10p;	//2//骨格筋率
@end

enum {
	DtOpWake	= 0,		// Wake up
	DtOpRest		= 1,		// at Rest
	DtOpDown	= 2,		// Slowdown
    DtOpSleep	= 3,		// for Sleep
	DtOpEnd		= 4		// End count
};
typedef NSInteger DateOpt;

#define E2_ENTITYNAME			@"E2record"
#define E2_bCaution					@"bCaution"
#define E2_dateTime					@"dateTime"
#define E2_nDateOpt					@"nDateOpt"
#define E2_nYearMM					@"nYearMM"
#define E2_sNote1						@"sNote1"
#define E2_sNote2						@"sNote2"
#define E2_sEquipment				@"sEquipment"
#define E2_nBpHi_mmHg			@"nBpHi_mmHg"
#define E2_nBpLo_mmHg			@"nBpLo_mmHg"
#define E2_nPulse_bpm			@"nPulse_bpm"
#define E2_nWeight_10Kg		@"nWeight_10Kg"
#define E2_nTemp_10c			@"nTemp_10c"
#define E2_nPedometer				@"nPedometer"
#define E2_nBodyFat_10p		@"nBodyFat_10p"
#define E2_nSkMuscle_10p		@"nSkMuscle_10p"

#define Goal_sNote1						@"Goal_sNote1"
#define Goal_sNote2						@"Goal_sNote2"
#define Goal_sEquipment				@"Goal_sEquipment"
#define Goal_nBpHi_mmHg			@"Goal_nBpHi_mmHg"		// iCloud-KVS Key
#define Goal_nBpLo_mmHg			@"Goal_nBpLo_mmHg"
#define Goal_nPulse_bpm				@"Goal_nPulse_bpm"
#define Goal_nWeight_10Kg			@"Goal_nWeight_10Kg"
#define Goal_nTemp_10c				@"Goal_nTemp_10c"
#define Goal_nPedometer				@"Goal_nPedometer"
#define Goal_nBodyFat_10p			@"Goal_nBodyFat_10p"
#define Goal_nSkMuscle_10p		@"Goal_nSkMuscle_10p"

#define E2_dateTime_GOAL		@"2200-01-01T00:00:00 +0000"  // 目標値を記録したE2固有レコード（最大日付+1日）
#define E2_nYearMM_GOAL			 220001		// 比較レスポンス向上のために利用する
#define E2_dateTime_MAX		@"2090-12-31T23:59:59 +0000"  // 最大入力許可日付
#define E2_nBpHi_MIN			30			//_MIN 最小値
#define E2_nBpHi_INIT			120			//_INIT 初期値
#define E2_nBpHi_MAX			300			//_MAX 最大値　 .xcdatamodeldの最大値設定と合わせること （最小値は、nil 許可）
#define E2_nBpLo_MIN			20
#define E2_nBpLo_INIT			80
#define E2_nBpLo_MAX			200
#define E2_nPuls_MIN			10
#define E2_nPuls_INIT			65
#define E2_nPuls_MAX			200
#define E2_nWeight_MIN		0
#define E2_nWeight_INIT		650
#define E2_nWeight_MAX		2000	//x10(Kg)
#define E2_nTemp_MIN			310
#define E2_nTemp_INIT			365
#define E2_nTemp_MAX		429		//x10(℃)
#define E2_nPedometer_MIN	0
#define E2_nPedometer_INIT	5000
#define E2_nPedometer_MAX	99999	//(歩)
#define E2_nBodyFat_MIN			0
#define E2_nBodyFat_INIT		235
#define E2_nBodyFat_MAX		1000	//x10(%)
#define E2_nSkMuscle_MIN		0
#define E2_nSkMuscle_INIT		285
#define E2_nSkMuscle_MAX		1000	//x10(%)


NSDate *dateFromUTC( NSString *utc );
NSString *utcFromDate( NSDate *dt );


// END
