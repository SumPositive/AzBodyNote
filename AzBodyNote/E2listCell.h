//
//  E2recordCell.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MocEntity.h"


@interface E2listCell : UITableViewCell
{
	E2record		*Re2node;
	
	IBOutlet UILabel			*ibLbDate;
	IBOutlet UILabel			*ibLbBpHi;
	IBOutlet UILabel			*ibLbBpLo;
	IBOutlet UILabel			*ibLbPuls;
	IBOutlet UILabel			*ibLbWeight;
	IBOutlet UILabel			*ibLbTemp;
}

@property (nonatomic, retain) E2record		*Re2node;

/*
@property (nonatomic, retain) IBOutlet UILabel			*ibLbDate;
@property (nonatomic, retain) IBOutlet UILabel			*ibLbBpHi;
@property (nonatomic, retain) IBOutlet UILabel			*ibLbBpLo;
@property (nonatomic, retain) IBOutlet UILabel			*ibLbPuls;
@property (nonatomic, retain) IBOutlet UILabel			*ibLbWeight;
@property (nonatomic, retain) IBOutlet UILabel			*ibLbTemp;
*/

@end
