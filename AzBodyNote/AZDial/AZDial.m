//
//  AZDial.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import "AZDial.h"

#define FrameH				44	// 高さはApple標準(44)に固定する
#define ImgW					40	// タイルの幅
#define ImgH					30

#define BLOCK				800.0		//=(ImgW * 10 * 2)	// 10=タイリング数  2=2の倍数にするため
#define PITCH					30.0			// スクロール感度　　増減するための最低変位量　＜＜ImgWの約数にするとステッパを使ったとき、ダイアルが動かないように見える。
														//【注意】 34.0だと[+]右回転に見えるが、36.0にすると左回転に見えてしまう。

@interface AZDial (PrivateMethods)
- (void)scrollReset;
@end

@implementation AZDial

- (void)makeView:(BOOL)stepper
{
	if (stepper) {
		if (mIsOS5) {
			if (!mStepper) {
				CGRect rc = self.bounds;
				rc.origin.y = 7;
				// .width=94 .height=27 は固定されている
				mStepper = [[UIStepper alloc] initWithFrame:rc];
				[self addSubview:mStepper];
				[mStepper addTarget:self action:@selector(actionStepperChange:) forControlEvents:UIControlEventValueChanged];
			}
		} else {
			if (!mStepBuUp) {
				mStepBuUp = [UIButton buttonWithType:UIButtonTypeCustom];
				[self addSubview:mStepBuUp];
				[mStepBuUp addTarget:self action:@selector(actionStepBuUpTouch:) forControlEvents:UIControlEventTouchUpInside];
				[mStepBuUp setImage:[UIImage imageNamed:@"AZDialStepperPlus"] forState:UIControlStateNormal];
				CGRect rc = self.bounds;
				rc.origin.x = 47;
				rc.origin.y = 6;
				rc.size.width = 47;
				rc.size.height = 31;
				mStepBuUp.frame = rc;		//[+]右側
			}
			if (!mStepBuDown) {
				mStepBuDown = [UIButton buttonWithType:UIButtonTypeCustom];
				[self addSubview:mStepBuDown];
				[mStepBuDown addTarget:self action:@selector(actionStepBuDownTouch:) forControlEvents:UIControlEventTouchUpInside];
				[mStepBuDown setImage:[UIImage imageNamed:@"AZDialStepperMinus"] forState:UIControlStateNormal];
				CGRect rc = self.bounds;
				rc.origin.y = 6;
				rc.size.width = 47;
				rc.size.height = 31;
				mStepBuDown.frame = rc;		//[-]左側
			}
		}
		//初期値セットは、setValue: から scrollReset:　が呼び出される。
	} else {
		if (mStepper) {
			[mStepper removeFromSuperview];
			mStepper = nil;
		}
		if (mStepBuUp) {
			[mStepBuUp removeFromSuperview];
			mStepBuUp = nil;
		}
		if (mStepBuDown) {
			[mStepBuDown removeFromSuperview];
			mStepBuDown = nil;
		}
		mStepperMag = 1.0; // Default
	}
	
	// ScrollView		高さ:44　= self.bounds.size.height
	CGRect rcScroll = self.bounds;
	if (stepper) {
		rcScroll.origin.x = 94 + 2 + 10;	// self内の座標
		rcScroll.size.width -= (rcScroll.origin.x + 10);
	} else {
		rcScroll.origin.x = 10;	// self内の座標
		rcScroll.size.width -= (10 + 10);
	}
	rcScroll.origin.y = 0;  //(FrameH - ImgH)/2;
	//rcScroll.size.height = ImgH;
	if (mScrollView) {
		mScrollView.frame = rcScroll;
	} else {
		mScrollView = [[UIScrollView alloc] initWithFrame:rcScroll];
		//setValue:にて// mScrollView.contentSize = CGSizeMake( mScrollMax + rcScroll.size.width, ImgH );
		//setValue:にて// mScrollView.contentOffset = CGPointMake( mScrollMax - mScrollValue, 0);
		mScrollView.delegate = self;
		mScrollView.showsVerticalScrollIndicator = NO;
		mScrollView.showsHorizontalScrollIndicator = NO;
		mScrollView.pagingEnabled = NO;
		mScrollView.scrollsToTop = NO;
		mScrollView.bounces = NO;
		//mScrollView.backgroundColor = [UIColor whiteColor];
		[self addSubview:mScrollView];
	}

	// 背景画像
	CGRect rcBack = self.bounds;
	if (stepper) {
		rcBack.origin.x = 94 + 2;
		rcBack.origin.y = 0;
		rcBack.size.width -= rcBack.origin.x;
	} else {
		rcBack.origin.x = 0;
		rcBack.origin.y = 0;
	}
	if (mImgBack) {
		mImgBack.frame = rcBack;
	} else {
		mImgBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AZDialBack"]];
		mImgBack.frame = rcBack;
		mImgBack.contentMode = UIViewContentModeScaleToFill;
		mImgBack.contentStretch = CGRectMake(0.5, 0,  0, 0);
		[self	addSubview:mImgBack];
	}
	// mScrollView 座標系をセット
	[self scrollReset];	// mScrollViewやBLOCK再配置処理
}


- (id)initWithFrame:(CGRect)frame 
		   delegate:(id)delegate 
			  value:(NSInteger)value			// 初期値
			   min:(NSInteger)vmin			// 最小値
			   max:(NSInteger)vmax			// 最大値
			   step:(NSInteger)vstep		// 増減値
			stepper:(BOOL)stepper;
{
	assert(delegate);
	assert(vmin < vmax);
	//assert(vmin <= value);
	//assert(value <= vmax);
	if (value < vmin) value = vmin;
	else if (vmax < value) value = vmax;
	//assert(1 <= vstep);
	if (vstep < 1) vstep =1;
	
	UIImage *imgTile = [UIImage imageNamed:@"AZDialTile"];	// H30 x W10の倍数
	if (imgTile==nil) return nil;
	UIColor *patternColor = [UIColor colorWithPatternImage:imgTile];
	
	self = [super initWithFrame:frame];
    if (self==nil) return nil;
	
	// Initialization
	//mIsMoved = YES;	// =YES:setValue:等の初期値セット中 ⇒ delegate呼び出ししない。
	mDelegate = delegate;
	mVmin = vmin;
	mVmax = vmax;
	mVstep = vstep;
	mStepperMag = 1.0;
	//mValue は、mScrollView生成後、setValue:によりセットしている。
	mIsOS5 = ([[[UIDevice currentDevice] systemVersion] compare:@"5.0"] != NSOrderedAscending);  // !<  (>=) "5.0"

	[self makeView:stepper];
	
	// Left BLOCK
	CGRect rcImg = CGRectMake( (-2)*BLOCK, (FrameH - ImgH)/2, BLOCK, ImgH);	// scrollReset:にてBLOCK再配置処理されるように(-2)*している
	mIvLeft = [[UIImageView alloc] initWithFrame:rcImg];
	mIvLeft.contentMode = UIViewContentModeTopLeft;
	mIvLeft.backgroundColor = patternColor;
	[mScrollView addSubview:mIvLeft];
	// Center BLOCK
	mIvCenter = [[UIImageView alloc] initWithFrame:rcImg];
	mIvCenter.contentMode = UIViewContentModeTopLeft;
	mIvCenter.backgroundColor = patternColor;
	[mScrollView addSubview:mIvCenter];
	// Right BLOCK
	mIvRight = [[UIImageView alloc] initWithFrame:rcImg];
	mIvRight.contentMode = UIViewContentModeTopLeft;
	mIvRight.backgroundColor = patternColor;
	[mScrollView addSubview:mIvRight];
	
	// mValue, mScrollView 座標系をセット
	[self setValue:value  animated:NO];	//---> scrollReset:にてmScrollViewやBLOCK再配置処理
	
	//mIsMoved = NO;
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{	// Drawing code
	
}


#pragma mark - Methods

- (void)scrollReset
{	// mScrollView 座標系セット
	//mIsMoved = YES;	// =YES:setValue:等の初期値セット中 ⇒ delegate呼び出ししない。
	//mScrollView.delegate = nil;
	
	NSLog(@"-- scrollReset -- mValue=%d  mVmin=%d  mVmax=%d  :: mScrollMax=%.1f  mScrollOfs=%.1f",
		  mValue, mVmin, mVmax, mScrollMax, mScrollOfs);

	CGFloat ff = (CGFloat)(mVmax - mVmin) / mVstep * PITCH;
	if (mScrollMax != ff) {
		mScrollMax = ff;
		mScrollView.contentSize = CGSizeMake( mScrollMax + mScrollView.frame.size.width, ImgH );	//  +PITCH が無いと原点0に戻らなくなる。
		NSLog(@"                       -- CHANGE - mScrollMax=%.1lf  mVstep=%d  STEP=%d", mScrollMax, mVstep, (int)PITCH);
	}

	ff = mScrollMax - (CGFloat)((mValue - mVmin) / mVstep * PITCH);	  // 右側が原点になるため
	if (mScrollOfs != ff) {
		mScrollOfs = ff;
		mScrollView.contentOffset = CGPointMake( mScrollOfs, 0);
		NSLog(@"                       -- CHANGE - mScrollMax=%.1lf  mScrollOfs=%.1lf  STEP=%d", mScrollMax, mScrollOfs, (int)PITCH);
	}
	
	if ( ( 0 < mIvLeft.frame.origin.x && mScrollOfs < mIvCenter.frame.origin.x - PITCH*3)
		|| ( mIvRight.frame.origin.x + BLOCK < mScrollMax && mIvRight.frame.origin.x + PITCH*3 < mScrollOfs) ) 
	{	// mIvCenterの範囲外が指定された場合、再配置する
		NSInteger iNo = floor( (mScrollOfs) / BLOCK );  // Center No.  小数以下切り捨て
		NSLog(@"                       -- mIvCenter1 - X=%.1lf  Wid=%.1lf  iNo=%d", mIvCenter.frame.origin.x, mIvCenter.frame.origin.x + BLOCK, iNo);
		CGRect rc = mIvLeft.frame;
		//Left
		rc.origin.x =  (iNo - 1) * BLOCK;
		mIvLeft.frame = rc;
		//Center
		rc.origin.x += BLOCK;
		mIvCenter.frame = rc;
		NSLog(@"                       -- mIvCenter2 - X=%.1lf  Wid=%.1lf", mIvCenter.frame.origin.x, mIvCenter.frame.origin.x + BLOCK);
		//Right
		rc.origin.x += BLOCK;
		mIvRight.frame = rc;
	}

	//mIsMoved = NO;	// return; で抜けることに注意
	//mScrollView.delegate = self;

	if (mIsOS5) {
		if (!mStepper) return;
		mStepper.minimumValue = mVmin;
		mStepper.maximumValue = mVmax;
		mStepper.stepValue = mVstep * mStepperMag;
		mStepper.value = mValue;
	} else {
		if (!mStepBuUp || !mStepBuDown) return;
		mStepBuUp.enabled = (mValue < mVmax);
		mStepBuDown.enabled = (mVmin < mValue);
	}
}

- (NSInteger)getValue
{
	return mValue;
}

- (void)setValue:(NSInteger)value  animated:(BOOL)animated
{
	if (value < mVmin) value = mVmin;
	else if (mVmax < value) value = mVmax;
	// SET
	mValue = value;
	
	if (animated) {
		// アニメ準備
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.5];
		// アニメ終了位置
		[self scrollReset];	// mScrollView 座標系セット
		// アニメ開始
		[UIView commitAnimations];
	} else {
		[self scrollReset];	// mScrollView 座標系セット
	}
}

- (void)setStep:(NSInteger)vstep
{
	if (vstep < 1) mVstep =1;
	else mVstep = vstep;
	[self scrollReset];
}

- (void)setMin:(NSInteger)vmin
{
	if (mValue < vmin) mValue = vmin;
	// SET
	mVmin = vmin;
	// mScrollView 座標系セット
	[self scrollReset];
}

- (void)setMax:(NSInteger)vmax
{
	if (vmax < mValue) mValue = vmax;
	// SET
	mVmax = vmax;
	// mScrollView 座標系セット
	[self scrollReset];
}

- (void)setStepperMagnification:(CGFloat)vmagnif
{	// ステッパーは刻みを、mVstep * vmagnif にする
	mStepperMag = vmagnif;
	[self scrollReset];
}

- (void)setStepperShow:(BOOL)bShow
{
	if (bShow) {
		if (mStepper || mStepBuUp) return; // 既に表示中
	} else {
		if (!mStepper && !mStepBuUp) return; // 既に非表示
	}
	[self makeView:bShow];
}



#pragma mark - Action

- (void)actionStepperChange:(UIStepper *)sender
{
	[self	setValue:(NSInteger)sender.value animated:YES];

	if ([mDelegate respondsToSelector:@selector(volumeDone:value:)]) {
		[mDelegate volumeDone:self  value:mValue];
	}
}

- (void)actionStepBuUpTouch:(UIButton*)sender
{
	NSInteger ii = mValue + (mVstep * mStepperMag);
	if (mVmax < ii) ii = mVmax;
	[self	setValue:ii  animated:YES];
	if ([mDelegate respondsToSelector:@selector(volumeDone:value:)]) {
		[mDelegate volumeDone:self  value:mValue];
	}
}

- (void)actionStepBuDownTouch:(UIButton*)sender
{
	NSInteger ii = mValue - (mVstep * mStepperMag);
	if (ii < mVmin) ii = mVmin;
	[self	setValue:ii  animated:YES];
	if ([mDelegate respondsToSelector:@selector(volumeDone:value:)]) {
		[mDelegate volumeDone:self  value:mValue];
	}
}



#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	// スクロール中
	//if (mIsMoved) return;
	//mIsMoved = YES;

	static CGFloat sBase = (-1);
	if (sBase < 0) {
		sBase = scrollView.contentOffset.x;
	}
	CGFloat delta = scrollView.contentOffset.x - sBase;	// 変位量
	if ( fabs(delta) < PITCH/2 ) {
		//mIsMoved = NO;
		return;
	}
	sBase = scrollView.contentOffset.x;

	//NSLog(@".x=%.1f  Left.x=%.1f  Center.x=%.1f  Right.x=%.1f", scrollView.contentOffset.x, 
	//													mIvLeft.frame.origin.x, mIvCenter.frame.origin.x, mIvRight.frame.origin.x);
	
	// valueChange
	//NSInteger ii = floor( (mScrollMax - scrollView.contentOffset.x) / PITCH ) * mVstep;
	mValue = mVmin + floor( (mScrollMax - scrollView.contentOffset.x) / PITCH ) * mVstep;
	if ([mDelegate respondsToSelector:@selector(volumeChanged:value:)]) {
		[mDelegate volumeChanged:self  value:mValue];	// 変化、決定ではない
	}

	if ( scrollView.contentOffset.x < mIvCenter.frame.origin.x - PITCH*3 ) {
		// Left
		if ( 0 < mIvLeft.frame.origin.x ) {
			UIImageView *iv = mIvRight;
			mIvRight = mIvCenter;
			mIvCenter = mIvLeft;
			NSLog(@"                       -L- mIvCenter - X=%.1lf  Wid=%.1lf  <<< X=%.1f", 
				  mIvCenter.frame.origin.x, mIvCenter.frame.origin.x + BLOCK, scrollView.contentOffset.x);
			mIvLeft = iv;
			CGRect frame = mIvLeft.frame;
			frame.origin.x -= (BLOCK * 3);
			mIvLeft.frame = frame;
		}
	}
	else if ( mIvCenter.frame.origin.x + BLOCK + PITCH*3 < scrollView.contentOffset.x ) {
		// Right
		if ( mIvRight.frame.origin.x < mScrollMax ) {
			UIImageView *iv = mIvLeft;
			mIvLeft = mIvCenter;
			mIvCenter = mIvRight;
			NSLog(@"                       -R- mIvCenter - X=%.1lf  Wid=%.1lf  <<< X=%.1f", 
				  mIvCenter.frame.origin.x, mIvCenter.frame.origin.x + BLOCK, scrollView.contentOffset.x);
			mIvRight = iv;
			CGRect frame = mIvRight.frame;
			frame.origin.x += (BLOCK * 3);
			mIvRight.frame = frame;
		}
	}
	//mIsMoved = NO;
}

- (void)scrollDone:(UIScrollView *)scrollView
{	// Original
	//if (mIsMoved) return;
	//NG//NSInteger ii = floor( (mScrollMax - scrollView.contentOffset.x) / PITCH ) * mVstep;
	//NG//ここで、改めて位置から求めると、指を離した瞬間に動いて変化する場合がある。
	//OK//そのため、scrollViewDidScroll:にて表示されている mValue に決定することにした。
	if ([mDelegate respondsToSelector:@selector(volumeDone:value:)]) {
		[mDelegate volumeDone:self  value:mValue];	// 決定
	}
	
	NSInteger iStep = mVstep * mStepperMag;
	[self setValue:((mValue / iStep) * iStep)  animated:NO];	// ステッパーのステップに補正する
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{	// ドラッグ終了 ＜＜＜スクロールを止めてから、指を離したときに呼ばれる　　		decelerate=YES:まだ慣性動作中
	if (decelerate) {
		// まだ慣性動作中 ⇒ この後、scrollViewDidEndDecelerating：が呼び出される
	} else {
		// ピタッと止まった ＜＜指を離した瞬間に僅かに動くのは無視してピタット扱いになるようだ。
		[self scrollDone:scrollView];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{	// スクロール・ビューの動きが減速終了 ＜＜＜スクロール中に指を離して、自然に止まったときに呼ばれる
	[self scrollDone:scrollView];
}

@end
