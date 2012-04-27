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
		NSArray *ar = [kvs objectForKey:GUD_SettGraphs];
		if (ar) {
			mPanels = [[NSMutableArray alloc] initWithArray:ar];
		} else {
			// didFinishLaunchingWithOptions:にて初期セット済み
			alertBox(NSLocalizedString(@"SettGraph ERR GUD",nil), NSLocalizedString(@"SettGraph ERR GUD detail",nil), @"OK");
			GA_TRACK_EVENT_ERROR(@"SettGraph ERR GUD",0);
			[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
		}
	}
	//[self.tableView setEditing:YES];
	self.navigationItem.rightBarButtonItem = [self editButtonItem];
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

	//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	mValueDays = [[kvs objectForKey:GUD_SettStatDays] integerValue];
	if (mValueDays<1 OR GRAPH_PAGE_LIMIT <mValueDays) {
		mValueDays = 1;
	}
}

- (void)viewWillDisappear:(BOOL)animated
{	// 非表示になる前に呼び出される
	//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	[kvs setObject:mPanels forKey:GUD_SettGraphs];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section==0) {
		return 2;
	}
	assert(section==1);
    return [mPanels count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section==0) {
		if (indexPath.row==1) return 88; // Days
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
	return nil;
}

- (void)refreshGraphDays
{
	if (mLbValueDays) {
		mLbValueDays.text = [NSString stringWithFormat:@"%ld", (long)mValueDays];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *sysCellSubtitle = @"sysCellSubtitle"; //システム既定セル
	static NSString *sysCellDial = @"sysCellDial";
	//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	
	if (indexPath.section==0) {
		switch (indexPath.row) {
			case 0: {	// Goal
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
				if (cell == nil) {
					cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
				}
				cell.textLabel.text = NSLocalizedString(@"SettGraph Goal",nil);
				//cell.detailTextLabel.text = NSLocalizedString(@"SettGraph Goal detail",nil);
				//cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
				//cell.detailTextLabel.minimumFontSize = 10;
				if ([kvs boolForKey:GUD_bGoal]) {
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
				} else {
					cell.accessoryType = UITableViewCellAccessoryNone;
				}
				return cell;
			}	break;
			case 1: {	// 期間指定
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellDial];
				if (cell == nil) {
					cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellDial];
					// Label
					UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 25)];
					lb.font = [UIFont boldSystemFontOfSize:20];
					lb.adjustsFontSizeToFitWidth = YES;
					lb.minimumFontSize = 10;
					lb.backgroundColor = [UIColor clearColor];
					lb.text = NSLocalizedString(@"SettGraph Days",nil);
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
														  max: 200
														 step: 1
													  stepper: 1];
					[cell.contentView addSubview:mDialDays];
					mDialDays.backgroundColor = [UIColor clearColor]; //self.backgroundColor;
				}
				[self refreshGraphDays];
				return cell;
			}	break;
		}
	}
	
    assert(indexPath.section==1);
	if (indexPath.row<0 OR AzConditionCount<=indexPath.row) return nil;

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
	}
	
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
			cell.textLabel.text = NSLocalizedString(@"SettGraph BpHi",nil);
			break;
		case AzConditionBpLo:
			cell.textLabel.text = NSLocalizedString(@"SettGraph BpLo",nil);
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
				if ([kvs boolForKey:GUD_bGoal]) {
					[kvs setBool: NO forKey:GUD_bGoal];
					cell.accessoryType = UITableViewCellAccessoryNone;
				} else {
					[kvs setBool: YES forKey:GUD_bGoal];
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
				}
				[kvs synchronize];
			} break;
		}
		return;
	}
	
	assert(indexPath.section==1);
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	// グラフ表示チェック
	NSInteger item = [[mPanels objectAtIndex:indexPath.row] integerValue];
	NSNumber *num = [NSNumber numberWithInteger: item * (-1)]; //反転
	if ([num integerValue] < 0) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;	// グラフ表示ON
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;			// グラフ表示OFF
	}
	[mPanels replaceObjectAtIndex:indexPath.row withObject:num]; //置換

	// BpHi と BpLo を同調させる
	item = [[mPanels objectAtIndex:indexPath.row] integerValue];
	if (abs(item)==AzConditionBpHi) {
		// BpLoを更新する
		for (int iRow=0; iRow<[mPanels count]; iRow++) {
			if (abs([[mPanels objectAtIndex:iRow] integerValue])==AzConditionBpLo) {
				NSIndexPath *ip = [NSIndexPath indexPathForRow:iRow inSection:indexPath.section];
				cell = [tableView cellForRowAtIndexPath:ip];
				if ([num integerValue] < 0) {
					cell.accessoryType = UITableViewCellAccessoryCheckmark;	// グラフ表示ON
				} else {
					cell.accessoryType = UITableViewCellAccessoryNone;			// グラフ表示OFF
				}
				[mPanels replaceObjectAtIndex:iRow withObject:num]; //置換
				break;
			}
		}
	}
	else if (abs(item)==AzConditionBpLo) {
		// BpHiを更新する
		for (int iRow=0; iRow<[mPanels count]; iRow++) {
			if (abs([[mPanels objectAtIndex:iRow] integerValue])==AzConditionBpHi) {
				NSIndexPath *ip = [NSIndexPath indexPathForRow:iRow inSection:indexPath.section];
				cell = [tableView cellForRowAtIndexPath:ip];
				if ([num integerValue] < 0) {
					cell.accessoryType = UITableViewCellAccessoryCheckmark;	// グラフ表示ON
				} else {
					cell.accessoryType = UITableViewCellAccessoryNone;			// グラフ表示OFF
				}
				[mPanels replaceObjectAtIndex:iRow withObject:num]; //置換
				break;
			}
		}
	}
}


#pragma mark - <AZDialDelegate>
- (void)dialChanged:(id)sender dial:(NSInteger)dial
{	// dialが変位したとき
	mValueDays = dial;
	[self refreshGraphDays];
}

- (void)dialDone:(id)sender dial:(NSInteger)dial
{	// dial変位が停止したとき
	mValueDays = dial;
	[self refreshGraphDays];

	//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	[kvs setObject:[NSNumber numberWithInteger:mValueDays] forKey:GUD_SettStatDays];
}


@end
