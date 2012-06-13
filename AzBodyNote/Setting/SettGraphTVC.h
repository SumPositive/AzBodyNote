//
//  SettGraphTVC.h
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AZDial.h"

#import "AppDelegate.h"

#define BMI_Height_MIN	50	//これ未満ならば非表示
#define BMI_Height_MAX	250


@interface SettGraphTVC : UITableViewController <AZDialDelegate>
{
@private
	AppDelegate					*mAppDelegate;
	NSMutableArray				*mPanels;	//ここではBpLoを除外
	UILabel							*mLbHeight;
	AZDial								*mDialHeight;
	NSInteger						mHeight;
}

@property (nonatomic, assign) BOOL		ppBackGraph;

@end
