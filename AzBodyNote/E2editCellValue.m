//
//  E2editCellValue.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/02.
//  Copyright 2011 Azukid. All rights reserved.
//

#import "Global.h"
#import "AzBodyNoteAppDelegate.h"
#import "MocEntity.h"
#import "E2editTVC.h"
#import "E2editCellValue.h"
#import "CalcView.h"

@implementation E2editCellValue
@synthesize ibLbName, ibLbDetail, ibLbValue, ibLbUnit, ibBuValue;
@synthesize delegate, viewParent;
@synthesize Re2record, RzKey, mValueMin, mValueMax, mValueDec, mValueStep;


- (void)refreshValue
{
	if (mValue < 0) {
		ibLbValue.text = NSLocalizedString(@"None",nil);
	} else {
		if (mValueDec<=0) {
			ibLbValue.text = [NSString stringWithFormat:@"%d", mValue];
		} else {
			NSInteger iPow = (NSInteger)pow(10, mValueDec); //= 10 ^ mValueDec;
			NSInteger iInt = mValue / iPow;
			NSInteger iDec = mValue - iInt * iPow;
			if (iDec<=0) {
				ibLbValue.text = [NSString stringWithFormat:@"%ld", iInt];
			} else {
				ibLbValue.text = [NSString stringWithFormat:@"%ld.%ld", iInt, iDec];
			}
		}
	}
	//
}


#pragma mark - CalcView Action

- (NSInteger)integerFromDecimal:(NSDecimalNumber*)dec digits:(NSInteger)digits
{	
	// 小数部切り捨て
	NSDecimalNumberHandler *behavior = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundDown  // 切り捨て
																					  scale:0							// 小数部0桁
																		   raiseOnExactness:YES				// 精度
																			raiseOnOverflow:YES				// オーバーフロー
																		   raiseOnUnderflow:YES				// アンダーフロー
																		raiseOnDivideByZero:YES ];		// アンダーフロー
	NSDecimalNumber *decLong;
	if (digits <= 0) {
		decLong = [dec decimalNumberByRoundingAccordingToBehavior: behavior];  // 小数以下、切り捨てのみ
	} else {
		// x10^digits倍する
		NSDecimalNumber *decExp = [NSDecimalNumber decimalNumberWithMantissa: 1  exponent: digits  isNegative:NO];  //= 1 x 10^digits
		decLong = [dec decimalNumberByMultiplyingBy: decExp  withBehavior: behavior]; // = dec x (10^digits)
	}
	[behavior release];
	return (NSInteger)[decLong doubleValue]; // 整数値を返す
}

- (void)calcDone:(NSDecimalNumber*)decAnswer
{
	mValue = [self integerFromDecimal:decAnswer digits:mValueDec];
	if (mValue < mValueMin) mValue = mValueMin;  // min
	else if (mValueMax < mValue) mValue = mValueMax; // max
	[self refreshValue];

	if ([[Re2record valueForKey:RzKey] integerValue] != mValue) {
		[Re2record setValue:[NSNumber numberWithInteger:mValue] forKey:RzKey];
		if ([delegate respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate editUpdate];
		}
	}
}

- (IBAction)ibBuValue:(UIButton *)button
{
	NSLog(@"ibBuValue");
	double dPow = 1.0;
	if (1 <= mValueDec) {
		dPow = pow(10.0, mValueDec);
	}
	double dMin = (double)mValueMin / dPow;
	double dMax = (double)mValueMax / dPow;
	CalcView *calc = [[CalcView alloc] initWithTitle: ibLbName.text  min: dMin  max: dMax  decimal: mValueDec
											  target:self	  action:@selector(calcDone:)];
	[viewParent addSubview:calc];
	[calc show];
	[calc release];
}

- (void)mStepperChange:(UIStepper *)sender
{
	mValue = (NSInteger)sender.value;
	
	ibLbValue.text = [NSString stringWithFormat:@"%ld", mValue];
	[mVolume setValue:mValue];
	
	if ([[Re2record valueForKey:RzKey] integerValue] != mValue) {
		[Re2record setValue:[NSNumber numberWithInteger:mValue] forKey:RzKey];
		
		if ([delegate respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate editUpdate];
		}
	}
}

- (void)mBuDownTouch:(UIButton*)sender
{
	if (mValue <= mValueMin) return;

	mValue--;
	
	ibLbValue.text = [NSString stringWithFormat:@"%ld", mValue];
	[mVolume setValue:mValue];
	
	if ([[Re2record valueForKey:RzKey] integerValue] != mValue) {
		[Re2record setValue:[NSNumber numberWithInteger:mValue] forKey:RzKey];
		
		if ([delegate respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate editUpdate];
		}
	}
}

- (void)mBuUpTouch:(UIButton*)sender
{
	if (mValueMax <= mValue) return;
	
	mValue++;
	
	ibLbValue.text = [NSString stringWithFormat:@"%ld", mValue];
	[mVolume setValue:mValue];
	
	if ([[Re2record valueForKey:RzKey] integerValue] != mValue) {
		[Re2record setValue:[NSNumber numberWithInteger:mValue] forKey:RzKey];
		
		if ([delegate respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate editUpdate];
		}
	}
}

/*
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
	//RnValue = [NSNumber numberWithInteger:mValue];
	if ([[Re2record valueForKey:RzKey] integerValue] != mValue) {
		//AzBodyNoteAppDelegate *appDelegate = (AzBodyNoteAppDelegate *)[[UIApplication sharedApplication] delegate];
		//appDelegate.mIsUpdate = YES; // 変更あり
		[Re2record setValue:[NSNumber numberWithInteger:mValue] forKey:RzKey];
		
		if ([delegate respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate editUpdate];
		}
	}
}*/


- (void)drawRect:(CGRect)rect
{
	assert(Re2record);
	assert(RzKey);
	NSNumber *num = [Re2record valueForKey:RzKey ];
	if (num) {
		mValue = [num integerValue];
	} else {
		//mValue = (-1); // None
		mValue = (mValueMax - mValueMin) / 2;  //＜＜＜　前回値をセットする
	}
	
	NSInteger val = mValue;
	if (val < mValueMin || mValueMax < val) {
		val = (mValueMax - mValueMin) / 2;  //＜＜＜　前回値をセットする
	}

	mIsOS5 = ([[[UIDevice currentDevice] systemVersion] compare:@"5.0"] != NSOrderedAscending);  // !<  (>=) "5.0"
	
	if (mIsOS5) {	//iOS5 以上
		if (!mStepper) {
			mStepper = [[UIStepper alloc] initWithFrame:CGRectMake(10, 52, 0, 0)];
			[mStepper addTarget:self action:@selector(mStepperChange:) forControlEvents:UIControlEventValueChanged];
			[self addSubview:mStepper];
			mStepper.minimumValue = mValueMin;
			mStepper.maximumValue = mValueMax;
			mStepper.stepValue = 1.0;
			mStepper.value = val;
		}
		mBuDown = nil;
		mBuUp = nil;
	} else {
		if (!mBuUp) {
			mBuUp = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			[mBuUp addTarget:self action:@selector(mBuUpTouch:) forControlEvents:UIControlEventTouchUpInside];
			mBuUp.frame = CGRectMake(10+44+5, 51, 44, 30);
			[self addSubview:mBuUp];
			mBuUp.titleLabel.text = @"+";
		}
		if (!mBuDown) {
			mBuDown = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			[mBuDown addTarget:self action:@selector(mBuDownTouch:) forControlEvents:UIControlEventTouchUpInside];
			mBuDown.frame = CGRectMake(10, 51, 44, 30);
			[self addSubview:mBuDown];
			mBuDown.titleLabel.text = @"-";
		}
		mStepper = nil;
	}
	
	// AZVolume
	if (!mVolume) {
		mVolume = [[AZVolume alloc] initWithFrame:CGRectMake(115, 44, 200, 44) delegate:self
											value:val  min:mValueMin  max:mValueMax  step:1];
		[self addSubview:mVolume];
		mVolume.backgroundColor = self.backgroundColor;
	}
	
	[self refreshValue];
}

// <AZVolumeDelegate>
- (void)volumeChanged:(id)sender value:(NSInteger)value
{	// Volumeが変位したとき
	ibLbValue.text = [NSString stringWithFormat:@"%ld", value];
	//ibLbValue.backgroundColor = [UIColor yellowColor];
	if (mStepper) {	//iOS5 以上
		mStepper.value = value;
	}
}

- (void)volumeDone:(id)sender value:(NSInteger)value
{	// Volume変位が停止したとき
	ibLbValue.text = [NSString stringWithFormat:@"%ld", value];
	//ibLbValue.backgroundColor = [UIColor greenColor];

	mValue = value;
	if (mStepper) {	//iOS5 以上
		mStepper.value = value;
	}
	
	if ([[Re2record valueForKey:RzKey] integerValue] != mValue) {
		[Re2record setValue:[NSNumber numberWithInteger:mValue] forKey:RzKey];
		
		if ([delegate respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate editUpdate];
		}
	}
}

- (void)dealloc
{
	[RzKey release], RzKey = nil;
	[Re2record release], Re2record = nil;
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
