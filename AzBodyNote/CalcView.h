//
//  CalcView.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Global.h"


#define HEIGHT_TATE			300		// タテのときの高さ
#define HEIGHT_YOKO			220		// ヨコのときの高さ
#define GOLDENPER				1.618	// 黄金比
#define MINUS_SIGN				@"−"	// Unicode[2212] 表示用文字　[002D]より大きくするため
#define ANSWER_MAX			999999.991	// double近似値で比較するため+0.001してある
#define VIEW_HIGHT				480		//.window.rootViewController.view  addSubview:するため


@interface CalcView : UIView //<UITextFieldDelegate>
{
@private
	NSString							*title_;		// [AC]で表示するため
	NSDecimalNumber 		*answer_;	// 結果
	
	double						mMin;
	double						mMax;
	int							mDecimal;		// 小数桁数
	
	id								delegate_;
	
	UIView				*mSubView;
	NSDecimalNumberHandler	*mBehaviorDefault;	// 通貨既定の丸め処理
	NSDecimalNumberHandler	*mBehaviorCalc;		// 計算途中の丸め処理
	
	UILabel				*lbAnswer_;	// 結果表示
	UILabel				*lbFormula_;	// 計算式表示
	
	NSInteger			mRoundingScale;
	BOOL					mIsShow;
	int						mFunc;		// (0)Non (-4)+ (-5)- (-6)* (-7)/
	CGRect				mRectHide;		// 表示定位置
	CGRect				mRectShow;	// 隠れ位置
}

// 公開メソッド
//- (id)initWithTitle:(NSString*)title  min:(double)min  max:(double)max  decimal:(int)decimal  
//			 target:(__strong id)target action:(SEL)action;
- (id)initWithTitle:(NSString*)title  min:(double)min  max:(double)max  decimal:(int)decimal  delegate:(id)delegate;

- (void)show;

@end

@protocol AZCalcDelegate <NSObject>
#pragma mark - <AZCalcDelegate>
- (void)calcChanged:(id)sender  answer:(NSDecimalNumber*)answer;
- (void)calcDone:(id)sender  answer:(NSDecimalNumber*)answer;
@end
