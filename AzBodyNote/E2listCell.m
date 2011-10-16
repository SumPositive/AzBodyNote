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
@synthesize Re2node;
//@synthesize ibLbBpHi, ibLbBpLo, ibLbDate, ibLbPuls, ibLbWeight, ibLbTemp;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		Re2node = nil;
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
	if (Re2node) {
		NSDateFormatter *fm = [[NSDateFormatter alloc] init];
		// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
		NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		[fm setCalendar:calendar];
		[calendar release];
		//[df setLocale:[NSLocale systemLocale]];これがあると曜日が表示されない。
		[fm setDateFormat:@"dd  HH:mm"];
		ibLbDate.text = [fm stringFromDate:Re2node.dateTime];
		[fm release];

		ibLbBpHi.text = [self strValue:[Re2node.nBpHi_mmHg integerValue] dec:0]; 
		ibLbBpLo.text = [self strValue:[Re2node.nBpLo_mmHg integerValue] dec:0];
		ibLbPuls.text = [self strValue:[Re2node.nPulse_bpm integerValue] dec:0];
		ibLbWeight.text = [self strValue:[Re2node.nWeight_g integerValue] dec:1];
		ibLbTemp.text = [self strValue:[Re2node.nTemp_10c integerValue] dec:1];
	}
}

@end
