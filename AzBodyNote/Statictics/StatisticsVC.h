//
//  StatisticsVC.h
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
// 統計グラフは、嗜好多様につき「制限」せずにFree公開する
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "SViewBp.h"
#import "SettGraphTVC.h"

#define STAT_DAYS_MAX		70		//統計最大日数
#define STAT_DAYS_FREE	7			//Free制限日数

#define ZOOM_MAX				3.0
#define RECORD_WIDTH		8.0		//1日の幅

@interface StatisticsVC : UIViewController <UIScrollViewDelegate>
{
	IBOutlet UISegmentedControl	*ibSegment;
	IBOutlet UILabel							*ibLbDays;
	IBOutlet UIStepper						*ibSpDays;
	IBOutlet UIScrollView					*ibScrollView;
	
@private
	AppDelegate					*mAppDelegate;
	MocFunctions					*mMocFunc;
	//UIActivityIndicatorView	*actIndicator_;
	//NSArray							*mPanelGraphs;
	//NSUInteger						mStatDays;
	//BOOL								mGoalDisp;
	SViewBp							*mSvBp;
}
@end
