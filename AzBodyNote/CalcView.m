//
//  CalcView.m
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//

#import "Global.h"
#import "CalcView.h"


//----------------------------------------------------------NSMutableArray Stack Method
@interface NSMutableArray (StackAdditions)
- (void)push:(id)obj;
- (id)pop;
@end

@implementation NSMutableArray (StackAdditions)
- (void)push:(id)obj
{
	[self addObject: obj];
}

- (id)pop
{
    // nil if [self count] == 0
    id lastObject = [[[self lastObject] retain] autorelease];
    if (lastObject)
        [self removeLastObject];
    return lastObject;
}
@end
//----------------------------------------------------------NSMutableArray Stack Method


@interface CalcView (PrivateMethods)
int levelOperator( NSString *zOpe );  // 演算子の優先順位
- (NSDecimalNumber *)decimalAnswerFomula:(NSString *)strFomula;	// autorelease
//- (void)textFieldDidChange:(UITextField *)textField;
- (void)hide;
- (void)done;
- (void)cancel;
@end

@implementation CalcView
//@synthesize RzTitle;
//@synthesize RdecNum, RdecMin, RdecMax;
//@synthesize delegate;


#pragma mark - Action

// zFomula を計算し、答えを RdecAnswer に保持しながら mLbAnswer.text に表示する
- (void)finalAnswer:(NSString *)zFomula
{
	[mAnswer release], mAnswer = [self decimalAnswerFomula:zFomula]; // 戻りObjは、retainされている
	//NSLog(@"**********1 RdecAnswer=%@", RdecAnswer);
	if (mAnswer) {
		if (ANSWER_MAX < fabs([mAnswer doubleValue])) {
			mLbAnswer.text = @"Game Over";
			[mAnswer release], mAnswer = [[NSDecimalNumber alloc] initWithString:@"0.0"];
			// textField.text は、そのままなので計算続行可能。
			return;
		}
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // ＜＜計算途中、通貨小数＋2桁表示するため
		//[formatter setLocale:[NSLocale currentLocale]]; 
		[formatter setPositiveFormat:@"#,##0.####"];
		[formatter setNegativeFormat:@"-#,##0.####"];
		// 表示のみ　Rentity更新はしない
		mLbAnswer.text = [formatter stringFromNumber:mAnswer];
		[formatter release];
	}
	else {
		mLbAnswer.text = @"?";
	}
}

- (void)formulaShow
{
	if (mLbFormula.hidden==YES) {
		mLbFormula.hidden = NO;
		CGRect rc = mLbAnswer.frame;
		rc.size.height = 50 - mLbFormula.frame.size.height;
		mLbAnswer.frame = rc;
		mLbAnswer.font = [UIFont boldSystemFontOfSize:34];
	}
}
- (void)formulaHide
{
	if (mLbFormula.hidden==NO) {
		mLbFormula.hidden = YES;
		CGRect rc = mLbAnswer.frame;
		rc.size.height = 50;
		mLbAnswer.frame = rc;
		mLbAnswer.font = [UIFont boldSystemFontOfSize:50];
	}
}

- (void)buttonCalc:(UIButton *)button
{
	//AzLOG(@"buttonCalc: text[%@] tag(%d)", button.titleLabel.text, (int)button.tag);
	
	//クリック音を入れてみたが、無い方が良さそう。
	//AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate audioPlayer:@"Tock.caf"];  // キークリック音
	
	if (mLbAnswer.tag==0) {
		mLbAnswer.text = @"";
		mLbAnswer.tag = 1; // Answer
	}
	
	switch (button.tag) 
	{
		case 1: // 数値  ＜＜常時 Formulaの方へ書き込み、書式化したものを Answerへ表示する
			mLbFormula.text = [mLbFormula.text stringByAppendingString:button.titleLabel.text];
			break;
			
		case 2: { // 演算子
			mLbFormula.text = [mLbFormula.text stringByAppendingString:button.titleLabel.text];
			[self formulaShow];
		} break;
			
		case 4: { // AC
			[mAnswer release], mAnswer = nil;
			mLbAnswer.text = mTitle;		mLbAnswer.tag = 0; // Title
			[self formulaHide];
			mLbFormula.text = @"";
		} return;
			
		case 5: { // BS
				int iLen = [mLbFormula.text length];
				if (1 <= iLen) {
					mLbFormula.text = [mLbFormula.text substringToIndex:iLen-1];
				} else {
					//[AC]と同じ
					[mAnswer release], mAnswer = nil;
					mLbAnswer.text = mTitle;		mLbAnswer.tag = 0; // Title
					[self formulaHide];
					mLbFormula.text = @"";
				}
		} break;
			
	/*	case 6: // +/-
			if ([mLbFormula.text hasPrefix:@"-"]) {
				mLbFormula.text = [mLbFormula.text substringFromIndex:1];
			} else {
				mLbFormula.text = [NSString stringWithFormat:@"-(%@)", mLbFormula.text];
			}
			break;　*/
		case 6:	// [Cancel] AzBodyNote
			[self hide];
			return;
			break;
			
		case 9: // [Done]
			NSLog(@"[Done] RdecAnswer=%@", mAnswer);
			[self done];
			return;
			
		default:
			NSLog(@"ERROR");
			return;
	}
	
	// mLbFormula.text を計算し、その結果を mLbAnswer に表示する
	[self finalAnswer:mLbFormula.text];
	
}

- (void)show
{
	// アニメ準備
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; //減速
	[UIView setAnimationDuration:0.4];
	
	[self setFrame:mRectShow]; // 表示位置へ
	
	// Complete the animation
	[UIView commitAnimations];
	
	// 丸め設定
	[NSDecimalNumber setDefaultBehavior:mBehaviorCalc];	// 計算途中の丸め
}

- (void)hide_after_dissmiss
{	// hideアニメ終了後に呼び出されるので破棄する
	[self removeFromSuperview];
}

- (void)hide		// 閉じて破棄する
{
	[mAnswer release], mAnswer = nil;

	// アニメ準備
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationDuration:0.8];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];//加速
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hide_after_dissmiss)]; //アニメーション終了後に呼び出す＜＜setAnimationDelegate必要

	// アニメ終了位置
	[self setFrame:mRectHide];	// 隠す位置へ
	// 丸め設定
	[NSDecimalNumber setDefaultBehavior:mBehaviorDefault];
	
	// アニメ実行
	[UIView commitAnimations];
}

- (void)cancel
{
	[self hide];
}

- (void)done	// E3recordDetailTVCの中から呼び出されることがある
{
	if (mAnswer && mActionSelector)
	{
		//AzRETAIN_CHECK(@"save: RdecAnswer", RdecAnswer, 0);
		// デフォルト丸め処理
		[mAnswer release], mAnswer = [mAnswer decimalNumberByRoundingAccordingToBehavior:mBehaviorDefault];
		[mTarget performSelector:mActionSelector withObject:[mAnswer copy]];  // 受け取った側でreleaseすること
	}
	[self hide];
}


/*
 計算式		⇒　逆ポーランド記法
 "5 + 4 - 3"	⇒ "5 4 3 - +"
 "5 + 4 * 3 + 2 / 6" ⇒ "5 4 3 * 2 6 / + +"
 "(1 + 4) * (3 + 7) / 5" ⇒ "1 4 + 3 7 + 5 * /" OR "1 4 + 3 7 + * 5 /"
 
 "T ( 5 + 2 )" ⇒ "5 2 + T"
 */
static NSInteger siCalcMethod;		// 0=電卓式(2+2x2=8)　　1=計算式(2+2x2=6)

int levelOperator( NSString *zOpe )  // 演算子の優先順位
{
	if ([zOpe isEqualToString:@"*"] || [zOpe isEqualToString:@"/"]) {
		return 1;
	}
	else if ([zOpe isEqualToString:@"+"] || [zOpe isEqualToString:@"-"]) {
		if (siCalcMethod==0) return 1; // 電卓式(2+2x2=8) につき四則同順
		return 2;
	}
	return 99;
}

- (NSDecimalNumber *)decimalAnswerFomula:(NSString *)strFomula	// 計算式 ⇒ 逆ポーランド記法(Reverse Polish Notation) ⇒ 答え
{
	if ([strFomula length] <= 0) return nil;
	
	NSMutableArray *maStack = [NSMutableArray new];	// - Stack Method
	NSMutableArray *maRpn = [NSMutableArray new]; // 逆ポーランド記法結果
	NSDecimalNumber *decAns = nil;
	
	//-------------------------------------------------localPool BEGIN >>> @finaly release
	NSAutoreleasePool *autoPool = [[NSAutoreleasePool alloc] init]; //イベント（タッチ）毎の解放では不足(落ちる)なので独自に解放する
	@try {
		NSString *zTokn;
		NSString *zz;
		
		NSString *zTemp = [strFomula stringByReplacingOccurrencesOfString:@" " withString:@""]; // [ ]スペース除去
		NSString *zFlag = nil;
		if ([zTemp hasPrefix:@"-"] || [zTemp hasPrefix:@"+"]) {		// 先頭が[-]や[+]ならば符号として処理する
			zFlag = [zTemp substringToIndex:1]; // 先頭の1字
			zTemp = [zTemp substringFromIndex:1]; // 先頭の1字を除く
		}
		// マイナス符号 ⇒ " -"
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"×-" withString:@"× s"];  
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"÷-" withString:@"÷ s"];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"+-" withString:@"+ s"];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"--" withString:@"- s"];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"(-" withString:@"( s"];
		// マイナス演算子 ⇒ " - "
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@")-" withString:@") s "]; 
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"-(" withString:@" s ("];
		// 残った "-" を演算子になるように " s " にする
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"-" withString:@" s "];  
		// "s" を "-" に戻す
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"s" withString:@"-"];
		
		// [+]を挿入した結果、おかしくなる組み合わせを補正する
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"×+" withString:@"×"];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"÷+" withString:@"÷"];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"++" withString:@"+"];
		// 演算子の両側にスペース挿入
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"*" withString:@" * "]; // 前後スペース
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"/" withString:@" / "]; // 前後スペース
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"×" withString:@" * "]; // 半角文字化
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"÷" withString:@" / "]; // 半角文字化
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"+" withString:@" + "]; // [-]は演算子ではない
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"(" withString:@" ( "];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@")" withString:@" ) "];
		
		if (zFlag) {
			zTemp = [zFlag stringByAppendingString:zTemp]; // 先頭に符号を付ける
		}
		// スペースで区切られたコンポーネント(部分文字列)を切り出す
		NSArray *arComp = [zTemp componentsSeparatedByString:@" "];
		NSLog(@"arComp[]=%@", arComp);
		
		NSInteger iCapLeft = 0;
		NSInteger iCapRight = 0;
		NSInteger iCntOperator = 0;	// 演算子の数　（関数は除外）
		NSInteger iCntNumber = 0;	// 数値の数
		
		for (int index = 0; index < [arComp count]; index++) 
		{
			zTokn = [arComp objectAtIndex:index];
			//AzLOG(@"arComp[%d]='%@'", index, zTokn);
			
			if ([zTokn length] < 1 || [zTokn hasPrefix:@" "]) {
				// パス
			}
			else if ([zTokn doubleValue] != 0.0 || [zTokn hasSuffix:@"0"]) {		// 数値ならば
				iCntNumber++;
				[maRpn push:zTokn];
			}
			else if ([zTokn isEqualToString:@")"]) {	// "("までスタックから取り出してRPNへ追加、両括弧は破棄する
				iCapRight++;
				while ((zz = [maStack pop])) {
					if ([zz isEqualToString:@"("]) break; // 両カッコは、破棄する
					[maRpn push:zz];
				}
			}
			else if ([zTokn isEqualToString:@"("]) {
				iCapLeft++;
				[maStack push:zTokn];
			}
			else {
				while (0 < [maStack count]) {
					//			 スタック最上位の演算子優先順位 ＜ トークンの演算子優先順位
					if (levelOperator([maStack lastObject]) <= levelOperator(zTokn)) {
						[maRpn push:[maStack pop]];  // スタックから取り出して、それをRPNへ追加
					} else {
						break;
					}
				}
				// スタックが空ならばトークンをスタックへ追加する
				iCntOperator++;
				[maStack push:zTokn];
			}
		}
		// スタックに残っているトークンを全て逆ポーランドPUSH
		while ((zz = [maStack pop])) {
			[maRpn push:zz];
		}
		
		// 数値と演算子の数チェック
		if (iCntNumber < iCntOperator + 1) {
			@throw NSLocalizedString(@"Too many operators", nil); // 演算子が多すぎる
		}
		else if (iCntNumber > iCntOperator + 1) {
			@throw NSLocalizedString(@"Insufficient operator", nil); // 演算子が足らない
		}
		// 括弧チェック
		if (iCapLeft < iCapRight) {
			@throw NSLocalizedString(@"Closing parenthesis is excessive", nil); // 括弧が閉じ過ぎ
		}
		else if (iCapLeft > iCapRight) {
			@throw NSLocalizedString(@"Unclosed parenthesis", nil); // 括弧が閉じていない
		}
		
#ifdef AzDEBUG
		for (int index = 0; index < [maRpn count]; index++) 
		{
			AzLOG(@"maRpn[%d]='%@'", index, [maRpn objectAtIndex:index]);
		}
#endif
		
		// スタック クリア
		[maStack removeAllObjects]; //iStackIdx = 0;
		//-------------------------------------------------------------------------------------
		// maRpn 逆ポーランド記法を計算する
		NSDecimalNumber *d1, *d2;
		
		// この内部だけの丸め指定
		NSDecimalNumberHandler *behavior = [[NSDecimalNumberHandler alloc]
											initWithRoundingMode:NSRoundBankers		// 偶数丸め
											scale:mRoundingScale + 12	// 丸めた後の桁数
											raiseOnExactness:YES		// 精度
											raiseOnOverflow:YES			// オーバーフロー
											raiseOnUnderflow:YES		// アンダーフロー
											raiseOnDivideByZero:YES ];	// アンダーフロー
		[NSDecimalNumber setDefaultBehavior:behavior];	// 計算途中の丸め
		[behavior release];
		
		for (int index = 0; index < [maRpn count]; index++) 
		{
			NSString *zTokn = [maRpn objectAtIndex:index];
			
			if ([zTokn isEqualToString:@"*"]) {
				if (2 <= [maStack count]) {
					d2 = [NSDecimalNumber decimalNumberWithString:[maStack pop]]; // スタックからPOP
					d1 = [NSDecimalNumber decimalNumberWithString:[maStack pop]]; // スタックからPOP
					d1 = [d1 decimalNumberByMultiplyingBy:d2]; // d1 * d2
					[maStack push:[d1 description]];
				}
			}
			else if ([zTokn isEqualToString:@"/"]) {
				if (2 <= [maStack count]) {
					d2 = [NSDecimalNumber decimalNumberWithString:[maStack pop]]; // スタックからPOP
					d1 = [NSDecimalNumber decimalNumberWithString:[maStack pop]]; // スタックからPOP
					if ([d2 doubleValue] == 0.0) { // 0割
						@throw NSLocalizedString(@"How do you divide by zero", nil);
					}
					d1 = [d1 decimalNumberByDividingBy:d2]; // d1 / d2
					[maStack push:[d1 description]];
				}
			}
			else if ([zTokn isEqualToString:@"-"]) {
				if (1 <= [maStack count]) {
					d2 = [NSDecimalNumber decimalNumberWithString:[maStack pop]]; // スタックからPOP
					if (1 <= [maStack count]) {
						d1 = [NSDecimalNumber decimalNumberWithString:[maStack pop]]; // スタックからPOP
					} else {
						d1 = [NSDecimalNumber zero]; // 0.0;
					}
					d1 = [d1 decimalNumberBySubtracting:d2]; // d1 - d2
					[maStack push:[d1 description]];
				}
			}
			else if ([zTokn isEqualToString:@"+"]) {
				if (1 <= [maStack count]) {
					d2 = [NSDecimalNumber decimalNumberWithString:[maStack pop]]; // スタックからPOP
					if (1 <= [maStack count]) {
						d1 = [NSDecimalNumber decimalNumberWithString:[maStack pop]]; // スタックからPOP
					} else {
						d1 = [NSDecimalNumber zero]; // 0.0;
					}
					d1 = [d1 decimalNumberByAdding:d2]; // d1 + d2
					[maStack push:[d1 description]];
				}
			}
			else {
				//[maStack addObject:zTokn];  iStackIdx++; // スタックPUSH
				[maStack push:zTokn]; // 数値をスタックへPUSH
			}
		}
		
		// スタックに残った最後が答え
		if ([maStack count] == 1) {
			//計算途中精度を通貨小数＋2桁にする
			decAns = [NSDecimalNumber decimalNumberWithString:[maStack pop]];
			//NSLog(@"**********1 decAns=%@", decAns);
			decAns = [decAns decimalNumberByRoundingAccordingToBehavior:mBehaviorCalc]; // 計算結果の丸め処理
			//NSLog(@"**********2 decAns=%@", decAns);
			[decAns retain]; // localPool release されないように retain しておく。
		}
		else {
			@throw @"zRpnCalc:ERROR: [maStack count] != 1";
		}
	}
	@catch (NSException * errEx) {
		NSLog(@"Calc: error %@ : %@\n", [errEx name], [errEx reason]);
		decAns = nil;
	}
	@catch (NSString *errMsg) {
		NSLog(@"Calc: error=%@", errMsg);
		decAns = nil;
	}
	@finally {
		[autoPool release];
		//-------------------------------------------------localPool END
		[maRpn release];
		[maStack release];
	}
	return decAns;
}



#pragma mark - View lifecicle

//- (id)initWithTitle:(NSString*)zTitle min:(double)dMin max:(double)dMax delegate:(id)delagate
- (id)initWithTitle:(NSString*)title  min:(double)min  max:(double)max  decimal:(int)decimal 
			 target:(id)target action:(SEL)action
{
	assert(min < max);
	assert(-1 <= decimal);	// (-1)通貨専用
	assert(target);
	assert(action);
	
	mTarget = target;
	mActionSelector = action;

	mRectShow = CGRectMake(0, 0, 320, VIEW_HIGHT);  // self.frame;
	mRectHide = mRectShow;
	mRectHide.origin.y = mRectHide.size.height; // 下部に隠す為

	self = [super initWithFrame:mRectHide];
	if (self==nil) return nil; // ERROR

	self.backgroundColor = [UIColor clearColor];
	self.userInteractionEnabled = YES; // このViewがタッチを受ける

	mMin = min;
	mMax = max;
	mDecimal = decimal;
	mAnswer = nil;
	mIsShow = NO;
	mTitle = [title copy];	// [AC]で表示するため保持

	NSUserDefaults *udef = [NSUserDefaults standardUserDefaults];
	siCalcMethod = [udef integerForKey:GD_SetCalcMethod];	// 0=電卓式(2+2x2=8)　　1=計算式(2+2x2=6)

	//------------------------------------------
	assert(mSubView==nil);
	mSubView = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_HIGHT-250, 320, 250)]; // 縦横固定にする
	[self addSubview:mSubView], [mSubView release];
	mSubView.backgroundColor = [UIColor blackColor];
	mSubView.userInteractionEnabled = YES;
	//[self bringSubviewToFront:mSubView];
	// この mSubView に以下のパーツを載せる
	//------------------------------------------
/*	mLbTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 100, 30)];
	mLbTitle.backgroundColor = [UIColor whiteColor];
	mLbTitle.textColor = [UIColor blackColor];
	mLbTitle.text = title;
  	mLbTitle.textAlignment = UITextAlignmentRight;
	mLbTitle.font = [UIFont boldSystemFontOfSize:28];
	[mSubView addSubview:mLbTitle], [mLbTitle release]; */
	//------------------------------------------
	mLbAnswer = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 50)];
	mLbAnswer.backgroundColor = [UIColor blackColor];
	mLbAnswer.textColor = [UIColor whiteColor];
  	mLbAnswer.textAlignment = UITextAlignmentCenter;
	mLbAnswer.font = [UIFont boldSystemFontOfSize:50];
	mLbAnswer.minimumFontSize = 16;
	mLbAnswer.adjustsFontSizeToFitWidth = YES;
	mLbAnswer.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	[mSubView addSubview:mLbAnswer], [mLbAnswer release];
	mLbAnswer.tag = 0;	// (0)title  (1)answer
	mLbAnswer.text = mTitle;
	//------------------------------------------
	mLbFormula = [[UILabel alloc] initWithFrame:CGRectMake(0, 
														   mLbAnswer.frame.origin.y + mLbAnswer.frame.size.height - 16, 320, 16)];
	mLbFormula.backgroundColor = [UIColor brownColor];
	mLbFormula.textColor = [UIColor whiteColor];
  	mLbFormula.textAlignment = UITextAlignmentCenter;
	mLbFormula.font = [UIFont boldSystemFontOfSize:14];
	mLbFormula.minimumFontSize = 10;
	mLbFormula.adjustsFontSizeToFitWidth = YES;
	mLbFormula.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	[mSubView addSubview:mLbFormula], [mLbFormula release];
	mLbFormula.hidden = YES;
	mLbFormula.text = @"";
	
	//------------------------------------------
	float fxGap = 2;	// Xボタン間隔
	float fyGap;		// Yボタン間隔
	float fx;
	float fy;
	float fyTop;
	float fW;
	float fH;

	fy = mLbAnswer.frame.origin.y + mLbAnswer.frame.size.height + 2;
	fx = fxGap;
	fW = (320 - fxGap) / 5 - fxGap; // 1ページ5列
	fyGap = 5;	// Yボタン間隔
	fH = fW / GOLDENPER; // 黄金比
	fyTop = fy + fyGap;

	//NSMutableArray *maBu = [NSMutableArray new];
	int iIndex = 0;
	for (int iCol=0; iCol<5; iCol++)
	{
		fy = fyTop;
		for (int iRow=0; iRow<4; iRow++)
		{
			UIButton *bu = [UIButton buttonWithType:UIButtonTypeCustom];
			bu.titleLabel.font = [UIFont boldSystemFontOfSize:32];
			[bu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			bu.frame = CGRectMake(fx,fy, fW,fH);
			
			switch (iIndex) // bu.tag=1:数値　2:演算子　3:関数　4:Ac 5:BS 6:+/-   9:=
			{
				case  0: bu.tag=4; [bu setTitle:@"AC" forState:UIControlStateNormal];  
					bu.titleLabel.font = [UIFont boldSystemFontOfSize:24]; 
					[bu setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
					break;

				case  1: bu.tag=5; [bu setTitle:@"BS" forState:UIControlStateNormal];  
					bu.titleLabel.font = [UIFont boldSystemFontOfSize:24]; 
					[bu setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
					break;
				
				case  2: bu.tag=6; [bu setTitle:NSLocalizedString(@"Cancel",nil) forState:UIControlStateNormal]; 	// AzBodyNote
					bu.titleLabel.font = [UIFont systemFontOfSize:14]; 
					[bu setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
					break;

				case  3: bu.tag=1; [bu setTitle:@"00" forState:UIControlStateNormal]; break;
				
					
				case  4: bu.tag=1; [bu setTitle:@"7" forState:UIControlStateNormal]; break;
				case  5: bu.tag=1; [bu setTitle:@"4" forState:UIControlStateNormal]; break;
				case  6: bu.tag=1; [bu setTitle:@"1" forState:UIControlStateNormal]; break;
				case  7: bu.tag=1; [bu setTitle:@"0" forState:UIControlStateNormal]; break;

				case  8: bu.tag=1; [bu setTitle:@"8" forState:UIControlStateNormal]; break;
				case  9: bu.tag=1; [bu setTitle:@"5" forState:UIControlStateNormal]; break;
				case 10: bu.tag=1; [bu setTitle:@"2" forState:UIControlStateNormal]; break;
				case 11: bu.tag=1; [bu setTitle:@"." forState:UIControlStateNormal]; break;

				case 12: bu.tag=1; [bu setTitle:@"9" forState:UIControlStateNormal]; break;
				case 13: bu.tag=1; [bu setTitle:@"6" forState:UIControlStateNormal]; break;
				case 14: bu.tag=1; [bu setTitle:@"3" forState:UIControlStateNormal]; break;
				case 15: bu.tag=9; 
					[bu setTitle:NSLocalizedString(@"Done",nil) forState:UIControlStateNormal];
					bu.titleLabel.font = [UIFont boldSystemFontOfSize:20];
					[bu setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
					break;
					
				case 16: bu.tag=2; [bu setTitle:@"÷" forState:UIControlStateNormal]; break;
				case 17: bu.tag=2; [bu setTitle:@"×" forState:UIControlStateNormal]; break;
				case 18: bu.tag=2; [bu setTitle:@"-" forState:UIControlStateNormal]; break;
				case 19: bu.tag=2; [bu setTitle:@"+" forState:UIControlStateNormal]; break;

		/*		case 20: bu.tag=2; [bu setTitle:@"(" forState:UIControlStateNormal]; break;
				case 21: bu.tag=2; [bu setTitle:@")" forState:UIControlStateNormal]; break;
				case 22: bu.tag=7; 
					[bu setTitle:NSLocalizedString(@"Calc NoTax",nil) forState:UIControlStateNormal]; 
					bu.titleLabel.font = [UIFont boldSystemFontOfSize:18]; 
					break;
				case 23: bu.tag=8; 
					[bu setTitle:NSLocalizedString(@"Calc InTax",nil) forState:UIControlStateNormal]; 
					bu.titleLabel.font = [UIFont boldSystemFontOfSize:18]; 
					break; */
			}
			
			if (1 < bu.tag)	bu.alpha = 0.8;
			else			bu.alpha = 1.0;

			[bu setBackgroundImage:[UIImage imageNamed:@"Icon-Drum.png"] forState:UIControlStateNormal];
			[bu setBackgroundImage:[UIImage imageNamed:@"Icon-DrumPush.png"] forState:UIControlStateHighlighted];
			[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchUpInside];
			//[maBu addObject:bu];
			[mSubView addSubview:bu]; //[bu release]; autoreleaseされるため
			iIndex++;
			fy += (fH + fyGap);
		}
		fx += (fW + fxGap);
	}
	
	//mKeyButtons = [[NSArray alloc] initWithArray:maBu];
	//[maBu release];
	
	//[self viewDesign:rect]; // コントロール配置
	
	// Calc 初期化
	mFunc = 0;
	
	// 丸め方法
	NSUInteger uiRound = NSRoundPlain; //　四捨五入
	if ([[NSUserDefaults standardUserDefaults] boolForKey:GD_OptRoundBankers]) {
		uiRound = NSRoundBankers; // 偶数丸め
	}
	if (mDecimal < 0) {
		// 通貨型に合った丸め位置を取得
		if ([[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier] isEqualToString:@"ja_JP"]) { // 言語 + 国、地域
			mRoundingScale = 0;
		} else {
			mRoundingScale = 2;
		}
	} else {
		mRoundingScale = mDecimal;
	}
	// 計算結果の丸め設定　show にてデフォルト設定
	mBehaviorCalc = [[NSDecimalNumberHandler alloc] initWithRoundingMode:uiRound				// 丸め
																   scale:mRoundingScale + 2	// 丸めた後の桁数
														raiseOnExactness:YES					// 精度
														 raiseOnOverflow:YES					// オーバーフロー
														raiseOnUnderflow:YES					// アンダーフロー
													 raiseOnDivideByZero:YES ];					// アンダーフロー

	// 答えの丸め　hide にてデフォルト設定
	mBehaviorDefault = [[NSDecimalNumberHandler alloc] initWithRoundingMode:uiRound			// 丸め
																	  scale:mRoundingScale	// 丸めた後の桁数
														   raiseOnExactness:YES				// 精度
															raiseOnOverflow:YES				// オーバーフロー
														   raiseOnUnderflow:YES				// アンダーフロー
														raiseOnDivideByZero:YES ];			// アンダーフロー
    return self;
}

/*
- (void)drawRect:(CGRect)rect 
{    // Drawing code
	float fxGap = 2;	// Xボタン間隔
	float fyGap;		// Yボタン間隔
	float fx;
	float fy;
	float fyTop;
	float fW;
	float fH;

	// タテ
	fy = rect.size.height - HEIGHT_TATE + 5;
	
	fx = 10;
	mLbTitle.frame = CGRectMake(fx,fy, 100,30);
	fx += 100 + 10;
	mLbAnswer.frame = CGRectMake(fx,fy, 310-fx,30);
	
	fy += 32;

	fx = 10;
	mLbFormula.frame = CGRectMake(fx,fy, 310-fx,20);
	
	fy += 22;
	fx = fxGap;
	fW = (320 - fxGap) / 5 - fxGap; // 1ページ5列
	fyGap = 5;	// Yボタン間隔
	fH = fW / GOLDENPER; // 黄金比
	fyTop = fy + fyGap;

	NSInteger iIndex = 0;
	for (int iCol=0; iCol<5; iCol++)
	{
		fy = fyTop;
		for (int iRow=0; iRow<4; iRow++)
		{
			UIButton *bu = [mKeyButtons objectAtIndex:iIndex++];
			if (bu) {
				bu.frame = CGRectMake(fx,fy, fW,fH);
				//[bu setFrame:CGRectMake(fx,fy, fW,fH)];
			}
			fy += (fH + fyGap);
		}
		fx += (fW + fxGap);
	}
}
*/

/*
- (void)viewDesign:(CGRect)rect
{
	AzLOG(@"viewDesign:rect (x,y)=(%f,%f) (w,h)=(%f,%f)", rect.origin.x,rect.origin.y, rect.size.width,rect.size.height);
	
	float fxGap = 2;	// Xボタン間隔
	float fyGap;		// Yボタン間隔
	float fx = fxGap;
	float fy;
	float fyTop;
	float fW;
	float fH;
	
#ifdef AzPAD
	if (Re3edit) {
		fy = 90;
	} else {
		fy = 113;
	}
	MlbFormula.frame = CGRectMake(5,fy, rect.size.width-10,30);	// 1行
	fy += MlbFormula.frame.size.height;
	MscrollView.frame = CGRectMake(5,fy, rect.size.width-10, 214);
	fW = (rect.size.width-10 - fxGap) / 6 - fxGap; //Pad//6列まで全部表示
	MscrollView.contentSize = MscrollView.frame.size; //同じ＝1ページのみ固定
	// 以下、MscrollView座標
	fyGap = 5;	// Yボタン間隔
	fy = 0;
	fH = fW / GOLDENPER; // 黄金比
	fyTop = fy + fyGap;
#else
	if (rect.size.width < rect.size.height)
	{	// タテ
		//MlbCalc.frame = CGRectMake(fx,fy, 320-fx-fx,20);	// 3行
		fy = 95;
		mLbFormula.frame = CGRectMake(5,fy, 320-10,30);	// 1行
		fy += mLbFormula.frame.size.height;
		MscrollView.frame = CGRectMake(0,fy, 320,220);
		//fW = (320 - fxGap) / 4 - fxGap; // 1ページ4列まで表示、5列目は2ページ目へ
		fW = (320 - fxGap) / 5 - fxGap; // 1ページ5列まで表示、6列目は2ページ目へ
																								  //↓2ページ目の列数=1
		MscrollView.contentSize = CGSizeMake(320+(fW+fxGap)*1, MscrollView.frame.size.height);
		// 以下、MscrollView座標
		fyGap = 5;	// Yボタン間隔
		fy = 0;
		//fH = (MscrollView.frame.size.height - fyGap) / 4 - fyGap;
		//fH = fW / GOLDENPER; // 黄金比
		fH = fW / 1.30;
		fyTop = fy + fyGap;
	}
	else {	// ヨコ
		//MlbCalc.frame = CGRectMake(fx,fy, 480-fx-fx,20);	// 1行
		fy = 40;
		mLbFormula.frame = CGRectMake(5,fy, 480-10,30);	// 1行
		fy += mLbFormula.frame.size.height;
		MscrollView.frame = CGRectMake(0,fy, 480,180);
		//fW = (480 - fxGap) / 5 - fxGap; // 5列まで表示
		MscrollView.contentSize = MscrollView.frame.size;
		// 以下、MscrollView座標
		fyGap = 4;	// Yボタン間隔
		fy = 0;
		fH = (MscrollView.frame.size.height - fyGap) / 4 - fyGap;
		fW = fH * GOLDENPER; // 黄金比
		fx = (480 - (fxGap + (fW+fxGap)*6 + fxGap)) / 2;
		fx += fxGap;
		fyTop = fy + fyGap;
	}
#endif
	
	NSInteger iIndex = 0;
	for (int iCol=0; iCol<6; iCol++)
	{
		fy = fyTop;
		for (int iRow=0; iRow<4; iRow++)
		{
			UIButton *bu = [mKeyButtons objectAtIndex:iIndex++];
			if (bu) {
				bu.frame = CGRectMake(fx,fy, fW,fH);
				//[bu setFrame:CGRectMake(fx,fy, fW,fH)];
			}
			fy += (fH + fyGap);
		}
		fx += (fW + fxGap);
	}
}
*/

/***** UIView には回転は無い！！！
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
 */


#pragma mark  Unload - dealloc
- (void)dealloc 
{
	[mBehaviorCalc release];
	[mBehaviorDefault release];
	[mTitle release], mTitle = nil;
	[mAnswer release], mAnswer = nil;
	[super dealloc];
}


#pragma mark - <Touches>

// タッチイベント
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{	//Cancel
	UITouch *touch = [[event allTouches] anyObject];
	if ([touch view]==self) {
		[self hide];
	}
}




@end

