//
//  AZVolume.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import "AZVolume.h"

#define PAGE_WIDTH		(40 * 100)		// 1タイル幅=40 * 20=タイリング数
#define PAGES				200				// 2の倍数


@implementation AZVolume
@synthesize delegate;
@synthesize mVolume, mVolumeMin, mVolumeMax, mVolumeStep;


- (id)initWithFrame:(CGRect)frame
{
	BOOL  bHorizontal = YES;
	UIImage *imgTile = nil;
	if (frame.size.height < frame.size.width) {
		imgTile = [UIImage imageNamed:@"AZVolumeH40x30"];	// ヨコ型
		frame.size.height = 30 + 20;
	} else {
		imgTile = [UIImage imageNamed:@"AZVolumeV30x40"];	// タテ型
		frame.size.width = 30 + 20;
		bHorizontal = NO;
	}
	if (imgTile==nil) return nil;
	
	self = [super initWithFrame:frame];
    if (self==nil) return nil;
	// Initialization code
	if (bHorizontal) {
		frame.origin.x = 10;	// self内の座標
		frame.origin.y = 0;
		frame.size.width -= 20;
		mScrollView = [[UIScrollView alloc] initWithFrame:frame];
		mScrollView.contentSize = CGSizeMake(PAGE_WIDTH * PAGES, frame.size.height);
		mScrollView.contentOffset = CGPointMake(PAGE_WIDTH * (PAGES/2), 0); // Center
	} else {
		frame.origin.x = 0;	// self内の座標
		frame.origin.y = 10;
		frame.size.height -= 20;
		mScrollView = [[UIScrollView alloc] initWithFrame:frame];
		mScrollView.contentSize = CGSizeMake(frame.size.width, PAGE_WIDTH * PAGES);
		mScrollView.contentOffset = CGPointMake(0, PAGE_WIDTH * (PAGES/2)); // Center
	}
	mScrollView.delegate = self;
	mScrollView.showsVerticalScrollIndicator = NO;
	mScrollView.showsHorizontalScrollIndicator = NO;
	mScrollView.pagingEnabled = NO;
	mScrollView.scrollsToTop = NO;
	mScrollView.backgroundColor = [UIColor lightGrayColor];
	[self addSubview:mScrollView];
	//
	

	NSMutableArray* array = [NSMutableArray array];
	CGRect rcImg = CGRectMake(PAGE_WIDTH * (PAGES/2 - 1), 10, PAGE_WIDTH, 30); // (0)page
	
	UIColor *patternColor = [UIColor colorWithPatternImage:imgTile];
	
	for (int i=0; i < 3; i++) {
		UIImageView* iv = [[UIImageView alloc] initWithFrame:rcImg];
		iv.contentMode = UIViewContentModeTopLeft;
		//[iv setImage:imgTile];
		//[imgTile drawAsPatternInRect:rcImg];
		iv.backgroundColor = patternColor;
		[array addObject:iv];
		rcImg.origin.x += PAGE_WIDTH;
		[mScrollView addSubview:iv];
	}
	mViewList = [[NSArray alloc] initWithArray:array];
	mLeftViewIndex = 0;		// (0)page
	mCenterViewIndex = 1;	// (1)page
	mRightViewIndex = 2;		// (2)page
	mCenterOffset = PAGE_WIDTH * (PAGES/2);
	mScrollView.contentOffset = CGPointMake(mCenterOffset, 0); // Center (1)page
	mIsMoved = NO;
	
    return self;
}


- (void)setPoint:(CGPoint)point
{
	CGRect rc = self.frame;
	rc.origin = point;
	self.frame = rc;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{	// Drawing code
	self.backgroundColor = [UIColor yellowColor];
	
}

#pragma mark - <UIScrollViewDelegate>

typedef enum {
	kScrollDirectionLeft,
	kScrollDirectionRight,
	kScrollDirectionUp,
	kScrollDirectionDown
} ScrollDirection;

- (void)scrollWithDirection:(ScrollDirection)scrollDirection
{
	if (mIsMoved) return;
	mIsMoved = YES;

	NSInteger incremental = 0;
	NSInteger index = 0;
	//NSInteger imageIndex = 0;
	
	if (scrollDirection == kScrollDirectionLeft) {
		incremental = (-2);
		index = mRightViewIndex;
		mRightViewIndex = mCenterViewIndex;
		mCenterViewIndex = mLeftViewIndex;
		mLeftViewIndex = index;
	} else if (scrollDirection == kScrollDirectionRight) {
		incremental = 2;
		index = mLeftViewIndex;
		mLeftViewIndex = mCenterViewIndex;
		mCenterViewIndex = mRightViewIndex;
		mRightViewIndex = index;
	} else {
		assert(NO);
		return;
	}
	
	// change position
	//NSLog(@"mViewList=%@", mViewList);
	assert(index < [mViewList count]);
	UIImageView* iv = [mViewList objectAtIndex:index];
	CGRect frame = iv.frame;
	frame.origin.x += (PAGE_WIDTH * incremental);
	iv.frame = frame;
	
	iv = [mViewList objectAtIndex:mCenterViewIndex];
	mCenterOffset = iv.frame.origin.x;

	mIsMoved = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if ([delegate respondsToSelector:@selector(volumeChanged:)]) {
		[delegate volumeChanged:mVolume];
	}
	
	if (mIsMoved) return;
	CGFloat delta = (scrollView.contentOffset.x - mCenterOffset);
	if ((PAGE_WIDTH/2) <= fabs(delta)) {  // 半ページ以上スクロールしたとき
		if (0 < delta) {
			[self scrollWithDirection:kScrollDirectionRight];
		} else {
			[self scrollWithDirection:kScrollDirectionLeft];			
		}		
	}
}

@end
