//
//  SettPanelTVC.h
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"


@interface SettPanelTVC : UITableViewController
{
@private
	AppDelegate					*mAppDelegate;
	NSMutableArray				*mPanels;
	//NSMutableArray				*mGraphs;
}
@end
