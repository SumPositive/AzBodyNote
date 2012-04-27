//
//  StatisticsVC.h
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "SViewBp.h"
#import "SettGraphTVC.h"

#define STAT_DAYS_MAX		100		//統計最大日数
#define RECORD_WIDTH		8.0		//1日の幅

@interface StatisticsVC : UIViewController
{
	IBOutlet UISegmentedControl	*ibSegment;
	IBOutlet UIScrollView					*ibScrollView;
	
@private
	AppDelegate					*mAppDelegate;
	MocFunctions					*mMocFunc;
	//UIActivityIndicatorView	*actIndicator_;
	NSArray							*mPanelGraphs;
	NSUInteger						mStatDays;
	//BOOL								mGoalDisp;
	SViewBp							*mSvBp;
}
@end
