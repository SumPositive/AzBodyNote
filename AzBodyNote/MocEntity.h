//
//  MocEntity.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "AZManagedObject.h"

#define AzDataModelVersion			0

//---------------------------------------------------------------------------------------E1
@interface E1body : AZManagedObject 
@property (nonatomic, retain) NSDate			*dBirthday;		// NSDateは、UTC(+0000)協定時刻で記録 ⇒ 表示でタイムゾーン変換する
@property (nonatomic, retain) NSNumber   *nMkBpHi_mmHg;
@property (nonatomic, retain) NSNumber   *nMkBpLo_mmHg;
@property (nonatomic, retain) NSNumber   *nMkWeight_g;
@property (nonatomic, retain) NSString		*sName;
@property (nonatomic, retain) NSString		*sNote;
//@property (nonatomic, retain) NSSet			*e2records;		// E1 <-->> E2  ＜＜関連を無くした
@end
#define E1_dBirthday					@"dBirthday"
#define E1_nMkBpHi_mmHg		@"nMkBpHi_mmHg"
#define E1_nMkBpLo_mmHg	@"nMkBpLo_mmHg"
#define E1_nMkWeight_g			@"nMkWeight_g"
#define E1_sName						@"sName"
#define E1_sNote						@"sNote"
//#define E1_e2records				@"e2records"

//---------------------------------------------------------------------------------------E2
@interface E2record : AZManagedObject 
@property (nonatomic, retain) NSString		*bCaution;			// BOOL　YES=注意
@property (nonatomic, retain) NSDate			*dateTime;			// NSDateは、UTC(+0000)協定時刻で記録 
@property (nonatomic, retain) NSNumber   *nBpHi_mmHg;
@property (nonatomic, retain) NSNumber   *nBpLo_mmHg;
@property (nonatomic, retain) NSNumber   *nPulse_bpm;
@property (nonatomic, retain) NSNumber   *nTemp_10c;
@property (nonatomic, retain) NSNumber   *nWeight_10Kg;
@property (nonatomic, retain) NSNumber   *nYearMM;			// セクション表示のため「年月」を記録
@property (nonatomic, retain) NSString		*sEquipment;		// 場所や測定装置
@property (nonatomic, retain) NSString		*sNote1;
@property (nonatomic, retain) NSString		*sNote2;
//@property (nonatomic, retain) E1body			*e1body;		// E2 <<--> E1  ＜＜関連を無くした
@end
#define E2_bCaution					@"bCaution"
#define E2_dateTime					@"dateTime"
#define E2_nBpHi_mmHg			@"nBpHi_mmHg"
#define E2_nBpLo_mmHg			@"nBpLo_mmHg"
#define E2_nPulse_bpm			@"nPulse_bpm"
#define E2_nTemp_10c			@"nTemp_10c"
#define E2_nWeight_10Kg		@"nWeight_10Kg"
#define E2_nYearMM					@"nYearMM"
#define E2_sEquipment				@"sEquipment"
#define E2_sNote1						@"sNote1"
#define E2_sNote2						@"sNote2"
//#define E2_e1body					@"e1body"

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


// END
