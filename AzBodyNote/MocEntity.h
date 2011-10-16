//
//  MocEntity.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//
#import <Foundation/Foundation.h>

#define AzDataModelVersion			0


//---------------------------------------------------------------------------------------E1
@interface E1body : NSManagedObject {
}
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
@interface E2record : NSManagedObject {
}
@property (nonatomic, retain) NSString		*bCaution;			// BOOL　YES=注意
@property (nonatomic, retain) NSDate			*dateTime;			// NSDateは、UTC(+0000)協定時刻で記録 
@property (nonatomic, retain) NSNumber   *nBpHi_mmHg;
@property (nonatomic, retain) NSNumber   *nBpLo_mmHg;
@property (nonatomic, retain) NSNumber   *nPulse_bpm;
@property (nonatomic, retain) NSNumber   *nTemp_10c;
@property (nonatomic, retain) NSNumber   *nWeight_g;
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
#define E2_nWeight_g				@"nWeight_g"
#define E2_nYearMM					@"nYearMM"
#define E2_sEquipment				@"sEquipment"
#define E2_sNote1						@"sNote1"
#define E2_sNote2						@"sNote2"
//#define E2_e1body					@"e1body"

// END
