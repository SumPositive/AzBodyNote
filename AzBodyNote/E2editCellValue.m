//
//  E2editCellValue.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/02.
//  Copyright 2011 Azukid. All rights reserved.
//

#import "E2editCellValue.h"


@implementation E2editCellValue
@synthesize ibLbName, ibLbValue, ibLbUnit, ibSrValue, ibBuValue;
@synthesize RnValue, mValueMin, mValueMax, mValueRate, mValueStep;


- (void)refreshValue
{
	if (mValue < 0) {
		ibLbValue.text = NSLocalizedString(@"None",nil);
	} else {
		if (mValueRate<=1) {
			ibLbValue.text = [NSString stringWithFormat:@"%d", mValue];
		} else {
			NSInteger iInt = mValue / mValueRate;
			NSInteger iDec = mValue - iInt * mValueRate;
			if (iDec<=0) {
				ibLbValue.text = [NSString stringWithFormat:@"%ld", iInt];
			} else {
				ibLbValue.text = [NSString stringWithFormat:@"%ld.%ld", iInt, iDec];
			}
		}
	}
	//
}


- (IBAction)ibBuValue:(UIButton *)button
{
	NSLog(@"ibBuValue");
}

- (IBAction)ibSrValueChange:(UISlider *)slider
{
	//NSLog(@"ibSrValueChange .tag=%d", slider.tag);
	NSInteger iSlider = (NSInteger)(slider.value);
	//NSInteger iVal = [RnValue integerValue];
	if (mSliderBase < 0) {	// TouchDownは、Changeの後に通るため、このような処理にした。TouchUpにて(-1)にしている。
		mSliderBase = mValue;
	}
	if (mValue != mSliderBase + iSlider) {
		mValue = mSliderBase + iSlider;
		if (mValue < mValueMin) mValue = mValueMin;  // min
		else if (mValueMax < mValue) mValue = mValueMax; // max
		//NG//RnValue = [NSNumber numberWithInteger:iVal];
		[self refreshValue];
	}
}

- (IBAction)ibSrValueTouchUp:(UISlider *)slider
{	// Inside & Outside
	NSLog(@"ibSrValueTouchUp");
	slider.value = 0; // 中央に戻す
	mSliderBase = (-1);
	RnValue = [NSNumber numberWithInteger:mValue];
}


- (void)drawRect:(CGRect)rect
{
	mSliderBase = (-1);
	ibSrValue.value = 0;
	ibSrValue.minimumValue = mValueStep * -10;
	ibSrValue.maximumValue = mValueStep * 10;

	if (RnValue) {
		mValue = [RnValue integerValue];
	} else {
		mValue = (-1);
	}
	
	[self refreshValue];
}

- (void)dealloc
{
	[RnValue release], RnValue = nil;
	[super dealloc];
}

/*
 - (IBAction)ibBuValue:(UIButton *)button
 {
 NSLog(@"E2editCellValue -- ibBuValue");
 }
 
 - (IBAction)ibSrValueChange:(UISlider *)slider
 {
 NSLog(@"E2editCellValue -- ibSrValueChange");
 }
 */

@end
