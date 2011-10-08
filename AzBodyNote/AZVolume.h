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
	id							mDelegate;
	CGFloat				mScrollMin;
	CGFloat				mScrollMax;
	CGFloat				mScrollValue;

	//NSArray				*mViewList;
	//NSInteger			mIndexCenter;			// index of mViewList
	//NSInteger			mIndexLeft;		// index of mViewList
	//NSInteger			mIndexRight;	// index of mViewList
	BOOL					mIsMoved;
	UIImageView		*mIvLeft;
	UIImageView		*mIvCenter;
	UIImageView		*mIvRight;
}

//@property (nonatomic, assign) id							delegate;
//@property (nonatomic, assign) NSInteger			value;
//@property (nonatomic, assign) NSInteger			vmin;
//@property (nonatomic, assign) NSInteger			vmax;
//@property (nonatomic, assign) NSInteger			vstep;

- (id)initWithFrame:(CGRect)frame 
				delegate:(id)delegate 
				value:(NSInteger)value		// 初期値
				min:(NSInteger)vmin			// 最小値
				max:(NSInteger)vmax		// 最大値
				step:(NSInteger)vstep;		// 増減値

@end
