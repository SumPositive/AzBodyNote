//
//  AZVolume.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import "AZVolume.h"

#define FrameH				44	// 高さはApple標準(44)に固定する
#define ImgW					40
#define ImgH					30

#define BLOCK				800.0		//=(ImgW * 10 * 2)	// 10=タイリング数  2=2の倍数にするため
#define STEP					22.0


@interface NSObject (AZVolumeDelegate)
- (void)volumeChanged:(NSInteger)value;
@end

@implementation AZVolume

- (id)initWithFrame:(CGRect)frame 
		   delegate:(id)delegate 
			  value:(NSInteger)value			// 初期値
			   min:(NSInteger)vmin			// 最小値
			   max:(NSInteger)vmax		// 最大値
			  step:(NSInteger)vstep		// 増減値
{
	assert(delegate);
	assert(vmin < vmax);
	assert(vmin <= value);
	assert(value <= vmax);
	assert(1 <= vstep);
	
	UIImage *imgTile = [UIImage imageNamed:@"AZVolumeH40x30"];	// ヨコ型
	if (imgTile==nil) return nil;
	UIColor *patternColor = [UIColor colorWithPatternImage:imgTile];
	
	self = [super initWithFrame:frame];
    if (self==nil) return nil;
	
	// Initialization
	mDelegate = delegate;
	mScrollMin = (CGFloat)vmin * STEP;
	mScrollMax = (CGFloat)vmax * STEP;
	mScrollValue = (CGFloat)value * STEP;

	// 背景画像
	//frame.size.height = FrameH; // 高さ固定
	
	// ScrollView
	frame.origin.x = 10;	// self内の座標
	frame.origin.y = (FrameH - ImgH)/2;
	frame.size.width -= 20;
	frame.size.height = ImgH;
	mScrollView = [[UIScrollView alloc] initWithFrame:frame];
	mScrollView.contentSize = CGSizeMake( mScrollMax - mScrollMin + frame.size.width, ImgH );
	mScrollView.contentOffset = CGPointMake( mScrollValue - mScrollMin, 0);

	mScrollView.delegate = self;
	mScrollView.showsVerticalScrollIndicator = NO;
	mScrollView.showsHorizontalScrollIndicator = NO;
	mScrollView.pagingEnabled = NO;
	mScrollView.scrollsToTop = NO;
	mScrollView.bounces = NO;
	mScrollView.backgroundColor = [UIColor lightGrayColor];
	[self addSubview:mScrollView];


	NSInteger iNo = floor( (mScrollValue - mScrollMin) / BLOCK );  // 小数以下切り捨て
	//array[0] Left
	CGRect rcImg = CGRectMake( (iNo - 1) * BLOCK, 0, BLOCK, ImgH);
	mIvLeft = [[UIImageView alloc] initWithFrame:rcImg];
	mIvLeft.tag = (iNo - 1);
	mIvLeft.contentMode = UIViewContentModeTopLeft;
	mIvLeft.backgroundColor = patternColor;
	//mIvLeft.alpha = 0.5;
	[mScrollView addSubview:mIvLeft];

	//array[1] Center
	rcImg.origin.x += BLOCK;
	mIvCenter = [[UIImageView alloc] initWithFrame:rcImg];
	mIvCenter.tag = iNo;
	mIvCenter.contentMode = UIViewContentModeTopLeft;
	mIvCenter.backgroundColor = patternColor;
	[mScrollView addSubview:mIvCenter];

	//array[2] Right
	rcImg.origin.x += BLOCK;
	mIvRight = [[UIImageView alloc] initWithFrame:rcImg];
	mIvRight.tag = (iNo + 1);
	mIvRight.contentMode = UIViewContentModeTopLeft;
	mIvRight.backgroundColor = patternColor;
	//mIvRight.alpha = 0.5;
	[mScrollView addSubview:mIvRight];
	
	mIsMoved = NO;
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{	// Drawing code
	
}


#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (mIsMoved) return;
	mIsMoved = YES;

	static CGFloat sBase = (-1);
	if (sBase < 0) {
		sBase = scrollView.contentOffset.x;
	}
	CGFloat delta = scrollView.contentOffset.x - sBase;	// 変位量
	if ( fabs(delta) < STEP/2 ) {
		mIsMoved = NO;
		return;
	}
	sBase = scrollView.contentOffset.x;

	NSLog(@".x=%.1f  Left.x=%.1f  Center.x=%.1f  Right.x=%.1f", scrollView.contentOffset.x, mIvLeft.frame.origin.x, mIvCenter.frame.origin.x, mIvRight.frame.origin.x);
	// valueChange
	NSInteger ii = floor( (mScrollMin + scrollView.contentOffset.x) / STEP );
	if ([mDelegate respondsToSelector:@selector(volumeChanged:)]) {
		[mDelegate volumeChanged:ii];
	}

	if ( scrollView.contentOffset.x < mIvCenter.frame.origin.x ) {
		// Left
		if ( 0 < mIvLeft.frame.origin.x ) {
			UIImageView *iv = mIvRight;
			mIvRight = mIvCenter;
			mIvCenter = mIvLeft;
			mIvLeft = iv;
			CGRect frame = mIvLeft.frame;
			frame.origin.x -= (BLOCK * 3);
			mIvLeft.frame = frame;
		}
	}
	else if ( mIvCenter.frame.origin.x + BLOCK - scrollView.frame.size.width < scrollView.contentOffset.x ) {
		// Right
		if ( mIvRight.frame.origin.x < (mScrollMax - mScrollMin) ) {
			UIImageView *iv = mIvLeft;
			mIvLeft = mIvCenter;
			mIvCenter = mIvRight;
			mIvRight = iv;
			CGRect frame = mIvRight.frame;
			frame.origin.x += (BLOCK * 3);
			mIvRight.frame = frame;
		}
	}

	mIsMoved = NO;
}


@end
