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

/*	mAppDelegate.app_is_AdShow = NO; //これは広告表示しないViewである。 viewWillAppear:以降で定義すること
	if (mAppDelegate.adWhirlView) {	// Ad ON
		mAppDelegate.adWhirlView.frame = CGRectMake(0, 700, 320, 50);  // GAD_SIZE_320x50
		mAppDelegate.adWhirlView.hidden = YES;
		
		if (mAppDelegate.app_is_unlock) {
			// あずき商店にて Non-Ad を購入した直後。Ad停止＆破棄する
			[mAppDelegate adDealloc];
		}
	}*/
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	// Return the number of rows in the section.
	switch (section) {
		case 0:	return 2;			break;
		case 1:	return 2;			break;
		case 2:	return 2;			break;
		case 3:	return 1;			break;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//switch (indexPath.section*100 + indexPath.row) 
    return 44; // Default
}

// TableView セクションタイトルを応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	switch (section) {
		case 3:
			return	NSLocalizedString(@"All data will be removed", nil);
			break;
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *sysCellSubtitle = @"sysCellSubtitle"; //システム既定セル

	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
    
	switch (indexPath.section*100 + indexPath.row) 
	{
		case 0: {	// Tweet
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
			if ([kvs boolForKey:KVS_bTweet]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
				cell.imageView.image = [UIImage imageNamed:@"bird_32_blue"];
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.imageView.image = [UIImage imageNamed:@"bird_32_gray"];
			}
			return cell;
		}	break;
			
		case 1: {	// Calender
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			if ([kvs objectForKey:KVS_CalendarID]) {
				cell.imageView.image = [UIImage imageNamed:@"Icon32-Calender-ON"];
				cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",
									   NSLocalizedString(@"SettCalender",nil), 
									   [kvs objectForKey:KVS_CalendarTitle]];
			} else {
				cell.imageView.image = [UIImage imageNamed:@"Icon32-Calender"];
				cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",
									   NSLocalizedString(@"SettCalender",nil), 
									   NSLocalizedString(@"AZCalendarSelect NON",nil)];
			}
			cell.detailTextLabel.text = NSLocalizedString(@"SettCalender detail",nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			return cell;
		}	break;
			
		case 100: {	// SettGraph
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			cell.imageView.image = [UIImage imageNamed:@"Tab32-Graph"];
			cell.textLabel.text = NSLocalizedString(@"SettGraph",nil);
			cell.detailTextLabel.text = NSLocalizedString(@"SettGraph detail",nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			return cell;
		}	break;
			
		case 101: {	// SettStat
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			cell.imageView.image = [UIImage imageNamed:@"Tab32-Stat"];
			cell.textLabel.text = NSLocalizedString(@"SettStat",nil);
			cell.detailTextLabel.text = NSLocalizedString(@"SettStat detail",nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			return cell;
		}	break;

			
		case 200: {	// このアプリについて
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			cell.imageView.image = [UIImage imageNamed:@"Icon32"];
			cell.textLabel.text = AZLocalizedString(@"AZAbout",nil);
			cell.detailTextLabel.text = nil;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			return cell;
		}	break;

		case 201: {	// あずき商店
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			cell.imageView.image = [UIImage imageNamed:@"AZStore-32"];
			cell.textLabel.text = AZLocalizedString(@"AZStore",nil);
			cell.detailTextLabel.text = AZLocalizedString(@"AZStore detail",nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			return cell;
		}	break;
			
		
		case 300: {	// Dropbox - Download
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			cell.imageView.image = [UIImage imageNamed:@"AZDropbox-32"];
			cell.textLabel.text = NSLocalizedString(@"Dropbox Download",nil);
			cell.detailTextLabel.text = nil;
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
		case 0: {  // Tweet
			NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			if ([kvs boolForKey:KVS_bTweet]) {
				[kvs setBool: NO forKey:KVS_bTweet];
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.imageView.image = [UIImage imageNamed:@"bird_32_gray"];
			} else {
				[kvs setBool: YES forKey:KVS_bTweet];
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
				cell.imageView.image = [UIImage imageNamed:@"bird_32_blue"];
			}
			[kvs synchronize];
			//NG//[cell setNeedsDisplay]; 無反応
		} break;
			
		case 1: {  // AZCalendarSelect
			AZCalendarSelect *vc = [[AZCalendarSelect alloc] init];
			vc.hidesBottomBarWhenPushed = YES; //以降のタブバーを消す
			[self.navigationController pushViewController:vc animated:YES];
		} break;
			

		case 100: {  // 時系列グラフ設定
			SettGraphTVC *vc = [[SettGraphTVC alloc] init];
			vc.hidesBottomBarWhenPushed = YES; //以降のタブバーを消す
			[self.navigationController pushViewController:vc animated:YES];
		} break;
			
		case 101: {  // 統計グラフ設定
			SettStatTVC *vc = [[SettStatTVC alloc] init];
			vc.hidesBottomBarWhenPushed = YES; //以降のタブバーを消す
			[self.navigationController pushViewController:vc animated:YES];
		} break;
			
			
		case 200: {	// このアプリについて
			AZAboutVC *vc = [[AZAboutVC alloc] init];
			vc.ppImgIcon = [UIImage imageNamed:@"Icon57"];
			vc.ppProductTitle = @"Condition";	// 世界共通名称
			vc.ppProductSubtitle = NSLocalizedString(@"Product Title",nil); // ローカル名称
			vc.ppProductYear = @"2011";	// Copyright初年度
			vc.ppSupportSite = @"http://condition.azukid.com";
			vc.hidesBottomBarWhenPushed = YES; //以降のタブバーを消す
			[self.navigationController pushViewController:vc animated:YES];
		}	break;
			
		case 201: {	// あずき商店
			AZStoreTVC *vc = [[AZStoreTVC alloc] init];
			// 商品IDリスト
			NSSet *pids = [NSSet setWithObjects:STORE_PRODUCTID_UNLOCK, nil]; // 商品が複数ある場合は列記
			[vc setProductIDs:pids];
			vc.hidesBottomBarWhenPushed = YES; //以降のタブバーを消す
			[self.navigationController pushViewController:vc animated:YES];
		}	break;

	
		case 300: {	// Dropbox - Download
			// Dropbox を開ける
			AZDropboxVC *vc = [[AZDropboxVC alloc] initWithMode:AZDropboxDownload
													  extension:GD_EXTENSION delegate:self];
			vc.title = NSLocalizedString(@"Dropbox Download",nil);
			[vc setHidesBottomBarWhenPushed:YES]; // 現在のToolBar状態をPushした上で、次画面では非表示にする
			// Set up NEXT Left [Back] buttons.
			self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
													 initWithTitle: NSLocalizedString(@"Back", nil)
													 style:UIBarButtonItemStylePlain
													 target:nil  action:nil];
			//表示開始
			[self.navigationController pushViewController:vc animated:YES];
			//表示開始後にsetする
			[vc setCryptHidden:YES	 Enabled:NO];////表示後にセットすること
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


#pragma mark - <AZDropboxDelegate>
- (NSString*)azDropboxBeforeUpFilePath:(NSString*)filePath crypt:(BOOL)crypt {	// 未使用
	return @"NG";
}

- (NSString*)azDropboxDownAfterFilePath:(NSString*)filePath
{	//Down後処理＜DOWNしたファイルを読み込むなど＞
	// filePath から NSManagedObject を読み込む
	NSError *err = nil;
	// 読み込む
	NSString *zJson = [NSString stringWithContentsOfFile:filePath
												encoding:NSUTF8StringEncoding error:&err];
	if (err OR zJson==nil) {
		NSLog(@"tmpFileLoad: stringWithContentsOfFile: (err=%@)", [err description]);
		GA_TRACK_EVENT_ERROR([err description],0);
		return [err description];
	}
	NSLog(@"tmpFileLoad: zJson=%@", zJson);
	// JSON --> NSArray
	DBJSON	*js = [DBJSON new];
	NSArray *ary = [js objectWithString:zJson error:&err];
	if (err) {
		NSLog(@"tmpFileLoad: SBJSON: objectWithString: (err=%@) zJson=%@", [err description], zJson);
		GA_TRACK_EVENT_ERROR([err description],0);
		return [err description];
	}
	NSLog(@"tmpFileLoad: ary=%@", ary);
	//
	NSDictionary *dict = [ary objectAtIndex:0]; // Header
	if (![[dict objectForKey:@"#class"] isEqualToString:@"Header"]) {
		NSLog(@"tmpFileLoad: #class ERR: %@", dict);
		return @"NG #class";
	}
	if (![[dict objectForKey:@"#header"] isEqualToString:FILE_HEADER_PREFIX]) {
		NSLog(@"tmpFileLoad: #header ERR: %@", dict);
		return @"NG #header";
	}
	//----------------------------------------------------------------------------------  iCloud-KVS
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	[kvs setObject: azNSNull([dict objectForKey:Goal_nBpHi_mmHg])		forKey:Goal_nBpHi_mmHg];
	[kvs setObject: azNSNull([dict objectForKey:Goal_nBpLo_mmHg])		forKey:Goal_nBpLo_mmHg];
	[kvs setObject: azNSNull([dict objectForKey:Goal_nPulse_bpm])			forKey:Goal_nPulse_bpm];
	[kvs setObject: azNSNull([dict objectForKey:Goal_nTemp_10c])			forKey:Goal_nTemp_10c];
	[kvs setObject: azNSNull([dict objectForKey:Goal_nWeight_10Kg])	forKey:Goal_nWeight_10Kg];
	[kvs setObject: azNSNull([dict objectForKey:Goal_sEquipment])			forKey:Goal_sEquipment];
	[kvs setObject: azNSNull([dict objectForKey:Goal_sNote1])					forKey:Goal_sNote1];
	[kvs setObject: azNSNull([dict objectForKey:Goal_sNote2])					forKey:Goal_sNote2];
	//----------[0.9]以下追加
	[kvs setObject: azNSNull([dict objectForKey:Goal_nPedometer])			forKey:Goal_nPedometer];
	[kvs setObject: azNSNull([dict objectForKey:Goal_nBodyFat_10p])		forKey:Goal_nBodyFat_10p];
	[kvs setObject: azNSNull([dict objectForKey:Goal_nSkMuscle_10p])	forKey:Goal_nSkMuscle_10p];
	[kvs synchronize]; // iCloud最新同期（取得）
	//---------------------------------------------------------------------------------- 
	
	// E2record 全クリア
	[mAppDelegate.mocBase deleteAllCoreData];
	// E2record 生成
	for (NSDictionary *dict in ary)
	{
		NSString *zClass = [dict objectForKey:@"#class"];
		
		if ([zClass isEqualToString:E2_ENTITYNAME]) {
			[mAppDelegate.mocBase insertNewObjectForDictionary:dict];
		}
		//else if ([zClass isEqualToString:@"E1body"]) {
		//	[mocBase insertNewObjectForDictionary:dict];
		//}
	}
	// コミット
	[mAppDelegate.mocBase commit];
	// E2 件数
	mAppDelegate.app_e2record_count = [mAppDelegate.mocBase e2record_count];
	return nil; //OK
}

- (void)azDropboxDownCompleated
{	//ここで、Down成功後の再描画など行う
	// 再読み込み 通知発信---> E1viewController
	[[NSNotificationCenter defaultCenter] postNotificationName:NFM_REFRESH_ALL_VIEWS
														object:self userInfo:nil];
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}


@end
