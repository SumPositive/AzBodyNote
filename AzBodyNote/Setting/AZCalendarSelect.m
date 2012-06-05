//
//  AZCalendarSelect.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AZCalendarSelect.h"


@interface AZCalendarSelect ()

@end

@implementation AZCalendarSelect

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
		mAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
		assert(mAppDelegate);
		GA_TRACK_PAGE(@"AZCalendarSelect");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = NSLocalizedString(@"AZCalendarSelect",nil);

	mEventStore = [[EKEventStore alloc] init];
	
	mCalendars = [NSMutableArray new];
	for (EKCalendar *cal in [mEventStore calendars]) {
		if (cal.allowsContentModifications) {
			// 追加変更が可能なカレンダーだけを抽出する
			[mCalendars addObject:cal];
		}
	}
	NSLog(@"mCalendars={%@}", mCalendars);
	
	//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	mCalendarID = [kvs objectForKey:KVS_CalendarID];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[mAppDelegate adShow:2];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return iS_iPAD OR (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mCalendars count] + 1;  //+1:「なし」
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellCal";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}

	if (0 < indexPath.row && indexPath.row<=[mCalendars count]) {
		EKCalendar* calendar = [mCalendars objectAtIndex:indexPath.row-1];
		cell.textLabel.text = calendar.title;
		cell.textLabel.textColor = [UIColor colorWithCGColor:calendar.CGColor];
		switch (calendar.type) {
			case EKCalendarTypeLocal:
				cell.detailTextLabel.text = NSLocalizedString(@"AZCalendarSelect EKCalendarTypeLocal",nil);
				break;
			case EKCalendarTypeCalDAV:
				cell.detailTextLabel.text = NSLocalizedString(@"AZCalendarSelect EKCalendarTypeCalDAV",nil);
				break;
			case EKCalendarTypeExchange:
				cell.detailTextLabel.text = NSLocalizedString(@"AZCalendarSelect EKCalendarTypeExchange",nil);
				break;
			case EKCalendarTypeSubscription:
				cell.detailTextLabel.text = NSLocalizedString(@"AZCalendarSelect EKCalendarTypeSubscription",nil);
				break;
			case EKCalendarTypeBirthday:
				cell.detailTextLabel.text = NSLocalizedString(@"AZCalendarSelect EKCalendarTypeBirthday",nil);
				break;
			default:
				cell.detailTextLabel.text = nil;
				break;
		}
		if ([mCalendarID isEqualToString:calendar.calendarIdentifier]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	} else {
		cell.textLabel.text = NSLocalizedString(@"AZCalendarSelect NON",nil);
		cell.textLabel.textColor = [UIColor blackColor];
		cell.detailTextLabel.text = nil;
		if (mCalendarID) {
			cell.accessoryType = UITableViewCellAccessoryNone;
		} else {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
	}
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する
	
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];

	if (0 < indexPath.row && indexPath.row<=[mCalendars count]) {
		EKCalendar* calendar = [mCalendars objectAtIndex:indexPath.row - 1];
		if (mAppDelegate.app_is_unlock==NO) {	// Free制限
			if (calendar.type != EKCalendarTypeLocal) {
				// Freeでは「ローカルカレンダー」だけに制限する
				azAlertBox(NSLocalizedString(@"FreeLock",nil), 
						 NSLocalizedString(@"FreeLock CalendarLocal",nil), @"OK");
				return;
			}
		}
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		//
		mCalendarID = calendar.calendarIdentifier;
		NSLog(@"mCalendarID={%@}", mCalendarID);
		[kvs setObject:calendar.calendarIdentifier forKey:KVS_CalendarID];
		[kvs setObject:calendar.title forKey:KVS_CalendarTitle];
	} else {
		[kvs removeObjectForKey:KVS_CalendarID]; // なし
		[kvs removeObjectForKey:KVS_CalendarTitle]; // なし
	}
	[kvs synchronize];
	
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}

@end
