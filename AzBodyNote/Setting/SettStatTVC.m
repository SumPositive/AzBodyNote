//
//  SettStatTVC.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettStatTVC.h"
#import "StatisticsVC.h"


@implementation SettStatTVC
@synthesize ppBackStat = __BackStat;


- (void)actionBack
{
	[self dismissModalViewControllerAnimated:YES];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
		mAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
		assert(mAppDelegate);
		GA_TRACK_PAGE(@"SettStatTVC");
		__BackStat = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = NSLocalizedString(@"SettStat",nil);
	
	//self.navigationItem.rightBarButtonItem = [self editButtonItem];	//右[Edit]ボタン
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	if (__BackStat) {
		// Graphから呼び出されたときバックボタンが無いので付ける
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
												 initWithTitle: NSLocalizedString(@"SettStat Back", nil)
												 style:UIBarButtonItemStyleBordered
												 target:self action:@selector(actionBack)];
	}

	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	mValueDays = [[kvs objectForKey:KVS_SettStatDays] integerValue];
	if (mValueDays<1 OR STAT_DAYS_MAX<mValueDays) {
		mValueDays = 1;
	}
}

- (void)viewWillDisappear:(BOOL)animated
{	// 非表示になる前に呼び出される
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];

	
	[kvs synchronize];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section==0) {
		return 4;
	}
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section==0) {
		if (indexPath.row==0) return 88; // Days
		return 44;
	}
    return 44; // Default
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return nil;
}

- (void)refreshStatDays
{
	if (mLbValueDays) {
		mLbValueDays.text = [NSString stringWithFormat:@"%ld", (long)mValueDays];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *sysCellSubtitle = @"sysCellSubtitle"; //システム既定セル
	static NSString *sysCellDial = @"sysCellDial";
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	
	switch (indexPath.section*100 + indexPath.row) {
		case 0: {	// 期間指定
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellDial];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellDial];
				// Label
				UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 25)];
				lb.font = [UIFont boldSystemFontOfSize:20];
				lb.adjustsFontSizeToFitWidth = YES;
				lb.minimumFontSize = 10;
				lb.backgroundColor = [UIColor clearColor];
				lb.text = NSLocalizedString(@"SettStat Days",nil);
				[cell.contentView addSubview:lb];
				// Label
				mLbValueDays = [[UILabel alloc] initWithFrame:CGRectMake(200, 8, 70, 30)];
				mLbValueDays.font = [UIFont systemFontOfSize:26];
				mLbValueDays.textAlignment = UITextAlignmentRight;
				mLbValueDays.backgroundColor = [UIColor clearColor];
				[cell.contentView addSubview:mLbValueDays];
				// AZDial
				mDialDays = [[AZDial alloc] initWithFrame:CGRectMake(15, 40, 280, 44)
												 delegate: self
													 dial: mValueDays
													  min: 1
													  max: 50
													 step: 1
												  stepper: 1];
				[cell.contentView addSubview:mDialDays];
				mDialDays.backgroundColor = [UIColor clearColor]; //self.backgroundColor;
			}
			[self refreshStatDays];
			return cell;
		}	break;
			
		case 1: {	//Avg.
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			//cell.imageView.image = [UIImage imageNamed:@"Icon20-Goal"];
			cell.textLabel.text = NSLocalizedString(@"SettStat Avg",nil);
			cell.detailTextLabel.text = NSLocalizedString(@"SettStat Avg detail",nil);
			if ([kvs boolForKey:KVS_SettStatAvgShow]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			return cell;
		}	break;

		case 2: {	//時系列線で結ぶ
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			cell.textLabel.text = NSLocalizedString(@"SettStat TimeLine",nil);
			cell.detailTextLabel.text = NSLocalizedString(@"SettStat TimeLine detail",nil);
			if ([kvs boolForKey:KVS_SettStatTimeLine]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			return cell;
		}	break;

		case 3: {	//24Hour タテ結線する
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			cell.textLabel.text = NSLocalizedString(@"SettStat 24H_Line",nil);
			cell.detailTextLabel.text = NSLocalizedString(@"SettStat 24H_Line detail",nil);
			if ([kvs boolForKey:KVS_SettStat24H_Line]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			return cell;
		}	break;
}
    return nil;
}


#pragma mark TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する
	
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	switch (indexPath.section*100 + indexPath.row) {
		case 1: {  //KVS_SettStatAvgShow
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			if ([kvs boolForKey:KVS_SettStatAvgShow]) {
				[kvs setBool: NO forKey:KVS_SettStatAvgShow];
				cell.accessoryType = UITableViewCellAccessoryNone;
			} else {
				[kvs setBool: YES forKey:KVS_SettStatAvgShow];
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			[kvs synchronize];
		} break;

		case 2: {  //KVS_SettStatTimeLine
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			if ([kvs boolForKey:KVS_SettStatTimeLine]) {
				[kvs setBool: NO forKey:KVS_SettStatTimeLine];
				cell.accessoryType = UITableViewCellAccessoryNone;
			} else {
				[kvs setBool: YES forKey:KVS_SettStatTimeLine];
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			[kvs synchronize];
		} break;

		case 3: {  //KVS_SettStat24H_Line
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			if ([kvs boolForKey:KVS_SettStat24H_Line]) {
				[kvs setBool: NO forKey:KVS_SettStat24H_Line];
				cell.accessoryType = UITableViewCellAccessoryNone;
			} else {
				[kvs setBool: YES forKey:KVS_SettStat24H_Line];
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			[kvs synchronize];
		} break;
	}
}


#pragma mark - <AZDialDelegate>
- (void)dialChanged:(id)sender dial:(NSInteger)dial
{	// dialが変位したとき
	mValueDays = dial;
	[self refreshStatDays];
}

- (void)dialDone:(id)sender dial:(NSInteger)dial
{	// dial変位が停止したとき
	if (mAppDelegate.app_is_unlock==NO && STAT_DAYS_FREE < dial) {
		[mDialDays setDial:STAT_DAYS_FREE animated:NO];
		azAlertBox(NSLocalizedString(@"FreeLock",nil), 
				 NSLocalizedString(@"FreeLock StatLimit",nil), @"OK");
		return;
	}
	
	mValueDays = dial;
	[self refreshStatDays];

	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	[kvs setObject:[NSNumber numberWithInteger:mValueDays] forKey:KVS_SettStatDays];
}


@end
