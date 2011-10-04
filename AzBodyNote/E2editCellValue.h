//
//  E2editCellValue.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/02.
//  Copyright 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MocEntity.h"

@interface E2editCellValue : UITableViewCell
{
	id						delegate;
	UIView				*viewParent;  // ここへCalcをaddSubviewする
	E2record			*Re2record;
	NSString			*RzKey;
	//NSNumber		*RnValue;
	NSInteger		mValueMin;
	NSInteger		mValueMax;
	NSInteger		mValueDec; // 小数桁数： 0=整数=10^0,  1=0.1=10^-1,  2=0.01=10^-2,  3=0.001=10^-3,
	NSInteger		mValueStep; //増減単位
	
@private
	NSInteger		mSliderBase;
	NSInteger		mValue;
}

@property (nonatomic, retain) IBOutlet UILabel			*ibLbName;
@property (nonatomic, retain) IBOutlet UILabel			*ibLbValue;
@property (nonatomic, retain) IBOutlet UILabel			*ibLbUnit;
@property (nonatomic, retain) IBOutlet UISlider			*ibSrValue;		//.tagセットするため
@property (nonatomic, retain) IBOutlet UIButton			*ibBuValue;		//.tagセットするため

@property (nonatomic, assign) id						delegate;
@property (nonatomic, assign) UIView				*viewParent;
//@property (nonatomic, retain) NSNumber		*RnValue;	// 結果を戻すため
@property (nonatomic, retain) E2record			*Re2record;		// 結果を戻すため
@property (nonatomic, retain) NSString			*RzKey;			// 結果を戻すため
@property (nonatomic, assign) NSInteger		mValueMin;
@property (nonatomic, assign) NSInteger		mValueMax;
@property (nonatomic, assign) NSInteger		mValueDec;
@property (nonatomic, assign) NSInteger		mValueStep;

// (IBAction) は、E2editTVC をオーナーにする。
//- (IBAction)ibBuValue:(UIButton *)button;
//- (IBAction)ibSrValueChange:(UISlider *)slider;

@end
