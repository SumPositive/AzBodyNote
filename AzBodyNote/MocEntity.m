//
//  MocEntity.m
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//

#import "MocEntity.h"


//---------------------------------------------------------------------------------------E1 
@implementation E1body
@dynamic dBirthday;
@dynamic nMkBpHi_mmHg;
@dynamic nMkBpLo_mmHg;
@dynamic nMkWeight_g;
@dynamic sName;
@dynamic sNote;
//@dynamic e2records;
@end

//---------------------------------------------------------------------------------------E2 
@implementation E2record
@dynamic bCaution;
@dynamic dateTime;
@dynamic nBpHi_mmHg;
@dynamic nBpLo_mmHg;
@dynamic nPulse_bpm;
@dynamic nTemp_10c;
@dynamic nWeight_g;
@dynamic nYearMM;
@dynamic sEquipment;
@dynamic sNote1;
@dynamic sNote2;
//@dynamic e1body;

/* レスポンス向上のため属性(nYearMM)にした。　このように動的に求めることもできるとの例
- (NSInteger)dateYearMM
{	// セクション表示のため「年月」を取得する
	// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents* dateComponents =
	[calendar components:NSYearCalendarUnit | NSMonthCalendarUnit  fromDate:self.dateTime];
	return [dateComponents year] * 100 + [dateComponents month];
}
 */

@end


// END