//
//  E2listCell.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Global.h"
#import "MocEntity.h"


@interface E2listCell : UITableViewCell
{
	IBOutlet UILabel			*ibLbDate;
	IBOutlet UILabel			*ibLbBpHi;
	IBOutlet UILabel			*ibLbBpLo;
	IBOutlet UILabel			*ibLbPuls;
	IBOutlet UILabel			*ibLbWeight;
	IBOutlet UILabel			*ibLbTemp;
	IBOutlet UILabel			*ibLbNote1;
	IBOutlet UILabel			*ibLbPedo;
	IBOutlet UILabel			*ibLbBodyFat;
	IBOutlet UILabel			*ibLbSkMuscle;
}

@property (nonatomic, retain) E2record		*moE2node;

- (void)draw;

@end
