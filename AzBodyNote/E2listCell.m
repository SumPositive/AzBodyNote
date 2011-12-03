//
//  E2recordCell.m
//  AzBodyNote
//
//  Created by 松山 和正 on 11/10/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "E2listCell.h"
#import "E2listTVC.h"

@implementation E2listCell
{
	//__strong E2record		*Re2node_;
	
	IBOutlet UILabel			*ibLbDate;
	IBOutlet UILabel			*ibLbBpHi;
	IBOutlet UILabel			*ibLbBpLo;
	IBOutlet UILabel			*ibLbPuls;
	IBOutlet UILabel			*ibLbWeight;
	IBOutlet UILabel			*ibLbTemp;
	IBOutlet UILabel			*ibLbNote1;
	IBOutlet UILabel			*ibLbNote2;
}
@synthesize moE2node = moE2node_;
//@synthesize ibLbBpHi, ibLbBpLo, ibLbDate, ibLbPuls, ibLbWeight, ibLbTemp;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		//moE2node_ = nil;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSString *)strValue:(NSInteger)val dec:(NSInteger)dec
{
	if (val <= 0) return nil;
	
	if (dec<=0) {
		return [NSString stringWithFormat:@"%d", val];
	} else {
		NSInteger iPow = (NSInteger)pow(10, dec); //= 10 ^ mValueDec;
		NSInteger iInt = val / iPow;
		NSInteger iDec = val - iInt * iPow;
		if (iDec<=0) {
			switch (dec) {
				case 1: return [NSString stringWithFormat:@"%ld.0", iInt]; break;
				case 2: return [NSString stringWithFormat:@"%ld.00", iInt]; break;
				default:return [NSString stringWithFormat:@"%ld", iInt]; break;
			}
		} else {
			return [NSString stringWithFormat:@"%ld.%ld", iInt, iDec];
		}
	}
}

- (void)drawRect:(CGRect)rect
{
	// ここは初期化時にしか通らないので、独自 draw にした。
}

- (void)draw
{
	if (moE2node_) 
	{
		if ([moE2node_.nYearMM integerValue]==E2_nYearMM_GOAL) {
			ibLbDate.text = @"The GOAL";  //NSLocalizedString(@"TheGoal",nil);
		} else {
			NSDateFormatter *fm = [[NSDateFormatter alloc] init];
			// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
			NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			[fm setCalendar:calendar];
			//[calendar release];
			//[df setLocale:[NSLocale systemLocale]];これがあると曜日が表示されない。
			[fm setDateFormat:@"dd  HH:mm"];
			ibLbDate.text = [fm stringFromDate:moE2node_.dateTime];
			//[fm release];
		}
		
		//NSLog(@"--- moE2node_.sNote2=%@", moE2node_.sNote2);

		ibLbBpHi.text = [self strValue:[moE2node_.nBpHi_mmHg integerValue] dec:0]; 
		ibLbBpLo.text = [self strValue:[moE2node_.nBpLo_mmHg integerValue] dec:0];
		ibLbPuls.text = [self strValue:[moE2node_.nPulse_bpm integerValue] dec:0];
		ibLbWeight.text = [self strValue:[moE2node_.nWeight_10Kg integerValue] dec:1];
		ibLbTemp.text = [self strValue:[moE2node_.nTemp_10c integerValue] dec:1];
		ibLbNote1.text = moE2node_.sNote1;
		ibLbNote2.text = moE2node_.sNote2;
	}
}

@end
