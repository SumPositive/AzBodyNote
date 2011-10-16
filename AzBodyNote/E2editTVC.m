//
//  E2editTVC.m
//  AzBodyNote
//
//  Created by 松山 和正 on 11/10/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "MocEntity.h"
#import "MocFunctions.h"
#import "E2editTVC.h"
#import "E2editCellDial.h"
#import "E2editCellNote.h"

@implementation E2editTVC
@synthesize Re2edit;
//@synthesize ownerCellDial, ownerCellNote;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - delegate

- (void)editUpdate
{
	self.navigationItem.rightBarButtonItem.enabled = YES; // 変更あればYESにする
}



#pragma mark - IBAction

/*
- (IBAction)ibBuValue:(UIButton *)button
{
	NSLog(@"ibBuValue");
}

- (IBAction)ibSrValueChange:(UISlider *)slider
{
	NSLog(@"ibSrValueChange");
}

- (IBAction)actionCellValueTouch:(UIButton *)button
{
	NSLog(@"actionCellValueTouch .tag=%d", button.tag);
}
- (IBAction)actionCellSliderChange:(UISlider *)slider
{
	NSLog(@"actionCellSliderChange .tag=%d", slider.tag);
}
*/

- (void)setE2recordPrev
{
	assert(Re2edit);
	E2record	*e2prev;	// 直前のレコード
	// Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:NO];
	NSArray *sortDesc = [[NSArray alloc] initWithObjects:sort1,nil]; // 日付降順：Limit抽出に使用
	[sort1 release];
	
	// 直前のレコードを取得
	NSDate *dateNow = Re2edit.dateTime;	 // 現在編集中の日付
	if (dateNow==nil) dateNow = [NSDate date];
	
	// E2_nBpHi_mmHg
	NSArray *arFetch = [MocFunctions select:@"E2record" limit:1 offset:0
									  where:[NSPredicate predicateWithFormat: E2_nBpHi_mmHg @" > 0 AND " E2_dateTime @" < %@", dateNow]
									   sort:sortDesc]; // 日付降順の先頭から1件抽出
	if ([arFetch count]==1) {
		e2prev = [arFetch objectAtIndex:0];
		NSLog(@"Re2prev.nBpHi_mmHg=%d", [e2prev.nBpHi_mmHg integerValue]);
		mPrevBpHi = [e2prev.nBpHi_mmHg integerValue];
	} else {
		mPrevBpHi = 130;
	}
	// E2_nBpLo_mmHg
	arFetch = [MocFunctions select:@"E2record" limit:1 offset:0
									  where:[NSPredicate predicateWithFormat: E2_nBpLo_mmHg @" > 0 AND " E2_dateTime @" < %@", dateNow]
									   sort:sortDesc]; // 日付降順の先頭から1件抽出
	if ([arFetch count]==1) {
		e2prev = [arFetch objectAtIndex:0];
		mPrevBpLo = [e2prev.nBpLo_mmHg integerValue];
	} else {
		mPrevBpLo = 80;
	}
	// E2_nPulse_bpm
	arFetch = [MocFunctions select:@"E2record" limit:1 offset:0
									  where:[NSPredicate predicateWithFormat: E2_nPulse_bpm @" > 0 AND " E2_dateTime @" < %@", dateNow]
									   sort:sortDesc]; // 日付降順の先頭から1件抽出
	if ([arFetch count]==1) {
		e2prev = [arFetch objectAtIndex:0];
		mPrevPuls = [e2prev.nPulse_bpm integerValue];
	} else {
		mPrevPuls = 70;
	}
	// E2_nWeight_g
	arFetch = [MocFunctions select:@"E2record" limit:1 offset:0
									  where:[NSPredicate predicateWithFormat: E2_nWeight_g @" > 0 AND " E2_dateTime @" < %@", dateNow]
									   sort:sortDesc]; // 日付降順の先頭から1件抽出
	if ([arFetch count]==1) {
		e2prev = [arFetch objectAtIndex:0];
		mPrevWeight = [e2prev.nWeight_g integerValue];
	} else {
		mPrevWeight = 700;
	}
	// E2_nTemp_10c
	arFetch = [MocFunctions select:@"E2record" limit:1 offset:0
									  where:[NSPredicate predicateWithFormat: E2_nTemp_10c @" > 0 AND " E2_dateTime @" < %@", dateNow]
									   sort:sortDesc]; // 日付降順の先頭から1件抽出
	if ([arFetch count]==1) {
		e2prev = [arFetch objectAtIndex:0];
		mPrevTemp= [e2prev.nTemp_10c integerValue];
	} else {
		mPrevTemp = 370;
	}
}

- (void)actionClear
{
	assert(mIsAddNew);
	assert(Re2edit);
	//appDelegate.mIsUpdate = NO;
	self.navigationItem.rightBarButtonItem.enabled = NO; // 変更あればYESにする
	
	Re2edit.dateTime = [NSDate date];
	Re2edit.sNote1 = nil;
	Re2edit.sNote2 = nil;
	Re2edit.nBpHi_mmHg = nil;
	Re2edit.nBpLo_mmHg = nil;
	Re2edit.nPulse_bpm = nil;
	Re2edit.nWeight_g = nil;
	Re2edit.nTemp_10c = nil;
	
	[self setE2recordPrev];
	[self.tableView reloadData];
}

- (void)actionSave
{
	// データ整合処理
	// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents* comp = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit
										 fromDate:Re2edit.dateTime];
	Re2edit.nYearMM = [NSNumber numberWithInteger:([comp year] * 100 + [comp month])];
	
	// Save & Commit
	[MocFunctions commit];

	//appDelegate.mIsUpdate = NO;
	self.navigationItem.rightBarButtonItem.enabled = NO; // 変更あればYESにする

	if (mIsAddNew) {
		// AddNew mode
		//alertBox(NSLocalizedString(@"AddNew Save",nil) , nil, NSLocalizedString(@"Roger",nil));
		//[Re2edit release], 
		Re2edit = [MocFunctions insertAutoEntity:@"E2record"];
		[self actionClear];
		[self.tableView reloadData];
		// List画面に切り替えて、追加行を一時ハイライトする
		self.navigationController.tabBarController.selectedIndex = 1; // List画面へ
	} else {
		// Edit mode
		[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
	}
}

- (void)actionCancel
{
	assert(mIsAddNew==NO);
	// Edit mode ONLY
	[MocFunctions rollBack];
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	//appDelegate = (AzBodyNoteAppDelegate *)[[UIApplication sharedApplication] delegate];
	//appDelegate.mIsUpdate = NO;
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	
	if (Re2edit) {
		// Modify mode.
		self.title = NSLocalizedString(@"Modify",nil);
		mIsAddNew = NO;
		/* [<Back]ボタンの方が解りやすい。 修正あるのにBackしたときはアラート表示してからRollback処理する。
		// [Cancel]ボタンを左側に追加する  Navi標準の戻るボタンでは actionCancel 処理ができないため
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
												  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
												  target:self action:@selector(actionCancel)] autorelease];*/
	} else {
		// AddNew mode.
		self.title = NSLocalizedString(@"AddNew",nil);
		mIsAddNew = YES;
		Re2edit = [MocFunctions insertAutoEntity:@"E2record"]; // autorelese
		// [Clear]ボタンを左側に追加する
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
												  initWithTitle:NSLocalizedString(@"Clear",nil) style:UIBarButtonItemStyleBordered 
												  target:self action:@selector(actionClear)] autorelease];
	}
	[self setE2recordPrev];
	
	// SAVEボタンを右側に追加する
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
											   target:self action:@selector(actionSave)] autorelease];
	self.navigationItem.rightBarButtonItem.enabled = NO; // 変更あればYESにする

	// TableView
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // セル区切り線なし
	//self.tableView.separatorColor = [UIColor blackColor];
	//self.tableView.backgroundColor = [UIColor colorWithRed:151.0/256 green:80.0/256 blue:77.0/256 alpha:0.7];
	UIImage *imgTile = [UIImage imageNamed:@"Tx-WoodWhite320"];
	self.tableView.backgroundColor = [UIColor colorWithPatternImage:imgTile];
	
	// iAd
	if (mADBanner==nil) {
		mADBanner = [[ADBannerView alloc] init];
		mADBanner.delegate = self;
		mADBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
		[self.parentViewController.view addSubview:mADBanner];
		mADBannerY = self.tabBarController.tabBar.frame.origin.y - mADBanner.frame.size.height;	// 表示位置
		NSLog(@"mADBannerY=%.1f", mADBannerY);
	}
	CGRect rc = mADBanner.frame;
	rc.origin.y = self.view.frame.size.height + 50; // 下へ隠す
	mADBanner.frame = rc;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	if (mADBanner) {
		[mADBanner cancelBannerViewAction];
		mADBanner.delegate = nil;
		mADBanner = nil;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	//[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait); // タテ正面のみ
}

- (void)dealloc
{
	[Re2edit release], Re2edit = nil;
	[super dealloc];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{	// Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	// Return the number of rows in the section.
    return 7 + 1;  // +1:末尾の余白セル
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row==0) {
		return 44; // DateTime
	}
    return 88; // Default
}

- (UITableViewCell *)cellDate:(UITableView *)tableView
{
	static NSString *Cid = @"CellDate";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cid];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cid] autorelease];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.textLabel.font = [UIFont systemFontOfSize:20];
		//cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
		//cell.detailTextLabel.font = [UIFont systemFontOfSize:20];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.contentView.backgroundColor = [UIColor clearColor];
	}
	//cell.textLabel.text = NSLocalizedString(@"DateTime",nil);
	
	NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
	// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[fmt setCalendar:calendar];
	[calendar release];
	//[df setLocale:[NSLocale systemLocale]];これがあると曜日が表示されない。
	[fmt setDateFormat:@"yyyy-M-d EE HH:mm"];
	if (mIsAddNew OR Re2edit.dateTime==nil) {
		Re2edit.dateTime = [NSDate date];
	}
	//cell.detailTextLabel.text = [fmt stringFromDate:Re2edit.datetime];
	cell.textLabel.text = [NSString stringWithFormat:@"%@   %@", NSLocalizedString(@"DateTime",nil), 
						   [fmt stringFromDate:Re2edit.dateTime]];
	[fmt release];
	return cell;
}

- (E2editCellDial *)cellDial:(UITableView *)tableView
{
	static NSString *Cid = @"E2editCellDial";  //== Class名
	E2editCellDial *cell = (E2editCellDial*)[tableView dequeueReusableCellWithIdentifier:Cid];
	if (cell == nil) {
		UINib *nib = [UINib nibWithNibName:Cid   bundle:nil];
		[nib instantiateWithOwner:self options:nil];
		//cell = self.ownerCellDial;
		// 
		cell.delegate = self;
		cell.viewParent = self.navigationController.view;  // CalcをaddSubviewするため
		// 選択禁止
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
	}
	return cell;
}

- (E2editCellNote *)cellNote:(UITableView *)tableView
{
	static NSString *Cid = @"E2editCellNote";  //== Class名
	E2editCellNote *cell = (E2editCellNote*)[tableView dequeueReusableCellWithIdentifier:Cid];
	if (cell == nil) {
		UINib *nib = [UINib nibWithNibName:Cid   bundle:nil];
		[nib instantiateWithOwner:self options:nil];
		//cell = self.ownerCellNote;
		// 
		cell.delegate = self;
		// 選択禁止
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
	}
	return cell;
}

- (UITableViewCell *)cellBlank:(UITableView *)tableView
{	// 余白セル
	static NSString *Cid = @"CellBlank";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cid];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cid] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    assert(indexPath.section==0);
	switch (indexPath.row) {
		case 0: {
			UITableViewCell *cell = [self cellDate:tableView];
			return cell;
		}	break;
			
		case 1: {
			E2editCellNote *cell = [self cellNote:tableView];
			cell.delegate = self;
			cell.Re2record = Re2edit;
			cell.ibTfNote1.placeholder = @"Condition, memo";
			cell.ibTfNote2.placeholder = @"Medicine,  memo";
			[cell drawRect:cell.frame]; // コンテンツ描画
			return cell;
		}	break;
			
		case 2: {
			E2editCellDial *cell = [self cellDial:tableView];
			cell.ibLbName.text = NSLocalizedString(@"BpHi Name",nil);
			cell.ibLbDetail.text = NSLocalizedString(@"BpHi Detail",nil);
			cell.ibLbUnit.text = @"mmHg";
			cell.Re2record = Re2edit;
			cell.RzKey = E2_nBpHi_mmHg;
			cell.mValueMin = 30;
			cell.mValueMax = 300;
			cell.mValueDec = 0;
			cell.mValueStep = 1;
			cell.mValuePrev = mPrevBpHi;
			[cell drawRect:cell.frame]; // コンテンツ描画
			return cell;
		}	break;

		case 3: {
			E2editCellDial *cell = [self cellDial:tableView];
			cell.ibLbName.text = NSLocalizedString(@"BpLo Name",nil);
			cell.ibLbDetail.text = NSLocalizedString(@"BpLo Detail",nil);
			cell.ibLbUnit.text = @"mmHg";
			cell.Re2record = Re2edit;
			cell.RzKey = E2_nBpLo_mmHg;
			cell.mValueMin = 20;
			cell.mValueMax = 200;
			cell.mValueDec = 0;
			cell.mValueStep = 1;
			cell.mValuePrev = mPrevBpLo;
			[cell drawRect:cell.frame]; // コンテンツ描画
			return cell;
		}	break;

		case 4: {
			E2editCellDial *cell = [self cellDial:tableView];
			cell.ibLbName.text = NSLocalizedString(@"Pulse Name",nil);
			cell.ibLbDetail.text = NSLocalizedString(@"Pulse Detail",nil);
			cell.ibLbUnit.text = NSLocalizedString(@"Pulse unit",nil);
			cell.Re2record = Re2edit;
			cell.RzKey = E2_nPulse_bpm;
			cell.mValueMin = 10;
			cell.mValueMax = 170;
			cell.mValueDec = 0;
			cell.mValueStep = 1;
			cell.mValuePrev = mPrevPuls;
			[cell drawRect:cell.frame]; // コンテンツ描画
			return cell;
		}	break;

		case 5: {
			E2editCellDial *cell = [self cellDial:tableView];
			cell.ibLbName.text = NSLocalizedString(@"Weight Name",nil);
			cell.ibLbDetail.text = NSLocalizedString(@"Weight Detail",nil);
			cell.ibLbUnit.text = @"Kg";
			cell.Re2record = Re2edit;
			cell.RzKey = E2_nWeight_g;
			cell.mValueMin = 0;
			cell.mValueMax = 140000;
			cell.mValueDec = 1;
			cell.mValueStep = 100;
			cell.mValuePrev = mPrevWeight;
			[cell drawRect:cell.frame]; // コンテンツ描画
			return cell;
		}	break;
			
		case 6: {
			E2editCellDial *cell = [self cellDial:tableView];
			cell.ibLbName.text = NSLocalizedString(@"Temp Name",nil);
			cell.ibLbDetail.text = NSLocalizedString(@"Temp Detail",nil);
			cell.ibLbUnit.text = @"℃";
			cell.Re2record = Re2edit;
			cell.RzKey = E2_nTemp_10c;
			cell.mValueMin = 310;
			cell.mValueMax = 429;
			cell.mValueDec = 1;
			cell.mValueStep = 1;
			cell.mValuePrev = mPrevTemp;
			[cell drawRect:cell.frame]; // コンテンツ描画
			return cell;
		}	break;
}
	return [self cellBlank:tableView];
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
	
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}


#pragma mark - iAd

// iAd delegate  取得できたときに呼ばれる　⇒　表示する
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{	// iAd 広告あり
	NSLog(@"iAd - bannerViewDidLoadAd");
	// アニメ開始位置
	
	// アニメ準備
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; // slow at end
	[UIView setAnimationDuration:1.2];
	// アニメ終了位置
	CGRect rc = banner.frame;
	rc.origin.y = mADBannerY;		// 表示位置
	banner.frame = rc;
	banner.alpha = 1;
	// アニメ開始
	[UIView commitAnimations];
}

// iAd delegate  取得できなかったときに呼ばれる　⇒　非表示にする
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{	// iAd 広告なし
	NSLog(@"iAd - didFailToReceiveAdWithError");
	// アニメ開始位置
	
	// アニメ準備
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn]; // slow at beginning
	[UIView setAnimationDuration:1.2];
	// アニメ終了位置
	CGRect rc = banner.frame;
	rc.origin.y = self.view.frame.size.height + 50;	// 下へ隠す
	banner.frame = rc;
	banner.alpha = 0;
	// アニメ開始
	[UIView commitAnimations];
}

// iAd delegate
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{	// 広告表示前にする処理があれば記述
	return YES;
}

@end
