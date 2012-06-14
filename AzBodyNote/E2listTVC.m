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
	if ([appDelegate_ app_is_unlock]==NO) {
		NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
		[kvs synchronize]; // 最新同期
		if ([kvs boolForKey:STORE_PRODUCTID_UNLOCK] && appDelegate_.app_is_unlock==NO) {
			appDelegate_.app_is_unlock = YES;
		}
	}
	[self.tableView reloadData];
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
		GA_TRACK_EVENT_ERROR([error localizedDescription],0);
		//abort();
	}		
	[self.tableView reloadData];
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
		mocFunc_ = [MocFunctions sharedMocFunctions]; //appDelegate_.mocBase; // Read Only
	}
	assert(mocFunc_);
	
	// Set up the edit and add buttons.
	//self.navigationItem.leftBarButtonItem = self.editButtonItem;

	// NEXT (E2editTVC) Left Back [<<] buttons.
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
											 initWithTitle:NSLocalizedString(@"Cancel",nil)
											 style:UIBarButtonItemStylePlain target:nil action:nil];

	ibLbTitleDay.text = NSLocalizedString(@"List_Date",nil); 
	ibLbTitleTime.text = NSLocalizedString(@"List_Time",nil);
	ibLbTitleBpHi.text = NSLocalizedString(@"List_BpHi",nil);
	ibLbTitleBpLo.text = NSLocalizedString(@"List_BpLo",nil);
	ibLbTitlePuls.text = NSLocalizedString(@"List_Puls",nil);
	ibLbTitleWeight.text = NSLocalizedString(@"List_Weight",nil);
	ibLbTitleTemp.text = NSLocalizedString(@"List_Temp",nil);
	ibLbTitlePedo.text = NSLocalizedString(@"List_Pedo",nil);
	ibLbTitleBodyFat.text = NSLocalizedString(@"List_BodyFat",nil);
	ibLbTitleSkMuscle.text = NSLocalizedString(@"List_SkMuscle",nil);

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

	// 再読み込み
    [self reloadFetchedResults:nil];
	
	// Dropbox Download後など、再フェッチを要求する通知が届く
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFetchedResults:) 
												 name:NFM_REFETCH_ALL_DATA
											   object:nil];
	
	// listen to our app delegates notification that we might want to refresh our detail view
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(refreshAllViews:) 
												 name:NFM_REFRESH_ALL_VIEWS 
											   object:nil];
	
	// iCloud KVS 変更通知を受け取る
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshAllViews:) 
												 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification 
											   object:nil];

	// アクティブになったとき、「現在」日時更新する
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(refreshAllViews:) 
												 name:NFM_AppDidBecomeActive
											   object:[[UIApplication sharedApplication] delegate]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//	appDelegate_.app_is_AdShow = YES; //これは広告表示可能なViewである。 viewWillAppear:以降で定義すること

	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	appDelegate_.app_is_unlock = [kvs boolForKey:STORE_PRODUCTID_UNLOCK];

	// 表示行調整
	if (indexPathEdit_) { // E2editTVC:から戻ったとき、
		@try {	// 範囲オーバーで落ちる可能性があるため。　＜＜最終行を削除したとき。
			NSLog(@"viewWillAppear: indexPathEdit_=%@", indexPathEdit_);
			NSArray *aPaths = [NSArray arrayWithObject:indexPathEdit_];
			[self.tableView reloadRowsAtIndexPaths:aPaths withRowAnimation:UITableViewRowAnimationFade];
		}
		@catch (NSException *exception) {
			// 最終行を削除したとき
			NSLog(@"LOGIC ERROR!!! - indexPathEdit_.row=%ld", (long)indexPathEdit_.row);
			GA_TRACK_ERROR([exception description])
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
			GA_TRACK_ERROR([exception description])
		}
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[appDelegate_ adShow:1];
	
/*	if (appDelegate_.adWhirlView) {	// Ad ON
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:1.2];
		appDelegate_.adWhirlView.frame = CGRectMake(0, 480-49-50, 320, 50);  // GAD_SIZE_320x50
		appDelegate_.adWhirlView.hidden = NO;
		[UIView commitAnimations];
	}*/
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

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return iS_iPAD OR (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{	// 回転した後に呼び出される
	[appDelegate_ adRefresh];
}


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
	if (appDelegate_.app_is_unlock) {
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
				static NSString *Cid = @"E2listBasic";  //== Class名
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cid];
				if (cell == nil) {
					UINib *nib = [UINib nibWithNibName:Cid   bundle:nil];
					[nib instantiateWithOwner:self options:nil];
				}
				cell.imageView.image = [UIImage imageNamed:@"AZDropbox-32"];
				cell.textLabel.text = NSLocalizedString(@"Dropbox Upload",nil);
				cell.textLabel.textColor = [UIColor blackColor];
				cell.detailTextLabel.text = NSLocalizedString(@"Dropbox Upload detail",nil);
				cell.detailTextLabel.textColor = [UIColor brownColor];
				cell.userInteractionEnabled = YES;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
				cell.imageView.image = nil;
				cell.textLabel.text = @"";
				cell.userInteractionEnabled = NO;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryType = UITableViewCellAccessoryNone;
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
			//AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
			//[appDelegate dropboxView];
			// Dropbox を開ける
			AZDropboxVC *vc = [[AZDropboxVC alloc] initWithAppKey: DBOX_KEY
														appSecret: DBOX_SECRET
														root: kDBRootAppFolder	//kDBRootAppFolder or kDBRootDropbox
														rootPath: @"/"
														mode: AZDropboxUpload
														extension: GD_EXTENSION 
														delegate: self];
							   
			//vc.title = NSLocalizedString(@"Dropbox Upload",nil);
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
			NSDateFormatter *fm = [[NSDateFormatter alloc] init];
			// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
			NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			[fm setCalendar:calendar];
			[fm setDateFormat:@"yyyy-MM"];	//年-月
			[vc setUpFileName: [fm stringFromDate:[NSDate date]]];
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
		GA_TRACK_EVENT_ERROR([error localizedDescription],0);
	    //abort();
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

#pragma mark - <AZDropboxDelegate>
- (NSString*)azDropboxBeforeUpFilePath:(NSString*)filePath crypt:(BOOL)crypt
{	//Up前処理＜UPするファイルを準備する＞
	// NSManagedObject を filePath へ書き出す           crypt未対応
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	[kvs synchronize]; // iCloud最新同期（取得）
	// E2record 取得
	// Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:NO];
	NSArray *sortDesc = [NSArray arrayWithObjects: sort1,nil]; // 日付降順：Limit抽出に使用
	NSArray *aE2records = [mocFunc_ select: E2_ENTITYNAME
									  limit: 0
									 offset: 0
									  where: [NSPredicate predicateWithFormat:E2_nYearMM @" > 200000"] // 未保存を除外する
									   sort: sortDesc]; // 最新日付から抽出
	// NSManagedObject を NSDictionary変換する。　JSON変換できるようにするため
	NSMutableArray *maE2 = [NSMutableArray new];
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
						  @"Header",									@"#class",
						  FILE_HEADER_PREFIX,					@"#header",
						  utcFromDate([NSDate date]),	@"#update",
						  @"2",												@"#version",
						  //----------------------------------------------------------------------------------  iCloud-KVS
						  azNSNull([kvs objectForKey:Goal_nBpHi_mmHg]),		Goal_nBpHi_mmHg,
						  azNSNull([kvs objectForKey:Goal_nBpLo_mmHg]),		Goal_nBpLo_mmHg,
						  azNSNull([kvs objectForKey:Goal_nPulse_bpm]),			Goal_nPulse_bpm,
						  azNSNull([kvs objectForKey:Goal_nTemp_10c]),			Goal_nTemp_10c,
						  azNSNull([kvs objectForKey:Goal_nWeight_10Kg]),		Goal_nWeight_10Kg,
						  azNSNull([kvs objectForKey:Goal_sEquipment]),			Goal_sEquipment,
						  azNSNull([kvs objectForKey:Goal_sNote1]),					Goal_sNote1,
						  azNSNull([kvs objectForKey:Goal_sNote2]),					Goal_sNote2,
						  //----------[0.9]以下追加
						  azNSNull([kvs objectForKey:Goal_nPedometer]),			Goal_nPedometer,
						  azNSNull([kvs objectForKey:Goal_nBodyFat_10p]),		Goal_nBodyFat_10p,
						  azNSNull([kvs objectForKey:Goal_nSkMuscle_10p]),	Goal_nSkMuscle_10p,
						  //---------------------------------------------------------------------------------- 
						  nil];
	[maE2 addObject:dict];	// #class = "Header"
	// E2record
	for (E2record *e2 in aE2records) {
		//NSLog(@"----- e2=%@", e2);
		@autoreleasepool {
			NSDictionary *dic = [mocFunc_ dictionaryObject:e2];
			if (dic) {
				//NSLog(@"----- ----- dic=%@", dic);
				[maE2 addObject:dic];	// #class = "E2record"
			}
		}
	}
	
	// NSArray --> JSON
	DBJSON	*js = [DBJSON new];
	NSError *err = nil;
	NSString *zJson = [js stringWithObject:maE2 error:&err];
	if (err) {
		NSLog(@"tmpFileSave: SBJSON: stringWithObject: (err=%@) zJson=%@", [err description], zJson);
		GA_TRACK_EVENT_ERROR([err description],0);
		return [err description];
	}
	NSLog(@"tmpFileSave: zJson=%@", zJson);
	// 書き出す
	//[zJson writeToFile:zPath atomically:YES]; NG//非推奨になった。
	[zJson writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&err];
	if (err) {
		NSLog(@"tmpFileSave: writeToFile: (err=%@)", [err description]);
		GA_TRACK_EVENT_ERROR([err description],0);
		return [err description];
	}
	return nil; //OK
}

- (NSString*)azDropboxDownAfterFilePath:(NSString*)filePath {	// 未使用
	return @"NG";
}

- (void)azDropboxDownCompleated {	// 未使用
}


@end
