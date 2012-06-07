//
//  SettGraphTVC.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettGraphTVC.h"
#import "GraphVC.h"


@implementation SettGraphTVC
@synthesize ppBackGraph = __BackGraph;


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
		GA_TRACK_PAGE(@"SettGraphTVC");
		__BackGraph = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = NSLocalizedString(@"SettGraph",nil);
	
	if (mPanels==nil) {
		//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
		NSArray *ar = [kvs objectForKey:KVS_SettGraphs];
		if (ar) {
			mPanels = [[NSMutableArray alloc] initWithArray:ar];
			// 設定中は、BpLoを取り除き、BpHiだけにする ＞＞ 保存時にBpHiの次にBpLoを挿入する
			for (int iRow=0; iRow<[mPanels count]; iRow++) {
				NSInteger item = [[mPanels objectAtIndex:iRow] integerValue];
				if (abs(item)==AzConditionBpLo) {
					[mPanels removeObjectAtIndex:iRow];	//BpLo削除
					break;
				}
			}
		} else {
			// didFinishLaunchingWithOptions:にて初期セット済み
			azAlertBox(NSLocalizedString(@"SettGraph ERR GUD",nil), NSLocalizedString(@"SettGraph ERR GUD detail",nil), @"OK");
			GA_TRACK_EVENT_ERROR(@"SettGraph ERR GUD",0);
			[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
		}
	}
	//[self.tableView setEditing:YES];
	self.navigationItem.rightBarButtonItem = [self editButtonItem];	//右[Edit]ボタン
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	if (__BackGraph) {
		// Graphから呼び出されたときバックボタンが無いので付ける
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
												 initWithTitle: NSLocalizedString(@"SettGraph Back", nil)
												 style:UIBarButtonItemStyleBordered
												 target:self action:@selector(actionBack)];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[mAppDelegate adShow:2];
}

- (void)viewWillDisappear:(BOOL)animated
{	// 非表示になる前に呼び出される
	// 設定中は、BpLoを取り除き、BpHiだけ ＞＞ 保存時にBpHiの次にBpLoを挿入する
	for (int iRow=0; iRow<[mPanels count]; iRow++) {
		NSInteger item = [[mPanels objectAtIndex:iRow] integerValue];
		if (abs(item)==AzConditionBpHi) {
			if (item < 0) {
				item = AzConditionBpLo * (-1); //Lo ON
			} else {
				item = AzConditionBpLo; //Lo OFF
			}
			// BpHiの次にBpLoを挿入する
			[mPanels insertObject:[NSNumber numberWithInteger:item] atIndex:iRow+1];
			break;
		}
	}
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	[kvs setObject:mPanels forKey:KVS_SettGraphs];
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
    return iS_iPAD OR (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section==0) {
		return 1;
	}
	assert(section==1);
    return [mPanels count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section==0) {
		return 44;
	}
    return 44; // Default
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section==1) {
		return NSLocalizedString(@"SettGraph Header",nil);
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (section==1 && !mAppDelegate.app_is_unlock) {
		return @"\n\n\n"; //広告スペース
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *sysCellSubtitle = @"sysCellSubtitle"; //システム既定セル
	//static NSString *sysCellDial = @"sysCellDial";

	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	
	if (indexPath.section==0) {
		switch (indexPath.row) {
			case 0: {	// Goal
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
				if (cell == nil) {
					cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
				}
				cell.imageView.image = [UIImage imageNamed:@"Icon20-Goal"];
				cell.textLabel.text = NSLocalizedString(@"SettGraph Goal",nil);
				//cell.detailTextLabel.text = NSLocalizedString(@"SettGraph Goal detail",nil);
				//cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
				//cell.detailTextLabel.minimumFontSize = 10;
				if ([kvs boolForKey:KVS_bGoal]) {
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
				} else {
					cell.accessoryType = UITableViewCellAccessoryNone;
				}
				return cell;
			}	break;
		}
	}
	
	//section==1 パネル並び替え
    assert(indexPath.section==1);
	if (indexPath.row<0 OR AzConditionCount<=indexPath.row) return nil;

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
	}
	cell.imageView.image = nil;
	
	NSInteger item = [[mPanels objectAtIndex:indexPath.row] integerValue];
	if (item < 0) {
		item *= (-1);
		cell.accessoryType = UITableViewCellAccessoryCheckmark;	// グラフ表示ON
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;			// グラフ表示OFF
	}
	assert(0<=item);
	// パネル名称
	switch (item) {
		case AzConditionNote:
			cell.textLabel.text = NSLocalizedString(@"SettGraph Note",nil);
			//cell.userInteractionEnabled = NO; //NG//Moveできない
			cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
			break;
		case AzConditionBpHi:
			cell.textLabel.text = NSLocalizedString(@"SettGraph Bp",nil);
			break;
		case AzConditionBpLo: //ここではBpHiのみ代表として使用
			assert(NO);
			break;
		case AzConditionPuls:
			cell.textLabel.text = NSLocalizedString(@"SettGraph Pulse",nil);
			break;
		case AzConditionTemp:
			cell.textLabel.text = NSLocalizedString(@"SettGraph Temp",nil);
			break;
		case AzConditionWeight:
			cell.textLabel.text = NSLocalizedString(@"SettGraph Weight",nil);
			break;
		case AzConditionPedo:
			cell.textLabel.text = NSLocalizedString(@"SettGraph Pedo",nil);
			break;
		case AzConditionFat:
			cell.textLabel.text = NSLocalizedString(@"SettGraph Fat",nil);
			break;
		case AzConditionSkm:
			cell.textLabel.text = NSLocalizedString(@"SettGraph Skm",nil);
			break;
	}
    return cell;
}

#pragma mark  TableView Edit 
// TableView Editモードの表示
- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
	[super setEditing:editing animated:animated];
    // この後、self.editing = YES になっている。
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{   // Return NO if you do not want the specified item to be editable.
    return (indexPath.section==1);
}

// TableView Editボタンスタイル
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return UITableViewCellEditingStyleNone;
}

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

#pragma mark  TableView Move
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{	// Return NO if you do not want the item to be re-orderable.
	if (indexPath.section==1) {
		return YES;
	}
	return NO;
}

// Editモード時の行移動「先」を返す　　＜＜最終行のAdd専用行への移動ならば1つ前の行を返している＞＞
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)fromPath toProposedIndexPath:(NSIndexPath *)toPath 
{
	if (toPath.section==1) {
		return toPath;	//移動先OK
	}
	return fromPath; //移動先NGにつき、元の位置を返す
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
	  toIndexPath:(NSIndexPath *)toIndexPath
{
	if (fromIndexPath.section != 1) return;
	if (toIndexPath.section != 1) return;

	__strong NSNumber *num = [mPanels objectAtIndex:fromIndexPath.row];
	[mPanels removeObjectAtIndex:fromIndexPath.row];
	[mPanels insertObject:num atIndex:toIndexPath.row];
}


#pragma mark TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する

	if (indexPath.section==0) {
		switch (indexPath.row) {
			case 0: {  // Goal
				//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
				NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
				UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
				if ([kvs boolForKey:KVS_bGoal]) {
					[kvs setBool: NO forKey:KVS_bGoal];
					cell.accessoryType = UITableViewCellAccessoryNone;
				} else {
					[kvs setBool: YES forKey:KVS_bGoal];
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
				}
				[kvs synchronize];
			} break;
		}
		return;
	}
	
	assert(indexPath.section==1);
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	//BOOL bCheck;
	// グラフ表示チェック
	NSInteger item = [[mPanels objectAtIndex:indexPath.row] integerValue];
	NSNumber *num = [NSNumber numberWithInteger: item * (-1)]; //反転
	if ([num integerValue] < 0) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;	// グラフ表示ON
		//bCheck = YES;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;			// グラフ表示OFF
		//bCheck = NO;
	}
	[mPanels replaceObjectAtIndex:indexPath.row withObject:num]; //置換
}


@end
