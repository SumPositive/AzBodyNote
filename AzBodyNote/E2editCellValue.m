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
@synthesize ibLbName, ibLbDetail, ibLbValue, ibLbUnit;
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

	[mDial setValue:mValue  animated:YES];
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

- (IBAction)ibBuNone:(UIButton *)button
{
	NSLog(@"ibBuNone");
	mValue = (-1); // None
	//[mDial setValue:mValue  animated:YES];
	[self refreshValue];
	
	if ([[Re2record valueForKey:RzKey] integerValue] != mValue) {
		[Re2record setValue:[NSNumber numberWithInteger:mValue] forKey:RzKey];
		if ([delegate respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate editUpdate];
		}
	}
}


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

	
	// AZDial
	if (!mDial) {
		mDial = [[AZDial alloc] initWithFrame:CGRectMake(10, 44, 300, 44)
									 delegate: self
											value: val
										  min: mValueMin
										  max: mValueMax
										 step: 1
									stepper: YES ];
		[self addSubview:mDial];
		mDial.backgroundColor = [UIColor clearColor]; //self.backgroundColor;
	}
	
	[self refreshValue];
}

// <AZDialDelegate>
- (void)volumeChanged:(id)sender value:(NSInteger)value
{	// Volumeが変位したとき
	ibLbValue.text = [NSString stringWithFormat:@"%ld", value];
}

- (void)volumeDone:(id)sender value:(NSInteger)value
{	// Volume変位が停止したとき
	ibLbValue.text = [NSString stringWithFormat:@"%ld", value];

	mValue = value;
	
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

@end
