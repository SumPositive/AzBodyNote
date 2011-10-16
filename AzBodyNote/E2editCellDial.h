//
//  E2editCellDial.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/02.
//  Copyright 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MocEntity.h"
#import "AZDial.h"

@interface E2editCellDial : UITableViewCell <AZDialDelegate>
{
	id						delegate;
	UIView				*viewParent;  // ここへCalcをaddSubviewする
	E2record			*Re2record;
	NSString			*RzKey;
	
	NSInteger		mValueMin;
	NSInteger		mValueMax;
	NSInteger		mValueDec; // 小数桁数： 0=整数=10^0,  1=0.1=10^-1,  2=0.01=10^-2,  3=0.001=10^-3,
	NSInteger		mValueStep; //増減単位
	NSInteger		mValuePrev; // 直前の値（mValue=nil のときに表示する）

	IBOutlet UILabel			*ibLbValue;

	NSInteger		mSliderBase;
	NSInteger		mValue;
	AZDial				*mDial;
}

@property (nonatomic, assign) id						delegate;
@property (nonatomic, assign) UIView				*viewParent;
@property (nonatomic, retain) E2record			*Re2record;		// 結果を戻すため
@property (nonatomic, retain) NSString			*RzKey;			// 結果を戻すため
@property (nonatomic, assign) NSInteger		mValueMin;
@property (nonatomic, assign) NSInteger		mValueMax;
@property (nonatomic, assign) NSInteger		mValueDec;
@property (nonatomic, assign) NSInteger		mValueStep;
@property (nonatomic, assign) NSInteger		mValuePrev;

@property (nonatomic, retain) IBOutlet UILabel			*ibLbName;
@property (nonatomic, retain) IBOutlet UILabel			*ibLbDetail;
@property (nonatomic, retain) IBOutlet UILabel			*ibLbUnit;

//@property (nonatomic, retain) IBOutlet UILabel			*ibLbValue;

- (IBAction)ibBuValue:(UIButton *)button;
- (IBAction)ibBuNone:(UIButton *)button;

@end
