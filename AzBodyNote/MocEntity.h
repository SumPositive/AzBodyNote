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
@property (nonatomic, retain) NSNumber   *nMkWaist_cm;
@property (nonatomic, retain) NSNumber   *nMkWeight_g;
@property (nonatomic, retain) NSString		*sName;
@property (nonatomic, retain) NSString		*sNote;
@property (nonatomic, retain) NSSet			*e2records;		// E1 <-->> E2
@end

//---------------------------------------------------------------------------------------E2
@interface E2record : NSManagedObject {
}
@property (nonatomic, retain) NSString		*bCaution;			// BOOL　YES=注意
@property (nonatomic, retain) NSDate			*dateTime;			// NSDateは、UTC(+0000)協定時刻で記録 
@property (nonatomic, retain) NSNumber   *nBpHi_mmHg;
@property (nonatomic, retain) NSNumber   *nBpLo_mmHg;
@property (nonatomic, retain) NSNumber   *nMeal_cal;
@property (nonatomic, retain) NSNumber   *nPulse_bpm;
@property (nonatomic, retain) NSNumber   *nTemp_10c;
@property (nonatomic, retain) NSNumber   *nWaist_cm;
@property (nonatomic, retain) NSNumber   *nWeight_g;
@property (nonatomic, retain) NSString		*sEquipment;		// 場所や測定装置
@property (nonatomic, retain) NSString		*sNote1;
@property (nonatomic, retain) NSString		*sNote2;
@property (nonatomic, retain) NSData			*yMeal_photo;
@property (nonatomic, retain) E1body			*e1body;		// E2 <<--> E1
@end


// END
