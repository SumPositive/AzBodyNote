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
