//
//  E2editCellDial.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/02.
//  Copyright 2011 Azukid. All rights reserved.
//

#import "Global.h"
#import "AzBodyNoteAppDelegate.h"
#import "MocEntity.h"
#import "E2editTVC.h"
#import "E2editCellDial.h"
#import "CalcView.h"

@implementation E2editCellDial
{
	__unsafe_unretained id						delegate;
	__unsafe_unretained UIView				*viewParent;  // ここへCalcをaddSubviewする
	
	__strong E2record			*Re2record;
	__strong NSString			*RzKey;
	
	NSInteger		mValueMin;
	NSInteger		mValueMax;
	NSInteger		mValueDec; // 小数桁数： 0=整数=10^0,  1=0.1=10^-1,  2=0.01=10^-2,  3=0.001=10^-3,
	NSInteger		mValueStep; //増減単位
	NSInteger		mValuePrev; // 直前の値（mValue=nil のときに表示する）
	
	IBOutlet UILabel			*ibLbName;
	IBOutlet UILabel			*ibLbDetail;
	IBOutlet UILabel			*ibLbUnit;
	IBOutlet UILabel			*ibLbValue;
	
	NSInteger		mSliderBase;
	NSInteger		mValue;
	AZDial				*mDial;
}

@synthesize ibLbName, ibLbDetail, ibLbUnit;  // ibLbValue
@synthesize  delegate, viewParent;
@synthesize Re2record, RzKey, mValueMin, mValueMax, mValueDec, mValueStep, mValuePrev;


- (void)refreshValue
{
	NSInteger  val = mValue;
	if (val < 0) {
		val = mValuePrev;
		ibLbValue.textColor = [UIColor brownColor];
	} else {
		ibLbValue.textColor = [UIColor blackColor];
	}

	if (mValueDec<=0) {
		ibLbValue.text = [NSString stringWithFormat:@"%d", val];
	} else {
		NSInteger iPow = (NSInteger)pow(10, mValueDec); //= 10 ^ mValueDec;
		NSInteger iInt = val / iPow;
		NSInteger iDec = val - iInt * iPow;
		if (iDec<=0) {
			//ibLbValue.text = [NSString stringWithFormat:@"%ld", iInt];
			switch (mValueDec) {
				case 1: ibLbValue.text =  [NSString stringWithFormat:@"%ld.0", iInt]; break;
				case 2: ibLbValue.text =  [NSString stringWithFormat:@"%ld.00", iInt]; break;
				default: ibLbValue.text =  [NSString stringWithFormat:@"%ld", iInt]; break;
			}
		} else {
			ibLbValue.text = [NSString stringWithFormat:@"%ld.%ld", iInt, iDec];
		}
	}
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
	//[behavior release];
	return (NSInteger)[decLong doubleValue]; // 整数値を返す
}

- (void)calcDone:(NSDecimalNumber*)decAnswer
{
	mValue = [self integerFromDecimal:decAnswer digits:mValueDec];
	if (mValue < mValueMin) mValue = mValueMin;  // min
	else if (mValueMax < mValue) mValue = mValueMax; // max

	[mDial setDial:mValue  animated:YES];
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
	//[calc release];
}

- (IBAction)ibBuNone:(UIButton *)button
{
	NSLog(@"ibBuNone");
	[mDial setDial:mValuePrev  animated:YES];
	mValue = (-1); // None
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
	NSNumber *num = [Re2record valueForKey:RzKey];
	if (num) {
		mValue = [num integerValue];
	} else {
		mValue = (-1); // None
	}

	if (mValuePrev<mValueMin || mValueMax<mValuePrev) {
		mValuePrev = (mValueMax - mValueMin) / 2; //平均値
	}
	
	NSInteger val = mValue;
	if (val < mValueMin || mValueMax < val) {
		val = mValuePrev;  //＜＜＜　前回値をセットする
	}

	
	// AZDial
	if (mDial) {
		[mDial setDial:val animated:YES];
	} else {
		// 新規生成
		mDial = [[AZDial alloc] initWithFrame:CGRectMake(15, 44, 295, 44)
									 delegate: self
										 dial: val
										  min: mValueMin
										  max: mValueMax
										 step: 1
									stepper: YES ];
		[self addSubview:mDial];
		mDial.backgroundColor = [UIColor clearColor]; //self.backgroundColor;
	}
	
	[self refreshValue];
}


#pragma mark - <AZDialDelegate>

- (void)dialChanged:(id)sender dial:(NSInteger)dial
{	// dialが変位したとき
	mValue = dial;
	[self refreshValue];
}

- (void)dialDone:(id)sender dial:(NSInteger)dial
{	// dial変位が停止したとき
	mValue = dial;
	[self refreshValue];
	
	if ([[Re2record valueForKey:RzKey] integerValue] != mValue) {
		[Re2record setValue:[NSNumber numberWithInteger:mValue] forKey:RzKey];
		
		if ([delegate respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate editUpdate];
		}
	}
}

/*
- (void)dealloc
{
	[RzKey release], RzKey = nil;
	[Re2record release], Re2record = nil;
	[super dealloc];
}*/

@end
