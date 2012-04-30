//
//  SettStatTVC.h
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AZDial.h"

#import "AppDelegate.h"


@interface SettStatTVC : UITableViewController <AZDialDelegate>
{
@private
	AppDelegate					*mAppDelegate;

	NSInteger		mValueDays;
	AZDial				*mDialDays;
	UILabel			*mLbValueDays;
}

@property (nonatomic, assign) BOOL		ppBackStat;

@end
