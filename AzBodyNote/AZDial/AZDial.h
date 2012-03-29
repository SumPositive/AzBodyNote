//
//  AZDial.h
//  AZClass
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//
// ------------------------------------------------ AZClass 使用規則
// マスタソースは、AZClass フォルダ配下に保存する。
// 各アプリソースへコピーして使用する。
// 修正あるときは、各アプリソースで仕上げた後、マスタへコピーすること。
//
// ------------------------------------------------ Update History
// 2012-03-29 Up: setStepperMagnification:廃止し、setStepperStep:新設
// 2012-01-19 Fix: step>1のときmin未満になることを回避
// 2011-10-06 Start.
// ------------------------------------------------ 

#import <UIKit/UIKit.h>

@interface AZDial : UIView	<UIScrollViewDelegate>

- (id)initWithFrame:(CGRect)frame delegate:(id)delegate 
			   dial:(NSInteger)dial		// 初期値
				min:(NSInteger)min			// 最小値
				max:(NSInteger)max		// 最大値
			   step:(NSInteger)step			// 増減値
			stepper:(NSInteger)stepperStep;	//2012-03-29// ステッパ増減値  0=非表示

- (void)setFrame:(CGRect)frame;	// NEW 回転のため

- (void)setDial:(NSInteger)dial  animated:(BOOL)animated;  //NG//setValue:ダメ Key-Valueになってしまう。
- (void)setMin:(NSInteger)vmin;
- (void)setMax:(NSInteger)vmax;
- (void)setStep:(NSInteger)vstep;	// 増減値
- (void)setStepperShow:(BOOL)bShow;
- (void)setStepperStep:(NSInteger)vstep;	//2012-03-29// 増減値
//2012-03-29//- (void)setStepperMagnification:(CGFloat)vmagnif;
- (NSInteger)getDial;

@end


@protocol AZDialDelegate <NSObject>
#pragma mark - <AZDialDelegate>
- (void)dialChanged:(id)sender  dial:(NSInteger)dial;
- (void)dialDone:(id)sender  dial:(NSInteger)dial;
@end

