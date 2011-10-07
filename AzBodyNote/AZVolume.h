//
//  AZVolume.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AZVolume : UIView	<UIScrollViewDelegate>
{
	id							delegate;
	NSInteger			mVolumeMin;
	NSInteger			mVolumeMax;
	NSInteger			mVolumeStep;
	NSInteger			mVolume;
	
@private
	UIScrollView			*mScrollView;
	
	NSArray				*mViewList;
	NSInteger			mCenterViewIndex;			// index of mViewList
	NSInteger			mLeftViewIndex;		// index of mViewList
	NSInteger			mRightViewIndex;	// index of mViewList
	CGFloat				mCenterOffset;
	BOOL					mIsMoved;
}

@property (nonatomic, assign) id							delegate;
@property (nonatomic, assign) NSInteger			mVolume;
@property (nonatomic, assign) NSInteger			mVolumeMin;
@property (nonatomic, assign) NSInteger			mVolumeMax;
@property (nonatomic, assign) NSInteger			mVolumeStep;

//@property (nonatomic, retain) NSArray* viewList;
//@property (nonatomic, retain) NSArray* imageList;
//@property (nonatomic, readonly, getter=isCirculated) BOOL circulated;

- (id)initWithFrame:(CGRect)frame;
- (void)setPoint:(CGPoint)point;

// AZVolumeDelegate
- (void)volumeChanged:(NSInteger)volume;

@end
