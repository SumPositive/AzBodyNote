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

@private
	UIScrollView			*mScrollView;
	
	NSArray				*mViewList;
	NSInteger			mCenterViewIndex;			// index of mViewList
	NSInteger			mLeftViewIndex;		// index of mViewList
	NSInteger			mRightViewIndex;	// index of mViewList
	//BOOL circulated_;
}

//@property (nonatomic, retain) NSArray* viewList;
//@property (nonatomic, retain) NSArray* imageList;
//@property (nonatomic, readonly, getter=isCirculated) BOOL circulated;

- (id)initWithFrame:(CGRect)frame;
- (void)setPoint:(CGPoint)point;

@end
