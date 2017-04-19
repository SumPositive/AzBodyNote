//
//  E2listCell.m
//  AzBodyNote
//
//  Created by 松山 和正 on 11/10/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "E2listCell.h"
#import "GViewBp.h"		//enum optType

@implementation E2listCell
@synthesize moE2node = moE2node_;
//@synthesize ibLbBpHi, ibLbBpLo, ibLbDate, ibLbPuls, ibLbWeight, ibLbTemp;

/***通らない
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		//moE2node_ = nil;
    }
    return self;
}
*/

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
	// ここは初期化時にしか通らないので、独自 draw にした。
}

- (void)draw
{
	if (moE2node_) 
	{
		NSDateFormatter *fm = [[NSDateFormatter alloc] init];
		// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
		NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
		[fm setCalendar:calendar];
		[fm setDateFormat:@"dd  HH:mm"];
		ibLbDate.text = [fm stringFromDate:moE2node_.dateTime];
		if (moE2node_.nDateOpt) {
			switch ([moE2node_.nDateOpt integerValue]) {
				case DtOpWake: //起床後
					ibIvDateOpt.image = [UIImage imageNamed:@"Icon20-Wake"]; //H20xW24px
					break;
				case DtOpRest:
					ibIvDateOpt.image = [UIImage imageNamed:@"Icon20-Rest"]; //H20xW24px
					break;
				case DtOpDown:
					ibIvDateOpt.image = [UIImage imageNamed:@"Icon20-Down"]; //H20xW24px
					break;
				case DtOpSleep: //就寝前
					ibIvDateOpt.image = [UIImage imageNamed:@"Icon20-Sleep"];
					break;
				default:
					ibIvDateOpt.image = nil;
					break;
			}
		} else {
			ibIvDateOpt.image = nil;
		}
		//NSLog(@"--- moE2node_.sNote2=%@", moE2node_.sNote2);
		ibLbBpHi.text = strValue([moE2node_.nBpHi_mmHg integerValue], 0); 
		ibLbBpLo.text = strValue([moE2node_.nBpLo_mmHg integerValue], 0); 
		ibLbPuls.text = strValue([moE2node_.nPulse_bpm integerValue], 0); 
		ibLbWeight.text = strValue([moE2node_.nWeight_10Kg integerValue], 1); 
		ibLbTemp.text = strValue([moE2node_.nTemp_10c integerValue], 1); 
		ibLbPedo.text = strValue([moE2node_.nPedometer integerValue], 0); 
		ibLbBodyFat.text = strValue([moE2node_.nBodyFat_10p integerValue] , 1); 
		ibLbSkMuscle.text = strValue([moE2node_.nSkMuscle_10p integerValue], 1); 

		if (0<[moE2node_.sNote1 length]) {
			if (0<[moE2node_.sNote2 length]) {
				ibLbNote1.text = [NSString stringWithFormat:@"%@  %@", moE2node_.sNote1,  moE2node_.sNote2];
			} else {
				ibLbNote1.text = moE2node_.sNote1;
			}
		} else {
			if (0<[moE2node_.sNote2 length]) {
				ibLbNote1.text = moE2node_.sNote2;
			} else {
				ibLbNote1.text = nil;
			}
		}
	}
	else { // GOAL!
		//  iCloud KVS 
		NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
		//E2listTVC:viewWillAppear:にて処理// [kvs synchronize]; // iCloud最新同期（取得）
		ibLbDate.text = @"Goal    ";  //NSLocalizedString(@"TheGoal",nil);
		ibIvDateOpt.image = [UIImage imageNamed:@"Icon20-Goal"];

		ibLbBpHi.text = strValue([[kvs objectForKey:Goal_nBpHi_mmHg] integerValue], 0); 
		ibLbBpLo.text = strValue([[kvs objectForKey:Goal_nBpLo_mmHg] integerValue], 0); 
		ibLbPuls.text = strValue([[kvs objectForKey:Goal_nPulse_bpm] integerValue], 0); 
		ibLbWeight.text = strValue([[kvs objectForKey:Goal_nWeight_10Kg] integerValue], 1); 
		ibLbTemp.text = strValue([[kvs objectForKey:Goal_nTemp_10c] integerValue], 1); 
		ibLbPedo.text = strValue([[kvs objectForKey:Goal_nPedometer] integerValue], 0); 
		ibLbBodyFat.text = strValue([[kvs objectForKey:Goal_nBodyFat_10p] integerValue], 1); 
		ibLbSkMuscle.text = strValue([[kvs objectForKey:Goal_nSkMuscle_10p] integerValue], 1);
		
		if (0<[azNil([kvs objectForKey:Goal_sNote1]) length]) {
			if (0<[azNil([kvs objectForKey:Goal_sNote2]) length]) {
				ibLbNote1.text = [NSString stringWithFormat:@"%@  %@",
								  [kvs objectForKey:Goal_sNote1],  [kvs objectForKey:Goal_sNote2]];
			} else {
				ibLbNote1.text = [kvs objectForKey:Goal_sNote1];
			}
		} else {
			if (0<[azNil([kvs objectForKey:Goal_sNote2]) length]) {
				ibLbNote1.text = [kvs objectForKey:Goal_sNote2];
			} else {
				ibLbNote1.text = nil;
			}
		}
	}
}

@end
