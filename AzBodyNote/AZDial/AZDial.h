//
//  AZDial.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AZDial : UIView	<UIScrollViewDelegate>

- (id)initWithFrame:(CGRect)frame 
				delegate:(id)delegate 
				dial:(NSInteger)dial		// 初期値
				min:(NSInteger)min			// 最小値
				max:(NSInteger)max		// 最大値
			   step:(NSInteger)step			// 増減値
			stepper:(BOOL)stepper;			// ステッパボタン有無

- (void)setDial:(NSInteger)dial  animated:(BOOL)animated;  //NG//setValue:ダメ Key-Valueになってしまう。
- (void)setStep:(NSInteger)vstep;		// 増減値
- (void)setMin:(NSInteger)vmin;
- (void)setMax:(NSInteger)vmax;
- (void)setStepperMagnification:(CGFloat)vmagnif;
- (void)setStepperShow:(BOOL)bShow;
- (NSInteger)getDial;

@end


@protocol AZDialDelegate <NSObject>
- (void)dialChanged:(id)sender  dial:(NSInteger)dial;
- (void)dialDone:(id)sender  dial:(NSInteger)dial;
@end

