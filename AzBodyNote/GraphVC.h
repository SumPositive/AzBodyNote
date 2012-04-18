//
//  GraphVC.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "AppDelegate.h"
#import "MocEntity.h"
#import "MocFunctions.h"
#import "GraphView.h"
#import "GViewDate.h"
#import "GViewLine.h"


#ifdef DEBUGxxx
#define GRAPH_PAGE_LIMIT			10		// < iOverlay
#else
#define GRAPH_PAGE_LIMIT			50		// グラフ表示の最大レコード数　＜＜有料版にてページ移動可能にする予定
#endif

#define RECORD_WIDTH				44.0		// 1レコード分の幅
#define GRAPH_H_GAP			5.0		// グラフの最大および最小の極限余白
#define SEPARATE_HEIGHT	3.0		// 区切り線の高さ


@interface GraphVC : UIViewController <UIScrollViewDelegate>
{
/*	IBOutlet UILabel				*ibLbBpHi;
	IBOutlet UILabel				*ibLbBpLo;
	IBOutlet UILabel				*ibLbPuls;
	IBOutlet UILabel				*ibLbWeight;
	IBOutlet UILabel				*ibLbTemp;
 */
	IBOutlet UIScrollView		*ibScrollView;
	//IBOutlet GraphView			*ibGraphView;

@private
	AppDelegate					*mAppDelegate;
	MocFunctions					*mMocFunc;
	
	NSUInteger								uiActivePage_;
	NSUInteger								uiActivePageMax_;
	UIActivityIndicatorView			*actIndicator_;
	CGPoint									pointNext_;
	NSArray							*mPanelGraphs;
	
	GViewDate						*mGvDate;
	//GViewDate						*mGvDate2;
	GViewLine						*mGvBpHi;
	GViewLine						*mGvBpLo;
	GViewLine						*mGvPuls;
	GViewLine						*mGvTemp;
	GViewLine						*mGvWeight;
	GViewLine						*mGvPedo;
	GViewLine						*mGvFat;
	GViewLine						*mGvSk;
}

@end
