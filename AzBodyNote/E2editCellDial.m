//
//  E2editCellDial.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/02.
//  Copyright 2011 Azukid. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "MocEntity.h"
#import "E2editTVC.h"
#import "E2editCellDial.h"
#import "CalcView.h"

@implementation E2editCellDial
{
	//__unsafe_unretained id						delegate;
	//__unsafe_unretained UIView				*viewParent;  // ここへCalcをaddSubviewする
	
	//__strong E2record			*Re2record;
	//__strong NSString			*RzKey;
	
	//NSInteger		mValueMin;
	//NSInteger		mValueMax;
	//NSInteger		mValueDec; // 小数桁数： 0=整数=10^0,  1=0.1=10^-1,  2=0.01=10^-2,  3=0.001=10^-3,
	//NSInteger		mValueStep; //増減単位
	//NSInteger		mValuePrev; // 直前の値（mValue=nil のときに表示する）
	
	IBOutlet UILabel			*ibLbName;
	IBOutlet UILabel			*ibLbDetail;
	IBOutlet UILabel			*ibLbUnit;
	IBOutlet UILabel			*ibLbValue;
	
	NSInteger		mSliderBase;
	NSInteger		mValue;
	AZDial				*mDial;
}
@synthesize ibLbName, ibLbDetail, ibLbUnit;  // ibLbValue
@synthesize delegate = delegate_;
@synthesize viewParent = viewParent_;
@synthesize Re2record = Re2record_;
@synthesize RzKey = RzKey_;
@synthesize mValueMin = valueMin_;
@synthesize mValueMax = valueMax_;
@synthesize mValueDec = valueDec_;
@synthesize mDialStep = dialStep_;
@synthesize mStepperStep = stepperStep_;
@synthesize mValuePrev = valuePrev_;


- (void)refreshValue
{
	NSInteger  val = mValue;
	if (val < 0) {
		val = valuePrev_;
		ibLbValue.textColor = [UIColor brownColor];
	} else {
		ibLbValue.textColor = [UIColor blackColor];
	}

	if (valueDec_<=0) {
		ibLbValue.text = [NSString stringWithFormat:@"%d", val];
	} else {
		NSInteger iPow = (NSInteger)pow(10, valueDec_); //= 10 ^ valueDec_;
		NSInteger iInt = val / iPow;
		NSInteger iDec = val - iInt * iPow;
		if (iDec<=0) {
			//ibLbValue.text = [NSString stringWithFormat:@"%ld", iInt];
			switch (valueDec_) {
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

- (IBAction)ibBuValue:(UIButton *)button
{
	NSLog(@"ibBuValue");
	double dPow = 1.0;
	if (1 <= valueDec_) {
		dPow = pow(10.0, valueDec_);
	}
	double dMin = (double)valueMin_ / dPow;
	double dMax = (double)valueMax_ / dPow;
	//CalcView *calc = [[CalcView alloc] initWithTitle: ibLbName.text  min: dMin  max: dMax  decimal: valueDec_
	//										  target:self	  action:@selector(calcDone:)];
	CalcView *calc = [[CalcView alloc] initWithTitle: ibLbName.text  min: dMin  max: dMax  decimal: valueDec_ delegate:self];
	//[viewParent_ addSubview:calc];
	//広告やTabBarよりも上に出すため。
	[viewParent_.window.rootViewController.view  addSubview:calc];
	[calc show];
	//[calc release];
}

- (IBAction)ibBuClear:(UIButton *)button
{
	NSLog(@"ibBuClear");
	[mDial setDial:valuePrev_  animated:YES];
	mValue = (-1); // None
	[self refreshValue];
	
	if ([Re2record_ valueForKey:RzKey_] != nil) {  // nil 
		//[Re2record_ setValue:[NSNumber numberWithInteger:mValue] forKey:RzKey_];
		[Re2record_ setValue:nil forKey:RzKey_];
		if ([delegate_ respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate_ editUpdate];
		}
	}
}


- (void)drawRect:(CGRect)rect
{
	if (Re2record_==nil) return;
	assert(Re2record_);
	assert(RzKey_);
	
	if (valuePrev_<valueMin_ || valueMax_<valuePrev_) {
		valuePrev_ = (valueMax_ - valueMin_) / 2; //平均値
	}

	NSNumber *num = [Re2record_ valueForKey:RzKey_];
	if (num) {
		mValue = [num integerValue];
	} else {
		mValue = (-1); // 以下で valuePrev_(前回値)がセットされる
	}
	
	NSInteger val = mValue;
	if (val < valueMin_ || valueMax_ < val) {
		val = valuePrev_;  //＜＜＜　前回値をセットする
	}

	if (dialStep_<1) dialStep_ = 1;
	
	// AZDial
	if (mDial) {
		[mDial setMin:valueMin_];
		[mDial setMax:valueMax_];
		[mDial setStep:dialStep_];
		[mDial setStepperStep:stepperStep_];
		[mDial setDial:val animated:NO];
	} else {
		// 新規生成
		mDial = [[AZDial alloc] initWithFrame:CGRectMake(15, 44, 295, 44)
									 delegate: self
										 dial: val
										  min: valueMin_
										  max: valueMax_
										 step: dialStep_
									stepper: stepperStep_];
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
	
	if ([[Re2record_ valueForKey:RzKey_] integerValue] != mValue) {
		[Re2record_ setValue:[NSNumber numberWithInteger:mValue] forKey:RzKey_];
		
		if ([delegate_ respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate_ editUpdate];
		}
	}
}

#pragma mark - <AZCalcDelegate>
- (void)calcChanged:(id)sender  answer:(NSDecimalNumber*)answer
{
	// Nothing
}

- (void)calcDone:(id)sender  answer:(NSDecimalNumber*)answer
{
	mValue = [self integerFromDecimal:answer digits:valueDec_];
	if (mValue < valueMin_) mValue = valueMin_;  // min
	else if (valueMax_ < mValue) mValue = valueMax_; // max
	
	[mDial setDial:mValue  animated:YES];
	[self refreshValue];
	
	if ([[Re2record_ valueForKey:RzKey_] integerValue] != mValue) {
		[Re2record_ setValue:[NSNumber numberWithInteger:mValue] forKey:RzKey_];
		if ([delegate_ respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate_ editUpdate];
		}
	}
}

/*
- (void)calcDone:(NSDecimalNumber*)decAnswer
{
	mValue = [self integerFromDecimal:decAnswer digits:valueDec_];
	if (mValue < valueMin_) mValue = valueMin_;  // min
	else if (valueMax_ < mValue) mValue = valueMax_; // max
	
	[mDial setDial:mValue  animated:YES];
	[self refreshValue];
	
	if ([[Re2record_ valueForKey:RzKey_] integerValue] != mValue) {
		[Re2record_ setValue:[NSNumber numberWithInteger:mValue] forKey:RzKey_];
		if ([delegate_ respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate_ editUpdate];
		}
	}
}*/

/*
- (void)dealloc
{
	[RzKey_ release], RzKey_ = nil;
	[Re2record_ release], Re2record_ = nil;
	[super dealloc];
}*/

@end
