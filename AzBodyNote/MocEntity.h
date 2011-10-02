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
@property (nonatomic, retain) NSDate			*birthday;	// NSDateは、UTC(+0000)協定時刻で記録 ⇒ 表示でタイムゾーン変換する
@property (nonatomic, retain) NSNumber   *markBpHi_mmHg;
@property (nonatomic, retain) NSNumber   *markBpLo_mmHg;
@property (nonatomic, retain) NSNumber   *markWaist_cm;
@property (nonatomic, retain) NSNumber   *markWeight_g;
@property (nonatomic, retain) NSString		*name;
@property (nonatomic, retain) NSString		*note;
@property (nonatomic, retain) NSSet			*e2records;		// E1 <-->> E2
@end

//---------------------------------------------------------------------------------------E2
@interface E2record : NSManagedObject {
}
@property (nonatomic, retain) NSNumber   *bpHi_mmHg;
@property (nonatomic, retain) NSNumber   *bpLo_mmHg;
@property (nonatomic, retain) NSString		*caution;
@property (nonatomic, retain) NSString		*condition;
@property (nonatomic, retain) NSDate			*datetime;	// NSDateは、UTC(+0000)協定時刻で記録 
@property (nonatomic, retain) NSString		*equipment;
@property (nonatomic, retain) NSNumber   *meal_cal;
@property (nonatomic, retain) NSData			*meal_photo;
@property (nonatomic, retain) NSString		*note;
@property (nonatomic, retain) NSNumber   *pulse_bpm;
@property (nonatomic, retain) NSNumber   *temp_10c;
@property (nonatomic, retain) NSNumber   *waist_cm;
@property (nonatomic, retain) NSNumber   *weight_g;
@property (nonatomic, retain) E1body			*e1body;		// E2 <<--> E1
@end


// END
