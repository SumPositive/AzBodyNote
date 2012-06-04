//
//  GraphVC.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "GViewDate.h"
#import "GViewBp.h"
#import "GViewLine.h"
#import "SettGraphTVC.h"


#ifdef DEBUGxxx
#define GRAPH_PAGE_LIMIT			10		// < iOverlay
#else
#define GRAPH_PAGE_LIMIT			50		// グラフ表示の最大レコード数　
#endif

//#define RECORD_WIDTH		40.0		// 1レコード分の幅  ibViewRecordの幅参照
#define SEPARATE_HEIGHT	3.0		// 区切り線の高さ


@interface GraphVC : UIViewController <UIScrollViewDelegate>
{
	IBOutlet UIScrollView		*ibScrollView;
	IBOutlet UIView				*ibViewRecord;	//この幅を1レコードの幅とする

@private
	AppDelegate					*mAppDelegate;
	MocFunctions					*mMocFunc;
	NSUInteger						mPage;
	NSUInteger						mPageMax;
	NSUInteger						mLimit;
	UIActivityIndicatorView	*mActIndicator;
	NSArray							*mPanelGraphs;
	BOOL								mGoalDisp;
	CGFloat							mPadScale;	//= iPad / iPhone

	UIImageView					*mIvSetting;
	GViewDate						*mGvDate;
	GViewBp							*mGvBp;
	GViewLine						*mGvPuls;
	GViewLine						*mGvTemp;
	GViewLine						*mGvWeight;
	GViewLine						*mGvPedo;
	GViewLine						*mGvFat;
	GViewLine						*mGvSkm;
}

@end
