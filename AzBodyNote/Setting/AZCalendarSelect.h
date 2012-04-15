//
//  AZCalendarSelect.h
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <eventkit/EventKit.h>


@interface AZCalendarSelect : UITableViewController
{

@private
	AppDelegate					*mAppDelegate;
	EKEventStore					*mEventStore;
	NSMutableArray				*mCalendars;
	NSString							*mCalendarID;
}
@end
