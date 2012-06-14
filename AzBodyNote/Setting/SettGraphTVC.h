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


@interface SettGraphTVC : UITableViewController <AZDialDelegate>
{
@private
	AppDelegate					*mAppDelegate;
	NSMutableArray				*mPanels;	//ここではBpLoを除外
	
	UILabel							*mLbTall;
	AZDial								*mDialTall;
	NSInteger						mBMI_Tall;
}

@property (nonatomic, assign) BOOL		ppBackGraph;

@end
