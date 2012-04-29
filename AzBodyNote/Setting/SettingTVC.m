//
//  SettingTVC.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "SettingTVC.h"



@interface SettingTVC (Private)
@end

@implementation SettingTVC


- (id)initWithStyle:(UITableViewStyle)style;
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
		//NG//mAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
		GA_TRACK_PAGE(@"SettingTVC");
    }
    return self;
}

- (void)viewDidLoad
{
	if (mAppDelegate==nil) {		// initWithStyleではダメ(nil)だった。
		mAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	}
	assert(mAppDelegate);

    [super viewDidLoad];
	self.title = NSLocalizedString(@"TabSettings",nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self.tableView reloadData];

	mAppDelegate.app_is_AdShow = NO; //これは広告表示しないViewである。 viewWillAppear:以降で定義すること
	if (mAppDelegate.adWhirlView) {	// Ad ON
		mAppDelegate.adWhirlView.frame = CGRectMake(0, 700, 320, 50);  // GAD_SIZE_320x50
		mAppDelegate.adWhirlView.hidden = YES;
		
		if (mAppDelegate.app_is_unlock) {
			// あずき商店にて Non-Ad を購入した直後。Ad停止＆破棄する
			[mAppDelegate adDealloc];
		}
	}
}
/*
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}
*/
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{	// Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	// Return the number of rows in the section.
	if (section==0) {
		return 3;
	} else {
		return 2;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section*100 + indexPath.row) 
	{
		case 0:	// Tweet
		case 1:	// Goal
		case 2:	// Calender
		case 3:	// Panels Graphs
			return  55;
	}
    return 44; // Default
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *sysCellSubtitle = @"sysCellSubtitle"; //システム既定セル

	//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
    
	switch (indexPath.section*100 + indexPath.row) 
	{
		case 0: {	// SettGraph
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			cell.textLabel.text = NSLocalizedString(@"SettGraph",nil);
			cell.detailTextLabel.text = NSLocalizedString(@"SettGraph detail",nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			return cell;
		}	break;
			
		case 1: {	// Tweet
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			cell.textLabel.text = NSLocalizedString(@"SettTweet",nil);
			if (mAppDelegate.app_is_unlock) {
				cell.detailTextLabel.text = NSLocalizedString(@"SettTweet detail",nil);
			} else {
				cell.detailTextLabel.text = NSLocalizedString(@"SettTweet detail FREE",nil);
			}
			if ([kvs boolForKey:GUD_bTweet]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			return cell;
		}	break;
			
		case 2: {	// Calender
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			if ([kvs objectForKey:GUD_CalendarID]) {
				cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",
									   NSLocalizedString(@"SettCalender",nil), 
									   [kvs objectForKey:GUD_CalendarTitle]];
			} else {
				cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",
									   NSLocalizedString(@"SettCalender",nil), 
									   NSLocalizedString(@"AZCalendarSelect NON",nil)];
			}
			cell.detailTextLabel.text = NSLocalizedString(@"SettCalender detail",nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			return cell;
		}	break;
			
	/*	case 9: {	// GSpread
			static NSString *cid = @"SettCellGSpread";  //== Identifire に一致させること
			SettCellGSpread *cell = (SettCellGSpread*)[tableView dequeueReusableCellWithIdentifier:cid];
			if (cell == nil) {
				UINib *nib = [UINib nibWithNibName:cid   bundle:nil];
				[nib instantiateWithOwner:self options:nil];
				cell = (SettCellGSpread*)[tableView dequeueReusableCellWithIdentifier:cid];
				assert(cell);
			}
			return cell;
		}	break;*/
			
		case 100: {	// このアプリについて
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			//cell.imageView.image = [UIImage imageNamed:@"Icon57"];
			//cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
			//cell.imageView.frame = CGRectMake(0, 0, 32, 32);
			cell.textLabel.text = AZClassLocalizedString(@"AZAbout",nil);
			cell.detailTextLabel.text = nil;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			return cell;
		}	break;

		case 101: {	// あずき商店
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			cell.imageView.image = [UIImage imageNamed:@"Icon-Store-32"];
			cell.textLabel.text = AZClassLocalizedString(@"AZStore",nil);
			cell.detailTextLabel.text = AZClassLocalizedString(@"AZStore detail",nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			return cell;
		}	break;
	}
    return nil;
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{	// 画面遷移のとき、didSelectRowAtIndexPath:よりも先に呼び出される
	NSLog(@"prepareForSegue: sender=%@", sender);
	NSLog(@"prepareForSegue: segue=%@", segue);
	NSLog(@"prepareForSegue: [segue identifier]=%@", [segue identifier]);
	NSLog(@"prepareForSegue: [segue sourceViewController]=%@", [segue sourceViewController]);
	NSLog(@"prepareForSegue: [segue destinationViewController]=%@", [segue destinationViewController]);
	
/*	if ([[segue identifier] isEqualToString:@"push_Information"])
	{
		InformationVC *vc = [segue destinationViewController];
	}*/
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する
	
	switch (indexPath.section*100 + indexPath.row) 
	{
		case 0: {  // グラフ設定
			SettGraphTVC *vc = [[SettGraphTVC alloc] init];
			vc.hidesBottomBarWhenPushed = YES; //以降のタブバーを消す
			[self.navigationController pushViewController:vc animated:YES];
		} break;
			
		case 1: {  // Tweet
			NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			if ([kvs boolForKey:GUD_bTweet]) {
				[kvs setBool: NO forKey:GUD_bTweet];
				cell.accessoryType = UITableViewCellAccessoryNone;
			} else {
				[kvs setBool: YES forKey:GUD_bTweet];
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			[kvs synchronize];
		} break;
			
		case 2: {  // AZCalendarSelect
			AZCalendarSelect *vc = [[AZCalendarSelect alloc] init];
			vc.hidesBottomBarWhenPushed = YES; //以降のタブバーを消す
			[self.navigationController pushViewController:vc animated:YES];
		} break;
			
		case 100: {	// このアプリについて
			AZAboutVC *vc = [[AZAboutVC alloc] init];
			vc.ppImgIcon = [UIImage imageNamed:@"Icon57"];
			vc.ppProductTitle = @"Condition";	// 世界共通名称
			vc.ppProductSubtitle = NSLocalizedString(@"Product Title",nil); // ローカル名称
			vc.ppProductYear = @"2011";	// Copyright初年度
			vc.ppSupportSite = @"http://condition.azukid.com";
			vc.hidesBottomBarWhenPushed = YES; //以降のタブバーを消す
			[self.navigationController pushViewController:vc animated:YES];
		}	break;
			
		case 101: {	// あずき商店
			AZStoreTVC *vc = [[AZStoreTVC alloc] init];
			// 商品IDリスト
			NSSet *pids = [NSSet setWithObjects:STORE_PRODUCTID_UNLOCK, nil]; // 商品が複数ある場合は列記
			[vc setProductIDs:pids];
			vc.hidesBottomBarWhenPushed = YES; //以降のタブバーを消す
			[self.navigationController pushViewController:vc animated:YES];
		}	break;
	}
}


#pragma mark - <AZStoreDelegate>
- (void)azStorePurchesed:(NSString*)productID
{	//既に呼び出し元にて、[userDefaults setBool:YES  forKey:productID]　登録済み
	GA_TRACK_EVENT(@"AZStore", @"azStorePurchesed", productID,1);
	if ([productID isEqualToString:STORE_PRODUCTID_UNLOCK]) {
		mAppDelegate.app_is_unlock = YES; //購入済み
	}
	// NFM_REFRESH_ALL_VIEWS 通知
	NSNotification* refreshNotification = [NSNotification notificationWithName:NFM_REFRESH_ALL_VIEWS
																		object:self  userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
}

@end
