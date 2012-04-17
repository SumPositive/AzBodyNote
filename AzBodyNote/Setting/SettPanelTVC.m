//
//  SettPanelTVC.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettPanelTVC.h"

@interface SettPanelTVC ()

@end

@implementation SettPanelTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
		mAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
		assert(mAppDelegate);
		GA_TRACK_PAGE(@"SettPanelTVC");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = NSLocalizedString(@"SettPanel",nil);
	
	if (mPanels==nil) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSArray *ar = [userDefaults objectForKey:GUD_SettPanels];
		if (ar) {
			mPanels = [[NSMutableArray alloc] initWithArray:ar];
		} else {
			// didFinishLaunchingWithOptions:にて初期セット済み
			alertBox(NSLocalizedString(@"SettPanel ERR GUD",nil), NSLocalizedString(@"SettPanel ERR GUD detail",nil), @"OK");
			GA_TRACK_EVENT_ERROR(@"SettPanel ERR GUD",0);
			[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
		}
	}
	//[self.tableView setEditing:YES];
	self.navigationItem.rightBarButtonItem = [self editButtonItem];
}

- (void)viewWillDisappear:(BOOL)animated
{	// 非表示になる前に呼び出される
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:mPanels forKey:GUD_SettPanels];
	[userDefaults synchronize];
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
    return [mPanels count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section==0) {
		return NSLocalizedString(@"SettPanel Header",nil);
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    assert(indexPath.section==0);
	if (indexPath.row<0 OR AzConditionCount<=indexPath.row) return nil;

    static NSString *CellIdentifier = @"CellPanel";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
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
			cell.textLabel.text = NSLocalizedString(@"SettPanel Note",nil);
			cell.userInteractionEnabled = NO; // 操作なし
			break;
		case AzConditionBpHi:
			cell.textLabel.text = NSLocalizedString(@"SettPanel BpHi",nil);
			break;
		case AzConditionBpLo:
			cell.textLabel.text = NSLocalizedString(@"SettPanel BpLo",nil);
			break;
		case AzConditionPuls:
			cell.textLabel.text = NSLocalizedString(@"SettPanel Pulse",nil);
			break;
		case AzConditionTemp:
			cell.textLabel.text = NSLocalizedString(@"SettPanel Temp",nil);
			break;
		case AzConditionWeight:
			cell.textLabel.text = NSLocalizedString(@"SettPanel Weight",nil);
			break;
		case AzConditionPedo:
			cell.textLabel.text = NSLocalizedString(@"SettPanel Pedo",nil);
			break;
		case AzConditionFat:
			cell.textLabel.text = NSLocalizedString(@"SettPanel Fat",nil);
			break;
		case AzConditionSkm:
			cell.textLabel.text = NSLocalizedString(@"SettPanel Skm",nil);
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
    return YES;
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
    return YES;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	__strong NSNumber *num = [mPanels objectAtIndex:fromIndexPath.row];
	[mPanels removeObjectAtIndex:fromIndexPath.row];
	[mPanels insertObject:num atIndex:toIndexPath.row];
}


#pragma mark TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する

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
}

@end
