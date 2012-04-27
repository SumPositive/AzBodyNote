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
#define GRAPH_PAGE_LIMIT			100		// グラフ表示の最大レコード数　
#endif

#define RECORD_WIDTH		36.0		// 1レコード分の幅
#define SEPARATE_HEIGHT	3.0		// 区切り線の高さ


@interface GraphVC : UIViewController <UIScrollViewDelegate>
{
	IBOutlet UIScrollView		*ibScrollView;

@private
	AppDelegate					*mAppDelegate;
	MocFunctions					*mMocFunc;
	NSUInteger						mPage;
	NSUInteger						mPageMax;
	UIActivityIndicatorView	*actIndicator_;
	NSArray							*mPanelGraphs;
	//NSUInteger						mGraphDays;
	BOOL								mGoalDisp;
	GViewDate						*mGvDate;
	GViewBp							*mGvBp;
	GViewLine						*mGvPuls;
	GViewLine						*mGvTemp;
	GViewLine						*mGvWeight;
	GViewLine						*mGvPedo;
	GViewLine						*mGvFat;
	GViewLine						*mGvSk;
}

@end