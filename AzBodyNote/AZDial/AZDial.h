//
//  AZDial.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AZDial : UIView	<UIScrollViewDelegate>
{
@private
	UIScrollView			*mScrollView;
	UIImageView		*mImgBack;
	id							mDelegate;
	
	NSInteger			mValue;
	NSInteger			mVmin;
	NSInteger			mVmax;
	NSInteger			mVstep;
	
	//CGFloat				mScrollMin; = 0 固定
	CGFloat				mScrollMax;		// ScrollView左端から右端までの距離
	CGFloat				mScrollOfs;		// ScrollView左端からの距離

	//BOOL					mIsMoved;
	UIImageView		*mIvLeft;
	UIImageView		*mIvCenter;
	UIImageView		*mIvRight;
	
	// Stepper button
	BOOL					mIsOS5;			//=YES: iOS5以上
	UIStepper				*mStepper;		// iOS5以上
	UIButton				*mStepBuUp;		// iOS5未満
	UIButton				*mStepBuDown;	// iOS5未満
	CGFloat				mStepperMag;	// ステッパーの刻みを mVstep * mStepperMag にする
}

- (id)initWithFrame:(CGRect)frame 
				delegate:(id)delegate 
				value:(NSInteger)value		// 初期値
				min:(NSInteger)vmin			// 最小値
				max:(NSInteger)vmax		// 最大値
			   step:(NSInteger)vstep			// 増減値
			stepper:(BOOL)stepper;			// ステッパボタン有無

- (void)setValue:(NSInteger)value  animated:(BOOL)animated;
- (void)setStep:(NSInteger)vstep;		// 増減値
- (void)setMin:(NSInteger)vmin;
- (void)setMax:(NSInteger)vmax;
- (void)setStepperMagnification:(CGFloat)vmagnif;
- (void)setStepperShow:(BOOL)bShow;
- (NSInteger)getValue;

@end


@protocol AZDialDelegate <NSObject>
- (void)volumeChanged:(id)sender  value:(NSInteger)value;
- (void)volumeDone:(id)sender  value:(NSInteger)value;
@end

