//
//  E2listTVC.m
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive. All rights reserved.
//
#import "E2listTVC.h"


#define ALERT_TAG_DeleteE2		901

#define LIST_PAGE_LIMIT				50		// 1ページ行数


@interface E2listTVC ()
- (void)configureCell:(E2listCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation E2listTVC
@synthesize fetchedResultsController = __fetchedRc;


#pragma mark - iCloud

- (void)refreshAllViews:(NSNotification*)note 
{	// iCloud-CoreData に変更があれば呼び出される
    if (note) {
		//  iCloud KVS 
		if ([appDelegate_ app_is_sponsor]==NO) {
			NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
			[kvs synchronize]; // 最新同期
			appDelegate_.app_is_sponsor = [kvs boolForKey:GUD_bPaid];
			if (appDelegate_.app_is_sponsor && appDelegate_.app_is_unlock==NO) {
				appDelegate_.app_is_unlock = YES;
			}
		}
		//[self viewWillAppear:NO];
		[self.tableView reloadData];
    }
}

- (void)reloadFetchedResults:(NSNotification*)note 
{
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		GA_TRACK_EVENT_ERROR([error description],0);
		abort();
	}		
    
    if (note) {
        [self.tableView reloadData];
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	GA_TRACK_PAGE(@"E2listTVC");

	if (!appDelegate_) {
		appDelegate_ = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	}
	assert(appDelegate_);
	
	if (!mocFunc_) {
		//  AddNew と Edit が別々に発する rollback の影響を避けるため、別々のContext上で処理する。
		//mocFunc_ = [[MocFunctions alloc] initWithMoc:[appDelegate_ managedObjectContext]];
		mocFunc_ = appDelegate_.mocBase; // Read Only
	}
	assert(mocFunc_);
	
	// Set up the edit and add buttons.
	//self.navigationItem.leftBarButtonItem = self.editButtonItem;

	// NEXT (E2editTVC) Left Back [<<] buttons.
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
											 initWithTitle:NSLocalizedString(@"Cancel",nil)
											 style:UIBarButtonItemStylePlain target:nil action:nil];

	ibLbDate.text = NSLocalizedString(@"List_Date",nil); 
	ibLbTime.text = NSLocalizedString(@"List_Time",nil);
	ibLbBpHi.text = NSLocalizedString(@"List_BpHi",nil);
	ibLbBpLo.text = NSLocalizedString(@"List_BpLo",nil);
	ibLbPuls.text = NSLocalizedString(@"List_Puls",nil);
	ibLbWeight.text = NSLocalizedString(@"List_Weight",nil);
	ibLbTemp.text = NSLocalizedString(@"List_Temp",nil);
	ibLbPedo.text = NSLocalizedString(@"List_Pedo",nil);
	ibLbBodyFat.text = NSLocalizedString(@"List_BodyFat",nil);
	ibLbSkMuscle.text = NSLocalizedString(@"List_SkMuscle",nil);

	// TableView
	//self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // セル区切り線なし
	//self.tableView.separatorColor = [UIColor blackColor];
	UIImage *imgTile = [UIImage imageNamed:@"Tx-WdWhite320"];
	self.tableView.backgroundColor = [UIColor colorWithPatternImage:imgTile];
	
	//
	if (lbPagePrev_==nil) {
		lbPagePrev_ = [[UILabel alloc] initWithFrame:CGRectMake(0, -35, 320, 30)];
	}
	lbPagePrev_.textAlignment = UITextAlignmentCenter;
	lbPagePrev_.backgroundColor = [UIColor clearColor];
	if (appDelegate_.app_is_unlock) {
		lbPagePrev_.text = NSLocalizedString(@"List Top",nil);
	} else {
		lbPagePrev_.text = NSLocalizedString(@"List Limit",nil);
	}
	[self.tableView addSubview:lbPagePrev_];

    [self reloadFetchedResults:nil];
	
	// observe the app delegate telling us when it's finished asynchronously setting up the persistent store
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFetchedResults:) 
												 name:NFM_REFETCH_ALL_DATA
											   object:[[UIApplication sharedApplication] delegate]];
	
	// listen to our app delegates notification that we might want to refresh our detail view
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(refreshAllViews:) 
												 name:NFM_REFRESH_ALL_VIEWS 
											   object:[[UIApplication sharedApplication] delegate]];
	
	// iCloud KVS 変更通知を受け取る
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshAllViews:) 
												 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification 
											   object:nil];
	
/*** UserDef方式にした。
	//---------------------------------------------------------------------------------------------------------
	// didFinishLaunchingWithOptions:では、早すぎるためか落ちるため、ここに実装してた。
	// E2 目標(The GOAL)固有レコードが無ければ追加する
	NSArray *arFetch = [mocFunc_ select:E2_ENTITYNAME
										limit:0		//=0:無制限  ＜＜ 1にすると結果は0件になるのでダメ
										offset:0
										where:[NSPredicate predicateWithFormat: E2_dateTime @" == %@", [MocFunctions dateGoal]]
										sort:nil];
	if ([arFetch count] <= 0) { // 無いので追加する
		E2record *moE2goal = [mocFunc_ insertAutoEntity:E2_ENTITYNAME];
		// 固有日付をセット
		moE2goal.dateTime = [MocFunctions dateGoal];
		moE2goal.nYearMM = [NSNumber numberWithInteger: E2_nYearMM_GOAL];	// 主に、こちらで比較チェックする
		NSLog(@"moE2goal.dateTime=%@  .nYearMM=%@", moE2goal.dateTime, moE2goal.nYearMM);
		// 目標の初期値　⇒ GOALの値がAddNewの初期値になる
		moE2goal.nBpHi_mmHg = [NSNumber numberWithInteger: E2_nBpHi_INIT];
		moE2goal.nBpLo_mmHg = [NSNumber numberWithInteger: E2_nBpLo_INIT];
		moE2goal.nPulse_bpm = [NSNumber numberWithInteger: E2_nPuls_INIT];
		moE2goal.nWeight_10Kg = [NSNumber numberWithInteger: E2_nWeight_INIT];
		moE2goal.nTemp_10c = [NSNumber numberWithInteger: E2_nTemp_INIT];
		// Save & Commit
		[mocFunc_ commit];
	}
	else if (1 < [arFetch count]) { // 2以上あるので削除する
		for (E2record *e2 in arFetch) {
			------------??????????????????????
			[mocFunc_ deleteEntity:e2];
		}
		// Save & Commit
		[mocFunc_ commit];
	}
*/
	
/*	//--------------------------------------------------------------------------------------------------------- AdMob
	if (appDelegate_.app_is_sponsor==NO && adMobView_==nil) {
		adMobView_ = [[GADBannerView alloc]
					  initWithFrame:CGRectMake(0, 0,			// TableCell用
											   GAD_SIZE_320x50.width,
											   GAD_SIZE_320x50.height)];
		adMobView_.delegate = self;		// Unload時に nil セットして解除すること。
		adMobView_.rootViewController = self.navigationController;
		adMobView_.adUnitID = AdMobID_BodyNote;
		GADRequest *request = [GADRequest request];
		[adMobView_ loadRequest:request];
		adMobView_.tag = 0;
		adMobView_.alpha = 0;
	}*/
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	appDelegate_.app_is_AdShow = YES; //これは広告表示可能なViewである。 viewWillAppear:以降で定義すること

	//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	//mbGoal = [userDefaults boolForKey:GUD_bGoal];

	if (indexPathEdit_) { // E2editTVC:から戻ったとき、
		@try {	// 範囲オーバーで落ちる可能性があるため。　＜＜最終行を削除したとき。
			NSLog(@"viewWillAppear: indexPathEdit_=%@", indexPathEdit_);
			NSArray *aPaths = [NSArray arrayWithObject:indexPathEdit_];
			[self.tableView reloadRowsAtIndexPaths:aPaths withRowAnimation:UITableViewRowAnimationFade];
		}
		@catch (NSException *exception) {
			// 最終行を削除したとき
			NSLog(@"LOGIC ERROR!!! - indexPathEdit_.row=%ld", (long)indexPathEdit_.row);
			GA_TRACK_EVENT_ERROR(@"LOGIC ERROR!!! - indexPathEdit_.row OVER",0);
			//assert(NO);
		}
		@finally {
			indexPathEdit_ = nil; // Editモード解除
		}
	}
	else { 
		// 最終行を表示する
		@try {	// 範囲オーバーで落ちる可能性があるため。 
			NSIndexPath* ipGoal = [NSIndexPath indexPathForRow:0 inSection: [[__fetchedRc sections] count]];
			// GOAL! 行へ
			[self.tableView scrollToRowAtIndexPath: ipGoal
								  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
			// GOAL! リフレッシュ
			NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
			[kvs synchronize]; // iCloud最新同期（取得）
			NSArray *aPaths = [NSArray arrayWithObject: ipGoal];
			[self.tableView reloadRowsAtIndexPaths: aPaths withRowAnimation:UITableViewRowAnimationFade];
		}
		@catch (NSException *exception) {
			NSLog(@"LOGIC ERROR!!! - 最終行");
			GA_TRACK_EVENT_ERROR(@"LOGIC ERROR!!! - LINE OVER",0);
			assert(NO);
		}
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (appDelegate_.adWhirlView) {	// Ad ON
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:1.2];
		appDelegate_.adWhirlView.frame = CGRectMake(0, 480-49-50, 320, 50);  // GAD_SIZE_320x50
		appDelegate_.adWhirlView.hidden = NO;
		[UIView commitAnimations];
	}
}

/*
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated
{	// 非表示になった後に呼び出される
    [super viewDidDisappear:animated];
}
*/
/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoadで生成したObjを解放する。
	//NSLog(@"--- viewDidUnload ---"); 
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
/*	// ARCによりrelease不要になったが、delegateの解放は必須。
	if (appDelegate_.app_is_sponsor==NO && adMobView_) {
		adMobView_.delegate = nil;  //受信STOP  ＜＜これが無いと破棄後に呼び出されて落ちる
		adMobView_ = nil;
	}*/
	
	[super viewDidUnload];
	// この後に loadView ⇒ viewDidLoad ⇒ viewWillAppear がコールされる
}




#pragma mark - <delegate>

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != 1) return; // Cancel
	// OK
	switch (alertView.tag) 
	{
		case ALERT_TAG_DeleteE2: {	// この記録を削除する
			if (indexPathDelete_) {
				[mocFunc_ deleteEntity:[__fetchedRc objectAtIndexPath:indexPathDelete_]];
				[mocFunc_ commit];
				indexPathDelete_ = nil;
			}
			//[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
		}	break;
	}
}


#pragma mark - <UITableViewDelegate>

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[__fetchedRc sections] count] + 1;	//+1:GOAL
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section < [[__fetchedRc sections] count]) 
	{ // 明細セクション
		id <NSFetchedResultsSectionInfo> sectionInfo = [[__fetchedRc sections] objectAtIndex:section];
		return [sectionInfo numberOfObjects];
	}
	// GOALセクション
	if (appDelegate_.app_is_sponsor) {
		return 2;
	} else {
		return 3; // Goal + Dropbox + Ad
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{	// セクション ヘッダ
	if (section < [[__fetchedRc sections] count])
	{ // 明細セクション
		NSInteger iYearMM = [[[[__fetchedRc sections] objectAtIndex:section] name] integerValue];
		NSInteger iYear = iYearMM / 100;
		
		if ([[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode] isEqualToString:@"ja"]) 
		{ // 「書式」で変わる。　「言語」でない
			return [NSString stringWithFormat:@"%d年 %d月", iYear, iYearMM - (iYear * 100)]; 
		}
		else {
			static const char *mon[] = { "???", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };			
			int iMon = iYearMM - (iYear * 100);
			if (iMon<1 OR 12<iMon ) iMon = 0;
			return [NSString stringWithFormat:@"%s, %d", mon[ iMon ], iYear]; 
		}
	}
	// GOALセクション
	NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
	// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[fmt setCalendar:calendar];
	if ([[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode] isEqualToString:@"ja"]) 
	{ // 「書式」で変わる。　「言語」でない
		[fmt setDateFormat:@"yyyy年 M月 d日 EE"];
	}
	else {
		[fmt setDateFormat:@"EE, MMM d, yyyy"];
	}
	return [NSString stringWithFormat:@"%@  %@", NSLocalizedString(@"Latest",nil), [fmt stringFromDate:[NSDate date]]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section < [[__fetchedRc sections] count]) 
	{ // 明細セクション
		static NSString *Cid = @"E2listCell";  //== Class名
		E2listCell *cell = (E2listCell*)[tableView dequeueReusableCellWithIdentifier:Cid];
		if (cell == nil) {
			UINib *nib = [UINib nibWithNibName:Cid   bundle:nil];
			[nib instantiateWithOwner:self options:nil];
		}
		// Configure the cell.
		[self configureCell:cell atIndexPath:indexPath];
		return cell;
	}
	else { // GOALセクション
		switch (indexPath.row) {
			case 0: {
				static NSString *Cid = @"E2listCell";  //== Class名
				E2listCell *cell = (E2listCell*)[tableView dequeueReusableCellWithIdentifier:Cid];
				if (cell == nil) {
					UINib *nib = [UINib nibWithNibName:Cid   bundle:nil];
					[nib instantiateWithOwner:self options:nil];
				}
				// Configure the cell.
				[self configureCell:cell atIndexPath:nil]; // GOAL!
				return cell;
			}	break;

			case 1: {	// Dropbox  "esuslogo101409"
				static NSString *Cid = @"E2listDropbox"; // .storyboard定義名
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cid];
				if (cell == nil) {
					UINib *nib = [UINib nibWithNibName:Cid   bundle:nil];
					[nib instantiateWithOwner:self options:nil];
				}
				return cell;
			}	break;
				
			case 2: {	// Ad余白
				static NSString *Cid = @"E2listBasic";  //== Class名
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cid];
				if (cell == nil) {
					UINib *nib = [UINib nibWithNibName:Cid   bundle:nil];
					[nib instantiateWithOwner:self options:nil];
					//cell.accessoryType = UITableViewCellAccessoryNone;
					//cell.showsReorderControl = NO; // Move禁止
					//cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
				}
				cell.textLabel.text = @"";
				return cell;
			}	break;
		}
	}
    return nil;
}

- (void)configureCell:(E2listCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"configureCell: indexPath=%@", indexPath);
	if (indexPath) {
		cell.moE2node = (E2record*)[__fetchedRc objectAtIndexPath:indexPath];
	} else {
		cell.moE2node = nil; // GOAL!
	}
	[cell draw]; // moE2node を描画する
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{	// Return NO if you do not want the specified item to be editable.
	if (indexPath.section < [[__fetchedRc sections] count]) 
	{ // 明細セクション
		return YES;	// フリックDelete許可
	}
	return NO; // GOAL! Delete禁止
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
						forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {	// Delete the managed object for the given index path
		// Alert確認する
		indexPathDelete_ = [indexPath copy];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Delete E2",nil)
														message: nil
													   delegate: self		// clickedButtonAtIndexが呼び出される
											  cancelButtonTitle: NSLocalizedString(@"Cancel",nil)
											  otherButtonTitles: NSLocalizedString(@"DELETE",nil), nil];
		alert.tag = ALERT_TAG_DeleteE2;
		[alert show];
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{	// 画面遷移のとき、didSelectRowAtIndexPath:よりも先に呼び出される
	NSLog(@"prepareForSegue: sender=%@", sender);
	NSLog(@"prepareForSegue: segue=%@", segue);
	NSLog(@"prepareForSegue: [segue identifier]=%@", [segue identifier]);
	NSLog(@"prepareForSegue: [segue sourceViewController]=%@", [segue sourceViewController]);
	NSLog(@"prepareForSegue: [segue destinationViewController]=%@", [segue destinationViewController]);
	
	if ([[segue identifier] isEqualToString:@"pushE2edit"])
	{
		// Assume self.view is the table view
		NSIndexPath *path = [self.tableView indexPathForSelectedRow];//選択中のセル位置
		NSLog(@"prepareForSegue: path={%@}", path);
		E2editTVC *editVc = [segue destinationViewController];
		editVc.hidesBottomBarWhenPushed = YES; //以降のタブバーを消す
		if (path.section < [[__fetchedRc sections] count]) 
		{ // 明細セクション
			//NSLog(@"prepareForSegue: __fetchedRc={%@}", __fetchedRc);
			//NSLog(@"prepareForSegue: [__fetchedRc sections]={%@}", [__fetchedRc sections]);
			//NSLog(@"prepareForSegue: [__fetchedRc objectAtIndexPath:path]={%@}", [__fetchedRc objectAtIndexPath:path]);
			editVc.editMode = 1;		//Edit
			editVc.moE2edit = (E2record *)[__fetchedRc objectAtIndexPath:path];
		} else {
			editVc.editMode = 2;		//GOAL Edit
			editVc.moE2edit = nil;	//GOAL
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する

	// Storyboard導入により、prepareForSegue:が、ここよりも「先に」呼び出されることに留意。
	// E2editTVC:遷移は、prepareForSegue:にて処理している。
	
	if ([[__fetchedRc sections] count] <= indexPath.section) 
	{	// Functions
		indexPathEdit_ = nil; // Editモード解除
		if (indexPath.row==1) {	// Dropbox
			AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
			[appDelegate dropboxView];
		}
	}
	else {
		indexPathEdit_ = [indexPath copy];	// 戻ったときにセルを再描画するため
	}
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{	// データ抽出コントローラを生成する
    if (__fetchedRc)
    {	// 既に生成済み
        return __fetchedRc;
    }
    
    /*
     Set up the fetched results controller.
    */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	// エンティティ指定
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:E2_ENTITYNAME inManagedObjectContext:[mocFunc_ getMoc]];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// ページ先頭行
	[fetchRequest setFetchOffset: 0];
	
	// 1ページ行数
	[fetchRequest setFetchLimit: 0]; // 無制限 //[0.8.1]新しい保存にて件数制限するようにした

	// where
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat: E2_nYearMM @" > 200000"]]; // 未保存を除外する
    
	// ソート条件指定
    // Edit the sort key as appropriate.
    NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_nYearMM ascending:YES];		// セクション指定のため
    NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:YES];	
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects: sort1, sort2, nil];
    //[sort2 release];
    //[sort1 release];
    [fetchRequest setSortDescriptors:sortDescriptors];
    //[sortDescriptors release];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFrc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																								managedObjectContext:[mocFunc_ getMoc] 
																								  sectionNameKeyPath:E2_nYearMM	// セクション指定のため
																					  cacheName:nil]; // CoreData: FATAL ERROR:がでるためcacheName:nilにした。
    aFrc.delegate = self;

	// データ抽出する
	NSError *error = nil;
	if (![aFrc performFetch:&error])
	{
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		GA_TRACK_EVENT_ERROR([error description],0);
	    abort();
	}
	
    __fetchedRc = aFrc; //retain
    //[aFrc release];
    //[fetchRequest release];
    return aFrc;
}    


#pragma mark - <NSFetchedResultsControllerDelegate>

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
		/*非表示状態なので不要。 表示されたときに、viewWillAppear:にて描画処理されるため
		case NSFetchedResultsChangeUpdate:
            [self configureCell:(E2listCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;*/
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */


#pragma mark - <UIScrollViewDelegate> Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	// スクロール中に呼ばれる
	//NSLog(@"scrollViewDidScroll: .contentOffset.y=%f", scrollView.contentOffset.y);
	if (scrollView.contentOffset.y < -50) {
		// 前ページへ予告表示
		if (lbPagePrev_.tag != 1) {
			lbPagePrev_.tag = 1;
			if (appDelegate_.app_is_unlock) {
				lbPagePrev_.text = NSLocalizedString(@"List Top",nil);
			} else {
				lbPagePrev_.text = NSLocalizedString(@"List Paid",nil);
			}
		}
	} else {
		if (lbPagePrev_.tag != 0) {
			lbPagePrev_.tag = 0;
			if (appDelegate_.app_is_unlock) {
				lbPagePrev_.text = NSLocalizedString(@"List Top",nil);
			} else {
				lbPagePrev_.text = NSLocalizedString(@"List Limit",nil);
			}
		}
	}
}
/*
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{	// スクロール終了時（指を離した時）に呼ばれる
	//NSLog(@"scrollViewDidEndDragging: .contentOffset.y=%f  decelerate=%d", scrollView.contentOffset.y, decelerate);
	if (appDelegate_.gud_bPaid) {
		if (scrollView.contentOffset.y < -50) {
			// 前ページへ
			//e2offset_ += LIST_PAGE_LIMIT;
			//[self.tableView reloadData];
		}
	}
}
*/

/*
#pragma mark - AdMob <GADBannerViewDelegate>
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView 
{	// AdMob 広告あり
	adMobView_.tag = 1;
	if (adMobView_.alpha==1) return; // 既に表示
	NSLog(@"E2list: AdMob - DidReceive");
	// 非表示ならば、表示する
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:2.0];
	adMobView_.alpha = 1;
	[UIView commitAnimations];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error 
{	// AdMob 広告なし
	adMobView_.tag = 0;
	if (adMobView_.alpha==0) return; // 既に非表示
	NSLog(@"E2list: AdMob - FailToReceive　Error:%@", [error localizedDescription]);
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:2.0];
	adMobView_.alpha = 0;
	[UIView commitAnimations];
}
 */

@end
