//
//  CalcView.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HEIGHT_TATE			300		// タテのときの高さ
#define HEIGHT_YOKO			220		// ヨコのときの高さ
#define GOLDENPER				1.618	// 黄金比
#define MINUS_SIGN				@"−"	// Unicode[2212] 表示用文字　[002D]より大きくするため
#define ANSWER_MAX			999999.991	// double近似値で比較するため+0.001してある
#define VIEW_HIGHT				(460 - 24)		// 画面有効高さ   -24=TabBarのため


@interface CalcView : UIView //<UITextFieldDelegate>
{
@private
	//--------------------------retain
	NSString					*mTitle;		// [AC]で表示するため
	NSDecimalNumber	*mAnswer;	// 結果
	//----------------------------------------------assign
	double						mMin;
	double						mMax;
	int							mDecimal;		// 小数桁数
	id								mTarget;
	SEL							mActionSelector;
	
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	UIView				*mSubView;
	NSDecimalNumberHandler	*mBehaviorDefault;	// 通貨既定の丸め処理
	NSDecimalNumberHandler	*mBehaviorCalc;		// 計算途中の丸め処理
	//NSArray								*mKeyButtons;
	
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//UILabel				*mLbTitle;
	UILabel				*mLbAnswer;	// 結果表示
	UILabel				*mLbFormula;	// 計算式表示

	//----------------------------------------------assign
	NSInteger			mRoundingScale;
	BOOL					mIsShow;
	int						mFunc;		// (0)Non (-4)+ (-5)- (-6)* (-7)/
	CGRect				mRectHide;		// 表示定位置
	CGRect				mRectShow;	// 隠れ位置
}

//@property (nonatomic, retain) NSString					*RzTitle;
//@property (nonatomic, retain) NSDecimalNumber	*RdecAnswer;	
//@property (nonatomic, retain) NSDecimalNumber	*RdecMin;
//@property (nonatomic, retain) NSDecimalNumber	*RdecMax;
//@property (nonatomic, assign) id		delegate;

// 公開メソッド
- (id)initWithTitle:(NSString*)title  min:(double)min  max:(double)max  decimal:(int)decimal  
			 target:(id)target action:(SEL)action;
- (void)show;

@end
