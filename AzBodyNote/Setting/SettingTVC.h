//
//  SettingTVC.h
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AZAboutVC.h"
#import "AZStoreTVC.h"	//<AZStoreDelegate>
#import "AZDropboxVC.h"	//<AZDropboxDelegate>

#import "Global.h"
#import "AppDelegate.h"
#import "AZCalendarSelect.h"
#import "SettGraphTVC.h"
#import "SettStatTVC.h"


@interface SettingTVC : UITableViewController <AZStoreDelegate, AZDropboxDelegate>
{
@private
	AppDelegate					*mAppDelegate;
}
@end
