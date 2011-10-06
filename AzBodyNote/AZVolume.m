//
//  AZVolume.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import "AZVolume.h"


@implementation AZVolume

/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
*/

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
		float fW = frame.size.width * 200;
		mScrollView = [[UIScrollView alloc] initWithFrame:frame];
		mScrollView.contentSize = CGSizeMake(fW, frame.size.height);
		mScrollView.contentOffset = CGPointMake(fW/2.0, 0);
	} else {
		frame.origin.x = 0;	// self内の座標
		frame.origin.y = 10;
		frame.size.height -= 20;
		float fH = frame.size.height * 200;
		mScrollView = [[UIScrollView alloc] initWithFrame:frame];
		mScrollView.contentSize = CGSizeMake(frame.size.width, fH);
		mScrollView.contentOffset = CGPointMake(0, fH/2.0);
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
	CGRect rcImg = CGRectMake(-40*10, 0, 40*10, 30); // (0)page
	//[imgTile drawAsPatternInRect:rcImg];
	
	for (int i=0; i < 3; i++) {
		UIImageView* iv = [[UIImageView alloc] initWithFrame:rcImg];
		iv.contentMode = UIViewContentModeTopLeft;
		[iv setImage:imgTile];
		[array addObject:iv];
		rcImg.origin.x += 40*10;
		[mScrollView addSubview:iv];
	}
	mViewList = array;
	mLeftViewIndex = 0;		// (0)page
	mCenterViewIndex = 1;	// (1)page
	mRightViewIndex = 2;		// (2)page
	mScrollView.contentOffset = CGPointMake(rcImg.size.width/2 - mScrollView.frame.size.width/2, 0); // Center

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
	NSInteger incremental = 0;
	NSInteger index = 0;
	//NSInteger imageIndex = 0;
	
	if (scrollDirection == kScrollDirectionLeft) {
		incremental = (-1);
		index = mRightViewIndex;
		mRightViewIndex = mCenterViewIndex;
		mCenterViewIndex = mLeftViewIndex;
		mLeftViewIndex = index;
	} else if (scrollDirection == kScrollDirectionRight) {
		incremental = 1;
		index = mLeftViewIndex;
		mLeftViewIndex = mCenterViewIndex;
		mCenterViewIndex = mRightViewIndex;
		mRightViewIndex = index;
	}
	
	// change position
	UIImageView* view = [mViewList objectAtIndex:index];
	CGRect frame = view.frame;
	frame.origin.x += 40*10 * incremental;
	view.frame = frame;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat position = scrollView.contentOffset.x / 40*10;
	CGFloat delta = position - (CGFloat)mCenterViewIndex;
	
	if (fabs(delta) >= 1.0f) {
		if (delta > 0) {
			[self scrollWithDirection:kScrollDirectionRight];
		} else {
			[self scrollWithDirection:kScrollDirectionLeft];			
		}		
	}
}

@end
